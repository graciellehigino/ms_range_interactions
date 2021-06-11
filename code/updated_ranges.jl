include("02-get_networks.jl")

## Load required data

# Mammals in the Serengeti ecosystem
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Subset subnetwork using this list of mammals
# MM = MM[mammals]

# List interactions in DataFrame
interactions_df = DataFrame(interactions(MM))
rename!(interactions_df, :from => :pred, :to => :prey)

predators = unique(interactions_df.pred)
preys = unique(interactions_df.prey)

intersect(predators, preys) # intermediate predators
setdiff(predators, preys)
union(predators, preys) # why not 32??

# Investigate missing species
missing_species = setdiff(mammals, union(predators, preys))
# "Hippopotamus_amphibius"
# "Loxodonta_africana"
missing_codes = filter(:species => in(missing_species), sp).code
filter(:prey_code => in(missing_codes), lk) # none, nobody eats hippos or elephants
missing_links = filter(:pred_code => in(missing_codes), lk) # but hippos and elephants eat things --> plants?
missing_preys = unique(missing_links.prey_code)
missing_plants = filter(:code => in(missing_preys), sp)
all(missing_plants.type .== "plant") # it's all plants!
show(missing_plants; allrows=true)

# Investigate intermediate predators as preys
filter(:prey => in(predators), interactions_df)

# Investigate predators with themselves as prey
filter(x -> x.prey == x.pred, interactions_df) # only Panthera_leo
filter(:pred => ==("Panthera_leo"), interactions_df) # at least lions have tons of other preys
# Remove that interactions
# filter!(x -> x.prey != x.pred, interactions_df)
# preys = unique(interactions_df.prey)

# Remove intermediate predators from analyses
# filter!(:prey => !in(predators), interactions_df)
# preys = unique(interactions_df.prey)

# Group interactions by predator
gdf = groupby(interactions_df, :pred)
show(stdout, "text/plain", gdf)

# Get ranges
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

## Update predactor ranges

# Function to get union between layers --> pixels where at least one species present 
import Base.union
function union(layers::Vector{T}) where {T <: SimpleSDMLayer}
    # Make sure layers are compatible
    SimpleSDMLayers._layers_are_compatible(layers)

    # Combine layers in single array
    mat = mapreduce(x -> vec(x.grid), hcat, layers)
    # Get all pixels with at least one non-nothing element in one of the layers
    unionvec = [any(!isnothing, row) ? 1.0 : nothing for row in eachrow(mat)]

    return SimpleSDMPredictor(Array(reshape(unionvec, size(layers[1])...)), layers[1])
end
union(layer1::SimpleSDMLayer, layer2::SimpleSDMLayer) = union([layer1, layer2])

# Function to update predator ranges
function update_range(ranges::Vector{T}, interactions_list::DataFrame, sp::String, type::Symbol=:pred) where {T <: SimpleSDMLayer}
    type in [:pred, :prey] || throw(ArgumentError("type must be :pred or :prey"))
    
    # Get interaction species names
    if type == :pred
        interactions_list = filter(:pred => ==(sp), interactions_list)
        int_sp = interactions_list.prey
    elseif type == :prey
        interactions_list = filter(:prey => ==(sp), interactions_list)
        int_sp = interactions_list.pred
    end

    # Get species indexes in ranges maps
    sp_ind = first(indexin([sp], mammals))
    int_inds = indexin(int_sp, mammals)

    # Get species ranges
    sp_range = ranges[sp_ind]
    int_ranges = ranges[int_inds]

    # Get union of interacting species range --> pixels where at least one interacting species present
    union_range = union(int_ranges)
    # Update focal species range
    pred_updated = mask(union_range, sp_range)

    return pred_updated
end

# Get predator ranges
preds_updated = [update_range(ranges, interactions_df, sp) for sp in predators]
preys_updated = [update_range(ranges, interactions_df, sp, :prey) for sp in preys]

# Get original ranges (in same order)
preds_original = ranges[indexin(predators, mammals)]
preys_original = ranges[indexin(preys, mammals)]

## Produce table 
# |  species | # of preys | # predators | total range size | proportion of range with at least 1 prey | proportion of range with at least 1 predator |

# Predators
results_preds = DataFrame(
    species = predators,
    n_preys = [nrow(filter(:pred => ==(p), interactions_df)) for p in predators],
    # n_preds = missing,
    total_range_size = length.(preds_original),
    prop_preys = length.(preds_updated) ./ length.(preds_original),
    # prop_preds = missing,
)
# Preys
results_preys = DataFrame(
    species = preys,
    # n_preys = missing,
    n_preds = [nrow(filter(:prey => ==(p), interactions_df)) for p in preys],
    total_range_size = length.(preys_original),
    # prop_preys = missing,
    prop_preds = length.(preys_updated) ./ length.(preys_original),
)
# Combine results
results = outerjoin(results_preds, results_preys; on=:species, makeunique=true)
dropmissing(results, [:total_range_size, :total_range_size_1]) |> x ->
    x.total_range_size == x.total_range_size_1 # true, they're equal
results.total_range_size = ifelse.(ismissing.(results.total_range_size), results.total_range_size_1, results.total_range_size)
select!(results, :species, :n_preys, :n_preds, :total_range_size, :prop_preys, :prop_preds)
# Export to CSV
CSV.write(joinpath("data", "clean", "range_proportions.csv"), results)

# Get predator richness
richness_updated = mosaic(sum, preds_updated)
richness_original = mosaic(sum, preds_original)

# Plot to compare
plot(richness_original, c=:turku)
plot(richness_updated, c=:turku)

# Compare with previous range update
richness_diff = richness_original - replace(richness_updated, nothing => 0.0)

plot(replace(richness_diff, 0.0 => nothing), c=:turku)
plot(delta_Sxy_layer, c=:turku)
replace(richness_diff, 0.0 => nothing) == delta_Sxy_layer # true, they're the same now! 🎉

# Export nicer plot
plot(; 
    frame=:box,
    xlim=extrema(longitudes(richness_diff)),
    ylim=extrema(latitudes(richness_diff)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(richness_diff, c=:turku)
savefig(joinpath("figures", "species_removal_layer-style.png"))

richness_diff_nozeros = replace(richness_diff, 0.0 => nothing)
plot(; 
    frame=:box,
    xlim=extrema(longitudes(richness_diff_nozeros)),
    ylim=extrema(latitudes(richness_diff_nozeros)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(richness_diff_nozeros, c=:turku)
savefig(joinpath("figures", "species_removal_layer-style_no-zeros.png"))

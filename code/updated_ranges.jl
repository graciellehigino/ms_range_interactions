include("02-get_networks.jl")

## Load required data

# Get ranges
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

# List interactions in DataFrame
interactions_df = DataFrame(interactions(MM))
rename!(interactions_df, :from => :pred, :to => :prey)

# Separate predators & preys
predators = unique(interactions_df.pred)
preys = unique(interactions_df.prey)

# Investigate missing species
missing_species = setdiff(mammals, union(predators, preys))

# Investigate intermediate predators as preys
filter(:prey => in(predators), interactions_df)

# Remove predators with themselves as prey
#=
filter!(x -> x.prey != x.pred, interactions_df) # only Pantera_leo
preys = unique(interactions_df.prey)
test
=#

# Remove intermediate predators from analyses
# (Needed to match the results from 02-get_networks.jl)
#=
filter!(:prey => !in(predators), interactions_df)
preys = unique(interactions_df.prey)
=#

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
function update_range(ranges_dict::Dict{String, T}, interactions_list::DataFrame, sp::String, type::Symbol=:pred) where {T <: SimpleSDMLayer}
    type in [:pred, :prey] || throw(ArgumentError("type must be :pred or :prey"))

    # Get interaction species names
    if type == :pred
        interactions_list = filter(:pred => ==(sp), interactions_list)
        int_sp = interactions_list.prey
    elseif type == :prey
        interactions_list = filter(:prey => ==(sp), interactions_list)
        int_sp = interactions_list.pred
    end

    # Get species ranges
    sp_range = ranges_dict[sp]
    int_ranges = [ranges_dict[sp] for sp in int_sp]

    # Get union of interacting species range --> pixels where at least one interacting species present
    union_range = union(int_ranges)
    # Update focal species range
    pred_updated = mask(union_range, sp_range)

    return pred_updated
end

# Get updated ranges
ranges_dict = Dict(mammals .=> ranges)
preds_updated = [update_range(ranges_dict, interactions_df, sp) for sp in predators]
preys_updated = [update_range(ranges_dict, interactions_df, sp, :prey) for sp in preys]

# Get original ranges (in same order, which is different from the order in mammals.csv)
preds_original = ranges[indexin(predators, mammals)]
preys_original = ranges[indexin(preys, mammals)]

## Produce table

# |  species | # of preys | # predators | total range size | proportion of range with at least 1 prey | proportion of range with at least 1 predator |

# Predators
results_preds = DataFrame(
    species = predators,
    n_preys = [nrow(filter(:pred => ==(p), interactions_df)) for p in predators],
    total_range_size = length.(preds_original),
    prop_preys = length.(preds_updated) ./ length.(preds_original),
)

# Preys
results_preys = DataFrame(
    species = preys,
    n_preds = [nrow(filter(:prey => ==(p), interactions_df)) for p in preys],
    total_range_size = length.(preys_original),
    prop_preds = length.(preys_updated) ./ length.(preys_original),
)

# Combine results
results = outerjoin(results_preds, results_preys; on=:species, makeunique=true)
results.total_range_size = ifelse.(ismissing.(results.total_range_size), results.total_range_size_1, results.total_range_size)
select!(results, :species, :n_preys, :n_preds, :total_range_size, :prop_preys, :prop_preds)

# Add missing species
missing_species_df = DataFrame(
    species = missing_species,
    total_range_size = length.(ranges[indexin(missing_species, mammals)]),
)
append!(results, missing_species_df; cols=:union)

# Export to CSV
CSV.write(joinpath("data", "clean", "range_proportions.csv"), results)

## Export as markdown table

# Format as Markdown table
using Latexify
results.species .= replace.(results.species, "_" => " ")
table = latexify(results, env=:mdtable, fmt="%.3f", latex=false, escape_underscores=true)

# Export to file
table_path = joinpath("tables", "table_ranges.md")
open(table_path, "w") do io
    print(io, table)
end

# Fix digits
lines = readlines(table_path; keep=true)
open(table_path, "w") do io
    for line in lines
        line = replace(line, " 0.000" => " x.xxx")
        line = replace(line, ".000" => "")
        line = replace(line, " x.xxx" => " 0.000")
        print(io, line)
    end
end

## Richness difference plot

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
replace(richness_diff, 0.0 => nothing) == delta_Sxy_layer # true if intermediate predators filtered earlier

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

# Export plot without zeros, as in 02-get_networks.jl
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
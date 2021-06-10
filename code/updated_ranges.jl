using SimpleSDMLayers: eachindex
include("02-get_networks.jl")

using Combinatorics

## Load required data

# Mammals in the Serengeti ecosystem
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Subset subnetwork using this list of mammals
MM = MM[mammals]

# List interactions in DataFrame
interactions_df = DataFrame(interactions(MM))
rename!(interactions_df, :from => :pred, :to => :prey)

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
function update_range(ranges::Vector{T}, interactions_list::SubDataFrame) where {T <: SimpleSDMLayer}
    # Get species names
    pred = first(interactions_list.pred)
    preys = interactions_list.prey

    # Get species indexes in ranges maps
    pred_ind = first(indexin([pred], mammals))
    prey_inds = indexin(preys, mammals)

    # Get species ranges
    pred_range = ranges[pred_ind]
    prey_ranges = ranges[prey_inds]

    # Get union of prey range --> pixels where at least one prey present
    union_range = union(prey_ranges)
    # Update predator range
    pred_updated = mask(union_range, pred_range)

    return pred_updated
end

# Get predator ranges
ranges_updated = [update_range(ranges, sdf) for sdf in gdf]

# Get predator richness
richness_updated = mosaic(sum, ranges_updated)

# Get original ranges & richness
predators = unique(interactions_df.pred)
ranges_original = ranges[indexin(predators, mammals)]
richness_original = mosaic(sum, ranges_original)

# Plot to compare
plot(richness_original, c=:turku)
plot(richness_updated, c=:turku)

# Compare with previous range update
richness_diff = richness_updated - richness_original
richness_diff.grid = replace(x -> isnothing(x) ? x : abs(x), richness_diff.grid)

plot(replace(richness_diff, 0.0 => nothing), c=:turku, clim=(1.0, 6.0))
plot(delta_Sxy_layer, c=:turku) # not the same...

## Produce table 
# |  species | # of preys | # predators | total range size | proportion of range with at least 1 prey | proportion of range with at least 1 predator |
results = DataFrame(
    species = predators,
    n_preys = [nrow(sdf) for sdf in gdf],
    n_preds = missing,
    total_range_size = length.(ranges_original),
    prop_preys = length.(ranges_updated) ./ length.(ranges_original),
    prop_pred = missing,
)
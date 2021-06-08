import Pkg; Pkg.activate("."); Pkg.instantiate()

using SimpleSDMLayers
using Plots
using Shapefile
using DataFrames

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0)

# Get the list of mammals
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Get the individual ranges back (and remove the NaN)
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

# Get species richness
#= # Write to tif file
richness = mosaic(sum, ranges)
geotiff(joinpath("data", "clean", "richness.tif"), richness)
=#
# Read from tif file
richness = geotiff(SimpleSDMPredictor, joinpath("data", "clean", "richness.tif"))

# Map the richness
include("shapefile.jl")
plot(; 
    frame=:box,
    xlim=extrema(longitudes(richness)),
    ylim=extrema(latitudes(richness)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(richness, frame=:box, c=:turku, clim=(1, maximum(richness)))
savefig(joinpath("figures", "richness.png"))

## Create a layer with the names of the species present
# Group ranges in DataFrame
ranges_df = DataFrame(ranges)
rename!(ranges_df, ["longitude", "latitude", mammals...])

# Replace presences by species names
names_df = select(ranges_df, Not([:longitude, :latitude]))
for i in 1:ncol(names_df)
    names_df[!, i] = replace(names_df[!, i], 1.0 => mammals[i])
end
names_df

# Get list of species per row (per site)
species_lists = Union{Nothing, Vector{String}}[]
for row in eachrow(names_df)
    sp_row = filter(!ismissing, collect(row))
    sp_row = length(sp_row) > 0 ? Vector{String}(sp_row) : nothing
    push!(species_lists, sp_row)
end
species_lists

# Arrange in DataFrame
lists_df = select(ranges_df, :longitude, :latitude)
insertcols!(lists_df, :species_list => species_lists)

# Arrange as layer
list_layer = SimpleSDMPredictor(lists_df, :species_list, ranges[1])

list_layer
list_layer.grid

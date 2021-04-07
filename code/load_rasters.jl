import Pkg; Pkg.activate(".")

using SimpleSDMLayers
using Plots
using Shapefile

# This is the bounding box we care about
bounding_box = (left=-20., right=55., bottom=-35., top=40.)

# Get the list of hosts
speciespool = readlines(joinpath("data", "species.csv"))
filter!(!endswith(" spp."), speciespool) # Species with spp. at the end are plants, so we can remove them

# Get the list of mammals
mammals = readlines(joinpath("data", "mammals.csv"))

# Get the individual ranges back (and remove the NaN)
ranges = [replace(geotiff(SimpleSDMPredictor, "stack.tif", i), NaN=>nothing) for i in eachindex(mammals)]

# Map the richness
include("shapefile.jl")
richness = mosaic(sum, ranges)
plot(; frame=:box, xlim=extrema(longitudes(richness)), ylim=extrema(latitudes(richness)), dpi=500)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(richness, frame=:box, c=:turku, clim=(1, maximum(richness)))
xaxis!("Latitude")
yaxis!("Latitude")
savefig("richness.png")


using SimpleSDMLayers
using Plots
using Shapefile

# I store my IUCN data in the same location, so adapt this to where your files are
const IUCNPATH = expanduser(joinpath("~", ".data", "iucn"))
const IUCNDB = "MAMMALS_TERRESTRIAL_ONLY"

# Make a folder to store the rasters if needed
ispath("rasters") || mkpath("rasters")

# This is the bounding box we care about
bounding_box = (left=-20., right=55., bottom=-35., top=40.)

# Get the list of hosts
speciespool = readlines(joinpath("data", "species.csv"))
filter!(!endswith(" spp."), speciespool) # Species with spp. at the end are plants, so we can remove them

# Main loop
valid_names = zeros(Bool, length(speciespool))

Threads.@threads for i in 1:length(speciespool)
    sp = speciespool[i]
    @info "Extracting $(sp) on thread $(Threads.threadid())"
    fname = joinpath("rasters", replace(sp, " " => "_")*".tif")
    if !isfile(fname)
        try
            query = `gdal_rasterize -l "$(IUCNDB)" -a presence $(IUCNPATH)/$(IUCNDB)/$(IUCNDB).shp $(fname) -where "binomial LIKE '$(sp)'" -ts 2200, 1100`
            run(query)
            mp = convert(Float64, geotiff(SimpleSDMResponse, fname; bounding_box...))
            replace!(mp, zero(eltype(mp)) => nothing)
            geotiff(broadcast(v -> isnothing(v) ? v : one(eltype(mp)), mp), fname)
            mp = nothing
            GC.gc()
            valid_names[i] = true
        catch
            # If this doesn't work, we get rid of the empty file and move on
            rm(fname)
            continue
        end
    end
end

mammals = speciespool[findall(valid_names)]

# Get all the ranges as an array
ranges = [geotiff(SimpleSDMPredictor, joinpath("rasters", f)) for f in readdir("rasters")]

# Save everything as a stack, order like the hosts array
# Requires SimpleSDMLayers v0.5.0, in development on branch tp/rasterdl
# Right now this script uses v0.4.10 from master
# geotiff("stack.tif", ranges)

# Map the richness
include("shapefile.jl")
richness = mosaic(sum, ranges)
plot(; frame=:box, xlim=extrema(longitudes(richness)), ylim=extrema(latitudes(richness)), dpi=500)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(richness, frame=:box, c=:turku, clim=(1, maximum(richness)))
xaxis!("Latitude")
yaxis!("Latitude")
savefig("richness.png")

# Get the individual ranges back (and remove the NaN)
# Also requires v0.5.0
# r = [replace(geotiff(SimpleSDMPredictor, "stack.tif", i), NaN=>nothing) for i in eachindex(mammals)]
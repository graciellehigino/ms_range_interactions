import Pkg; Pkg.activate(".")

using SimpleSDMLayers
using CSV
using DataFrames

# I store my IUCN data in the same location, so adapt this to where your files are
const IUCNPATH = expanduser(joinpath("~", ".data", "iucn"))
const IUCNDB = "MAMMALS"

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
            query = `gdal_rasterize -l "$(IUCNDB)" -a presence $(IUCNPATH)/$(IUCNDB)/$(IUCNDB).shp $(fname) -where "binomial LIKE '$(sp)'" -tr 0.1666666666666666574 0.1666666666666666574 -te -180.0 -90.0 180.0 90.0`
            run(query)
            mp = convert(Float64, geotiff(SimpleSDMResponse, fname; bounding_box...))
            replace!(mp, zero(eltype(mp)) => nothing)
            geotiff(fname, broadcast(v -> isnothing(v) ? v : one(eltype(mp)), mp))
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

# Get names of species with valid files
mammals = speciespool[findall(valid_names)]

# Export names
CSV.write(joinpath("data", "mammals.csv"), DataFrame(mammals = mammals), header = false)

# Get all the ranges as an array
ranges = [geotiff(SimpleSDMPredictor, joinpath("rasters", f)) for f in readdir("rasters")]

# Save everything as a stack, order like the hosts array
geotiff("stack.tif", ranges)

## Investigate dimensions difference
size(ranges[1])
size(ranges[indexin(freshwater, mammals)[1]])
# Different sizes

# Re-do rasterizations
sp = mammals[[1, indexin(freshwater, mammals)[1]]]
fname = [joinpath("rasters", replace(sp, " " => "_")*".tif") for sp in sp]
query1 = `gdal_rasterize -l "$(IUCNDB)" -a presence $(IUCNPATH)/$(IUCNDB)/$(IUCNDB).shp $(fname[1]) -where "binomial LIKE '$(sp[1])'" -tr 0.1666666666666666574 0.1666666666666666574 -te -180.0 -90.0 180.0 90.0`
run(query1)
query2 = `gdal_rasterize -l "$(IUCNFR)" -a presence $(IUCNPATH)/$(IUCNFR)/$(IUCNFR).shp $(fname[2]) -where "binomial LIKE '$(sp[2])'" -tr 0.1666666666666666574 0.1666666666666666574 -te -180.0 -90.0 180.0 90.0`
run(query2)

# Check rasters without subsetting coordinates
mp = [convert(Float64, geotiff(SimpleSDMResponse, fname)) for fname in fname]
size.(mp) # different dimensions
longitudes.(mp) # same longitudes
latitudes.(mp) # different latitudes
stride.(mp) # same longitude stride, different latitude stride
using ArchGDAL
datasets = [ArchGDAL.read(fname) for fname in fname] # same dimensions in raster file
[ArchGDAL.getgeotransform(d) for d in datasets] # but not the same latitude upper limit!!

# Check the shapefiles directly in QGIS
# Latitude extents are not the same for the terrestrial and freshwater files
# TERRESTRIAL: -179.9989999999999668,-55.9794644069999663 : 179.9990000000000805,83.6274355920000687
# FRESHWATER : -179.9989999999999668,-56.1026617959999498 : 179.9990000000000805,89.9000000000000909
# So rasterizing by pre-setting a number of pixels in problematic

# Check rasters when subsetting coordinates (as in main loop)
mp = [convert(Float64, geotiff(SimpleSDMResponse, fname; bounding_box...)) for fname in fname]
[replace!(mp, zero(eltype(mp)) => nothing) for mp in mp]
size.(mp) # not the same dimensions as L82-83!!
# The subsetting bug is causing problems again...

# Check last steps of main loop (re-writing & re-reading)
[geotiff(fname, broadcast(v -> isnothing(v) ? v : one(eltype(mp)), mp)) for (fname, mp) in zip(fname, mp)]
testload = [geotiff(SimpleSDMPredictor, joinpath(fname)) for fname in fname]
size.(mp)
size.(testload)
# Dimensions when re-reading (testload) are not the same as the re-written dimensions (mp)...

# Plot results
using Plots
using Shapefile
include("shapefile.jl")
bgplot = plot(; frame=:box, xlim=extrema(longitudes(mp[1])), ylim=extrema(latitudes(mp[1])), dpi=500)
plot!(bgplot, worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)

mp = [broadcast(v -> isnothing(v) ? v : one(eltype(mp)), mp) for mp in mp]

plot!(deepcopy(bgplot), mp[1], frame=:box, c=:BuPu)
plot!(deepcopy(bgplot), mp[2], frame=:box, c=:BuPu)

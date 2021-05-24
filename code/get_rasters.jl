import Pkg; Pkg.activate(".")

using SimpleSDMLayers
using CSV
using DataFrames

# I store my IUCN data in the same location, so adapt this to where your files are
const IUCNPATH = expanduser(joinpath("~", ".data", "iucn"))
const IUCNDB = "MAMMALS_TERRESTRIAL_ONLY"
const IUCNFR = "MAMMALS_FRESHWATER"

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

# Get species from the MAMMALS_FRESHWATER data set
freshwater = ["Hippopotamus amphibius", "Leptailurus serval"]

Threads.@threads for i in 1:length(freshwater)
    sp = freshwater[i]
    @info "Extracting $(sp) on thread $(Threads.threadid())"
    fname = joinpath("rasters", replace(sp, " " => "_")*".tif")
    if !isfile(fname)
        query = `gdal_rasterize -l "$(IUCNFR)" -a presence $(IUCNPATH)/$(IUCNFR)/$(IUCNFR).shp $(fname) -where "binomial LIKE '$(sp)'" -ts 2200, 1100`
        run(query)
        mp = convert(Float64, geotiff(SimpleSDMResponse, fname)); bounding_box...))
        replace!(mp, zero(eltype(mp)) => nothing)
        geotiff(fname, broadcast(v -> isnothing(v) ? v : one(eltype(mp)), mp))
        mp = nothing
        GC.gc()
    end
end

# Add to species list
append!(mammals, freshwater)
sort!(mammals)

# Export names
CSV.write(joinpath("data", "mammals.csv"), DataFrame(mammals = mammals), header = false)

# Get all the ranges as an array
ranges = [geotiff(SimpleSDMPredictor, joinpath("rasters", f)) for f in readdir("rasters")]

# Save everything as a stack, order like the hosts array
geotiff("stack.tif", ranges)


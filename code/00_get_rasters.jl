include("A1_required.jl")

# I store my IUCN data in the same location, so adapt this to where your files are
const IUCNPATH = expanduser(joinpath("~", ".data", "iucn"))
const IUCNDB = "MAMMALS"

# Make a folder to store the rasters if needed
ispath("rasters") || mkpath("rasters")

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0)

# Get the list of hosts
# speciespool = readlines(joinpath("data", "species.csv"))
# filter!(!endswith(" spp."), speciespool) # Species with spp. at the end are plants, so we can remove them

# I like this code below better, even though it's longer! It does the same thing
# and gives the same results, but it only deals with explicit information on the
# DF, and we won't need to explain how do we know that species names with spp.
# are plants, and why we decided to exclude some plants and not others.
speciespool = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
filter!(x -> x.type != "plant", speciespool)
speciespool = speciespool[:,:species]

# Rename species following IUCN taxonomy
replace!(speciespool, "Damaliscus korrigum" => "Damaliscus lunatus", "Taurotragus oryx" => "Tragelaphus oryx")

# Main loop
valid_names = zeros(Bool, length(speciespool))

Threads.@threads for i in 1:length(speciespool)
    sp = speciespool[i]
    @info "Extracting $(sp) on thread $(Threads.threadid())"
    fname = joinpath("rasters", replace(sp, " " => "_")*".tif")
    try
        query = `gdal_rasterize -l "$(IUCNDB)" -a presence $(IUCNPATH)/$(IUCNDB)/$(IUCNDB).shp $(fname) -where "binomial LIKE '$(sp)'" -tr 0.5 0.5 -te -180.0 -90.0 180.0 90.0`
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

# Get names of species with valid files
mammals = speciespool[findall(valid_names)]
mammals = replace.(mammals, " " => "_")

# Export names
CSV.write(joinpath("data", "clean", "mammals.csv"), DataFrame(mammals = mammals), header = false)

# Get all the ranges as an array
files = string.(mammals, ".tif")
ranges = [geotiff(SimpleSDMPredictor, joinpath("rasters", f)) for f in files]

# Save everything as a stack, order like the hosts array
geotiff(joinpath("data", "clean", "stack.tif"), ranges)

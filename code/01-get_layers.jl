using Pkg
Pkg.activate(".")
Pkg.instantiate

using SimpleSDMLayers
using CSV
using DataFrames
using HTTP

# Get list of species
species = DataFrame(CSV.File("data/raw/pcbi.1002321.s004.csv", comment="%"));

# Prepare the layer according to the IUCN limits
struct IUCNRange <: SimpleSDMLayers.SimpleSDMSource end
SimpleSDMLayers.latitudes(::Type{IUCNRange}) = (-55.979464, 83.627436)
SimpleSDMLayers.longitudes(::Type{IUCNRange}) = (-179.999000,179.999000)

ispath("./data/raw/rasters") || mkpath("./data/raw/rasters")

# Get the predictors
ranges = Dict{String,SimpleSDMPredictor}()
for sp in species[:,2]
    @info sp
    fname = joinpath("rasters", replace(sp, " " => "_")*".tif")
    if !isfile(fname)
        query = `gdal_rasterize -l "MAMMALS_TERRESTRIAL_ONLY" -a presence rangemaps/MAMMALS_TERRESTRIAL_ONLY.shp $(fname) -where "binomial LIKE '$(sp)'" -ts 560, 280`
        run(query)
    end
    mp = SimpleSDMLayers.raster(SimpleSDMResponse, IUCNRange(), fname)
    ranges[sp] = mp
    mp = nothing
    GC.gc()
end

# Richness map
richness = similar(ranges[first(species)])
for sp in keys(ranges)
    r = ranges[sp]
    for i in eachindex(r)
        if !isnothing(r[i])
            if isnothing(richness[i])
                richness[i] = Float64(1.0)
            else
                richness[i] += Float64(1.0)
            end
        end
    end
end

# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals 
include("shapefile.jl") # mapping functions

using CSV
using GBIF

# Load required data
#=
using JLD2
@load joinpath("data", "clean", "gbif-occurrences.jld2") occ
=#
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)
gbif_occ_layers = geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_occurrences.tif"))
gbif_ranges = geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"))
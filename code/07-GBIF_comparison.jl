# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals 
include("shapefile.jl") # mapping functions

using CSV
using GBIF

## Load required data
#=
using JLD2
@load joinpath("data", "clean", "gbif-occurrences.jld2") occ
=#
# GBIF data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)
gbif_occ_layers = geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_occurrences.tif"))
gbif_ranges = geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"))

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0)

# Get the list of mammals
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Species list with types
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
sp.species = replace.(sp.species, " " => "_")
replace!(sp.species, "Damaliscus_korrigum" => "Damaliscus_lunatus", "Taurotragus_oryx" => "Tragelaphus_oryx")

## Compare GBIF occurrences & ranges

# Get the individual ranges back (and remove the NaN)
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

# Separate occurrences per species
spp_df = [filter(:species => ==(m), occ_df) for m in mammals];

# Get IUCN value at corresponding coordinates
[insertcols!(df, :IUCN => r[df]) for (df, r) in zip(spp_df, ranges)]

# Reassemble
occ_df = reduce(vcat, spp_df)
replace!(occ_df.IUCN, nothing => 0.0)

# Get proportion of occurrences in GBIF ranges
comparison_df = combine(groupby(occ_df, :species), nrow => :n_occ, :IUCN => sum)
transform!(comparison_df, [:IUCN_sum, :n_occ] => ByRow(/) => :IUCN_prop)
comparison_df = leftjoin(comparison_df, sp; on=:species)

# Plot result
scatter(
    comparison_df.n_occ, 
    comparison_df.IUCN_prop;
    group=comparison_df.type
)
# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals 
include("shapefile.jl") # mapping functions

using CSV
using GBIF
using Statistics

## Load required data

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0)

# Get the list of mammals
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Species list with types
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
sp.species = replace.(sp.species, " " => "_")
replace!(sp.species, "Damaliscus_korrigum" => "Damaliscus_lunatus", "Taurotragus_oryx" => "Tragelaphus_oryx")

# Get the individual ranges back (and remove the NaN)
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

# GBIF data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)
gbif_occ_layers = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_occurrences.tif"), i) for i in eachindex(mammals)]
gbif_ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"), i) for i in eachindex(mammals)]

## Compare GBIF occurrences & ranges

# Separate occurrences per species
spp_df = [filter(:species => ==(m), occ_df) for m in mammals];

# Get IUCN value at corresponding coordinates
[insertcols!(df, :IUCN => r[df]) for (df, r) in zip(spp_df, ranges)]

# Reassemble
occ_df = reduce(vcat, spp_df)
replace!(occ_df.IUCN, nothing => 0.0)

# Get proportion of occurrences in GBIF ranges
comparison_df = combine(groupby(occ_df, :species), nrow => :occ_n, :IUCN => sum => :occ_sum)
transform!(comparison_df, [:occ_sum, :occ_n] => ByRow(/) => :occ_prop)
comparison_df = rightjoin(sp, comparison_df; on=:species)
select!(comparison_df, Not(:code))

## Compare layers

# Mask GBIF range by IUCN range (updates GBIF range value to nothing if IUCN range is nothing)
gbif_mask = mask.(ranges, gbif_ranges)

# Add to comparison
insertcols!(
    comparison_df,
    :range => length.(ranges),
    :gbif_range => length.(gbif_ranges),
    :range_prop => length.(gbif_mask) ./ length.(gbif_ranges),
) 

# Short DataFrame
comparison_short = select(comparison_df, :species, :type, :occ_n,:range, :occ_prop, :range_prop)
show(comparison_short, allrows = true)
cor(comparison_short.occ_prop, comparison_short.range_prop) # 0.955

## Plot results
scatter(
    comparison_df.occ_n, 
    comparison_df.occ_prop;
    group=comparison_df.type
)

scatter(
    comparison_df.range, 
    comparison_df.range_prop;
    group=comparison_df.type
)
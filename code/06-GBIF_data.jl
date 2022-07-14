# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals
include("shapefile.jl") # mapping functions

using CSV
using GBIF
using DataFramesMeta

# Getting taxa codes
sp_codes = taxon.(mammals, rank = :SPECIES)

# Bounding box
lat, lon = (bounding_box.bottom, bounding_box.top), (bounding_box.left, bounding_box.right)

# Getting observations
## Start query
occ = occurrences.(
    sp_codes,
    "hasCoordinate" => "true",
    "decimalLatitude" => lat,
    "decimalLongitude" => lon,
)
## Loop to get all occurrences
Threads.@threads for o in occ
    while length(o) < size(o)
        occurrences!(o)
    end
    @info "$(o.occurrences[1].taxon.name) occurrences returned ($(length(o))/$(size(o)))"
end
# Export to JLD2 for faster reload
#=
using JLD2
@save joinpath("data", "clean", "gbif-occurrences.jld2") occ
@load joinpath("data", "clean", "gbif-occurrences.jld2") occ
=#

## Create DataFrame

# Make Data Frames
occ_df = DataFrame.(occ)
occ_df = reduce(vcat, occ_df)
select!(occ_df, :species, :longitude, :latitude)
occ_df.species = replace.(occ_df.species, " " => "_")

# Remove observations with coordinates around (0.0, 0.0) which are outside mainland
filter!(x -> !(x.latitude > -2.0 && x.latitude < 2.0 && x.longitude > -2.0 && x.longitude < 2.0), occ_df)

# Make sure the species names match
isequal(unique(occ_df.species), mammals) # not the same
setdiff(unique(occ_df.species), mammals) # Taurotragus oryx is the difference

id_mismatch = filter(x -> !(x.species in mammals), occ_df)
unique(id_mismatch.species) # Yep it's only Taurotragus oryx
# The GBIF website agrees it's a synonym of Tragelaphus oryx, citing IUCN as source, so we're good

replace!(occ_df.species, "Taurotragus_oryx" => "Tragelaphus_oryx")
isequal(unique(occ_df.species), mammals) # true

# Save as CSV
CSV.write(joinpath("data", "clean", "gbif_occurrences.csv"), occ_df)

## Create layers

# Make sure GBIF records order is the same as in mammals CSV file
[replace(o.occurrences[1].taxon.name, " " => "_") for o in occ] == mammals

# Create background layer
bglayer = SimpleSDMPredictor(WorldClim, BioClim, 1; bounding_box...)
boundingbox(bglayer) == boundingbox(ranges[1]) || @error "background layer bounding box is different from range layer bounding box"
size(bglayer) == size(ranges[1]) || @error "background layer size is different from range layer size"

# Create an abundance layer (number of GBIF occurrences per pixel)
gbif_occ_layers = [mask(bglayer, o, Float64) for o in occ]
replace!.(gbif_occ_layers, 0.0 => nothing)

# Convert as presence absence layers
gbif_ranges = [mask(bglayer, o, Bool) for o in occ]
replace!.(gbif_ranges, false => nothing)
gbif_ranges = [convert(Float64, r) for r in gbif_ranges]

# Export to tif files
geotiff(joinpath("data", "clean", "gbif_occurrences.tif"), gbif_occ_layers)
geotiff(joinpath("data", "clean", "gbif_ranges.tif"), gbif_ranges)

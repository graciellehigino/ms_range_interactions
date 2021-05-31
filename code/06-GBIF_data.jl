# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals 
include("shapefile.jl") # mapping functions

using GBIF

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
    "continent" => "AFRICA"
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

# Make Data Frames
occ_df = DataFrame.(occ)
occ_df = reduce(vcat, occ_df)
select!(occ_df, :species, :longitude, :latitude)

# Make sure the species names match
isequal(unique(occ_df.species), mammals) # not the same
setdiff(unique(occ_df.species), mammals) # Taurotragus oryx is the difference

id_mismatch = filter(x -> !(x.species in mammals), occ_df)
unique(id_mismatch.species) # Yep it's only Taurotragus oryx
# The GBIF website agrees it's a synonym of Tragelaphus oryx, citing IUCN as source, so we're good

replace!(occ_df.species, "Taurotragus oryx" => "Tragelaphus oryx")
isequal(unique(occ_df.species), mammals) # true

#### Preparing the query for the GBIF download API ###

include("A1_required.jl")

## 1. GBIF Query ###

# Bounding box
lat, lon = (bounding_box.bottom, bounding_box.top), (bounding_box.left, bounding_box.right)
left, right, bottom, top = bounding_box

# Getting taxa codes
sp_taxon = taxon.(mammals, rank = :SPECIES)
sp_codes = [t.species.second for t in sp_taxon]
unique!(sp_codes)

# Add taxa codes and bounding box to the JSON query
query = """
{
    "creator": "username",
    "notification_address": [
        "useremail"
    ],
    "sendNotification": true,
    "format": "SIMPLE_CSV",
    "predicate": {
        "type": "and",
        "predicates": [
        {
            "type": "in",
            "key": "TAXON_KEY",
            "values": $(sp_codes)
        },
        {
            "type":"equals",
            "key":"HAS_COORDINATE",
            "value":"true"
        },
        {
            "type":"within",
            "geometry":"POLYGON(($left $top,
                      $left $bottom, $right $bottom,
                      $right $top,$left $top))"
        }
    ]}
}
"""
open(joinpath("code", "query.json"), "w") do io
    println(io, query)
end

# Next edit the query file with your GBIF username and email
# Then run add your username and password to the following curl command
# and run it in a terminal

# curl --include --user username:password --header "Content-Type: application/json" --data @code/query.json https://api.gbif.org/v1/occurrence/download/request

# This will send the request to GBIF. You will then receive an email with a
# download link (probably within minutes)

# ⚠️ DO NOT COMMIT THE FILES WITH YOUR USERNAME, EMAIL, OR PASSWORD ⚠️

## 2. Download dataset ####

# Download & extract dataset if absent
csv_file = joinpath("data", "gbif_occurrences_query.csv")
zip_file = joinpath("data", "gbif_occurrences_query.zip")
if !isfile(csv_file)
    if !isfile(zip_file)
        download("https://api.gbif.org/v1/occurrence/download/request/0174925-220831081235567.zip", zip_file)
    end
    zf = ZipFile.Reader(zip_file)
    write(csv_file, read(zf.files[1]))
    close(zf)
end

## 3. Select the columns of interest ###

# Load the dataset
occ_df = CSV.read(joinpath(csv_file), DataFrame; delim="\t", quoted=false)

# Note that quoted=false is absolutely necessary to avoid a bug while reading.
# After manual verification, the data is not quoted.
# However, some elements in the occurrenceID column start with a ", which is the
# quote character. E.g. "AFEW-DSCN0025
# The bug specifically happens on line 59,279 which you can reproduce with:
# DataFrame(CSV.File(csv_file), delim="\t", ntasks=1, limit=59278)) # works
# DataFrame(CSV.File(csv_file), delim="\t", ntasks=1, limit=59279)) # doesn't

# Select the columns of interest
select!(occ_df, [:species, :decimalLongitude, :decimalLatitude, :eventDate])

# Quick note: following the Darwing Core (https://dwc.tdwg.org/terms/) and
# GBIF.jl, we are interested in the eventDate column, not dateIdentified

# Rename columns
rename!(occ_df, [:species, :longitude, :latitude, :date])

## 4. Additional data manipulations

# Arrange species names as elsewhere
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

# Export
CSV.write(joinpath("data", "clean", "gbif_occurrences.csv"), occ_df)
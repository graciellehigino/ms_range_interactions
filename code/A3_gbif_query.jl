#### Preparing the query for the GBIF download API ###

include("A1_required.jl")

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
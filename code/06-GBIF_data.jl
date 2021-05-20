using GBIF

# Getting taxa codes
sp_codes = taxon.([i for i in mammals], rank = :SPECIES)

# Bounding box
lat, lon = (bounding_box.bottom, bounding_box.top), (bounding_box.left, bounding_box.right)

# Getting observations
## Start query
occ = occurrences.(sp_codes,
            "hasCoordinate" => "true",
            "decimalLatitude" => lat,
            "decimalLongitude" => lon,
            "continent" => "AFRICA")
## loop to get all occurrences
while length.(occ) < size.(occ)
    occurrences!.(occ)
end

# Making Data Frames
occ_vector = collect.(view.(occ))
occ_df = DataFrame.(occ_vector)

# Getting points by species 
occ_coordinates = DataFrame(fill(0, nrow(occ_df[1]), 3),
[:species, :longitude, :latitude])

occ_coordinates.longitude = occ_df[1].longitude
occ_coordinates.latitude = occ_df[1].latitude
occ_coordinates[!, :species] .= mammals[1]


for i in 1:length(occ_df)
    long = occ_df[i].longitude
    lat = occ_df[i].latitude
    species = mammals[i]
    x = hcat(fill.(species, length(long)), long, lat)
    x = DataFrame(x)
    rename!(x, :x1 => :species, :x2 => :latitude, :x3 => :longitude)
    if ~isdefined(occ_coordinates, 1) | (i == 1)
        global occ_coordinates = x
    else
        append!(occ_coordinates, x)
    end
end

# Only species with IUCN ranges
occ_gbif_iucn = filter(x -> x.species ∈ names(names_df), occ_coordinates)

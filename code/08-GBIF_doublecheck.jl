using SimpleSDMLayers
using Plots
using Shapefile
using DataFrames
using GBIF

# Load IUCN ranges
mammals = readlines(joinpath("data", "clean", "mammals.csv"))
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]
ranges_updated = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "ranges_updated.tif"), i) for i in eachindex(mammals)]

# Load GBIF ranges
gbif_ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"), i) for i in eachindex(mammals)]

# Extract the layers for the serval
serval = ranges[findfirst(==("Leptailurus_serval"), mammals)]
serval_updated = ranges_updated[findfirst(==("Leptailurus_serval"), mammals)]
serval_gbif = gbif_ranges[findfirst(==("Leptailurus_serval"), mammals)]

# Let's see what its distribution looks like
plot(serval, c=:BuPu, title="Original range")
plot(serval_updated, c=:BuPu, title="Updated range")
plot(serval_gbif, c=:BuPu, title="GBIF range") # not many points, maybe add some buffer?

# Get the range loss
_loss_sites = setdiff(keys(serval), keys(serval_updated))
serval_loss = similar(serval)
serval_loss[_loss_sites] = fill(1.0, length(_loss_sites))
serval_loss = replace(serval_loss, 0.0 => nothing)
plot(serval_loss, c=:BuPu, title="Range loss")

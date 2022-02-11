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
plot(serval, c=:BuPu)
plot(serval_updated, c=:BuPu)
plot(serval_gbif, c=:BuPu) # not many points, maybe add some buffer?

# Get the range loss
serval_loss = similar(serval)
serval_loss[keys(serval_updated)] .= -1.0 # need to update SimpleSDMLayers?
serval_loss[keys(serval_loss)]
plot(serval_loss, c=:BuPu)
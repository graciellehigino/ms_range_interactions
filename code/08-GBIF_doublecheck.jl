using SimpleSDMLayers
using Plots
using Shapefile
using DataFramesMeta
using GBIF
using CSV
using Statistics

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

## Extract the prey's range

# Get the Serengeti data
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
lk = DataFrame(CSV.File(joinpath("data", "links_code.csv")))
sp.species = replace.(sp.species, " " => "_")
replace!(sp.species, "Damaliscus_korrigum" => "Damaliscus_lunatus", "Taurotragus_oryx" => "Tragelaphus_oryx")

# Get the serval's preys
preys = @chain lk begin
    leftjoin(sp, on=[:pred_code => :code])
    @subset(:species .== "Leptailurus_serval")
    leftjoin(sp, on=[:prey_code => :code], makeunique=true)
    rename(:species_1 => :prey)
    _.prey
end
prey = preys[1] # since there's only 1 prey in this case

# Get the preys' range
prey_range = ranges[findfirst(==(prey), mammals)]
prey_gbif_range = gbif_ranges[findfirst(==(prey), mammals)]
plot(prey_range, c=:BuPu)
plot(prey_gbif_range, c=:BuPu) # definitely some observations inside the removed range

# Get the sites where the prey has GBIF observations in the removed range
_prey_sites = intersect(keys(serval_loss), keys(prey_gbif_range))
prey_mismatch = similar(serval_loss)
prey_mismatch[_prey_sites] = fill(1.0, length(_prey_sites))

# Map the mismatch
include("shapefile.jl")
begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(prey_mismatch)),
        ylim=extrema(latitudes(prey_mismatch)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(prey_mismatch, c=:BuPu, title="Prey mismatch", cb_title="Prey present within removed range")
end
savefig(joinpath("figures", "serval_prey_mismatch.png"))

# Add a buffer
buffered = slidingwindow(prey_mismatch, mean, 100.0)
buffered = broadcast(x -> x > 0.0 ? 1.0 : 0.0, buffered)
begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(buffered)),
        ylim=extrema(latitudes(buffered)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(buffered, c=:BuPu, title="Prey mismatch (buffered)", cb_title="Prey present within 100km of removed range")
end
savefig(joinpath("figures", "serval_prey_mismatch_buffered.png"))

# What percentage of the range does the buffer represent?
sum(buffered)/length(buffered)

# Recalculate buffer from all GBIF observations for the prey
_prey_sites2 = intersect(keys(serval), keys(prey_gbif_range))
prey_mismatch2 = similar(serval)
prey_mismatch2[_prey_sites2] = fill(1.0, length(_prey_sites2))
@time buffered2 = slidingwindow(prey_mismatch2, mean, 100.0)
buffered2 = broadcast(x -> x > 0.0 ? 1.0 : 0.0, buffered2)
buffered2[keys(serval_updated)] = fill(nothing, length(keys(serval_updated)))
begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(buffered2)),
        ylim=extrema(latitudes(buffered2)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(buffered2, c=:BuPu, title="Prey mismatch (buffered2)", cb_title="Prey present within 100km of removed range")
end
savefig(joinpath("figures", "serval_prey_mismatch_buffered2.png"))

# Is the buffer different if we start from the reference layer?
_prey_sites3 = keys(prey_gbif_range)
reference_layer = SimpleSDMPredictor(WorldClim, BioClim, 1; boundingbox(serval)...)
prey_mismatch3 = similar(reference_layer)
prey_mismatch3[_prey_sites3] = fill(1.0, length(_prey_sites3))
@time buffered3 = slidingwindow(prey_mismatch3, mean, 100.0)
buffered3 = broadcast(x -> x > 0.0 ? 1.0 : 0.0, buffered3)
buffered3[keys(serval_updated)] = fill(nothing, length(keys(serval_updated)))
_background_sites = setdiff(keys(reference_layer), keys(serval_loss))
buffered3[_background_sites] = fill(nothing, length(_background_sites))
begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(buffered3)),
        ylim=extrema(latitudes(buffered3)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(buffered3, c=:BuPu, title="Prey mismatch (buffered3)", cb_title="Prey present within 100km of removed range")
end
savefig(joinpath("figures", "serval_prey_mismatch_buffered3.png"))

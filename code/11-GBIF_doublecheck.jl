include("A1_required.jl")

# Load IUCN ranges
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

## Add a buffer around the prey's range

# Get the sites where the prey has GBIF observations _on land_
_prey_sites2 = keys(prey_gbif_range)
reference_layer = SimpleSDMPredictor(WorldClim, BioClim, 1; boundingbox(serval)...)
reference_layer = coarsen(reference_layer, mean, (3, 3))
prey_mismatch2 = similar(reference_layer)
prey_mismatch2[_prey_sites2] = fill(1.0, length(_prey_sites2))

# Add a 100 km buffer around the GBIF observation pixels
buffered = slidingwindow(prey_mismatch2, mean, 100.0)
buffered = broadcast(x -> x > 0.0 ? 1.0 : 0.0, buffered)

# Apply the buffer only on the sites that are part of the range loss
_background_sites = setdiff(keys(reference_layer), keys(serval_loss))
buffered[_background_sites] = fill(nothing, length(_background_sites))

# Map the buffered mismatch
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

# What percentage of the range loss does the buffered range represent?
sum(buffered)/length(buffered) # ~ 6%

# What percentage of the prey's GBIF observations are within the range loss?
length(_prey_sites)/length(prey_gbif_range) # ~ 36%

## GBIF figure with the serval and it's prey only

# Proportions of GBIF pixels in IUCN ranges
serval_prop = length(intersect(keys(serval), keys(serval_gbif)))/length(serval_gbif)
prey_prop = length(intersect(keys(prey_range), keys(prey_gbif_range)))/length(prey_gbif_range)

# Assemble data frame
mismatch_df = DataFrame(
    species = ["Leptailurus serval", replace(prey, "_" => " ")],
    range = [length(serval), length(prey_range)],
    prop = [serval_prop, prey_prop]
)

# Plot it
options = (
    # group=carnivores.species,
    ylim=(-0.03, 1.0),
    xlim=(-0.2, 7),
    xticks=0:1:7,
    markershape=[:pentagon :circle],
    markersize=6,
    color=[cgrad(:seaborn_colorblind)[6] :lightgrey],
    markerstrokewidth=0,
    legend=:bottomright,
    legendtitle="Species",
    legendtitlefontvalign=:bottom,
    # labels=permutedims(replace.(carnivores.species, "_" => " ")),
    foreground_color_legend=nothing,
    background_color_legend=:white,
    dpi=500,
)
@df mismatch_df scatter(
    :range ./ 10^4, :prop;
    group=:species,
    xaxis="IUCN range size in pixels (x 10,000)",
    yaxis="Proportion of GBIF pixels in IUCN range",
    options...
)
savefig(joinpath("figures", "serval_gbif-figure.png"))

## Plot range loss & buffer side-by-side

# Map the range loss
p_loss = begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(buffered)),
        ylim=extrema(latitudes(buffered)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
        title="Serval range loss"
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, cbar=:none)
    plot!(serval, c=cgrad(:BuPu, rev=true))
    plot!(serval_updated, c=:orange)
    scatter!([-180.0 -180.0],
        legend=(0.15, 0.13),
        shape=:rect,
        mc=[cgrad(:BuPu)[1] :orange],
        labels=["Removed range" "Remaining range"],
        background_colour_legend=nothing,
        foreground_colour_legend=nothing,
        legend_font_pointsize=6,
        extra_kwargs=:subplot,
        legend_hfactor=1.25,
    )
end

# Map the buffered mismatch
p_buffer = begin
    plot(;
        frame=:box,
        xlim=extrema(longitudes(buffered)),
        ylim=extrema(latitudes(buffered)),
        dpi=600,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey)
    plot!(buffered, c=:BuPu, title="Mismatch with prey range", cb=:none)
    scatter!(
        [-180.0 -180.0],
        legend=(0.15, 0.13),
        shape=:rect,
        mc=cgrad(:BuPu)[[1, end]] |> permutedims,
        labels=["Removed range" "Prey occurrence buffer"],
    )
    scatter!(
        keys(serval_gbif);
        label="Serval GBIF occurrences",
        msw=0, ma=0.5, ms=2,
        background_colour_legend=nothing,
        foreground_colour_legend=nothing,
        legend_font_pointsize=6,
        extra_kwargs=:subplot,
        legend_hfactor=1.25,
    )
end

# Combine side-by-side
plot(p_loss, p_buffer, dpi=600, size=(800, 400), left_margin=10px)
savefig(joinpath("figures", "serval_mismatch_combined.png"))
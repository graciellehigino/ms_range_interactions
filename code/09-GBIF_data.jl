include("A1_required.jl")

# Load data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)

# Create background layer
bglayer = SimpleSDMPredictor(WorldClim, BioClim, 1; resolution=10.0, bounding_box...)
bglayer = coarsen(bglayer, mean, (3, 3))

## Create layers

# Create presence-absence layers
gbif_ranges = fill(similar(bglayer), length(mammals))
for i in eachindex(mammals)
    spdf = filter(:species => ==(mammals[i]), occ_df)
    splayer = mask(bglayer, spdf, Bool)
    replace!(splayer, false => nothing)
    gbif_ranges[i] = convert(Float32, splayer)
end
gbif_ranges

# Export to tif file
geotiff(joinpath("data", "clean", "gbif_ranges.tif"), gbif_ranges)

## Explore year distribution

# Get years
occ_with_dates = dropmissing(occ_df, :date)
occ_with_dates.year = year.(occ_with_dates.date)

# Calculate mode per species
Pkg.add("StatsBase")
using StatsBase
group_species = groupby(occ_with_dates, :species)
mode_species = combine(group_species, :year => StatsBase.mode)
Pkg.rm("StatsBase")


# Plot the distribution of the occurrences' year of record per species
p = plot(layout = 32, size = (1200, 800), dpi= 600)

for i in 1:32
    plot!(group_species[i].year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype=:histogram, legends = :none, fillcolor = "black", bins = :scott, xlims = extrema(occ_with_dates.year))
    vline!([transpose(mode_species.year_mode)], linecolor = :red)

end
p

savefig(joinpath("figures", "GBIF_years_total.png"))

# Distribution of the occurrences' year > 1900 per species

p = plot(layout = 32, size = (1200, 800), dpi= 600)
subset(group_species[1], :year => ByRow(>(1900)))
for i in 1:32
    group_species_subset = subset(group_species[i], :year => ByRow(>(1900)))
    plot!(group_species_subset.year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype=:histogram, legends = :none, fillcolor = "black", nbins = maximum(occ_with_dates.year) - 1900, xlims = (1900, maximum(occ_with_dates.year)), xr = 45, tickfontsize = 6)
    vline!([transpose(mode_species.year_mode)], linecolor = :red)
end
p

savefig(joinpath("figures", "GBIF_years_1900.png"))

# Distribution of the occurrences' year > 1970 per species

p = plot(layout = 32, size = (1200, 800), dpi= 600)
subset(group_species[1], :year => ByRow(>(1900)))
for i in 1:32
    group_species_subset = subset(group_species[i], :year => ByRow(>(1970)))
    plot!(group_species_subset.year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype=:histogram, legends = :none, fillcolor = "black", nbins = 50, xlims = (maximum(occ_with_dates.year)-50, maximum(occ_with_dates.year)), xr = 45, tickfontsize = 6)
    vline!([transpose(mode_species.year_mode)], linecolor = :red)
end
p

savefig(joinpath("figures", "GBIF_years_1972.png"))

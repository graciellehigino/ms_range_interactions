include("A1_required.jl")

# Load data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)


## Keep recent GBIF occurrences only 
year_recent = 2000 # all observations before this year will be discarded 

# Get years
occ_with_dates = dropmissing(occ_df, :date)
occ_with_dates.year = year.(occ_with_dates.date)

# Keep recent observations 
occ_df_recent = subset(occ_with_dates, :year => ByRow(>(year_recent)))


## Create layers

# Create background layer
bglayer = SimpleSDMPredictor(WorldClim, BioClim, 1; resolution=10.0, bounding_box...)
bglayer = coarsen(bglayer, mean, (3, 3))

# Create presence-absence layers
gbif_ranges = fill(similar(bglayer), length(mammals))
for i in eachindex(mammals)
    spdf = filter(:species => ==(mammals[i]), occ_df_recent)
    splayer = mask(bglayer, spdf, Bool)
    replace!(splayer, false => nothing)
    gbif_ranges[i] = convert(Float32, splayer)
end
gbif_ranges

# Export to tif file
geotiff(joinpath("data", "clean", "gbif_ranges.tif"), gbif_ranges)


## Explore year distribution

# Calculate median per species
group_species = groupby(occ_with_dates, :species)
median_species = combine(group_species, :year => StatsBase.median)


# Plot the distribution of the occurrences' year of record for each species
p = plot(layout = 32, size = (1200, 800), dpi= 600)

for i in 1:32
    plot!(group_species[i].year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype = :histogram, legends = :none, fillcolor = "black", bins = :scott, xlims = extrema(occ_with_dates.year))
    vline!([transpose(median_species.year_median)], linecolor = :red)
end
p

savefig(joinpath("figures", "GBIF_years_total.png"))


# Distribution of the occurrences' year > 1900 for each species
occ_with_dates_1900 = subset(occ_with_dates, :year => ByRow(>(1900)))

group_species_1900 = groupby(occ_with_dates_1900, :species)
median_species_1900 = combine(group_species_1900, :year => StatsBase.median)

p = plot(layout = 32, size = (1200, 800), dpi= 600)

for i in 1:32
    plot!(group_species_1900[i].year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype = :histogram, legends = :none, fillcolor = "black", nbins = maximum(occ_with_dates.year) - 1900, xlims = (1900, maximum(occ_with_dates.year)), xr = 45, tickfontsize = 6)
    vline!([transpose(median_species_1900.year_median)], linecolor = :red)
end
p

savefig(joinpath("figures", "GBIF_years_1900.png"))

# Distribution of the occurrences' year > 1970 for each species

occ_with_dates_1970 = subset(occ_with_dates, :year => ByRow(>(1970)))

group_species_1970 = groupby(occ_with_dates_1970, :species)
median_species_1970 = combine(group_species_1970, :year => StatsBase.median)

p = plot(layout = 32, size = (1200, 800), dpi= 600)

for i in 1:32
    plot!(group_species_1970[i].year, subplot = i, title = replace(levels(occ_df.species)[i], "_" => " "), titlefontsize = 7,
    seriestype = :histogram, legends = :none, fillcolor = "black", nbins = 50, xlims = (maximum(occ_with_dates.year)-50, maximum(occ_with_dates.year)), xr = 45, tickfontsize = 6)
    vline!([transpose(median_species.year_median)], linecolor = :red)
end
p

savefig(joinpath("figures", "GBIF_years_1970.png"))


# Proportion of recent occurrences for each species 

group_species_recent = groupby(occ_df_recent, :species)

prop_recent = [nrow(group_species_recent[i]) / nrow(group_species[i]) for i in 1:32] 

plot(prop_recent, 
    seriestype = :histogram, legends = :none, fillcolor = "darkred", nbins = 50, xlims = (0, 1), ylims=(0, 6), xr = 45, tickfontsize = 6,
    xlabel = "Proportion of GBIF occurrences after $(year_recent)",
    ylabel = "Frequency", 
    guidefontsize=8)

savefig(joinpath("figures", "GBIF_years_prop_2000.png"))



# Proportion and number of recent occurrences for each species
nb_recent = [nrow(group_species_recent[i]) for i in 1:32] 

scatter(prop_recent, nb_recent,
    legends = :none, xr = 45, tickfontsize = 6,
    color = "darkred", markersize = 6, 
    xlims = (0, 1), ylims = (0, 9500),
    xlabel = "Proportion of GBIF occurrences after $(year_recent)",
    ylabel = "Number of GBIF occurrences after $(year_recent)",
    guidefontsize=8)

savefig(joinpath("figures", "GBIF_years_prop_nb_2000.png"))





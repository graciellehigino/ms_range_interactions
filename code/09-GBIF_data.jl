include("A1_required.jl")

# Getting taxa codes
sp_codes = taxon.(mammals, rank = :SPECIES)

# Bounding box
lat, lon = (bounding_box.bottom, bounding_box.top), (bounding_box.left, bounding_box.right)

# Getting observations
#=
## Start query
occ = occurrences.(
    sp_codes,
    "hasCoordinate" => "true",
    "decimalLatitude" => lat,
    "decimalLongitude" => lon,
)
## Loop to get all occurrences
Threads.@threads for o in occ
    while length(o) < size(o)
        occurrences!(o)
    end
    @info "$(o.occurrences[1].taxon.name) occurrences returned ($(length(o))/$(size(o)))"
end
# Export to JLD2 for faster reload

@save joinpath("data", "clean", "gbif-occurrences.jld2") occ
=#
@load joinpath("data", "clean", "gbif-occurrences.jld2") occ


## Create DataFrame

# Make DataFrame
occ_df = DataFrame.(occ)
occ_df = reduce(vcat, occ_df)
select!(occ_df, :species, :longitude, :latitude, :date)
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

# Save as CSV
CSV.write(joinpath("data", "clean", "gbif_occurrences.csv"), occ_df)


## Investigate difference with original query with Africa as continent
# Load datasets
old = CSV.read(joinpath("data", "clean", "gbif_occurrences_old.csv"), DataFrame) # get from previous commit
new = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)

# Compare number of observations per species
_nold = combine(groupby(old, :species), nrow => :nrow_old)
_nnew = combine(groupby(new, :species), nrow => :nrow_new)
diff = @chain begin
    leftjoin(_nold, _nnew, on = :species)
    @transform(diff = :nrow_new .- :nrow_old)
    sort(:diff, rev=true)
end
diff


## Create layers

# Make sure GBIF records order is the same as in mammals CSV file
[replace(o.occurrences[1].taxon.name, " " => "_") for o in occ] == mammals

# Create background layer
bglayer = SimpleSDMPredictor(WorldClim, BioClim, 1; resolution=10.0, bounding_box...)
bglayer = coarsen(bglayer, mean, (3, 3))

# Create an abundance layer (number of GBIF occurrences per pixel)
gbif_occ_layers = [mask(bglayer, o, Float64) for o in occ]
replace!.(gbif_occ_layers, 0.0 => nothing)

# Convert as presence absence layers
gbif_ranges = [mask(bglayer, o, Bool) for o in occ]
replace!.(gbif_ranges, false => nothing)
gbif_ranges = [convert(Float64, r) for r in gbif_ranges]

# Export to tif files
geotiff(joinpath("data", "clean", "gbif_occurrences.tif"), gbif_occ_layers)
geotiff(joinpath("data", "clean", "gbif_ranges.tif"), gbif_ranges)


## Explore year distribution

# Calculate median date for each species
using StatsBase

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
year_recent = 2000

occ_with_dates_recent = subset(occ_with_dates, :year => ByRow(>(year_recent)))
group_species_recent = groupby(occ_with_dates_recent, :species)

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





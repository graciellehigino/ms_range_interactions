# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals

#### Build metawebs

# Get Serengeti species (plants and mammals) and their interactions
# Data from Baskerville et al. (2011)
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
lk = DataFrame(CSV.File(joinpath("data", "links_code.csv")))

sp.species = replace.(sp.species, " " => "_")

# Rename species following IUCN taxonomy
replace!(sp.species, "Damaliscus_korrigum" => "Damaliscus_lunatus", "Taurotragus_oryx" => "Tragelaphus_oryx")

# Remove self interactions
filter!(x -> x.pred_code != x.prey_code, lk)

# Number of species and of interactions in the metaweb
S = nrow(sp)
L = nrow(lk)

# Find row and column numbers of all interactions to build metaweb
# Adjacency matrix ordered by species list
# All realized interactions have a value of 1
rows = [findall(lk.pred_code[i] .== sp.code)[1] for i in 1:L]
cols = [findall(lk.prey_code[i] .== sp.code)[1] for i in 1:L]
vals = ones(Bool, L)

# Build metaweb of all species (plants and mammals)
M = sparse(rows, cols, vals, S, S)
M = UnipartiteNetwork(Matrix(M), sp.species)

# Export trophic levels for later use
trophic_df = DataFrame(species = collect(keys(trophic_level(M))), level = collect(values(trophic_level(M))))
CSV.write(joinpath("data", "clean", "trophic_levels.csv"), trophic_df)

# Get list of plants and mammals (carnivores and herbivores)
plants = sp.species[sp.type .== "plant"]
mammals = sp.species[sp.type .!= "plant"]
herbivores = sp.species[sp.type .== "herbivore"]
carnivores = sp.species[sp.type .== "carnivore"]

# Make sure order of species is the same as in CSV file
if mammals != readlines(joinpath("data", "clean", "mammals.csv"))
    @error "mammals object does not match the `mammals.csv` file"
end

# Build metaweb of mammals (subnetwork of metaweb of mammals and plants)
MM = M[mammals]

# Export metaweb as DataFrame
interactions_df = DataFrame(interactions(MM))
rename!(interactions_df, :from => :pred, :to => :prey)
CSV.write(joinpath("data", "clean", "metaweb.csv"), interactions_df)

# Count the number of plants that are eaten by each herbivores
M_plants_herb = M[vcat(plants, herbivores)]

kout_plants_herb = collect(values(degree(M_plants_herb, dims = 1))) # out-degree of herbivores and plants
kout_herb = kout_plants_herb[kout_plants_herb .!= 0] # out-degree of herbivores
kout_herb_avg = mean(kout_herb) # mean out-degree of herbivores
kout_herb_sd = std(kout_herb)
kout_herb_ext = extrema(kout_herb)

#### Build spatially-explicit networks of mammals and remove carnivores with no paths to an herbivore

# Remove carnivores not connected to any herbivores
function remove_carnivores(sp_list)
    # sp_list: a list of mammals at a given location

    if isnothing(sp_list)
        return sp_list
    else

    # Get the subnetwork before correction
    MMxy = MM[sp_list]

    # Which species are herbivores and carnivores
    carni = in(carnivores).(sp_list)
    herbi = in(herbivores).(sp_list)

    carn = sp_list[carni]
    herb = sp_list[herbi]

    # Which carnivores have a path to an herbivore?
    paths = shortest_path(MMxy)[carni, herbi]

    predi = sum.(eachrow(paths)) .>= 1

    carn = carn[predi]

    # New list of species (herbivores and connected carnivores)
    new_list = vcat(herb, carn)

    if isempty(new_list)
        new_list = nothing
    end

    return new_list
    end
end

# New species list at every location (corr stands for corrected)
species_lists_corr = remove_carnivores.(species_lists)

# Get subnetworks at every location from a species list
function get_subnetwork(sp_list)
    # sp_list: a list of mammals at a given location

    if isnothing(sp_list)
        return missing
    else

    # Get the subnetwork
    MMxy = MM[sp_list]

    return MMxy
    end
end

# Local networks of mammals according to IUCN range maps
Nxy = get_subnetwork.(species_lists)

# Local networks of mammals after removing species with no paths to an herbivore
Nxy_corr = get_subnetwork.(species_lists_corr)



#### Analyse network structure

# Get the number of mammal species (before correction)
function get_richness(Nxy)
    # Nxy: local network of mammals (before correction)
    if ismissing(Nxy)
        return nothing
    else
    S = convert(Float64, length(species(Nxy)))
    return S
    end
end

# Get the number of mammal species (after correction)
function get_richness(Nxy, Nxy_corr)
    # Nxy: local network of mammals (before correction)
    # Nxy_corr: local network of mammals (after correction)
    if ismissing(Nxy)
        return nothing
    elseif ismissing(Nxy_corr)
        return 0.0
    else
    S = convert(Float64, length(species(Nxy_corr)))
    return S
    end
end

# Species richness before correction
Sxy = get_richness.(Nxy)

# Species richness after correction
Sxy_corr = get_richness.(Nxy, Nxy_corr)

# Difference of species richness (before/after correction)
function get_diff(Sxy, Sxy_corr)
    # Sxy: species richness at one location (before correction)
    # Sxy_corr: species richness at the same location (after correction)
    if isnothing(Sxy_corr)
        return nothing
    else
        return Sxy - Sxy_corr
    end
end

delta_Sxy = get_diff.(Sxy, Sxy_corr)

# Proportion of remaining species
function get_prop(Sxy, Sxy_corr)
    # Sxy: species richness at one location (before correction)
    # Sxy_corr: species richness at the same location (after correction)
    if isnothing(Sxy_corr)
        return nothing
    else
        return Sxy_corr / Sxy
    end
end

prop_Sxy = get_prop.(Sxy, Sxy_corr)

# Arrange in DataFrame
Sxy_df = select(ranges_df, :longitude, :latitude)
insertcols!(Sxy_df, :Sxy => Sxy, :Sxy_corr => Sxy_corr,
            :delta_Sxy => delta_Sxy, :prop_Sxy => prop_Sxy)

# Arrange as layers
Sxy_layer = SimpleSDMPredictor(Sxy_df, :Sxy, ranges[1])
delta_Sxy_layer = SimpleSDMPredictor(Sxy_df, :delta_Sxy, ranges[1])
prop_Sxy_layer = SimpleSDMPredictor(Sxy_df, :prop_Sxy, ranges[1])

# Export as tif
geotiff(joinpath("data", "clean", "richness_diff.tif"), delta_Sxy_layer)

# Map differences in species richness
plot(;
    frame=:box,
    xlim=extrema(longitudes(delta_Sxy_layer)),
    ylim=extrema(latitudes(delta_Sxy_layer)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(delta_Sxy_layer, c=cgrad(:turku, rev=true))
savefig(joinpath("figures", "species_removal.png"))

## Map of species richness before correction
map_richness = plot(;
    frame=:box,
    xlim=extrema(longitudes(Sxy_layer)),
    ylim=extrema(latitudes(Sxy_layer)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(Sxy_layer, c=cgrad(:turku, rev=true))

## Map of proportion of species remaining after correction
map_prop = plot(;
    frame=:box,
    xlim=extrema(longitudes(prop_Sxy_layer)),
    ylim=extrema(latitudes(prop_Sxy_layer)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(prop_Sxy_layer, c=cgrad(:viridis, rev=true))

## Proportion of remaining species as a function of species richeness
index = Sxy_df.Sxy .!= nothing

prop_richness = scatter(Sxy_df.Sxy[index],
                    Sxy_df.prop_Sxy[index],
                    frame=:box,
                    markershape=:circle,
                    markersize=4,
                    alpha=0.05,
                    palette=:seaborn_colorblind,
                    markerstrokewidth=0,
                    label="",
                    background_color_legend=:white,
                    dpi=500,
                    xaxis="Species richness",
                    yaxis="Proportion of species",
)

l = @layout [[a ; b] c]

plot(map_richness, map_prop, prop_richness,
    layout = l,
    title = ["(a)" "(b)" "(c)"],
    titleloc=:right,
    titlefont=font("Arial",10))

savefig(joinpath("figures", "richness_prop_removed.png"))



#### Create layers with updated species ranges

# Get individual species presence/absence at every location from updated lists
function get_updated_locations(sp, sp_list)
    # sp: the species to to look for
    # sp_list: a list of mammals at a given location

    if isnothing(sp_list)
        return nothing
    elseif sp in sp_list
        return 1.0
    else
        return nothing
    end
end

locations = [get_updated_locations.(m, species_lists_corr) for m in mammals]

# Get updated ranges
function get_updated_ranges(locations, layer)
    # locations: a list of presences for a species at given locations
    # layer: a layer with the dimensions for the new range

    # Reshape locations as a grid of correct size & type
    range_grid = reshape(locations, size(layer))
    range_grid = convert(typeof(richness.grid), range_grid)

    # New layer with updated range
    range_layer = SimpleSDMResponse(range_grid, layer)

    return range_layer
end
ranges_updated = [get_updated_ranges(l, richness) for l in locations]

# Plot to verify
function plot_layer(layer::SimpleSDMLayer)
    plot(;
        frame=:box,
        xlim=extrema(longitudes(layer)),
        ylim=extrema(latitudes(layer)),
        dpi=500,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(convert(Float64, layer), c=cgrad(:turku, rev = true))
end

plot_layer(ranges_updated[1])
plot_layer(ranges_updated[2])

## Export updated ranges

# Export as tif stack
geotiff(joinpath("data", "clean", "ranges_updated.tif"), ranges_updated)

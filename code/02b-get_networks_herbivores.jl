# Remove herbivores not connected to any carnivores
function remove_herbivores(sp_list)
    # sp_list: a list of mammals at a given location

    if isnothing(sp_list)
        return sp_list
    else

    # Change species name
    sp_list = replace.(sp_list, " " => "_")

    # Get the subnetwork before filtering
    MMxy = MM[sp_list]

    # Which species are herbivores and carnivores
    carni = in(carnivores).(sp_list)
    herbi = in(herbivores).(sp_list)
  
    carn = sp_list[carni]
    herb = sp_list[herbi]

    # Which herbivores have a path to a carnivore?
    paths = shortest_path(MMxy)[herbi, carni]

    predi = sum.(eachrow(paths)) .>= 1

    herb = herb[predi]

    # New list of species (herbivores and connected carnivores)
    new_list = vcat(carn, herb)

    if isempty(new_list)
        new_list = nothing
    end

    return new_list
    end
end

# New species list at every location
species_lists_h = remove_herbivores.(list_layer.grid)

subnetworks_h = get_subnetwork.(species_lists_h)


#### Analyse network structure and the filtering process

# Get difference of species richness at every location
delta_Sxy_h = get_richness_diff.(subnetworks, subnetworks_h)


# Arrange in DataFrame
delta_Sxy_h_df = select(ranges_df, :longitude, :latitude)
insertcols!(delta_Sxy_h_df, :delta_Sxy_h => delta_Sxy_h)

# Arrange as layer
delta_Sxy_h_layer = SimpleSDMPredictor(delta_Sxy_h_df, :delta_Sxy_h, ranges[1])
replace!(delta_Sxy_h_layer.grid, 0 => nothing)

# Map differences in species richness
plot(; frame=:box, xlim=extrema(longitudes(delta_Sxy_h_layer)), ylim=extrema(latitudes(delta_Sxy_h_layer)), dpi=500)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(delta_Sxy_h_layer, c=:turku)
xaxis!("Longitude")
yaxis!("Latitude")
savefig(joinpath("figures", "herbivores_removal.png"))
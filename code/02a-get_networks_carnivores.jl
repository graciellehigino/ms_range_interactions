# Build spatially-explicit networks of mammals and remove carnivores with no paths to an herbivore

# Remove carnivores not connected to any herbivores
function remove_carnivores(sp_list)
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

# New species list at every location
species_lists_c = remove_carnivores.(list_layer.grid)

# Get new subnetworks at every location (i.e. after filtering)
function get_subnetwork(sp_list)
    # sp_list: a list of mammals at a given location

    if isnothing(sp_list)
        return missing
    else

    # Change species name
    sp_list = replace.(sp_list, " " => "_")

    # Get the subnetwork 
    MMxy = MM[sp_list]

    return MMxy
    end
end

subnetworks = get_subnetwork.(species_lists)
subnetworks_c = get_subnetwork.(species_lists_c)


#### Analyse network structure and the filtering process

# Get difference of species richness at every location
function get_richness_diff(MM1, MM2)
    # MM1: network before filtering
    # MM2: network after filtering

    if ismissing(MM1) 
        return nothing
    
    elseif ismissing(MM2)

    # Count the number of species before
    S1 = convert(Float64, length(species(MM1)))
    return S1

    else
    S1 = convert(Float64, length(species(MM1)))
    S2 = convert(Float64, length(species(MM2)))
   
    return S1-S2
    end
end

delta_Sxy_c = get_richness_diff.(subnetworks, subnetworks_c)


# Arrange in DataFrame
delta_Sxy_c_df = select(ranges_df, :longitude, :latitude)
insertcols!(delta_Sxy_c_df, :delta_Sxy_c => delta_Sxy_c)

# Arrange as layer
delta_Sxy_c_layer = SimpleSDMPredictor(delta_Sxy_c_df, :delta_Sxy_c, ranges[1])
replace!(delta_Sxy_c_layer.grid, 0 => nothing)

# Map differences in species richness
plot(; frame=:box, xlim=extrema(longitudes(delta_Sxy_c_layer)), ylim=extrema(latitudes(delta_Sxy_c_layer)), dpi=500)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(delta_Sxy_c_layer, c=:turku)
xaxis!("Longitude")
yaxis!("Latitude")
savefig(joinpath("figures", "carnivores_removal.png"))


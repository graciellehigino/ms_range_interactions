# Load required scripts and packages
include("01-load_rasters.jl") # range maps of Serengeti mammals 
include("shapefile.jl") # mapping functions

import CSV
using DataFrames
using EcologicalNetworks
using SparseArrays
using Statistics


#### Build metawebs

# Get Serengeti species (plants and mammals) and their interactions
# Data from Baskerville et al. (2011)
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
lk = DataFrame(CSV.File(joinpath("data", "links_code.csv")))

sp.species = replace.(sp.species, " " => "_")

# Number of species and of interactions in the metaweb
S = nrow(sp)
L = nrow(lk)

# Find row and column numbers of all interactions
# Adjacency matrix ordered by species list
# All realized interactions have a value of 1
rows = [findall(lk.pred_code[i] .== sp.code)[1] for i in 1:L]
cols = [findall(lk.prey_code[i] .== sp.code)[1] for i in 1:L]
vals = ones(Bool, L)

# Build metaweb of all species (plants and mammals)
M = sparse(rows, cols, vals, S, S)
M = UnipartiteNetwork(Matrix(M), sp.species)


# Get list of plants and mammals (carnivores and herbivores)
plants = sp.species[sp.type .== "plant"]
mammals = sp.species[sp.type .!== "plant"]
herbivores = sp.species[sp.type .== "herbivore"]
carnivores = sp.species[sp.type .== "carnivore"]

# Investigate species difference with raster set
mammals_prev = readlines(joinpath("data", "clean", "mammals.csv"))
mammals_prev = replace.(mammals_prev, " " => "_")

length(mammals) # 32 elements
length(mammals_prev) # 28 elements
missing_sp = setdiff(mammals, mammals_prev)
# Following species are missing
#=
"Damaliscus_korrigum"
"Hippopotamus_amphibius"
"Leptailurus_serval"
"Taurotragus_oryx"
=# 
# Are they in original species pool?
speciespool = readlines(joinpath("data", "species.csv"))
speciespool = replace.(speciespool, " " => "_")
[sp in speciespool for sp in missing_sp] # All there
# So either IUCN has no data on these species or they're in another data set 
# (probably Freshwater mammals for Hippopotamus amphibius, at least)

# Build metaweb of all mammals
MM = M[mammals]

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
species_lists_c = remove_carnivores.(species_lists)

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
subnetworks_new = get_subnetwork.(species_lists_c)


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

delta_Sxy = get_richness_diff.(subnetworks, subnetworks_new)


# Arrange in DataFrame
delta_Sxy_df = select(ranges_df, :longitude, :latitude)
insertcols!(delta_Sxy_df, :delta_Sxy => delta_Sxy)

# Arrange as layer
delta_Sxy_layer = SimpleSDMPredictor(delta_Sxy_df, :delta_Sxy, ranges[1])
replace!(delta_Sxy_layer.grid, 0 => nothing)

# Map differences in species richness
plot(; frame=:box, xlim=extrema(longitudes(delta_Sxy_layer)), ylim=extrema(latitudes(delta_Sxy_layer)), dpi=500)
plot!(worldshape(50), c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(delta_Sxy_layer, c=:turku)
xaxis!("Longitude")
yaxis!("Latitude")
savefig(joinpath("figures", "species_removal.png"))


# Load required scripts and packages
include("load_rasters.jl") # range maps of Serengeti mammals 
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


# Build metaweb of all mammals
MM = M[mammals]
import CSV
using DataFrames
using EcologicalNetworks
using SparseArrays

# Get lists of species and of interactions
# Data from Baskerville et al. (2011)
sp = CSV.read(joinpath("data", "species_code.csv"), DataFrame)
lk = CSV.read(joinpath("data", "links_code.csv"), DataFrame)

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

# Build adjacency matrix (Unipartite network)
M = sparse(rows, cols, vals, S, S)
M = UnipartiteNetwork(Matrix(M), sp.species)


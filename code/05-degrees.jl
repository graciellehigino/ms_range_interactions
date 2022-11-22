include("04-ranges_diff.jl")

## Calculate the out degree of the organisms in the metaweb
mammal_degree = degree(MM, dims = 1)
mammal_degree_df = DataFrame(species = collect(keys(mammal_degree)), degree = collect(values(mammal_degree)))

## Merge the degree data with the range data
predator_nets = leftjoin(predator_ranges, mammal_degree_df, on=:species)

# Total network out-degrees
sp_outdegree = degree(M, dims=1);
sp_outdegree_df = DataFrame(species = collect(keys(sp_outdegree)), n_preys = collect(values(sp_outdegree)))

# Total network in-degrees
sp_indegree = degree(M, dims=2);
sp_indegree_df = DataFrame(species = collect(keys(sp_indegree)), n_predators = collect(values(sp_indegree)))

# Total preys and predators
sp_degrees = leftjoin(sp_outdegree_df, sp_indegree_df, on=:species)

ranges_degrees_df = copy(cooccurrence_beta)
rename!(ranges_degrees_df, :spA => "species")
ranges_degrees_df = leftjoin(ranges_degrees_df, predator_ranges; on=:species)
ranges_degrees_df = leftjoin(ranges_degrees_df, mammal_degree_df; on=:species)

all_sp_df = copy(original_range)
all_sp_df = leftjoin(all_sp_df, sp_outdegree_df; on=:species)

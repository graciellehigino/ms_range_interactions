# Check whether the change in range is dependent on the degree of the carnivore

## First calculate the out degree of the organisms in the metaweb
mammal_degree = degree(MM, dims = 1)
mammal_degree_df = DataFrame(species = collect(keys(mammal_degree)), degree = collect(values(mammal_degree)))

## Merge the degree data with the range data
predator_nets = leftjoin(predator_ranges, mammal_degree_df, on=:species)

# Total network out degrees
sp_outdegree = degree(M, dims=1);
sp_outdegree_df = DataFrame(species = collect(keys(sp_outdegree)), n_preys = collect(values(sp_outdegree)))

# Total network degrees
sp_indegree = degree(M, dims=2);
sp_indegree_df = DataFrame(species = collect(keys(sp_indegree)), n_predators = collect(values(sp_indegree)))

# Total preys and predators 
sp_degrees = leftjoin(sp_outdegree_df, sp_indegree_df, on=:species)
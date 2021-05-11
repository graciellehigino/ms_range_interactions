# Check whether the change in range is dependent on the degree of the carnivore

## First calculate the in degree of the organisms in the metaweb
mammal_degree = degree(MM, dims = 1)
mammal_degree_df = DataFrame(species = collect(keys(mammal_degree)), degree = collect(values(mammal_degree)))

## Merge the degree data with the range data
predator_nets = leftjoin(predator_ranges, mammal_degree_df, on=:species)
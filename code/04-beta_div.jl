# Carnivores
## Original metaweb
M[carnivores];

## Subnetwork of linked carnivores
# linked_c = reduce(union, skipmissing(subnetworks_c))

# Herbivores
## Original metaweb
M[herbivores];

## Networks herbivores
# linked_h = reduce(union, skipmissing(subnetworks_h))

# Beta-div
## Composition
#βs_c = βs(linked_c, M[carnivores])
#βs_h = βs(linked_h, M[herbivores])

#KGL01.([EcologicalNetworks.βs(i, j) for i in linked_c, j in M[carnivores]])


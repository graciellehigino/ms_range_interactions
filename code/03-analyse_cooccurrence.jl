include("02-get_networks.jl")

# Mammals in the Serengeti ecosystem
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Subset subnetwork using this list of mammals
MM = MM[mammals]

### Table of spatial overlap for interacting species

# Number of interactions between mammals in the metaweb
L = links(MM)

# Lists of predators and preys
preds = [interactions(MM)[i].from for i in 1:L]
preys = [interactions(MM)[i].to for i in 1:L]


# DataFrame of co-occurrence data for interacting species
# spA: Name of the predator
# spB: Name of the prey
# nbA: Number of pixels with the predator only
# nbB: Number of pixels with the prey only
# nbAB: Number of pixels with both species
cooccurrence_interact = DataFrame(fill(0, (length(preds), 5)), :auto)
rename!(cooccurrence_interact, [:spA, :spB, :nbA, :nbB, :nbAB])

cooccurrence_interact.spA = preds
cooccurrence_interact.spB = preys

# Count the number of pixels unique to one of the two species
function count_unique(A::String, B::String)
    AA = names_df[!, A]
    BB = names_df[!, B]

    nbA = sum(.!ismissing.(AA) .& ismissing.(BB))
    return nbA
end

cooccurrence_interact.nbA = count_unique.(preds, preys)
cooccurrence_interact.nbB = count_unique.(preys, preds)

# Count the number of pixels where both species cooccurre
function count_cooccurrence(A::String, B::String)
    AA = names_df[!, A]
    BB = names_df[!, B]

    nbAB = sum(.!ismissing.(AA) .& .!ismissing.(BB))
    return nbAB
end

cooccurrence_interact.nbAB = count_cooccurrence.(preds, preys)


### Table of spatial overlap for non-interacting species

# All combinations of species names
mammals_comb = collect(combinations(mammals,2))

spA = reduce(hcat, mammals_comb)[1,:]
spB = reduce(hcat, mammals_comb)[2,:]

# Which pairs of species are interacting (in either direction?)
function are_interacting(A::String, B::String)
    # Is there an interaction between from the first to the second species?
    A_to_B = has_interaction(MM, A, B)
    # Is there an interaction between from the second to the first species?
    B_to_A = has_interaction(MM, B, A)
    # Is there an interaction in either direction?
    A_B_interact = ifelse(A_to_B == 1 || B_to_A == 1, true, false)
    return A_B_interact
end

# Filter out species that are interacting
A_B_interact = are_interacting.(spA, spB)
spA = spA[.!A_B_interact]
spB = spB[.!A_B_interact]

# DataFrame of co-occurrence data for non-interacting species
# spA: Name of one species
# spB: Name of the other species (there is no ecological difference between species A and B)
# nbA: Number of pixels with species A only
# nbB: Number of pixels with species B only
# nbAB: Number of pixels with both species
cooccurrence_nointeract = DataFrame(fill(0, (length(spA), 5)), :auto)
rename!(cooccurrence_nointeract, [:spA, :spB, :nbA, :nbB, :nbAB])

cooccurrence_nointeract.spA = spA
cooccurrence_nointeract.spB = spB

cooccurrence_nointeract.nbA = count_unique.(spA, spB)
cooccurrence_nointeract.nbB = count_unique.(spB, spA)
cooccurrence_nointeract.nbAB = count_cooccurrence.(spA, spB)


### Measures of beta-diversity

cooccurrence_beta = copy(cooccurrence_interact)

# Ruggiero beta-diversity calculations (draft)
function beta(A::String, B::String, fun)

  nbA = count_unique(A, B)
  nbB = count_unique(B, A)
  nbAB = count_cooccurrence(A, B)

  if fun == "pred-to-prey"
    Ab = nbAB / (nbAB + nbA)
    return Ab

    elseif  fun == "prey-to-pred"
    Bb = nbAB / (nbAB + nbB)
    return Bb

    else
    print("please select the direction of the calculation, either 'prey-to-pred' or 'pred-to-prey'") # can someone fix this so it doesn't print loads of them ;)
    end
end

## This should calculate the predator to prey beta diversity
cooccurrence_beta.Rab = beta.(cooccurrence_beta.spA, cooccurrence_beta.spB, "pred-to-prey")

## This should calculate the prey to predator beta diversity
cooccurrence_beta.Rbb = beta.(cooccurrence_beta.spA, cooccurrence_beta.spB, "prey-to-pred")

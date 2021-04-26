include("load_rasters.jl")

using Combinatorics

# Get the list of mammals
mammals = readlines(joinpath("data", "mammals.csv"))

mammals = replace.(mammals, " " => "_")

# Get all combinations of species names
mammals_comb = collect(combinations(mammals,2))

# DataFrame of co-occurrence data
# spA: Name of species A
# spB: Name of species B
# nbA: Number of pixels with species A only
# nbB: Number of pixels with species B only
# nbAB: Number of pixels with both species
# JD: Jaccard diversity index
# P: Are species interacting (predation) in the metaweb?
cooccurrence = DataFrame(fill(0, (length(mammals_comb), 7)),
                 [:spA, :spB, :nbA, :nbB, :nbAB, :JD, :P])

cooccurrence.spA = reduce(hcat, mammals_comb)[1,:]
cooccurrence.spB = reduce(hcat, mammals_comb)[2,:]

# Count the number of pixels unique to species A or B
function count_unique(A::String, B::String)
    AA = names_df[!, A]
    BB = names_df[!, B]

    nbA = sum(.!isnothing.(AA) .& isnothing.(BB))
    return nbA
end

cooccurrence.nbA = count_unique.(cooccurrence.spA, cooccurrence.spB)
cooccurrence.nbB = count_unique.(cooccurrence.spB, cooccurrence.spA)

# Count the number of pixels where species A and B cooccure
function count_cooccurrence(A::String, B::String)
    AA = names_df[!, A]
    BB = names_df[!, B]

    nbAB = sum(.!isnothing.(AA) .& .!isnothing.(BB))
    return nbAB
end

cooccurrence.nbAB = count_cooccurrence.(cooccurrence.spA, cooccurrence.spB)

# Compute Jaccard diversity index for all species pairs
function JD(A::String, B::String)

    nbA = count_unique(A, B)
    nbB = count_unique(B, A)
    nbAB = count_cooccurrence(A, B)

    JD = nbAB / (nbA + nbB + nbAB)

    return JD
end

cooccurrence.JD = JD.(cooccurrence.spA, cooccurrence.spB)

# Interaction among all species pairs in the metaweb
include(joinpath("code", "02-get_networks.jl"))

function are_interacting(A::String, B::String)
    return has_interaction(M, A, B)
end

cooccurrence.P = are_interacting.(cooccurrence.spA, cooccurrence.spB)


# Relationship between cooccurrence and interaction
#using GLM

#glm(@formula(P ~ nbAB), cooccurrence, Bernoulli(), LogitLink()) # Not significant

# Ruggiero beta-diversity calculations (draft) 
## Focused on A - the top predators (highest trophic level)
function Abeta(A::String, B::String)

    nbA = count_unique(A, B)
    nbB = count_unique(B, A)
    nbAB = count_cooccurrence(A, B)

    Ab = nbAB / (nbAB + nbA)

    return Ab
end

## Focused on B - the small predators and herbivores (lower trophic level)
function Bbeta(A::String, B::String)

    nbA = count_unique(A, B)
    nbB = count_unique(B, A)
    nbAB = count_cooccurrence(A, B)

    Bb = nbAB / (nbAB + nbB)

    return Bb
end

cooccurrence.abeta = Abeta(cooccurrence.spA, cooccurrence.spB)
cooccurrence.bbeta = Bbeta(cooccurrence.spA, cooccurrence.spB)

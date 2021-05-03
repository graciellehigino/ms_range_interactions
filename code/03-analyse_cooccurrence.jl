include("load_rasters.jl")

using Combinatoric

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
include("code/02-get_metaweb.jl")

function are_interacting(A::String, B::String)
    return has_interaction(M, A, B)
end

cooccurrence.P = are_interacting.(cooccurrence.spA, cooccurrence.spB)


# Relationship between cooccurrence and interaction
using GLM

glm(@formula(P ~ nbAB), cooccurrence, Bernoulli(), LogitLink()) # Not significant

# Need to subset the dataframes into predators and herbivores which interact (so predators are spA and herbivores in spB)
cooccurrence_beta = filter(:P => isequal(1), cooccurrence)

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

---
bibliography: [references.bib]
---

# Intro

Finding a species in a certain location is like finding an encrypted message
that traveled through time. This message carries the species’ evolutionary
history, long migration journeys, effects of other species we do not even know
that exist, and ultimately the elements that shape its, yet unknown, future.
Ecologists have been trying to decode this message with progressively more
powerful tools, from their own field notes to highly complex computational
algorithms, such as habitat suitability models. These models attempt to describe
the species’ distribution based on their niche, considering their occurrences as
sample points of suitable abiotic variables and their absences as sample points
of unsuitable variables [@Peterson2012EcoNic]. However, these observations
(environmental variables and geographic location) only unveils part of the
mystery, and the missing link are ecological interactions.  

Biases and historical lack of information about species distribution and ecology
can lead us to the wrong conclusions [@Hortal2008HisBia]. Biodiversity
occurrence data are knowingly biased, and the sources of bias are often
taxonomic - including the bias related to the conservation status -, temporal or
geographical [@Boakes2010DisVie; @Ronquillo2020AssSpa; @Meyer2016MulBia]. A
complete assessment of ecological interactions is even more difficult than
sufficient sampling of species occurrence. The number of interactions sampled
will always be lower than the number of possible interactions, mainly due to the
existence of forbidden links [@Jordano2016SamNet]. This lack of information,
known as the Eltonian Shortfall, is aggravated by slanted and different
sampling methods [@Poisot2020EnvBia; @Hortal2015SevSho]. Nevertheless, we have
witnessed an increase in the availability of biodiversity data in the last
decades, including those collected through community science projects
[@Callaghan2019ImpBig, @Pocock2015BioRec] and organized dedicated databases
mostly accessed by specialists, such as mangal [@Poisot2016ManMak] and the
Global Biodiversity Information Facility (GBIF;
@GBIF:TheGlobalBiodiversityInformationFacility2021WhaGbi).  

Amongst these geographical data available are the range maps provided by the
International Union for the Conservation of Nature (IUCN). The geographical data
published by IUCN are collections of expert maps, which combine species
observations and expert knowledge [@IUCNSSCRedListTechnicalWorkingGroupMapSta].
These maps can be used in macroecological inferences in the lack of higher
quality information [@Fourcade2016ComSpe; @Alhajeri2019HigCor], but it has been
recommended that they are used with caution since they tend to underestimate the
distribution of species that are not well-known [@Herkt2017MacCon]. 

The connection between occurrence and interaction data is a frequent debate in
Ecology. For instance, some argue that occurrence data can also capture
real-time interactions [@Roy2016FocPla; @Ryan2018RolCit], and because of that it
would be reasonable not to include them in macroecological models. On the other
hand, many mechanistic simulation models in ecology have considered competition
and facilitation in range shifts, whilst the use of trophic interactions in this
context remains insufficient [@Cabral2017MecSim]. Here we investigate whether
occurrence data (more precisely range maps) can be refined based on species
interaction information, considering the basic assumption that predators can
only be present in regions where there are preys. Mismatches between occurence
and interaction data will produce updated range maps, and we will discuss the
ecological meaning of this difference.


# Methods

Serengeti paper - species list and interactions IUCN range maps
- Why we removed plants from everything Remove predators where there’s no prey
  available The beta-diversity metrics The GBIF comparison

# Results

Fig 01 - probably the species richness before and after?

Fig 02

Fig 03

Fig 04 - The [beta-diversity plot](figures/beta-div_pred-species.png) with 4
quadrants

Table 01 - The One With All the Species and Their Ranges and Predators and Preys

Fig 06 - Something with GBIF results

# Discussion

Some questions that’d be interesting to answer!!!!!
- Can we SDM one of the species with the updated rangemaps?
- Which rangemaps are the most accurate? 
  - We SDM species from inference data and check which rangemaps (original or
    updated) are more similar to that 
    - Might bring more questions about which data we’re missing (occurrence or
      links)
- What does a 0 value on beta-diversity mean? Why does it matter? 
  - Is it the data??????!!!?!?! WHO’S WRONG?!?!?!?
- Can GBIF help us identify if the things we observe is a matter of data or
  ecology?
- The follow-up paper "Spatial Robustness of networks" by Norma & Fredric 


# References

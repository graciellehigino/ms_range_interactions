---
bibliography: [references.bib]
---

# Intro

--to be rephrased-- 
The occurrence of a species in each location is an encrypted message that travels through time. It carries the species’ evolutionary history, long migration journeys, effects of other species we do not even know that exist, and ultimately the elements that shape its, yet unknown, future. Ecologists have been trying to decode this message with progressively more powerful tools, from their own field notes to highly complex computational algorithms, such as habitat suitability models. These models attempt to describe the species’ distribution based on their niche, considering their occurrences as sample points of suitable abiotic variables and their absences as sample points of unsuitable variables. However, these observations (environmental variables and geographic location) only unveils part of the mystery, and the missing link are ecological interactions.
--to be rephrased--

- Data availability / biases  
  - Occurrences  
  - Interactions  
- The “occurrence data captures interaction data” argument  
- Can we update occurrence data based on species interaction information? What are the mismatches between occurrence data and interactions?  
- Usability of IUCN range maps - underestimation of overlaps and stuff  
  - GBIF polemics  

# Methods
We investigated the effects of adjusting species distributions based on species interaction data across savannah ecosystems in Africa (Fig. 1). These ecosystems host a range of different species, including the well characterised predator-prey dynamics between iconic predators (e.g., lions, hyenas and leopards) and large herbivores (e.g., antelope, wildebeest and zebra), as well as a range of herbivorous and carnivorous small mammals. Here we focus on six groups of herbivores and carnivores from the Serengeti Food Web Data Set (Baskerville et al. 2011). These species exhibit direct antagonistic (predator-prey) interactions with one another and are commonly found across savanna ecosystems on the African continent.

IUCN range maps were compiled for the 32 species (23 herbivores and 9 carnivores) from Spatial Data Download portal (www.iucnredlist.org/resources/spatial-data-download). 
Species interaction data were subset from the wider interaction network presented in Baskerville et al. (2011). The network consisted of 32 taxa and 85 interactions. 

Serengeti paper - species list and interactions
IUCN range maps
- Why we removed plants from everything
- Remove predators where there’s no prey available
- The beta-diversity metrics
- The GBIF comparison

# Results

Fig 01 - probably the species richness before and after?

Fig 02

Fig 03

Fig 04 - The [beta-diversity plot](figures/beta-div_pred-species.png) with 4 quadrants

Table 01 - The One With All the Species and Their Ranges and Predators and Preys

Fig 06 - Something with GBIF results

# Discussion

Some questions that’d be interesting to answer!!!!!
- Can we SDM one of the species with the updated rangemaps?
- Which rangemaps are the most accurate? 
  - We SDM species from inference data and check which rangemaps (original or updated) are more similar to that 
    - Might bring more questions about which data we’re missing (occurrence or links)
- What does a 0 value on beta-diversity mean? Why does it matter? 
  - Is it the data??????!!!?!?! WHO’S WRONG?!?!?!?
- Can GBIF help us identify if the things we observe is a matter of data or ecology?
- The follow-up paper "Spatial Robustness of networks" by Norma & Fredric 


# References

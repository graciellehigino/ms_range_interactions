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

## Data 
We investigated the effects of adjusting species distributions based on species interaction data across savannah ecosystems in Africa (Fig. 1). These ecosystems host a range of different species, including the well characterised predator-prey dynamics between iconic predators (e.g., lions, hyenas and leopards) and large herbivores (e.g., antelope, wildebeest and zebra), as well as a range of herbivorous and carnivorous small mammals. Here we focus on six groups of herbivores and carnivores from the Serengeti Food Web Data Set (Baskerville et al. 2011). These species exhibit direct antagonistic (predator-prey) interactions with one another and are commonly found across savanna ecosystems on the African continent. Although plants are included in the Serengeti Food Web Data Set, there is an absence of global range maps for many plant species (Daru, 2020), and as such we did not include plants in the following analyses.
Species interaction data were subset from the wider interaction network presented in Baskerville et al. (2011). The network of herbivores and carnivores we used here contained 32 taxa and 85 interactions and had a connectance of 0.08. We refer to this network as the meta-network as it contains all possible species interactions between the different taxa that could occur across savanna ecosystems such as the Serengeti.
IUCN range maps were compiled for the 32 species included in the meta-network (23 herbivores and 9 carnivores) from the Spatial Data Download portal (www.iucnredlist.org/resources/spatial-data-download). Ranges were rasterized at XX km2 resolution. 
We created networks for each raster pixel, where cooccurring species were linked together based on the interactions from the meta-network. This generated a total of XX networks where at least two cooccurring and interacting species were present.

## Approach
We adjusted the ranges of carnivorous species based on a simple rule: we removed any part of a carnivore’s range that did not intersect at least one prey species range. Thus, unless the range of the predator overlapped at least one prey item, we removed that section of the predator’s range. We then calculated the difference in range size between the original IUCN ranges and those adjusted based on species interaction data. 

## Analysis
To understand the drivers of range adjustments we completed a series of analyses. Initially we calculated the extent to which interacting predator and prey species cooccurred across their ranges (geographical overlap) by adapting a metric previously used to calculate beta-diversity (Koleff et al., 2003). We adapted the method presented by Ruggiero (1998): a/[a + c]. We define a as the number of pixels where the focal species occurs and c is the number of pixels where the focal species and another species cooccur. The index can be calculated with prey or predators as the focal species. The index varies between 0 and 1, with values closer to 0 indicating that there is large overlap in the ranges of the two species and values closer to 1 indicative of low cooccurrence across their ranges. This metric allowed us to understand the extent to which the range of different species overlap and provides an early indication of potential range adjustments as predators with consistently high values are likely to have significant range reductions using the approach detailed above.
For each species we calculated the in and out degree to understand whether the level of trophic specialisation (i.e., number of prey items per predator or number of predators per prey) affects the extent to which the ranges of the species were altered. One would assume that predators with a greater number of prey (i.e., a higher degree) are less likely to have significant changes in range as it is more likely that at least one prey species is present across its entire range.

## Validation
For each species in the dataset we collated point observation data from the Global Biodiversity Information Facility (GBIF; www.gbif.org). These data were used to validate the range adjustments made based on species interactions (see Approach). To do so, we calculated the proportion of total GBIF observations occurring with the original and adjusted species ranges. We standardised these values by the total number of pixels within each range to account for variability in range size between different species.

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

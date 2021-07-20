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

Ecological networks represent species as nodes and their interactions as links, which allows quantifying the structure of animal-plant relationships,  and recognize species with higher degree values as better connected, and with a more important role in modularity [@Acevedo-Quintero2020StrFun].  The connection between species can be given by antagonistic and mutualistic interactions, which leads to the formation of complex networks that shape ecological structures and maintain the essential functions of ecosystems. One of these functions is herbivory [@Albrecht2018PlaAni]  Given the effect that herbivores exert on the composition, richness, and successional patterns of plant communities across multiple biomes; changes in herbivores abundance can lead to significant direct and indirect effects on plant-animal interaction and also the processes of the ecosystem [@Anderson2016SpaDis; @Dattilo2018EcoNet ; @Pringle2016LarHer ; @Young2013EffMam]. As occur whether interactions where the decrease in rains limits the plant resources, which leads to an ungulate birth decline, which turns lead to a reduction in carnivore births and survival. This strongly suggests the importance of herbivores for the study of networks, given their connection with vegetation and predators. [@Dobson2009FooStr] [Scott2018RolHer]. Therefore, we can assume that herbivores represent an important connector between the different trophic levels of a given ecosystem and thus the presence of large herbivores could argue the presence of both plant resources and predators.

The International Union for Conservation of Nature (IUCN) is the largest provider of species range maps, covering thousands of mammal, bird, amphibian, and reptile species. These maps consist of simplified polygons, often created as alpha or convex hulls, which are drawn around known species locations, refined based on expert knowledge of species.  Being simple polygons, range maps also ignore abundance gradients and can include inadequate areas within the estimated range. As a result, can turn in biased estimations of the mean or median ecological conditions experienced by a species.  Global Biodiversity Information Facility (GBIF) provides an online repository of observational georeferenced records of more than one million species with global coverage. GBIF occurrence data are compiled from a variety of sources, including citizen science programs, museum collections, and long-term monitoring schemes. Wich can lead to GBIF data notoriously biased because of irregular sampling effort, with more occurrences recorded in attractive and accessible areas, and for charismatic species. (Alhajeri et al., 2018)



# Methods

## Data 
We investigated the effects of adjusting species distributions based on species interaction data across savannah ecosystems in Africa (Fig. 1). These ecosystems host a range of different species, including the well characterised predator-prey dynamics between iconic predators (e.g., lions, hyenas and leopards) and large herbivores (e.g., antelope, wildebeest and zebra), as well as a range of herbivorous and carnivorous small mammals. Here we focus on six groups of herbivores and carnivores from the Serengeti Food Web Data Set (Baskerville et al. 2011). These species exhibit direct antagonistic (predator-prey) interactions with one another and are commonly found across savanna ecosystems on the African continent (McNaughton, 1992). Although plants are included in the Serengeti Food Web Data Set, there is an absence of global range maps for many plant species (Daru, 2020), and as such we did not directly include plants in the following analyses. Many savanna plants are functionally similar (i.e., grasses, trees and shrubs) and cooccur across the same habitats (Baskerville et al. 2011), furthermore many of the herbivores are generalists feeding on a wide range of plants from different functional groups. Therefore, we assume that plants consumed by large herbivores are present across their ranges, and as such the ranges of herbivores are not expected to be significantly constrained by the availability of food plants.
From the wider ecological network presented in Baskerville et al. (2011), we sampled interaction data for herbivores and carnivores. This network contained 32 taxa and 84 interactions (after removing all self-loops for predators) and had a connectance of 0.08. We refer to this network as the meta-web as it contains all possible species interactions between the different taxa that could occur across savanna ecosystems such as the Serengeti.
IUCN range maps were compiled for the 32 species included in the meta-network (23 herbivores and 9 carnivores) from the Spatial Data Download portal (www.iucnredlist.org/resources/spatial-data-download). Ranges were rasterized at 0.17 arc minute resolution (~19 km2).
We then combined interaction data from the meta-network and cooccurrence data generated from species ranges to create networks for each raster pixel. This generated a total of 84,244 networks where at least two cooccurring and interacting species were present.

## Approach
Organisms cannot persist unless they are directly or indirectly connected to a primary producer within their associated food web (Power, 1992). As such, if a predator (omnivore or carnivore) becomes disconnected from primary producers, either because the primary producer itself or an organism at an intermediate trophic level become extinct, then that predator will too become extinct. Thus, here we adjusted the ranges of predators based on a simple rule: we removed any part of a predator’s range that did not intersect with the range of at least one prey herbivore species. So, unless the range of the predator overlapped at least one prey item which in turn is directly connected to a primary producer (plants), we removed that section of the predator’s range.
We then calculated the difference in range size between the original IUCN ranges and those adjusted based on species interaction data.

## Analysis
To understand the drivers of range adjustments we completed a series of analyses. 
We calculated geographical overlap, the extent to which interacting predator and prey species cooccurred across their ranges, by adapting a method presented by Ruggiero (1998): a/[a + c]. We define a as the number of pixels where the focal species occurs and c is the number of pixels where the focal species and another species cooccur. This index of geographical overlap can be calculated with prey or predators as the focal species. Values vary between 0 and 1, with values closer to 0 indicating that there is large overlap in the ranges of the two species and values closer to 1 indicative of low cooccurrence across their ranges.
For each species we calculated the in and out degree to understand whether the level of trophic specialisation (i.e., number of prey items per predator or number of predators per prey) affects the extent to which the ranges of the species were altered. One would assume that predators with a greater number of prey (i.e., a higher degree) are less likely to have significant changes in range as it is more likely that at least one prey species is present across its entire range. 

## Validation
For each species in the dataset we collated point observation data from the Global Biodiversity Information Facility (GBIF; www.gbif.org). These data were used to validate the range adjustments made based on species interactions (see Approach). To do so, we calculated the proportion of total GBIF observations occurring with the original and adjusted species ranges. We standardised these values by the total number of pixels within each range to account for variability in range size between different species.



# Results

Mammal species found in the Serengeti food web are widespread in Africa, especially in grasslands and savannas (left panel of @fig:richness). However, most local networks (83.2%) built using the original IUCN range maps had at least one mammal species without a path to a primary producer (right panel of @fig:richness). On average, local food webs had almost the third of their mammal species (mean = 30.5%, median = 14.3%) disconnected from basal species. In addition, many networks (16.6%) only had disconnected mammals; these networks however all had a very low number of mammal species, specifically between 1 and 4. 

![Left panel: Spatial distribution of species richness according to the original IUCN range maps of all 32 mammal species of the Serengeti food web. Right panel: Proportion of mammal species remaining in each local network (i.e. each pixel) after removing all species without a path to a primary producer.](figures/richness_prop_removed.png){#fig:richness}

![Fig 01 - More specialized predators lose a higher proportion of their ranges. Both *Leptailurus serval* and *Canis mesomelas* have only one prey in the Serengeti foodweb, each of them with a very small range compared to those of their predators. The discrepancy between range sizes promotes significant range loss. ](figures/rel_loss-in_degree-species.png)
<!--->update with results without self-interaction<--->


Fig 02 - probably the species richness before and after?

Fig 03

Fig 04 - The [beta-diversity plot](figures/beta-div_pred-species.png) with 4 quadrants
There was high variation in the overlap of predator and prey ranges (Fig. 4). The range of several predators were well covered by prey (low values of prey-predator values), yet the ranges of some predators and prey were completely asynchronous, with no overlap (zero values for both overlap metrics; Fig. 4). For example, the range of Canis aureus is not covered by any prey species, whereas Panthera pardus exhibited highly variable levels of overlap with prey. In general, species exhibited more consistent values of prey-predator overlap, than predator-prey overlap – indicated by the spread of points along the x axis, yet more restricted variation on the y axis (Fig. 4). There was also no overall relationship between the two metrics, or for any predator species.

Table 01 - The One With All the Species and Their Ranges and Predators and Preys

Fig 06 - Something with GBIF results

# Discussion

Although species interactions have previously been shown to affect the distribution and abundance of species at large-scales, not all research supports the assertion that ecological interactions are important at macroecological scales (REF). Here we lend further evidence to this debate, showing that when ecological interaction data (predator-prey interactions within food webs) are used to refine species range maps, there are significant reductions in the predicted range size of predatory organisms. Despite showing the potential importance in accounting for species interactions when estimating the range of a species, it remains unclear the extent of which the patterns observed represent ecological processes or a lack of data. In the following sections we discuss the implications of our findings, in terms of species range maps, interaction data and the next steps required to enhance understanding of species distributions using information on ecological networks.

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

#### Geographical mismatch and data availability

The geographical mismatch between predators and preys have ecological
consequences such as loss of ecosystem functioning and extiction of populations
[CITATIONS]. Climate change is one of the causes of this, leading, for instance,
to the decrease of plants populations due to lack of pollination [CITATION]
[INCLUDE EXAMPLES]. However, this mismatch can also be purely informational.
When the distribution of predators and preys do not supperpose, it can mean we
lack information about the distribution of either species or about their
interactions. Here we address part of this problem by comparing the IUCN range
maps with GBIF occurrences, which helped us clarify what is the shortfall for
each species. 

The lack of superposition between IUCN range maps and GBIF occurrences suggests
that we certainly do miss geographical information about the distribution of a
certain species, but it is not an indicative about the completeness of the
information about ecological interactions. However, if both GBIF and IUCN
occurrences tend to superpose and still the species is locally removed, this
indicates we don't have information about all its interactions. The combination
of this rationale with out method of updating range maps based on ecological
interactions allows us to have a clearer idea of which information we are
missing. For example, the lion (*Panthera leo*) was one of the species with the
smallest difference between the original and the updated ranges
([@Fig:outdegree]), but 59.5% of the GBIF occurrences for this species fell
outside the IUCN range ([@Fig:gbif]). The fact that we don't find lions where it
doesn't have a prey is a good indicative that we have a good knowledge about its
interactions and we probably can trust the IUCN occurrence data in this
particular case, but the high disagreement between the IUCN and the GBIF
databases adds uncertainty about its geographical distribution. On the other
hand, *Leptailurus serval* and *Canis mesomelas* are two of the three species
that lose the higher proportion of range due to the lack of paths to a herbivore
([@Fig:outdegree]), but are also some of the species with the higher proportion
of GBIF occurrences inside IUCN range maps ([@Fig:gbif]). This indicates that
the information we are missing for these two species are their ecological
interactions. Finally, the extreme case of *Canis aureus* illustrates a lack of
both geographical and ecological information: none of its GBIF occurrences and
none of its preys occur inside its IUCN range. We believe, therefore, that
the validation of species distribution based on ecological interaction is a
relevant method that can further clarify information shortfalls.

## Acknowledgements

We acknowledge that this study was conducted on land within the traditional unceded territory of the Saint Lawrence Iroquoian, Anishinabewaki, Mohawk, Huron-Wendat, and Omàmiwininiwak nations. GH, FB, GD, and NF are funded by the NSERC BIOS$^2$ CREATE program; FB, NF, and TP are funded by IVADO; NF and TP are funded by a donation from the Courtois Foundation; GD is funded by the FRQNT doctoral scholarship; TP is funded by the Canadian Institute of Ecology & Evolution; FW is funded by the Royal Society (Grant number: CHL\\R1\\180156). 

# References

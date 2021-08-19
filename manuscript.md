---
bibliography: [references.bib]
---

# Intro

Finding a species in a certain location is like finding an encrypted message
that travelled through time. This message carries the species’ evolutionary
history, long migration journeys, effects of other species we do not even know
to exist, and ultimately the elements that shape its, yet unknown, future.
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
taxonomic, temporal or geographical [@Boakes2010DisVie; @Ronquillo2020AssSpa;
@Meyer2016MulBia]. Amongst these geographical data available are the range maps
provided by the International Union for the Conservation of Nature (IUCN). These
maps consist of simplified polygons, often created as alpha or convex hulls
around known species locations, refined by expert knowledge of species
[@IUCNSSCRedListTechnicalWorkingGroupMapSta]. Being simple polygons, they ignore
abundance gradients and can include inadequate areas within the estimated range.
As a result, they can lead to biased estimations of the ecological conditions
experienced by a species. These maps can be used in macroecological inferences
in the lack of more precise information [@Fourcade2016ComSpe;
@Alhajeri2019HigCor], but it has been recommended that they are used with
caution since they tend to underestimate the distribution of species that are
not well-known [@Herkt2017MacCon]. Another source of species distribution
information is the Global Biodiversity Information Facility (GBIF), which is an
online repository of georeferenced observational records that comes from various
sources, including community science programs, museum collections, and long-term
monitoring schemes. A great source of bias in these datasets is the irregular
sampling effort, with more occurrences originated from attractive and accessible
areas and observation of charismatic species [@Alhajeri2019HigCor]. A complete
assessment of ecological interactions is even more difficult. The
number of interactions sampled will always be lower than the number of possible
interactions, mainly due to forbidden links [@Jordano2016SamNet]. This lack of
information, known as the Eltonian Shortfall, is aggravated by slanted and
different sampling methods [@Poisot2020EnvBia; @Hortal2015SevSho]. Nevertheless,
we have witnessed an increase in the availability of biodiversity data in the
last decades, including those collected through community science projects
[@Callaghan2019ImpBig, @Pocock2015BioRec] and organized dedicated databases
mostly accessed by specialists, such as mangal [@Poisot2016ManMak] and the
Global Biodiversity Information Facility (GBIF;
@GBIF:TheGlobalBiodiversityInformationFacility2021WhaGbi).  

The connection between occurrence and interaction data is a frequent debate in
Ecology. For instance, some argue that occurrence data can also capture
real-time interactions [@Roy2016FocPla; @Ryan2018RolCit], and, because of that,
it would not be necessary to include ecological interaction dynamics in
macroecological models. On the other hand, many mechanistic simulation models in
ecology have considered the effect of competition and facilitation in range
shifts, whilst the use of trophic interactions in this context remains
insufficient [@Cabral2017MecSim]. The rationale behind these models comes from
the fact that interactions form complex networks that shape ecological
structures and maintain the essential functions of ecosystems, such as seed
dispersal, pollination, and biological control [@Albrecht2018PlaAni] that
ultimately affects the composition, richness, and successional patterns of
communities across multiple biomes. Therefore, changes in herbivores abundance,
for example, can lead to significant direct and indirect effects on plant-animal
interaction and also the processes of the ecosystem [@Anderson2016SpaDis;
@Dattilo2018EcoNet; @Pringle2016LarHer; @Young2013EffMam]. Herbivores and
pollinators, more precisely, are core study groups for these models since they
are the main connection between the plant resources (directly limited by
environmental conditions) and predators [@Dobson2009FooStr; Scott2018RolHer].
Consequently, the presence of large herbivores could represent the presence of
both plant resources and potential predators.

Here we investigate whether occurrence data (more precisely range maps) can be
refined based on species interaction information, considering the basic
assumption that predators can only be present in regions where there are preys.
We used the Serengeti food web dataset compiled by Baskerville *et al*.
[-@Baskerville2011SpaGui], which comprises carnivores, herbivores, and plants
from Tanzania. The Serengeti ecosystem has been extensively studied and its
foodweb is one of the most complete we have to date, including primary producers
identified to the species level [@Baskerville2011SpaGui]. We used these
interactions to refine occurrence maps of carnivores, locally excluding them
wherever a herbivore was not present. We also explored the differences between
the IUCN range maps and GBIF occurrences both before and after our analysis as
a tool to determine whether we miss geographical information about species
occurrence or ecological information about their interactions.


# Methods

## Data 
We investigated the effects of adjusting species distributions based on species
interaction data across savannah ecosystems in Africa (@fig:richness). These
ecosystems host a range of different species, including the well characterised
predator-prey dynamics between iconic predators (e.g., lions, hyenas and
leopards) and large herbivores (e.g., antelope, wildebeest and zebra), as well
as a range of herbivorous and carnivorous small mammals. Here we focus on six
groups of herbivores and carnivores from the Serengeti Food Web Data Set
[@Baskerville2011SpaGui]. These species exhibit direct antagonistic
(predator-prey) interactions with one another and are commonly found across
savanna ecosystems on the African continent [@McNaughton1992ProDis]. Although
plants are included in the Serengeti Food Web Data Set, there is an absence of
global range maps for many plant species [@Daru2020GreToo], and as such we did
not directly include plants in the following analyses. Many savanna plants are
functionally similar (i.e., grasses, trees and shrubs) and cooccur across the
same habitats [@Baskerville2011SpaGui], furthermore many of the herbivores are
generalists feeding on a wide range of plants from different functional groups.
Therefore, we assume that plants consumed by large herbivores are present across
their ranges, and as such the ranges of herbivores are not expected to be
significantly constrained by the availability of food plants.  

From the wider ecological network presented in Baskerville
[-@Baskerville2011SpaGui], we sampled interaction data for herbivores and
carnivores. This network contained 32 taxa and 84 interactions (after removing
all self-loops for predators) and had a connectance of 0.08. We refer to this
network as the meta-web as it contains all possible species interactions between
the different taxa that could occur across savanna ecosystems such as the
Serengeti.  

IUCN range maps were compiled for the 32 species included in the meta-network (23 herbivores and 9 carnivores) from the Spatial Data Download portal (www.iucnredlist.org/resources/spatial-data-download). Ranges were rasterized at 0.17 arc minute resolution (~19 km²).
We then combined interaction data from the meta-network and cooccurrence data
generated from species ranges to create networks for each raster pixel. This
generated a total of 84,244 networks where at least two cooccurring and
interacting species were present.  

## Approach
Organisms cannot persist unless they are directly or indirectly connected to a
primary producer within their associated food web [@Power1992TopBot]. As such,
if a predator (omnivore or carnivore) becomes disconnected from primary
producers, either because the primary producer itself or an organism at an
intermediate trophic level become extinct, then that predator will too become
extinct. Thus, here we adjusted the ranges of predators based on a simple rule:
we removed any part of a predator’s range that did not intersect with the range
of at least one prey herbivore species. So, unless the range of the predator
overlapped at least one prey item which in turn is directly connected to a
primary producer (plants), we removed that section of the predator’s range. We
then calculated the difference in range size between the original IUCN ranges
and those adjusted based on species interaction data.

## Analysis
To understand the drivers of range adjustments we completed a series of analyses. 
We calculated geographical overlap, the extent to which interacting predator and
prey species cooccurred across their ranges, by adapting a method presented by
[@Ruggiero1998GeoRan]: *a/[a + c]*. We define *a* as the number of pixels where
the focal species occurs and *c* is the number of pixels where the focal species
and another species cooccur. This index of geographical overlap can be
calculated with prey or predators as the focal species. Values vary between 0
and 1, with values closer to 0 indicating that there is large overlap in the
ranges of the two species and values closer to 1 indicative of low cooccurrence
across their ranges.  

For each predator species we calculated its out degree to understand whether the
level of trophic specialisation (i.e., number of prey items per predator)
affects the extent to which the ranges of the species were altered. One would
assume that predators with a greater number of prey (i.e., a higher degree) are
less likely to have significant changes in range as it is more likely that at
least one prey species is present across its entire range.   

## Validation
For each species in the dataset we collated point observation data from the Global Biodiversity Information Facility (GBIF; www.gbif.org). These data were used to validate the range adjustments made based on species interactions (see Approach). To do so, we calculated the proportion of total GBIF observations occurring with the original and adjusted species ranges. We standardised these values by the total number of pixels within each range to account for variability in range size between different species.



# Results

Mammal species found in the Serengeti food web are widespread in Africa,
especially in grasslands and savannas (left panel of @fig:richness). However,
most local networks (83.2%) built using the original IUCN range maps had at
least one mammal species without a path to a primary producer (right panel of
@fig:richness). On average, local food webs had almost the third of their mammal
species (mean = 30.5%, median = 14.3%) disconnected from basal species. In
addition, many networks (16.6%) only had disconnected mammals; these networks
however all had a very low number of mammal species, specifically between 1 and
4 (from a total of 32). 

![Left panel: spatial distribution of species richness according to the original IUCN range maps of all 32 mammal species of the Serengeti food web. Right panel: proportion of mammal species remaining in each local network (i.e. each pixel) after removing all species without a path to a primary producer.](figures/richness_prop_removed.png){#fig:richness}

### Specialized predators lose more range

![Negative relationship between the out degree of predator species and their
relative range loss. More specialized predators lose a higher proportion of
their ranges due to mismatch with the ranges of their preys.](figures/rel_loss-outdegree-species.png){#fig:degree}

Predators with less preys lose more range with our method ([@fig:degree]). For
instance, both *Leptailurus serval* and *Canis mesomelas* have only one prey in
the Serengeti foodweb ([@tbl:everyone]), each of them with a very small range compared to those of
their predators. This discrepancy between range sizes promotes significant range
loss. On the other hand, predators of the genus *Panthera* are some of the most
connected species, and they also lose the least proportion of their ranges. This
mismatch between predators and preys can also be a result of taxonomic
disagreement between the geographical and ecological data. Although *Canis
aureus* has the same number of preys than *Caracal caracal*, none of the preys
of the former occurs inside its original range ([@tbl:everyone]), which results in complete range
loss. 

![Geographical dissimilarity between the original IUCN range maps of predators and preys. Dots represent predator-prey pairs, with different symbols corresponding to different predators. For a given pair of species, the number $c$ of pixels where the predator and prey cooccur and the number $a$ of pixels where the focal species is present but not the other, were calculated. Geographic dissimilarities were given by a/(a+c), with the predator being the focal species in the predator to prey dissimilarity (x-axis), while the prey is the focal one in the prey to predator dissimilarity (y-axis).](figures/beta-div_pred-species.png){#fig:geo_diss} 

There was high variation in the overlap of predator and prey ranges
(@fig:geo_diss). The range of several predators were well covered by prey (low
values of prey-predator values), yet the ranges of some predators and prey were
completely asynchronous, with no overlap (zero values for both overlap metrics;
@fig:geo_diss). For example, the range of *Canis aureus* is not covered by any
prey species, whereas *Panthera pardus* exhibited highly variable levels of
overlap with prey ([@tbl:everyone]). In general, species exhibited more consistent values of
prey-predator overlap, than predator-prey overlap – indicated by the spread of
points along the x-axis, yet more restricted variation on the y axis
(@fig:geo_diss)). There was also no overall relationship between the two
metrics, or for any predator species.


: List of species analysed, their out and in degrees, total original range size and proportion of their ranges occupied by their preys and predators (values between 0 and 1). Notice how some species are isolated in the network (*Loxodonta africana*) and how *Canis aureus*'s range do not overlap with any of its preys. {#tbl:everyone}

|                Species | Number of preys | Number of predators | Total range size | Proportion of range occupied by preys | Proportion of range occupied by predators |
| ----------------------:| -------:| -------:| ----------------:| ----------:| ----------:|
|        Canis mesomelas |   1 |   1 |        19872 |      0.190 |      0.995 |
|     Loxodonta africana | 0 | 0 |         9654 |    0 |    0 |
|           Panthera leo |  18 | 0 |        11384 |      0.934 |    0 |
|     Eudorcas thomsonii | 0 |   6 |          463 |    0 |      1 |
|       Acinonyx jubatus |   8 |   1 |        15540 |      0.560 |      0.670 |
|     Aepyceros melampus | 0 |   5 |        10579 |    0 |      1 |
|  Alcelaphus buselaphus | 0 |   4 |        20761 |    0 |      1 |
|           Canis aureus |   4 |   1 |         7358 |      0.000 |      0.780 |
|        Caracal caracal |   4 | 0 |        47243 |      0.832 |    0 |
|  Connochaetes taurinus | 0 |   6 |         9650 |    0 |      1 |
|        Crocuta crocuta |  12 |   1 |        43307 |      0.848 |      0.252 |
|     Damaliscus lunatus | 0 |   4 |         5567 |    0 |      1 |
|           Equus quagga | 0 |   5 |         7070 |    0 |      1 |
|          Nanger granti | 0 |   6 |         2303 |    0 |      1 |
| Giraffa camelopardalis | 0 |   1 |         5418 |    0 |      0.470 |
|     Heterohyrax brucei | 0 |   1 |        17728 |    0 |      0.972 |
| Hippopotamus amphibius | 0 | 0 |         3695 |    0 |    0 |
|   Kobus ellipsiprymnus | 0 |   4 |        26705 |    0 |      1 |
|     Leptailurus serval |   1 |   1 |        38856 |      0.011 |      0.979 |
|          Lycaon pictus |  14 | 0 |         3873 |      0.916 |    0 |
|         Madoqua kirkii | 0 |   7 |         4002 |    0 |      1 |
|         Ourebia ourebi | 0 |   5 |        22380 |    0 |      1 |
|        Panthera pardus |  22 | 0 |        68137 |      0.766 |    0 |
|           Papio anubis | 0 |   1 |        23171 |    0 |      0.938 |
|       Pedetes capensis | 0 |   2 |        11901 |    0 |      1 |
| Phacochoerus africanus | 0 |   5 |        29963 |    0 |      0.999 |
|      Procavia capensis | 0 |   1 |        47697 |    0 |      0.647 |
|        Redunca redunca | 0 |   5 |        17465 |    0 |      1 |
|      Rhabdomys pumilio | 0 |   5 |          465 |    0 |      0.998 |
|        Syncerus caffer | 0 |   1 |        25223 |    0 |      0.250 |
|       Tragelaphus oryx | 0 |   2 |        20852 |    0 |      0.991 |
|   Tragelaphus scriptus | 0 |   3 |        36011 |    0 |      0.984 |


## Validation with GBIF occurrences

The proportion of GBIF pixels (pixels with at least one GBIF occurrence) falling in the IUCN ranges varied from low to high depending on the species ([@fig:gbif], left). No species had all of its GBIF occurrences within its IUCN range. The lowest proportions occurred for species with small ranges, although some species with small ranges showed high overlap. Species with median and large ranges had high proportions of occurrences falling into their IUCN range. Predators and preys displayed similar overlap variations. The only species for which none of the GBIF pixels occur in the IUCN range, _Canis aureus_, is also the only species whose range is not covered by any of its preys.

The proportion of GBIF pixels falling inside the updated ranges from our networks analysis was similar to the overlap with the original IUCN ranges for most predator species ([@fig:gbif, right]). The proportion for the updated ranges can only be equal or lower, as our analysis removes pixels from the original range and does not add new ones. Rather, the absence of a difference between the two types of ranges indicates that no pixels with GBIF observations, hence likely true habitats, were removed by our analysis. Four species showed no difference of proportion while three species showed only small differences (proportions of 0.01 to 0.05). On the other hand, two species, _Canis mesomelas_ and _Leptailurus serval_,  showed very high differences, with overlaps lower by 0.548 and 0.871 respectively. For _Leptailurus serval_, none of the GBIF observations occurred in the updated range. These two species are also the only predators with a single prey in our meta-network.

![Left panel: Relationship between the proportion of GBIF pixels (pixels with at least one occurrence in GBIF) falling into the IUCN range and the IUCN range size. Right panel: Proportion of GBIF pixels falling into the IUCN and updated ranges for every predator species. Arrows go from the proportion inside the original range to the proportion inside the updated range, which can only be equal or lower. Overlapping markers indicate no difference in the between the types of layers. Species markers are the same on both figures, with predators presented in distinct coloured markers and all herbivores grouped in a single grey marker. Pixels represent a resolution of 10 arc-minutes. ](figures/gbif_panels.png){#fig:gbif}

# Discussion

Although species interactions have previously been shown to affect the
distribution and abundance of species at large-scales [@Bullock2000GeoSep;
@Chesson2008IntPre; @Godsoe2012HowSpe; @Svenning2014InfInt; @Godsoe2017IntBio],
not all research supports the assertion that ecological interactions are
important at macroecological scales [Pearson2003PreImp; @Soberon2009NicDis]. For
instance, preys' range expansion tends to be slower when generalists predators
are present or when mutualists are absent [@Svenning2014InfInt]. On the other
hand, range preservation is also associated with ecological interactions, once
connected species can be protected of climate change and invasion
[@Dunne2002NetStr; @Memmott2004TolPol; @Ramos-Jiliberto2012TopPla]. Here we lend
further evidence to this debate, showing that when ecological interaction data
(predator-prey interactions within food webs) are used to refine species range
maps, there are significant reductions in the predicted range size of predatory
organisms. Despite showing the potential importance in accounting for species
interactions when estimating the range of a species, it remains unclear the
extent of which the patterns observed represent ecological processes or a lack
of data. In the following sections we discuss the implications of our findings,
in terms of species range maps, interaction data and the next steps required to
enhance understanding of species distributions using information on ecological
networks.

#### Connectivity, diversity and range preservation

In the Serengeti food web there is a positive relationship between the predators
out degree and the size of their ranges ([@tbl:everyone]). In addition, our
results show that there is a negative relationship between the relative loss of
range and number of preys ([@fig:degree]), reinforcing the idea that generalist
species tend to preserve their range. The factors limiting the geographical
range of a species in a community can vary with connectivity and richness.
Younger communities may be more affected by environmental limitations because
they are dominated by generalist species, while older metacommunities are
probably affected in different ways in the centre of the distribution, at the
edge of ranges and in sink and source communities. Additionally, it is likely
that species with larger ranges of distribution and those that are more
generalists would co-occur with a greater number of other species
[@Dattilo2020SpeDri], while dispersal capacity of competitive species modulate
their aggregation in space and the effect of interactions on their range limits
[@Godsoe2017IntBio].

#### Geographical mismatch and data availability

The geographical mismatch between predators and preys have ecological
consequences such as loss of ecosystem functioning and extiction of populations
[@Anderson2016SpaDis; @Dattilo2018EcoNet; @Pringle2016LarHer; @Young2013EffMam].
Climate change is one of the causes of this, leading, for instance, to the
decrease of plants populations due to lack of pollination [@Bullock2000GeoSep;
@Hellmann2012InfSpe; @Afkhami2014MutEff; @Godsoe2017IntBio; @Siren2020IntRan].
However, this mismatch can also be purely informational. When the distribution
of predators and preys do not supperpose, it can mean we lack information about
the distribution of either species or about their interactions. Here we address
part of this problem by comparing the IUCN range maps with GBIF occurrences,
which helped us clarify what is the shortfall for each species. 

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
(@fig:degree), but 59.5% of the GBIF occurrences for this species fell
outside the IUCN range (@fig:gbif). The fact that we don't find lions where it
doesn't have a prey is a good indicative that we have a good knowledge about its
interactions and we probably can trust the IUCN occurrence data in this
particular case, but the high disagreement between the IUCN and the GBIF
databases adds uncertainty about its geographical distribution. On the other
hand, *Leptailurus serval* and *Canis mesomelas* are two of the three species
that lose the higher proportion of range due to the lack of paths to a herbivore
(@fig:degree), but are also some of the species with the higher proportion
of GBIF occurrences inside IUCN range maps (@fig:gbif). This indicates that
the information we are missing for these two species are their ecological
interactions. Finally, the extreme case of *Canis aureus* illustrates a lack of
both geographical and ecological information: none of its GBIF occurrences and
none of its preys occur inside its IUCN range. We believe, therefore, that
the validation of species distribution based on ecological interaction is a
relevant method that can further clarify information shortfalls.

#### Next steps

Here we demonstrate how we can detect uncertainty in species distribution data
using ecological interactions. Knowing where questionable occurrence data is can
be crucial in ecological modelling[@Hortal2008UncMea; @Ladle2013MapSpe], and
accounting for these errors can improve model outputs by diminishing the error
propation [@Draper1995AssPro]. For instance, we believe this is a way to account
for ecological interactions in habitat suitability models without making the
models more complex, but making sure (not assuming) that the input data - the
species occurrence - actually accounts for ecological interactions. It is
important to notice, however, that the quality and usefulness of this method is
highly correlated with the amount and quality of data available about species'
occurrences **and** interactions. In our case, one predator (*Canis aureus*)
would be completely excluded of its original range probably because of a
taxonomic mismatch between datasets. Hence, this method can be useful when the
study group is well known, and the growing availability of data will certainly
improve the its applicability.

With this paper we hope to add to the collective effort to decode the encrypted
message that is the occurrence of a species in space and time. A promising venue
that adds to our method is the prediction of networks and interactions in large
scale [REFS], for they can add valuable information about ecological
interactions where they are missing. Additionally, in order to achieve a robust
modelling framework towards actual species distribution models we should invest
on efforts to collect and combine open data on species occurrence and
interactions, especially because we may have been losing ecological interactions
at least as fast as we are losing biodiversity [@Parejo2016InfMis].


## Acknowledgements

We acknowledge that this study was conducted on land within the traditional unceded territory of the Saint Lawrence Iroquoian, Anishinabewaki, Mohawk, Huron-Wendat, and Omàmiwininiwak nations. GH, FB, GD, and NF are funded by the NSERC BIOS$^2$ CREATE program; FB, NF, and TP are funded by IVADO; NF and TP are funded by a donation from the Courtois Foundation; GD is funded by the FRQNT doctoral scholarship; TP is funded by the Canadian Institute of Ecology & Evolution; FW is funded by the Royal Society (Grant number: CHL\\R1\\180156). 

# References

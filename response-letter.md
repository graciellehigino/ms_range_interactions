Dear editor,

Thank you for the valuable feedback on our manuscript. We are pleased that you
and the reviewer found interest and worth in our manuscript. We addressed each comment and found that the manuscript is indeed clearer now, and we hope to have it approved after your consideration.

We have added more context in the introduction section, but we've found it hard
to expand the first paragraph. We believe that this particular paragraph needs
to be more succinct, at the same time that it provides a complete picture of the
paper, framed in a storytelling structure. Then, on the second paragraph, we
start providing literature background and many examples, to help the reader
understand where our paper stands in the scientific context. We have included
discussions about the quality and accuracy of range maps (lines XX-XX), examples
of data biases (lines XX-XX), and we addressed the uniqueness of our study
compared to previous research (lines XX-XX). We hope that this structure is
clarifying and appealing to the readers.

Regarding the GBIF data cleaning, retrieval and the validation steps, we added a
more detailed description of our process (lines XX-XX, XX-XX and XX-XX). Data
retrieving is detailed in the source code provided on our GitHub repository
(code/06-GBIF_data.jl). We used the list of species from the network dataset and
retrieved any occurrence within our bounding box (between longitudes -20.0 and
55.0 degrees; and latitudes -35.0 and 40.0 degrees). Some taxonomic
investigation needed to be done due to inconsistencies between GBIF and IUCN
nomenclatures (in the case of _Taurotragus oryx_). We didn't perform any further
data cleaning procedures because this could hinder the goals of the paper, which
was to investigate the characteristics of the data available for research. As we
needed to compare two sets of raw data, and data cleaning protocols are
dependent on the use objectives, we chose to avoid data manipulation both for
GBIF and IUCN datasets.

For the validation step, we understand our phrasing was confusing, and we have
rewritten this section to clarify our method. Rather than using
absence data, what we did was to transform the point data into raster files, and
then restrict our range maps to the locations where we had GBIF occurrences.
Therefore, the pixels where there are no GBIF occurrences are not considered
true absence of a species, but absence of **data** about the occurrence of that
species.

Finally, we have addressed all the other minor comments throughout the text as
described below:
- We've added citations on the Methods section to support our argument that a
  mismatch between ranges can be originated from different sources (L. 68-70)
- We have suppressed lines 214-217.
- The abstract is now restructured according to PeerJ guidelines.
- References to tables and figures in the Discussion section were suppressed,
  with the exception of Figure 05 (line XX), which is an example of our results
  to clarify an important point of the discussion.
- Lines 22-23 (now lines XX-XX): the cited literature are not examples of models
  that do not take ecological interactions into account, but studies that have
  demonstrated how ecological interactions might be responsible for shaping a
  species' distribution. We've rewritten the sentence to clarify that.
-  Lines 68-70: we have rewritten the sentence to include the consideration
   misestimation of both species in a trophic interaction. We have also added
   citations and examples.
- We have addressed the grammatical suggestions throughout the text, except for
  the legend of figure 1. We thought that the suggested phrasing adds a little
  bit of confusion to the comprehension of the figure.

We hope our revised manuscript is now more appropriate for publishing at PeerJ.
Reiterating our appreciation for yours and the reviewer's thoughtful comments,
we are available to answer any further questions.

Best regards,
The Authors

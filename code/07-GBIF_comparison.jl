## Load required scripts and packages
import Pkg; Pkg.activate("."); Pkg.instantiate()

using CSV
using DataFrames
using GBIF
using Plots
using Plots.PlotMeasures
using Shapefile
using Statistics
using SimpleSDMLayers

include("shapefile.jl") # mapping functions

## Load required data

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0)

# Get the list of mammals
mammals = readlines(joinpath("data", "clean", "mammals.csv"))

# Species list with types
sp = DataFrame(CSV.File(joinpath("data", "species_code.csv")))
sp.species = replace.(sp.species, " " => "_")
replace!(sp.species, "Damaliscus_korrigum" => "Damaliscus_lunatus", "Taurotragus_oryx" => "Tragelaphus_oryx")

# Get the individual ranges back (original and updated)
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]
ranges_updated = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "ranges_updated.tif"), i) for i in eachindex(mammals)]

# GBIF data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)
gbif_ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"), i) for i in eachindex(mammals)]

## Compare GBIF occurrences & ranges

# Separate occurrences per species
spp_df = [filter(:species => ==(m), occ_df) for m in mammals];

# Get values from IUCN layers at corresponding GBIF coordinates
for (i, df) in enumerate(spp_df)
    insertcols!(df, :IUCN => ranges[i][df])
    insertcols!(df, :IUCN_updated => ranges_updated[i][df])
end

# Reassemble
occ_df = reduce(vcat, spp_df)
replace!(occ_df.IUCN, nothing => 0.0)
replace!(occ_df.IUCN_updated, nothing => 0.0)

# Get proportion of occurrences in GBIF ranges
comparison_df = combine(
    groupby(occ_df, :species),
    nrow => :occ_n,
    :IUCN => sum => :occ_sum,
    :IUCN_updated => sum => :occ_sum_updated,
)
transform!(
    comparison_df,
    [:occ_sum, :occ_n] => ByRow(/) => :occ_prop,
    [:occ_sum_updated, :occ_n] => ByRow(/) => :occ_prop_updated,
)
comparison_df = rightjoin(sp, comparison_df; on=:species)
select!(comparison_df, Not(:code))
comparison_df.occ_prop == comparison_df.occ_prop_updated

## Compare layers

# Mask GBIF range by IUCN range (updates GBIF range value to nothing if IUCN range is nothing)
gbif_mask = mask.(ranges, gbif_ranges)

# Add to comparison
insertcols!(
    comparison_df,
    :range => length.(ranges),
    :gbif_range => length.(gbif_ranges),
    :range_prop => length.(gbif_mask) ./ length.(gbif_ranges),
)

# Short DataFrame
comparison_short = select(comparison_df, :species, :type, :occ_n,:range, :occ_prop, :range_prop)
show(comparison_short, allrows = true)
cor(comparison_short.occ_prop, comparison_short.range_prop) # 0.955

## Export table

# Format as Markdown table
using Latexify
comparison_short.species .= replace.(comparison_short.species, "_" => " ")
table = latexify(comparison_short, env=:mdtable, fmt="%.3f", latex=false)
print(table) # copy & save to file

# Export to file
table_path = joinpath("tables", "table_gbif.md")
open(table_path, "w") do io
    print(io, table)
end

# Fix digits
lines = readlines(table_path; keep=true)
open(table_path, "w") do io
    for line in lines
        line = replace(line, " 0.000" => " x.xxx")
        line = replace(line, ".000" => "")
        line = replace(line, " x.xxx" => " 0.000")
        print(io, line)
    end
end

## Plot results

# Separate carnivores & herbivores
carnivores = filter(:type => ==("carnivore"), comparison_df)
herbivores = filter(:type => ==("herbivore"), comparison_df)

# Set plot options to reuse
options = (
    group=carnivores.species,
    ylim=(-0.03, 1.0),
    markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=6,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    legend=:bottomright,
    legendtitle="Species",
    legendtitlefontvalign=:bottom,
    labels=permutedims(replace.(carnivores.species, "_" => " ")),
    foreground_color_legend=nothing,
    background_color_legend=:white,
    dpi=500,
)

# 1. Pixel proportion according to IUCN range
scatter(
    carnivores.range ./ 10^4,
    carnivores.range_prop;
    xlabel="IUCN range size in pixels (x 10,000)",
    ylabel="Proportion of GBIF pixels in IUCN range",
    options...
)
scatter!(
    herbivores.range ./ 10^4,
    herbivores.range_prop;
    label="Herbivores",
    c=:lightgrey,
    markerstrokewidth=0,
    markersize=4,
    xticks=0:1:ceil(maximum(comparison_df.range ./ 10^4)),
)
savefig(joinpath("figures", "gbif_range-prop.png"))

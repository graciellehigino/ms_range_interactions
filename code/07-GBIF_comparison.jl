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

# Get the individual ranges back (and remove the NaN)
ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "stack.tif"), i) for i in eachindex(mammals)]

# GBIF data
occ_df = CSV.read(joinpath("data", "clean", "gbif_occurrences.csv"), DataFrame)
gbif_occ_layers = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_occurrences.tif"), i) for i in eachindex(mammals)]
gbif_ranges = [geotiff(SimpleSDMPredictor, joinpath("data", "clean", "gbif_ranges.tif"), i) for i in eachindex(mammals)]

## Compare GBIF occurrences & ranges

# Separate occurrences per species
spp_df = [filter(:species => ==(m), occ_df) for m in mammals];

# Get IUCN value at corresponding coordinates
[insertcols!(df, :IUCN => r[df]) for (df, r) in zip(spp_df, ranges)]

# Reassemble
occ_df = reduce(vcat, spp_df)
replace!(occ_df.IUCN, nothing => 0.0)

# Get proportion of occurrences in GBIF ranges
comparison_df = combine(groupby(occ_df, :species), nrow => :occ_n, :IUCN => sum => :occ_sum)
transform!(comparison_df, [:occ_sum, :occ_n] => ByRow(/) => :occ_prop)
comparison_df = rightjoin(sp, comparison_df; on=:species)
select!(comparison_df, Not(:code))

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

# 1. Pixel proportion according to IUCN range
scatter(
    comparison_df.range ./ 10^4,
    comparison_df.range_prop;
    group=comparison_df.type,
    xlabel="IUCN range size (x 10^4)",
    ylabel="Proportion of GBIF pixels in IUCN range",
    legend=:right,
    ylim=(0.0, 1.0)
)
savefig(joinpath("figures", "gbif_range-prop.png"))

# 2. Occurrence proportion according to IUCN range
scatter(
    comparison_df.range ./ 10^4,
    comparison_df.occ_prop;
    group=comparison_df.type,
    xlabel="IUCN range size (x 10^4)",
    ylabel="Proportion of occurrences in IUCN range",
    legend=:right,
    ylim=(0.0, 1.0)
)
savefig(joinpath("figures", "gbif_occ-prop.png"))

# 3. Occurrence proportion according to number of GBIF occurrences
scatter(
    comparison_df.occ_n,
    comparison_df.occ_prop;
    group=comparison_df.type,
    xlabel="Number of GBIF occurrences",
    ylabel="Proportion of occurrences in IUCN range",
    legend=:right
)
savefig(joinpath("figures", "gbif_occ-prop_occ-n.png"))

# 4. Predators only - Pixel proportion according to IUCN range
comparison_df |> x ->
    filter(:type => ==("carnivore"), x) |> x ->
    scatter(
        x.range ./ 10^4,
        x.range_prop;
        group=x.species,
        xlabel="IUCN range size (x 10^4)",
        ylabel="Proportion of GBIF pixels in IUCN range",
        # legend=:right,
        ylim=(0.0, 1.0),
        markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
        markersize=6,
        palette=:seaborn_colorblind,
        markerstrokewidth=0,
        legend=:right,
        foreground_color_legend=nothing,
        background_color_legend=:white,
    )
savefig(joinpath("figures", "gbif_range-prop_pred.png"))

# 5. Predators only - Occurrence proportion according to IUCN range
comparison_df |> x ->
    filter(:type => ==("carnivore"), x) |> x ->
    scatter(
        x.range ./ 10^4,
        x.occ_prop;
        group=x.species,
        xlabel="IUCN range size (x 10^4)",
        ylabel="Proportion of occurrences in IUCN range",
        # legend=:right,
        ylim=(0.0, 1.0),
        markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
        markersize=6,
        palette=:seaborn_colorblind,
        markerstrokewidth=0,
        legend=:right,
        foreground_color_legend=nothing,
        background_color_legend=:white,
    )
savefig(joinpath("figures", "gbif_occ-prop_pred.png"))

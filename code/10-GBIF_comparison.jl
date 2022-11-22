include("A1_required.jl")

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

# Keep recent GBIF occurrences only 
year_recent = 2000

occ_with_dates = dropmissing(occ_df, :date)
occ_with_dates.year = year.(occ_with_dates.date)

occ_df_recent = subset(occ_with_dates, :year => ByRow(>(year_recent)))


## Get IUCN range values at GBIF occurrences

# Separate occurrences per species
spp_df = [filter(:species => ==(m), occ_df_recent) for m in mammals];

# Get values from IUCN layers at corresponding GBIF coordinates
for (i, df) in enumerate(spp_df)
    df.IUCN = ranges[i][df]
    df.IUCN_updated = ranges_updated[i][df]
end

# Reassemble in single DataFrame
occ_df_recent = reduce(vcat, spp_df)

# Replace nothings by zeros before performing sum
replace!(occ_df_recent.IUCN, nothing => 0.0)
replace!(occ_df_recent.IUCN_updated, nothing => 0.0)

## Compare GBIF occurrences with IUCN ranges

# Get number of occurrences in IUCN ranges
comparison_occ = @chain occ_df_recent begin
    groupby(:species)
    @combine(
        total_occ = length(:species),
        n_occ_original = sum(:IUCN),
        n_occ_updated =  sum(:IUCN_updated),
    )
end

# Get proportion of occurrences in IUCN range
@transform!(
    comparison_occ,
    occ_prop = :n_occ_original ./ :total_occ,
    occ_prop_updated = :n_occ_updated ./ :total_occ,
)

# Get difference between original & previous range
@transform!(comparison_occ, occ_prop_diff = :occ_prop_updated .- :occ_prop)

## Compare GBIF layers with IUCN ranges (based on pixels with occurrences)

# Mask GBIF range by IUCN range (updates GBIF range value to nothing if IUCN range is nothing)
gbif_mask = mask.(ranges, gbif_ranges)
gbif_mask_updated = mask.(ranges_updated, gbif_ranges)

# Get number of pixels with presences/occurrences in each layer
comparison_layers = DataFrame(
    species = mammals,
    range = length.(ranges),
    range_updated = length.(ranges_updated),
    gbif_range = length.(gbif_ranges),
    mask_range = length.(gbif_mask),
    mask_range_updated = length.(gbif_mask_updated)
)

# Get proportions for comparison
@chain begin comparison_layers
    @transform!(
        range_prop = :mask_range ./ :gbif_range,
        range_prop_updated = :mask_range_updated ./ :gbif_range,
    )
    @transform!(range_prop_diff = :range_prop_updated .- :range_prop)
end

## Combine occurrence & layer comparisons

# Join DataFrames
comparison_df = leftjoin(comparison_occ, comparison_layers, on=:species)

# Add species type
comparison_df = @chain comparison_df begin
    rightjoin(sp, _; on=:species)
    select(Not(:code))
end

# Remove some columns for display
comparison_short = select(comparison_df, [:species, :type, :total_occ, :range, :occ_prop, :range_prop])
show(comparison_short, allrows = true)
cor(comparison_short.occ_prop, comparison_short.range_prop) # 0.955

# Compare original & updated ranges
comparison_diff = @chain comparison_df begin
    filter(:type => ==("carnivore"), _)
    select([:species, :type, :total_occ, :range, :occ_prop, :occ_prop_diff, :range_prop, :range_prop_diff])
end

## Export table

# Wrap as function to export
function export_table(path::String, table::DataFrame)
    # Reformat species names
    table.species .= replace.(table.species, "_" => " ")

    # Format as Markdown table
    table = latexify(table, env=:mdtable, fmt="%.3f", latex=false, escape_underscores=true)

    # Export to file
    open(path, "w") do io
        print(io, table)
    end

    # Fix digits
    lines = readlines(path; keep=true)
    open(path, "w") do io
        for line in lines
            line = replace(line, " 0.000" => " x.xxx")
            line = replace(line, ".000" => "")
            line = replace(line, " x.xxx" => " 0.000")
            print(io, line)
        end
    end
end

# Export selected tables
export_table(joinpath("tables", "gbif_proportions.md"), comparison_short)
export_table(joinpath("tables", "gbif_difference.md"), comparison_diff)

## Plot results

# Separate carnivores & herbivores
carnivores = filter(:type => ==("carnivore"), comparison_df)
herbivores = filter(:type => ==("herbivore"), comparison_df)

# Set plot options to reuse
options = (
    group=carnivores.species,
    ylim=(-0.03, 1.0),
    markershape=[:circle :rect :star5 :diamond :star4 :pentagon :star7 :utriangle :ltriangle],
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

# 1. Pixel proportion according to original IUCN range
prop_fig = scatter(
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

# 2. Range proportion difference with updated layers
comparison_stack = @chain comparison_df begin
    @subset(:type .== "carnivore")
    @select(:species, :range_prop, :range_prop_updated)
    stack([:range_prop, :range_prop_updated])
end

diff_fig = @df comparison_stack plot(
    replace.(:species, "_" => " "),
    :value;
    group=:species,
    line=(:arrow, 1.5),
    xrotation=45,
    legend=false,
    ylim=(-0.03, 1.0),
    ylabel="Proportion of GBIF pixels inside ranges",
    markershape=[:circle :rect :star5 :diamond :star4 :pentagon :star7 :utriangle :ltriangle],
    markersize=8,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    bottommargin=5.0mm,
    dpi=600,
)
savefig(joinpath("figures", "gbif_range-diff.png"))

# 3. Two-panel figure
plot(
    prop_fig,
    diff_fig;
    size=(1200, 450),
    dpi=600,
    leftmargin=35px,
    bottommargin=50px
)
savefig(joinpath("figures", "gbif_panels.png"))

## Plot all species distributions with GBIF observations on top
for i in eachindex(mammals)
    plot(;
        frame=:box,
        xlim=extrema(longitudes(ranges[i])),
        ylim=extrema(latitudes(ranges[i])),
        dpi=500,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50); c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(ranges[i]; c=:turku, colorbar=:none)
    scatter!(
        occ_df_recent[occ_df_recent.species .== mammals[i], :longitude],
        occ_df_recent[occ_df_recent.species .== mammals[i], :latitude];
        markerstrokewidth=0,
        markeralpha=0.5,
        markersize=2,
        title=replace(mammals[i], "_" => " "),
        legend=:none,
    )
    savefig(joinpath("figures", "ranges", "iucn_gbif" * mammals[i] * ".png"))
end

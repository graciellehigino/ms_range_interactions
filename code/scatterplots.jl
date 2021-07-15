using Base: get_preferences
using Plots.PlotMeasures


# Relationship between beta-diversities, colored by absolute loss of range
scatter(
    test_df.Rab,
    test_df.Rbb;
    xlabel="predator to prey beta diversity",
    ylabel="prey to predator beta diversity",
    marker_z=test_df.δ,
    markercolor=:sun,
    markerstrokewidth=0,
    size=(1000, 600),
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    xlim=[0, 1.0],
    label="predator range difference",
    foreground_color_legend=nothing,
    background_color_legend=:seashell,
)
savefig(joinpath("figures", "beta-div_pred-range-diff.png"))

# Relationship between beta-diversities, colored by absolute loss of range
# (log); markersize equals numer of cells where the predator *y* do not cooccur
# with a prey *x*
scatter(
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rab .< 1.0, :Rab],
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rbb .< 1.0, :Rbb];
    xlabel="predator to prey geographic dissimilarity",
    ylabel="prey to predator geographic dissimilarity",
    marker_z=-ranges_degrees_df.relative/100,
    markersize= log.(ranges_degrees_df.nbA),
    markercolor=:sun,
    markerstrokewidth=0,
    markeralpha=0.7,
    size=(1000, 600),
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    label="range without prey",
    #foreground_color_legend=nothing,
    legend = :right,
    background_color_legend=:white,
)
savefig(joinpath("figures", "betadiv-pred_range_diff-each_prey.png"))


# Relationship between beta-diversities, colored by relative loss of range,
# without "extreme cases"
scatter(
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rab .< 1.0, :Rab],
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rbb .< 1.0, :Rbb];
    xlabel="predator to prey geographic dissimilarity",
    ylabel="prey to predator geographic dissimilarity",
    marker_z=ranges_degrees_df.relative,
    markercolor=:sun,
    markerstrokewidth=0,
    size=(1000, 600),
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    xlim=[0, 1.0],
    label="predator range difference",
    legend = :right,
    foreground_color_legend=:lightgrey,
    background_color_legend=:white,
)
savefig(joinpath("figures", "beta-div_pred-range-diff-rel.png"))

# Relationship between beta-diversities, grouped by predator species
scatter(
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rab .< 1.0, :Rab],
    ranges_degrees_df[0.0 .< ranges_degrees_df.Rbb .< 1.0, :Rbb],
    regression = true,
    xlabel="predator to prey geographic dissimilarity",
    ylabel="prey to predator geographic dissimilarity",
    group=ranges_degrees_df[0.0 .< ranges_degrees_df.Rbb .< 1.0, :species],
    markershape=[:circle :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=3,
    linewidth = 4,
    palette = cgrad(:seaborn_colorblind)[[1, 3:9...]],
    markerstrokewidth=0,
    size=(800, 800),
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    legend = :right,
    foreground_color_legend=:lightgrey,
    background_color_legend=:white,
    aspect_ratio = :equal
)
savefig(joinpath("figures", "beta-div_pred-species.png"))

# Relative loss in range size vs. out degree
scatter(
    ranges_degrees_df.degree,
    ranges_degrees_df.relative .* -1;
    xlabel="Out degree of predators",
    ylabel="Relative loss of range",
    marker_z=ranges_degrees_df.old_range,
    markercolor=:sun,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    label="predators' original range",
    legend=:topright,
    foreground_color_legend=:lightgrey,
    background_color_legend=:white,
)
savefig(joinpath("figures", "rel_loss-out_degree-orig_range.png"))

# Out degree vs. relative lost in range size, colored by species
scatter(
    ranges_degrees_df.degree,
    ranges_degrees_df.relative .* -1;
    xlabel="Out degree of predators",
    ylabel="Relative loss of range",
    group=ranges_degrees_df.species,
    markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=6,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    legend=:topright,
    foreground_color_legend=:lightgrey,
    background_color_legend=:white,
    size=(1000, 600)
)
savefig(joinpath("figures", "rel_loss-outdegree-species.png"))

# Number of preys vs. original range - all species
scatter(
    all_sp_df.n_preys,
    all_sp_df.old_range ./ 10^4;
    xlabel="Out degree of species",
    ylabel="Original range (x 10km²)",
    markersize=3,
    markercolor=:orangered2,
    markerstrokewidth=0,
    left_margin=4mm,
    right_margin=6mm,
    top_margin=6mm,
    bottom_margin=3mm,
    legend=:none
)
scatter!(
    ranges_degrees_df.degree,
    ranges_degrees_df.old_range ./ 10^4;
    markercolor = :teal,
    markerstrokewidth = 0,
    markersize = 3,
    markershape = :rect
)
savefig(joinpath("figures", "outdegree-orig_range.png"))

# Number of preys vs. original range - only predators
scatter(
    ranges_degrees_df.degree,
    ranges_degrees_df.old_range ./ 10^4;
    xlabel="Out degree of predators",
    ylabel="Original range (x 10^4)",
    group=ranges_degrees_df.species,
    markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=4,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    left_margin=5mm,
    right_margin=5mm,
    top_margin=5mm,
    bottom_margin=5mm,
    legend=:topright,
    legendfontsize = 6,
    foreground_color_legend=nothing,
    background_color_legend=:white,
)
savefig(joinpath("figures", "outdegree_predators-orig_range-species.png"))

# In-degree vs. relative lost in range size, symbols are species and colors are original range size
scatter(
    ranges_degrees_df.relative .* -1,
    ranges_degrees_df.degree,
    xlabel="Relative range loss (%)",
    ylabel="Out-degree of predators (n)",
    marker_z=log.(ranges_degrees_df.old_range),
    markercolor=:sun,
    group=ranges_degrees_df.species,
    markershape = [:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle],
    markersize= 6,
    palette = :Dark2_8,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=15mm,
    top_margin=10mm,
    bottom_margin=10mm, 
    size=(1000, 600),
    legend=:topright,
    foreground_color_legend=:lightgrey,
    background_color_legend=:white,
    annotate = (128,10,text("Original range size (km²)", 12,  rotation = 270))
)
savefig(joinpath("figures", "rel_lost-in_degree-species-and-range.png"))

# Exploring occurrences
i_ex = indexin(["Canis_aureus"], mammals)[1]
plot(;
    frame=:box,
    xlim=extrema(longitudes(delta_Sxy_layer)),
    ylim=extrema(latitudes(delta_Sxy_layer)),
    dpi=500,
    xaxis="Longitude",
    yaxis="Latitude",
)
plot!(worldshape(50); c=:lightgrey, lc=:lightgrey, alpha=0.6)
plot!(ranges[i_ex]; c=:turku, colorbar=:none)
scatter!(
    occ_df[occ_df.species .== mammals[i_ex], :longitude],
    occ_df[occ_df.species .== mammals[i_ex], :latitude];
    markerstrokewidth=0,
    markeralpha=0.5,
    markersize=2,
    title=replace(mammals[i_ex], "_" => " "),
    legend=:none,
)
savefig(joinpath("figures", "ranges", "iucn_gbif_ex.png"))

for i in eachindex(mammals)
    plot(;
        frame=:box,
        xlim=extrema(longitudes(delta_Sxy_layer)),
        ylim=extrema(latitudes(delta_Sxy_layer)),
        dpi=500,
        xaxis="Longitude",
        yaxis="Latitude",
    )
    plot!(worldshape(50); c=:lightgrey, lc=:lightgrey, alpha=0.6)
    plot!(ranges[i]; c=:turku, colorbar=:none)
    scatter!(
        occ_df[occ_df.species .== mammals[i], :longitude],
        occ_df[occ_df.species .== mammals[i], :latitude];
        markerstrokewidth=0,
        markeralpha=0.5,
        markersize=2,
        title=replace(mammals[i], "_" => " "),
        legend=:none,
    )
    savefig(joinpath("figures", "ranges", "iucn_gbif" * mammals[i] * ".png"))
end


# TABLES ----- 
original_range # all species and their original ranges
sp_degrees # all species and their degrees
new_ranges_df # New ranges where species have at least one prey
table1 = leftjoin(original_range, new_ranges_df, on=:species)
table1 = leftjoin(table1, sp_degrees, on=:species)
table1 = leftjoin(table1, DataFrame(species = species(M), trophic_levels = floor.(values(trophic_level(M)))), on = :species)
sort!(table1, :trophic_levels, rev=true)

using Latexify
table1.species .= replace.(table1.species, "_" => " ")
table1 = latexify(table1, env=:mdtable, fmt="%.0f", latex=false)
print(table1) # copy & save to file

# Export to file
table_path = joinpath("tables", "range_proportions.md")
open(table_path, "w") do io
    print(io, table1)
end


using Base: get_preferences
using Plots.PlotMeasures

test_df = copy(cooccurrence_beta)
rename!(test_df, :spA => "species")
test_df = leftjoin(test_df, predator_ranges; on=:species)
test_df = leftjoin(test_df, mammal_degree_df; on=:species)

all_sp_df = copy(original_range)
all_sp_df = leftjoin(all_sp_df, sp_outdegree_df; on=:species)

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
savefig("figures/beta-div_pred-range-diff.png")

# Relationship between beta-diversities, colored by relative loss of range
scatter(
    test_df.Rab,
    test_df.Rbb;
    xlabel="predator to prey beta diversity",
    ylabel="prey to predator beta diversity",
    marker_z=test_df.relative,
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
savefig("figures/beta-div_pred-range-diff-rel.png")

# Relationship between beta-diversities, grouped by predator species
scatter(
    test_df.Rab,
    test_df.Rbb;
    xlabel="predator to prey beta diversity",
    ylabel="prey to predator beta diversity",
    group=test_df.species,
    markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=6,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    size=(1000, 600),
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    foreground_color_legend=nothing,
    background_color_legend=:seashell,
)
savefig("figures/beta-div_pred-species.png")

# Relative loss in range size vs. out degree
scatter(
    test_df.degree,
    test_df.relative .* -1;
    xlabel="Out degree of predators",
    ylabel="Relative loss of range",
    marker_z=test_df.old_range,
    markercolor=:sun,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    label="predators' original range",
    legend=:topright,
    foreground_color_legend=nothing,
    background_color_legend=:white,
)
savefig("figures/rel_loss-out_degree-orig_range.png")

# Out degree vs. relative lost in range size, colored by species
scatter(
    test_df.degree,
    test_df.relative .* -1;
    xlabel="Out degree of predators",
    ylabel="Relative loss of range",
    group=test_df.species,
    markershape=[:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle :ltriangle],
    markersize=6,
    palette=:seaborn_colorblind,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm,
    legend=:topright,
    foreground_color_legend=nothing,
    background_color_legend=:seashell,
)
savefig("figures/rel_loss-outdegree-species.png")

# Number of preys vs. original range - all species
scatter(
    all_sp_df.n_preys,
    all_sp_df.old_range ./ 10^4;
    xlabel="Out degree of species",
    ylabel="Original range (x 10km²)",
    markersize=3,
    markercolor=:sun,
    markerstrokewidth=0,
    left_margin=4mm,
    right_margin=6mm,
    top_margin=6mm,
    bottom_margin=3mm,
    legend=:none
)
scatter!(
    test_df.degree,
    test_df.old_range ./ 10^4;
    markercolor = :mediumpurple1,
    markerstrokewidth = 0,
    markersize = 3,
    markershape = :rect
)
savefig("figures/outdegree-orig_range.png")

# Number of preys vs. original range - only predators
scatter(
    test_df.degree,
    test_df.old_range ./ 10^4;
    xlabel="Out degree of predators",
    ylabel="Original range (x 10^4)",
    group=test_df.species,
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
savefig("figures/outdegree_predators-orig_range-species.png")

# In-degree vs. relative lost in range size, symbols are species and colors are original range size
scatter(
    test_df.relative .* -1,
    test_df.degree,
    xlabel="Relative range loss (%)",
    ylabel="In-degree of predators (n)",
    marker_z=test_df.old_range,
    markercolor=:sun,
    group=test_df.species,
    markershape = [:circle :rect :star5 :diamond :star4 :cross :xcross :utriangle],
    markersize= 6,
    palette = :Dark2_8,
    markerstrokewidth=0,
    left_margin=10mm,
    right_margin=10mm,
    top_margin=10mm,
    bottom_margin=10mm, 
    legend=:topright,
    foreground_color_legend=nothing,
    background_color_legend=:seashell,
    annotate = (128,10,text("Original range size (km²)", 12,  rotation = 270))
)
savefig("figures/rel_lost-in_degree-species-and-range.png")

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
savefig("figures/iucn_gbif_ex.png")

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
    savefig(joinpath("figures", "iucn_gbif" * mammals[i] * ".png"))
end


# TABLES ----- 
original_range # all species and their original ranges
sp_degrees # all species and their degrees
new_ranges_df # New ranges where species have at least one prey
table1 = leftjoin(original_range, new_ranges_df, on=:species)
table1 = leftjoin(table1, sp_degrees, on=:species)


# cooccurrence_interact.nbA # number of pixels with no preys
# cooccurrence_interact.nbB # number of pixels with no predators
# pred_has_prey = combine(groupby(cooccurrence_interact, :spA), :nbA=>sum=>:pred_has_prey) # cells where only predators occur
# rename!(pred_has_prey, :spA => "species")
# prey_has_pred = combine(groupby(cooccurrence_interact, :spB), :nbB=>sum=>:prey_has_pred) # cells where only prey occur
# rename!(prey_has_pred, :spB => "species")
# table1_preds = leftjoin(pred_has_prey, prey_has_pred, on=:species) # predators and preys of predators
# table1_preys = leftjoin(prey_has_pred, pred_has_prey, on=:species) # predators and preys of predators
# table1_preds_preys = unique(vcat(table1_preds, table1_preys, cols=:union), :species)
# table1 = leftjoin(table1, table1_preds_preys, on=:species)
# table1 = coalesce.(table1, 0)
# table1.pred_has_prey = table1.pred_has_prey .* 100 ./ table1.old_range
# table1.prey_has_pred = table1.prey_has_pred .* 100 ./ table1.old_range
# table1.pred_has_prey .= ifelse.(table1.pred_has_prey .> 100.00, 100.00, table1.pred_has_prey)
# table1.prey_has_pred .= ifelse.(table1.prey_has_pred .> 100.00, 100.00, table1.prey_has_pred)
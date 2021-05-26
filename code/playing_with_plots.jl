using Plots.PlotMeasures

test_df = copy(cooccurrence_beta)
rename!(test_df, :spA => "species")
test_df = leftjoin(test_df, predator_ranges; on=:species)
test_df = leftjoin(test_df, mammal_degree_df; on=:species)

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
# savefig("figures/beta-div_pred-range-diff.png")

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
# savefig("figures/beta-div_pred-range-diff-rel.png")

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
# savefig("figures/beta-div_pred-species.png")

# In-degree vs. relative loss in range size
scatter(
    test_df.relative .* -1,
    test_df.degree;
    xlabel="relative loss of range",
    ylabel="in-degree of predators",
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
    background_color_legend=:seashell,
)
# savefig("figures/rel_lost-in_degree-orig_range.png")

# In-degree vs. relative lost in range size, colored by species
scatter(
    test_df.relative .* -1,
    test_df.degree;
    xlabel="relative loss of range",
    ylabel="in-degree of predators",
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
# savefig("figures/rel_lost-in_degree-species.png")

# Exploring occurrences
i_ex = indexin(["Canis_aureus"], names(names_df))[1]
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
    occ_gbif_iucn[occ_gbif_iucn.species .== names(names_df)[i_ex], :latitude],
    occ_gbif_iucn[occ_gbif_iucn.species .== names(names_df)[i_ex], :longitude];
    markerstrokewidth=0,
    markeralpha=0.5,
    markersize=2,
    title=names(names_df)[i_ex],
    legend=:none,
)
# savefig("figures/iucn_gbif_ex.png")

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
        occ_gbif_iucn[occ_gbif_iucn.species .== names(names_df)[i], :latitude],
        occ_gbif_iucn[occ_gbif_iucn.species .== names(names_df)[i], :longitude];
        markerstrokewidth=0,
        markeralpha=0.5,
        markersize=2,
        title=names(names_df)[i],
        legend=:none,
    )
    savefig(joinpath("figures", "iucn_gbif" * names(names_df)[i] * ".png"))
end

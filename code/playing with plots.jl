using Plots.PlotMeasures

test_df = cooccurrence_beta
rename!(test_df, :spA => "species")
test_df=leftjoin(test_df, predator_ranges, on=:species)
test_df = leftjoin(test_df, mammal_degree_df, on=:species)

# Relationship between beta-diversities, colored by absolute lost of range
scatter(test_df.Rab, test_df.Rbb, xlabel="predator to prey beta diversity", ylabel="prey to predator beta diversity", marker_z=test_df.δ, markercolor=:sun, markerstrokewidth=0, size=(1000,600), left_margin=10mm, right_margin=10mm, top_margin=10mm, bottom_margin=10mm, xlim=[0,1.0], label="predator range difference", foreground_color_legend=nothing, background_color_legend=:seashell)
# savefig("figures/beta-div_pred-range-diff.png")

# Relationship between beta-diversities, colored by relative lost of range
scatter(test_df.Rab, test_df.Rbb, xlabel="predator to prey beta diversity", ylabel="prey to predator beta diversity", marker_z=test_df.relative, markercolor=:sun, markerstrokewidth=0, size=(1000,600), left_margin=10mm, right_margin=10mm, top_margin=10mm, bottom_margin=10mm, xlim=[0,1.0], label="predator range difference", foreground_color_legend=nothing, background_color_legend=:seashell)
# savefig("figures/beta-div_pred-range-diff-rel.png")

# In-degree vs. relative lost in range size
scatter(test_df.relative .* -1, test_df.degree, xlabel="relative lost of range", ylabel="in-degree of predators", marker_z=test_df.old_range, markercolor=:sun, markerstrokewidth=0, left_margin=10mm, right_margin=10mm, top_margin=10mm, bottom_margin=10mm, label="predators' original range", legend=:topright, foreground_color_legend=nothing, background_color_legend=:seashell)
# savefig("figures/rel_lost-in_degree-orig_range.png")


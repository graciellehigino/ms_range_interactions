test_df = cooccurrence_beta
rename!(test_df, :spA => "species")
test_df=leftjoin(test_df, predator_ranges, on=:species)
scatter(test_df.Rab, test_df.Rbb, xlabel="predator to prey beta diversity", ylabel="prey to predator beta diversity", marker_z=test_df.δ, markercolor=:sun, markerstrokewidth=0, size=(1000,600), left_margin=10mm, right_margin=10mm, top_margin=10mm, bottom_margin=10mm, xlim=[0,1.0], label="predator range difference", foreground_color_legend=nothing, background_color_legend=:seashell)

# savefig("figures/beta-div_pred-range-diff.png")


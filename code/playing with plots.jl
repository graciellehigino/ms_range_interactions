test_df = cooccurrence_beta
rename!(test_df, :spA => "species")
test_df=leftjoin(test_df, ranges_total, on=:species)
scatter(test_df.Rab, test_df.Rbb, xlabel="predator to prey beta diversity", ylabel="prey to predator beta diversity", marker_z=test_df.δ)
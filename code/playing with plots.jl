scatter(cooccurrence_beta.Rab, cooccurrence_beta.Rbb, z=ranges_total.δ)

test_df = cooccurrence_beta
rename!(test_df, :spA => "species")
test_df=leftjoin(test_df, ranges_total, on=:species)
scatter(test_df.Rab, test_df.Rbb, marker_z=test_df.δ, legend=:topright)
short_list = species_lists_c[.!isnothing.(species_lists_c)]
new_ranges_df = DataFrame(species = String[], range = Int64[])

for i in 1:length(short_list)
    for j in 1:length(mammals)
        a = sum(occursin.(mammals[j], short_list[i]))
        push!(new_ranges_df, [mammals[j], sum(a)])
    end
end
new_ranges_df = combine(groupby(new_ranges_df, :species),:range .=> sum)


# old ranges----not quite that
species_lists = Int64[]
for col in eachcol(names_df)
    sp_col = filter(!isnothing, collect(col))
    sp_col = length(sp_col) > 0 ? length(sp_col) : 0
    push!(species_lists, sp_col)
end
species_lists

ranges_total = new_ranges_df
ranges_total.old_ranges = species_lists

# Original range size

#original_range = [sum(.!isnothing.(ranges[i].grid)) for i in 1:length(ranges)]

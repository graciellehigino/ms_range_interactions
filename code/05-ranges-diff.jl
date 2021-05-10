short_list = species_lists_c[.!isnothing.(species_lists_c)]
new_ranges_df = DataFrame(species = String[], range = Int64[])

for i in 1:length(short_list)
    for j in 1:length(mammals)
        a = sum(occursin.(mammals[j], short_list[i]))
        push!(new_ranges_df, [mammals[j], sum(a)])
    end
end
new_ranges_df = combine(groupby(new_ranges_df, :species),:range .=> sum)


# Original range size
original_range = [sum(.!isnothing.(ranges[i].grid)) for i in 1:length(ranges)]

ranges_total = new_ranges_df
filter(:δ => !isequal(0), ranges_total)
ranges_total.original_range = original_range
ranges_total.δ = ranges_total.range_sum - ranges_total.original_range

# Only predators ranges
filter!(x -> x.species ∈ carnivores, ranges_total)

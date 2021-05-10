short_list = species_lists_c[.!isnothing.(species_lists_c)]
new_ranges_df = DataFrame(species = String[], range = Int64[])

for i in 1:length(short_list)
    for j in 1:length(mammals)
        a = sum(occursin.(mammals[j], short_list[i]))
        push!(new_ranges_df, [mammals[j], sum(a)])
    end
end
new_ranges_df = combine(groupby(new_ranges_df, :species),:range .=> sum)
rename!(ranges_total, :range_sum => :new_range)


# Original range size
original_range = DataFrame(species = names(names_df), old_range = [sum(.!isnothing.(ranges[i].grid)) for i in 1:length(ranges)])

ranges_total = new_ranges_df
ranges_total = leftjoin(ranges_total, original_range, on=:species)
ranges_total.δ = ranges_total.new_range - ranges_total.old_range

# Only predators ranges
predator_ranges = filter(x -> x.species ∈ carnivores, ranges_total)

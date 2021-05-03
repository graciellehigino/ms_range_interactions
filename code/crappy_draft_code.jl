new_ranges = SimpleSDMPredictor(species_lists_c)
ranges_list = [Array{Union{Nothing, String}, size(new_ranges.grid)}]
for i in eachindex(species_lists_c)
    for j in 1:length(mammals)
        if isnothing(species_lists_c[[i]])
            ranges_list[i] = nothing
        else
            if mammals[j] in species_lists_c[[i]]
                ranges_list[i] = mammals[j]
                push!(ranges_list)
            end
        end
    end
end



new_ranges_df = DataFrame(new_ranges)
rename!(new_ranges_df, ["longitude", "latitude", replace.(mammals, " " => "_")...])



species_lists = Union{Nothing, Vector{String}}[]
for row in eachcol(names_df)
    sp_row = filter(!isnothing, collect(col))
    sp_row = length(sp_row) > 0 ? Vector{String}(sp_row) : nothing
    push!(species_lists, sp_row)
end
species_lists

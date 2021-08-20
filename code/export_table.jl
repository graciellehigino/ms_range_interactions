## Export as markdown table

using CSV
using DataFrames
using Latexify

# Load ranges results & species groups
results = CSV.read(joinpath("data", "clean", "range_proportions.csv"), DataFrame)
sp_groups = CSV.read(joinpath("data", "species_groups.csv"), DataFrame)

# Fix the formatting
results.species .= replace.(results.species, "_" => " ")
for col in [:prop_preys, :prop_preds]
    results[!, col] = replace(results[!, col], missing => "-")
end
results

# Reorder species by the groups from Baskerville 2011
results = results |>
    x -> leftjoin(sp_groups, x, on=:species) |>
    x -> sort(x, [:group, :species]) |>
    x -> select(x, Not([:group, :description]))

# Rename columns
rename!(
    results,
    "species" => "Species",
    # "description" => "Group",
    "n_preys" => "Number of preys",
    "n_preds" => "Number of predators",
    "total_range_size" => "Total range size",
    "prop_preys" => "Proportion of range occupied by preys",
    "prop_preds" => "Proportion of range occupied by predators"
)

# Format as Markdown table
table = latexify(results, env=:mdtable, fmt="%.3f", latex=false, escape_underscores=true)

# Export to file
table_path = joinpath("tables", "table_ranges.md")
open(table_path, "w") do io
    print(io, table)
end

## Fix the digits

# Digits for integers are wrong (42.000 instead of 42)
# However, we can't just remove the .000 as we have some 0.000 we want to keep
# So we'll first change the 0.000 to x.xxx, fix the integers, then bring back the 0.000
# We'll also convert the remaining missing values to 0 at the end (as integers, not 0.000)
lines = readlines(table_path; keep=true)
open(table_path, "w") do io
    for line in lines
        line = replace(line, " 0.000" => " x.xxx")
        line = replace(line, ".000" => "")
        line = replace(line, " x.xxx" => " 0.000")
        line = replace(line, "missing" => "0")
        print(io, line)
    end
end

## Column widths

# Columns widths are determined by the longest string in each column
# This makes the proportion columns way too wide compared to the species column
# To fix it, we can change the 2nd line with the | -----:| signs
# The number of - determines the column width
# This is a combination which looked fine
lines = readlines(table_path; keep=true)
open(table_path, "w") do io
    for line in lines
        line = startswith(line, "| --") ? "| ----------------------:| -------:| -------:| -------:| ----------:| ----------:|\n" : line
        print(io, line)
    end
end

## Add species groups

# Species are sorted by the groups from Baskerville (2011), e.g. small/large carnivores
# We'll add the group description before the first species in that group

# Find the first species in each group
first_species = unique(sp_groups, :description)

# Find the lines that correspond
lines = readlines(table_path; keep=true)
group_lines_inds = [findfirst(contains(sp), lines) for sp in first_species.species]
group_lines = lines[group_lines_inds]

# Add the group descriptions
open(table_path, "w") do io
    for line in lines
        if line == group_lines[1] # first one goes directly after the header
            # Get the group
            group = first_species.description[line .== group_lines][1]
            # Add the group (without an empty line)
            line = "| **$(group)** | | | | | |\n$(line)"
        elseif line in group_lines[2:end] # other ones need an empty line first
            # Get the group
            group = first_species.description[line .== group_lines][1]
            # Add the group (with an empty line)
            line = "| | | | | | |\n| **$(group)** | | | | | |\n$(line)"
        end
        print(io, line)
    end
end

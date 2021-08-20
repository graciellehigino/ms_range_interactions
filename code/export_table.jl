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

# Fix digits
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

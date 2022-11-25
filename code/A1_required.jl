## Load required scripts and packages
import Pkg; Pkg.activate("."); Pkg.instantiate()

using Combinatorics
using CSV
using DataFramesMeta
using Dates
using EcologicalNetworks
using GBIF
using GLM
using JLD2
using Latexify
using Plots
using Plots.PlotMeasures
using Shapefile
using SimpleSDMLayers
using SparseArrays
using Statistics
using StatsBase
using StatsPlots

include("A2_shapefile.jl") # mapping functions

## Objects needed in most scripts

# This is the bounding box we care about
bounding_box = (left=-20.0, right=55.0, bottom=-35.0, top=40.0);

# Get the list of mammals
mammals = readlines(joinpath("data", "clean", "mammals.csv"));
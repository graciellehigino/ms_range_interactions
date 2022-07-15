## Load required scripts and packages
import Pkg; Pkg.activate("."); Pkg.instantiate()

using Combinatorics
using CSV
using DataFramesMeta
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
using StatsPlots

include("A2_shapefile.jl") # mapping functions
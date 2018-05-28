using Distributions
using Turing
using Stan
include(splitdir(Base.@__DIR__)[1]*"/benchmarks/benchmarkhelper.jl")

# NOTE: put Stan models before Turing ones if you want to compare them in print_log
model_list = ["gdemo-geweke",
              #"normal-loc",
              "normal-mixture",
              "gdemo",
              "gauss",
              "bernoulli",
              #"negative-binomial",
              "school8",
              "binormal",
              "kid"]

benchmakr_turing(model_list)

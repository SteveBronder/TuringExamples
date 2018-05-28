using Distributions
using Turing
using Stan

include(splitdir(Base.@__DIR__)[1]*"/benchmarks/benchmarkhelper.jl")
include(splitdir(Base.@__DIR__)[1]*"/stan-models/bernoulli-stan.data.jl")
include(splitdir(Base.@__DIR__)[1]*"/stan-models/bernoulli.model.jl")

tbenchmark("HMC(10, 0.25, 5)", "bermodel", "data=berstandata[1]")

bench_res = tbenchmark("HMC(1000, 0.25, 5)", "bermodel", "data=berstandata[1]")
logd = build_logd("Bernoulli Model", bench_res...)


include(splitdir(Base.@__DIR__)[1]*"/benchmarks/"*"bernoulli-stan.run.jl")
logd["stan"] = Dict("theta" => mean(theta_stan))
logd["time_stan"] = ber_time

print_log(logd)

using Requests
import Requests: get, post, put, delete, options, FileParam
send_log(logd)

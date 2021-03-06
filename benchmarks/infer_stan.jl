alg = CmdStan.Hmc(
    CmdStan.Static(n_steps * step_size),
    CmdStan.diag_e(),
    step_size,
    0.0,
)

model = Stanmodel(
    model=model_str, 
    nchains=1,
    Sample(
        algorithm=alg,
        num_warmup=0,
        num_samples=2_000,
        adapt=CmdStan.Adapt(engaged=false),
        save_warmup=true,
    ),
    printsummary=false,
    output_format=:array
)

if "--benchmark" in ARGS
    using Statistics: mean, std
    clog = "MODEL_NAME" in keys(ENV)    # cloud logging flag
    if clog
        # Setup W&B
        using PyCall: pyimport
        wandb = pyimport("wandb")
        wandb.init(project="turing-benchmark")
        wandb.config.update(Dict("ppl" => "stan", "model" => ENV["MODEL_NAME"]))
    end
    n_runs = 3
    times = []
    for i in 1:n_runs
        status, chain = stan(model, data, summary=false)
        # Parse inference time from log
        tl = read(pipeline(`tail tmp/noname_run.log`, `rg "s \(S"`), String)
        t = parse(Float64, match(r"[0-9]+.[0-9]+", tl).match)
        clog && wandb.log(Dict("time" => t))
        push!(times, t)
    end
    t_mean = mean(times)
    t_std = std(times)
    println("Benchmark results")
    println("  Running time: $t_mean +/- $t_std ($n_runs runs)")
    if clog
        wandb.run.summary.time_mean = t_mean
        wandb.run.summary.time_std  = t_std
    end
else
    @time status, chain = stan(model, data, summary=false)
end
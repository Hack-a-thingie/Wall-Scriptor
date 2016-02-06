#!/usr/bin/julia 
using DataFrames

df = readtable("data.csv")

df1 = by(df, :pid) do df
      times = df[:time]
      dt = Array(Int64, size(times, 1)-1)
      for i in 1:size(dt, 1)
        t0 = times[i]
        t1 = times[i+1]

        dt[i] = t1-t0
      end
      DataFrame(μ = mean(dt), var = var(dt), min = minimum(times))
end

stimes = df1[:min]
mdts = Array(Int64, size(stimes, 1)-1)

for i in 1:size(mdts, 1)
  t0 = stimes[i]
  t1 = stimes[i+1]

  mdts[i] = t1-t0
end

println("Mean ΔT: ", mean(mdts))
println("Var ΔT: ", var(mdts))
println("Mean of mean δt: ", mean(df1[:μ]))
println("Var of mean δt: ", var(df1[:μ]))
println("Mean of var δt: ", mean(df1[:var]))
println("Var of var δt: ", var(df1[:var]))


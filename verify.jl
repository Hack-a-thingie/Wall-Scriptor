using DataFrames

df = readtable("data.csv")
times = df[:, 1]

dt = Array(Int64, size(times, 1)-1)

for i in eachindex(dt)
  t0 = times[i]
  t1 = times[i+1]

  dt[i] = t1-t0
end

λ = 1000_000/mean(dt)
@show λ

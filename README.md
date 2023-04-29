# MeanFilters

[![Build Status](https://github.com/jw3126/MeanFilters.jl/workflows/CI/badge.svg)](https://github.com/jw3126/MeanFilters.jl/actions)
[![Coverage](https://codecov.io/gh/jw3126/MeanFilters.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jw3126/MeanFilters.jl)

The goal of this package is to solve one very narrow problem: compute the mean over a sliding window:

```julia
julia> using MeanFilters: meanfilter

julia> meanfilter([1,2,3,4], (-1:1,))
4-element Vector{Float64}:
 1.5
 2.0
 3.0
 3.5

julia> meanfilter([1 2 3; 4 5 6], (0:0,-1:1))
2×3 Matrix{Float64}:
 1.5  2.0  2.5
 4.5  5.0  5.5
```

In most cases you likely want to use [ImageFiltering.jl](https://github.com/JuliaImages/ImageFiltering.jl) instead. Advantages of this package over [ImageFiltering.jl](https://github.com/JuliaImages/ImageFiltering.jl) are:
* Tiny dependency
* Specialized algorithm for mean, which has decent performance for large windows:
```julia
using ImageFiltering
using BenchmarkTools
using MeanFilters

arr = randn(1000, 1000)
window = (-50:50, -20:20)
ker = fill(1/prod(length, window), window...)
out1 = @btime imfilter(arr, ker, NA())
out2 = @btime meanfilter(arr, window)
@assert out1 ≈ out2
```
```
  45.249 ms (443 allocations: 109.50 MiB)
  3.074 ms (247 allocations: 15.28 MiB)
```

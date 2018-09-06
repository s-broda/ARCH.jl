# Reference Manual
## Index

```@index
```

## Public API
```@meta
DocTestSetup = quote
    using ARCH
    using Random
    Random.seed!(1)
end
DocTestFilters = r".*[0-9\.]"
```

```@docs
ARCHModel
MeanSpec
VolatilitySpec
_ARCH
GARCH
EGARCH
StandardizedDistribution
StdNormal
StdTDist
simulate
simulate!
fit
fit!
selectmodel
```

```@meta
DocTestSetup = nothing
DocTestFilters = nothing
```
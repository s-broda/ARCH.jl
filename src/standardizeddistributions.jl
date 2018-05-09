abstract type StandardizedDistribution <: Distribution{Univariate, Continuous} end

function fit(::Type{SD}, data::Vector{T}, algorithm=BFGS; kwargs...) where {SD<:StandardizedDistribution, T<:AbstractFloat}
    obj = x -> -loglik(SD, data, x)
    lower, upper = constraints(SD, T)
    x0 = startingvals(SD, data)
    res = optimize(obj, x0, lower, upper, Fminbox{algorithm}(); kwargs...)
    coefs = res.minimizer
    return SD(coefs...)
end

struct StdNormal{T} <: StandardizedDistribution
    StdNormal{T}() where {T} = new{T}()
end
StdNormal(T::Type=Float64) = StdNormal{T}()
rand(::StdNormal{T}) where {T} = randn(T)
@inline logkernel(::Type{StdNormal}, x, coefs) = -abs2(x)/2
@inline logconst(::Type{StdNormal}, coefs)  =  -log2π/2
nparams(::Type{StdNormal}) = 0
fit(::Type{StdNormal}, data::Vector{T}) where {T<:AbstractFloat} = StdNormal(T)

function constraints(::Type{StdNormal}, ::Type{T})  where {T}
    lower = T[]
    upper = T[]
    return lower, upper
end

struct StdTDist{T} <: StandardizedDistribution
    ν::T
    StdTDist{T}(ν::T) where {T} = (ν>2 ? new{T}(ν) : error("degrees of freedom must be greater than 2."))
end
StdTDist(ν::T) where {T} = StdTDist{T}(ν)
StdTDist(ν::Integer) = StdTDist(float(ν))
rand(d::StdTDist) = tdistrand(d.ν)*sqrt((d.ν-2)/d.ν)
@inline logkernel(::Type{StdTDist}, x, coefs) = (-(coefs[1] + 1) / 2) * log(1 + x^2 / (coefs[1]-2))
@inline logconst(::Type{StdTDist}, coefs)  =  lgamma((coefs[1] + 1) / 2) - log((coefs[1]-2) * pi) / 2 - lgamma(coefs[1] / 2)
nparams(::Type{StdTDist}) = 1

function constraints(::Type{StdTDist}, ::Type{T}) where {T}
    lower = T[2]
    upper = T[Inf]
    return lower, upper
end

startingvals(::Type{StdTDist}, data::Array{T}) where {T} = T[5]

function loglik(::Type{SD}, data::Vector{<:AbstractFloat}, coefs::Vector{T2}) where {SD<:StandardizedDistribution, T2}
    T = length(data)
    length(coefs) == nparams(SD) || throw(NumParamError(nparams(SD), length(coefs)))
    @inbounds begin
        LL = zero(T2)
        @fastmath for t = 1:T
            LL += logkernel(SD, data[t], coefs)
        end#for
    end#inbounds
    LL +=  T*logconst(SD, coefs)
end#function
struct Spherical{T<:AbstractFloat} <: Number
    lat::T
    lon::T
end

# constructors
function Spherical{T}(z::Spherical{S}) where {T<:AbstractFloat,S}
    U = promote_type(T, S)
    return Spherical{T}(convert(U, z.lat), convert(U, z.lon))
end

function Spherical{T}(z::Complex{S}) where {T<:AbstractFloat,S}
    Tz = Complex{T}(z)
    return Spherical{T}(latitude(Tz), angle(Tz))
end

function Spherical{T}(z::Polar{S}) where {T<:AbstractFloat,S}
    Tz = Polar{T}(z)
    return Spherical{T}(latitude(Tz), angle(Tz))
end

function Spherical{T}(z::Number) where {T<:AbstractFloat}
    θ, ϕ = latitude(T(z)), angle(T(z))
    return Spherical{T}(θ, ϕ)
end

# Constructors without subtype
"""
	Spherical(latitude, azimuth)
Construct a spherical representation with given `latitude` in [-π/2,π/2] and `azimuth`.
"""
function Spherical(θ::Real, ϕ::Real)
    θ, ϕ = promote(float(θ), float(ϕ))
    Spherical{typeof(θ)}(θ, ϕ)
end

"""
    Spherical(z)
Construct a spherical representation of the value `z`.
"""
Spherical(z::Number) = Spherical(latitude(z), angle(z))

# one and zero
one(::Type{Spherical{T}}) where {T<:Real} = Spherical{T}(zero(T), zero(T))
one(::Type{Spherical}) = one(Spherical{Float64})
zero(::Type{Spherical{T}}) where {T<:Real} = Spherical{T}(-T(π) / 2, zero(T))
zero(::Type{Spherical}) = zero(Spherical{Float64})

# conversion into standard complex
function Complex(z::Spherical{S}) where {S<:Real}
    if iszero(z)
        zero(Complex{S})
    else
        cot((π - 2z.lat) / 4) * cis(z.lon)
    end
end

"""
	S2coord(u::Spherical)
Convert the spherical value to a 3-vector of coordinates on the unit sphere.
"""
S2coord(u::Spherical) = [cos(u.lat) * [cos(u.lon), sin(u.lon)]; sin(u.lat)]

# basic arithmetic
function +(u::Spherical, v::Spherical)
    if isinf(u)
        isinf(v) ? NaN : u
    elseif isinf(v)
        v
    else
        Spherical(Complex(u) + Complex(v))  # faster way?
    end
end
-(u::Spherical) = Spherical(u.lat, cleanangle(u.lon + π))
-(u::Spherical, v::Spherical) = u + (-v)
*(u::Spherical, v::Spherical) = Spherical(Polar(u) * Polar(v))   # faster way?
inv(u::Spherical) = Spherical(-u.lat, cleanangle(-u.lon))
/(u::Spherical, v::Spherical) = u * inv(v)

# π/2 is converted to Float64, so avoid it
latitude(z::Number) = (π - 4 * acot(abs(z))) / 2

# common complex overloads
angle(u::Spherical) = cleanangle(u.lon)
function abs(z::Spherical{T}) where {T}
    if iszero(z)
        zero(T)
    elseif isinf(z)
        T(Inf)
    else
        cot((π - 2z.lat) / 4)
    end
end
abs2(u::Spherical) = abs(u)^2
real(u::Spherical) = abs(u) * cos(u.lon)
imag(u::Spherical) = abs(u) * sin(u.lon)
conj(u::Spherical) = Spherical(u.lat, -u.lon)
sign(u::Spherical) = Spherical(zero(u.lat), u.lon)

real_type(::Spherical{T}) where {T} = T
real_type(::Type{Spherical{T}}) where {T} = T

# numerical comparisons
iszero(u::Spherical{T}) where T = u.lat == -T(π) / 2
isinf(u::Spherical{T}) where T = u.lat == T(π) / 2
isfinite(u::Spherical) = ~isinf(u)
isapprox(u::Spherical, v::Spherical; args...) = S2coord(u) ≈ S2coord(v)

# pretty output
show(io::IO, z::Spherical) = print(io, "(latitude = $(z.lat / π)⋅π, angle = $(z.lon / π)⋅π)")
show(io::IO, ::MIME"text/plain", z::Spherical) = print(io, "Complex Spherical: ", z)

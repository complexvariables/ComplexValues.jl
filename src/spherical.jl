struct Spherical{T<:Real} <: Number
	lat::T
	lon::T
end

# constructors
mod_to_spherelat(r) = π/2 - 2*acot(r)
function Spherical{T}(z::Number) where T<:Real
	r,ϕ = abs(z),angle(z)
	θ = mod_to_spherelat(r)
	Spherical{T}(convert(T,θ),convert(T,ϕ))
end
#Spherical(θ::T,ϕ::T) where {T<:Real} = Spherical{T}(θ,ϕ)  # automatic, from type def
Spherical(θ::Real,ϕ::Real) = Spherical(promote(θ,ϕ)...)
Spherical(z::Complex{T}) where {T<:Integer} = Spherical{Float64}(z)
Spherical(z::Complex{T}) where {T<:Real} = Spherical{T}(z)
Spherical(z::Real) = Spherical(complex(z,0))
#Spherical{T}(z::Spherical{T}) where {T} = z    # automatic, for Number

one(::Type{Spherical{T}}) where T<:Real = Spherical{T}(zero(T),zero(T))
one(::Type{Spherical}) = one(Spherical{Float64})
zero(::Type{Spherical{T}}) where T<:Real = Spherical{T}(T(-π/2),zero(T))
zero(::Type{Spherical}) = zero(Spherical{Float64})
inf(::Type{Spherical{T}}) where T<:Real = Spherical{T}(T(π/2),zero(T))
inf(::Type{Spherical}) = inf(Spherical{Float64})
inf(::Type{Spherical{T}},ϕ::Real) where T<:Real = Spherical{T}(T(π/2),T(ϕ))
inf(::Type{Spherical},ϕ::Real) = inf(Spherical{typeof(ϕ)},ϕ)


# conversion into standard complex
function Complex(z::Spherical{S}) where S<:Real
	if iszero(z)
		zero(Complex{S})
	elseif isfinite(z)
		cot(π/4-z.lat/2)*exp(Complex(zero(z.lon),z.lon))
	else
		Complex{S}(Inf)
	end
end

# basic arithmetic
+(u::Spherical,v::Spherical) = Spherical(Complex(u)+Complex(v))  # faster way?
-(u::Spherical) = Spherical(u.lat,u.lon+π)
-(u::Spherical,v::Spherical) = u + (-v)
*(u::Spherical,v::Spherical) = Spherical(Polar(u)*Polar(v))   # faster way?
inv(u::Spherical) = Spherical(-u.lat,-u.lon)
/(u::Spherical,v::Spherical) = u*inv(v)

# Common complex overloads
angle(u::Spherical) = u.lon
function abs(z::Spherical{T}) where T
	if iszero(z)
		zero(T)
	elseif isinf(z)
		T(Inf)
	else
		cot(π/4-z.lat/2)
	end
end
abs2(u::Spherical) = abs(u)^2
real(u::Spherical) = abs(u)*cos(u.lat)
imag(u::Spherical) = abs(u)*sin(u.lat)
conj(u::Spherical) = Spherical(u.lat,-u.lon)
sign(u::Spherical) = Spherical(zero(u.lat),u.lon)

iszero(u::Spherical) = u.lat == convert(typeof(u.lat),-π/2)
isinf(u::Spherical) = u.lat == convert(typeof(u.lat),π/2)
isfinite(u::Spherical) = ~isinf(u)
isapprox(u::Spherical,v::Spherical,args...) = isapprox(u.lat,v.lat,args...) & isapprox(u.lon.v.lon,args...)

# pretty output
show(io::IO,z::Spherical) = print(io,"(latitude = $(z.lat/pi)⋅π, angle = $(z.lon/pi)⋅π)")
show(io::IO,::MIME"text/plain",z::Spherical) = print(io,"Complex Spherical: ",z)
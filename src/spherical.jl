struct Spherical{T<:AbstractFloat} <: Number
	lat::T
	lon::T
end

# constructors
Spherical{T}(z::Spherical{T}) where {T<:AbstractFloat} = z

latitude(z::Number) = π/2 - 2*acot(abs(z))
function Spherical{T}(z::Number) where T<:AbstractFloat
	θ,ϕ = latitude(z),angle(z)
	Spherical{T}(convert(T,θ),convert(T,ϕ))
end

# Constructors without subtype
function Spherical(θ::Real,ϕ::Real) 
	θ,ϕ = promote(float(θ),float(ϕ))
	Spherical{typeof(θ)}(θ,ϕ)
end
Spherical(z::Number) = Spherical(latitude(z),angle(z))

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
	else
		cot(π/4-z.lat/2) * exp(complex(zero(z.lon),z.lon))
	end
end

# basic arithmetic
function +(u::Spherical,v::Spherical)
	if isinf(u) 
		isinf(v) ? NaN : u
	elseif isinf(v)
		v 
	else	
		Spherical(Complex(u)+Complex(v))  # faster way?
	end
end
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
real(u::Spherical) = abs(u)*cos(u.lon)
imag(u::Spherical) = abs(u)*sin(u.lon)
conj(u::Spherical) = Spherical(u.lat,-u.lon)
sign(u::Spherical) = Spherical(zero(u.lat),u.lon)

iszero(u::Spherical) = u.lat == convert(typeof(u.lat),-π/2)
isinf(u::Spherical) = u.lat == convert(typeof(u.lat),π/2)
isfinite(u::Spherical) = ~isinf(u)
S2coord(u::Spherical) = [cos(u.lat)*[cos(u.lon),sin(u.lon)];sin(u.lat)]
isapprox(u::Spherical,v::Spherical;args...) = S2coord(u) ≈ S2coord(v)

# pretty output
show(io::IO,z::Spherical) = print(io,"(latitude = $(z.lat/pi)⋅π, angle = $(z.lon/pi)⋅π)")
show(io::IO,::MIME"text/plain",z::Spherical) = print(io,"Complex Spherical: ",z)

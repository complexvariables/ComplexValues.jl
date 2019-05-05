struct Sphere{T<:Real} <: Number
	lat::T
	lon::T
end

# constructors
mod_to_spherelat(r) = π/2 - 2*acot(r)
function Sphere{T}(z::Number) where T<:Real
	r,ϕ = abs(z),angle(z)
	θ = mod_to_spherelat(r)
	Sphere{T}(convert(T,θ),convert(T,ϕ))
end
#Sphere(θ::T,ϕ::T) where {T<:Real} = Sphere{T}(θ,ϕ)  # automatic, from type def
Sphere(θ::Real,ϕ::Real) = Sphere(promote(θ,ϕ)...)
Sphere(z::Complex{T}) where {T<:Integer} = Sphere{Float64}(z)
Sphere(z::Complex{T}) where {T<:Real} = Sphere{T}(z)
Sphere(z::Real) = Sphere(Complex(z))
#Sphere{T}(z::Sphere{T}) where {T} = z    # automatic, for Number

one(::Type{Sphere{T}}) where T<:Real = Sphere{T}(zero(T),zero(T))
one(::Type{Sphere}) = one(Sphere{Float64})
zero(::Type{Sphere{T}}) where T<:Real = Sphere{T}(T(-π/2),zero(T))
zero(::Type{Sphere}) = zero(Sphere{Float64})
inf(::Type{Sphere{T}}) where T<:Real = Sphere{T}(T(π/2),zero(T))
inf(::Type{Sphere}) = inf(Sphere{Float64})
inf(::Type{Sphere{T}},ϕ::Real) where T<:Real = Sphere{T}(T(π/2),T(ϕ))
inf(::Type{Sphere},ϕ::Real) = inf(Sphere{typeof(ϕ)},ϕ)


# conversion into standard complex
function Complex(z::Sphere{S}) where S<:Real
	if iszero(z)
		zero(Complex{S})
	elseif isfinite(z)
		cot(π/4-z.lat/2)*exp(Complex(zero(z.lon),z.lon))
	else
		Complex{S}(Inf)
	end
end

# basic arithmetic
+(u::Sphere,v::Sphere) = Sphere(Complex(u)+Complex(v))  # faster way?
-(u::Sphere) = Sphere(u.lat,u.lon+π)
-(u::Sphere,v::Sphere) = u + (-v)
*(u::Sphere,v::Sphere) = Sphere(Polar(u)*Polar(v))   # faster way?
inv(u::Sphere) = Sphere(-u.lat,-u.lon)
/(u::Sphere,v::Sphere) = u*inv(v)

# Common complex overloads
angle(u::Sphere) = u.lon
function abs(z::Sphere{T}) where T
	if iszero(z)
		zero(T)
	elseif isinf(z)
		T(Inf)
	else
		cot(π/4-z.lat/2)
	end
end
abs2(u::Sphere) = abs(u)^2
real(u::Sphere) = abs(u)*cos(u.lat)
imag(u::Sphere) = abs(u)*sin(u.lat)
conj(u::Sphere) = Sphere(u.lat,-u.lon)

iszero(u::Sphere) = u.lat == convert(typeof(u.lat),-π/2)
isinf(u::Sphere) = u.lat == convert(typeof(u.lat),π/2)
isfinite(u::Sphere) = ~isinf(u)
isapprox(u::Sphere,v::Sphere,args...) = isapprox(u.lat,v.lat,args...) & isapprox(u.lon.v.lon,args...)

# pretty output
show(io::IO,z::Sphere) = print(io,"(latitude = $(z.lat/pi)⋅π, angle = $(z.lon/pi)⋅π)")
show(io::IO,::MIME"text/plain",z::Sphere) = print(io,"Sphere: ",z)

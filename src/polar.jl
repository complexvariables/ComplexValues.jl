struct Polar{T<:AbstractFloat} <: Number
	mod::T
	ang::T
	function Polar{T}(r::Real,ϕ::Real) where {T<:AbstractFloat}
		if r < 0
			@error "Cannot create Polar number with negative modulus"
		else
			new(T(r),T(ϕ))
		end
	end
end

# Constructors
Polar{T}(z::Polar{T}) where {T<:AbstractFloat} = z
Polar{T}(z::Number) where {T<:AbstractFloat} = Polar{T}(T(abs(z)),T(angle(z)))

# Constructors without subtype
function Polar(r::S,ϕ::T) where {S<:Real,T<:Real}
	r,ϕ = promote(float(r),float(ϕ))
	Polar{typeof(r)}(r,ϕ)
end
Polar(z::Number) = Polar(abs(z),angle(z))

one(::Type{Polar{T}}) where T<:AbstractFloat = Polar{T}(one(T),zero(T))
one(::Type{Polar}) = one(Polar{Float})
zero(::Type{Polar{T}}) where T<:AbstractFloat = Polar{T}(zero(T),zero(T))
zero(::Type{Polar}) = zero(Polar{Float})
inf(::Type{Polar{T}}) where T<:AbstractFloat = Polar{T}(T(Inf),zero(T))
inf(::Type{Polar}) = inf(Polar{Float})
inf(::Type{Polar{T}},ϕ::Real) where T<:AbstractFloat = Polar{T}(T(Inf),T(ϕ))
inf(::Type{Polar},ϕ::Real) = inf(Polar{typeof(ϕ)},ϕ)

# conversions 
function Complex(z::Polar{S}) where S
	# the following allows NaN angles to be ignored for 0 
	if iszero(z)
		zero(Complex{S})
	elseif isinf(z)
		throw(InexactError(:Complex,Complex,z))
	else
		z.mod*exp(Complex(zero(S),z.ang))
	end
end

# Basic arithmetic
function +(u::Polar,v::Polar)
	if isinf(u) 
		isinf(v) ? NaN : u
	elseif isinv(v)
		v 
	else	
		Polar(Complex(u)+Complex(v))  # faster way?
	end
end
-(u::Polar) = Polar(u.mod,u.ang+π)
-(u::Polar,v::Polar) = u + (-v)
*(u::Polar,v::Polar) = Polar(u.mod*v.mod,cleanangle(u.ang+v.ang))
inv(u::Polar) = Polar(inv(u.mod),-u.ang)
/(u::Polar,v::Polar) = u * inv(v)

# Common complex overloads
angle(u::Polar) = u.ang
abs(u::Polar) = u.mod
abs2(u::Polar) = u.mod^2
real(u::Polar) = u.mod*cos(u.ang)
imag(u::Polar) = u.mod*sin(u.ang)
conj(u::Polar) = Polar(u.mod,-u.ang)
sign(u::Polar) = Polar(one(u.mod),u.ang)

iszero(u::Polar) = iszero(u.mod)
isinf(u::Polar) = isinf(u.mod)
isfinite(u::Polar) = isfinite(u.mod)
isapprox(u::Polar,v::Polar;args...) = isapprox(u.mod,v.mod;args...) && isapprox(u.ang,v.ang;args...)

# pretty output
show(io::IO,z::Polar) = print(io,"(modulus = $(z.mod), angle = $(z.ang/pi)⋅π)")
show(io::IO,::MIME"text/plain",z::Polar) = print(io,"Complex Polar: ",z)

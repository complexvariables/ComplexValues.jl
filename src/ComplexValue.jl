module ComplexValue

export inf

# Individually overloaded operators
import Base: Complex,iszero,isapprox,isinf,isfinite,one,zero
import Base: +,-,*,/,sign,inv,angle,abs,abs2,real,imag,conj,show

# Utilities
cleanangle(θ) = π - mod(π-θ,2π)  # map angle to equivalent in (-pi,pi]

# Definitions of the types
include("sphere.jl")
include("polar.jl")
include("homogeneous.jl")

AbstractComplex = Union{Complex,Polar,Homogeneous,Sphere}
AbstractNonnative = Union{Polar,Homogeneous,Sphere}
AllValues = Union{Number,AbstractNonnative}

+(u::AllValues,v::AllValues) = +(promote(u,v)...)
-(u::AllValues,v::AllValues) = -(promote(u,v)...)
*(u::AllValues,v::AllValues) = *(promote(u,v)...)
/(u::AllValues,v::AllValues) = /(promote(u,v)...)
/(u::AllValues,v::AllValues,args...) = isapprox(promote(u,v)...,args...)
one(z::AbstractNonnative) = one(typeof(z))
zero(z::AbstractNonnative) = zero(typeof(z))
inf(z::AbstractNonnative) = inf(typeof(z))

# promotion rules and conversion boilerplate
import Base: promote_rule
promote_rule(::Union{Type{Complex{S}},Type{S}},::Type{Sphere{T}}) where {S<:Real,T<:Real} = Sphere{promote_type(S,T)}
promote_rule(::Union{Type{Complex{S}},Type{S}},::Type{Homogeneous{T}}) where {S<:Real,T<:Real} = Homogeneous{promote_type(S,T)}
promote_rule(::Union{Type{Complex{S}},Type{S}},::Type{Polar{T}}) where {S<:Real,T<:Real} = Polar{promote_type(S,T)}
promote_rule(::Union{Type{Sphere{S}},Type{Polar{S}}},::Type{Homogeneous{T}}) where {S<:Real,T<:Real} = Homogeneous{promote_type(S,T)}
promote_rule(::Type{Polar{S}},::Type{Sphere{T}}) where {S<:Real,T<:Real} = Polar{T}

# convert() boilerplate to invoke constructors
import Base.convert
convert(::Type{Complex{S}},z::AbstractNonnative) where S<:Real = convert(Complex{S},Complex(z))
# convert(::Type{Complex{S}},z::Homogeneous{T}) where {S<:Real,T<:Real} = convert(Complex{S},Complex(z))
# convert(::Type{Sphere{T}},z::Number) where T = Sphere{T}(Complex(z))
# convert(::Type{Homogeneous{T}},z::Number) where T = Homogeneous{T}(z)
# convert(::Type{Homogeneous{S}},z::Sphere{T}) where {S,T} = Homogeneous{S}(Complex(z))
# convert(::Type{Homogeneous{S}},z::Polar{T}) where {S,T} = Homogeneous{S}(Complex(z))
# convert(::Type{Sphere{S}},z::Homogeneous{T}) where {S,T} = Sphere{S}(Complex(z))
# convert(::Type{Sphere{S}},z::Polar{T}) where {S,T} = Sphere{S}(Complex(z))

convert(::Type{Polar{S}},z::AbstractNonnative) where S<:Real = Polar{S}(z)
convert(::Type{Polar{S}},z::Number) where S<:Real = Polar{S}(Complex(z))
convert(::Type{Sphere{S}},z::AbstractNonnative) where S<:Real = Sphere{S}(z)
convert(::Type{Sphere{S}},z::Number) where S<:Real = Sphere{S}(Complex(z))
convert(::Type{Homogeneous{S}},z::AbstractNonnative) where S<:Real = Homogeneous{S}(z)
convert(::Type{Homogeneous{S}},z::Number) where S<:Real = Homogeneous{S}(Complex(z))

# Fallback constructor is to use Complex as an intermediary. Types can overload this with specifc cases.
Polar{S}(z::AbstractNonnative) where S<:Real = Polar{S}(Complex(z))
Sphere{S}(z::AbstractNonnative) where S<:Real = Sphere{S}(Complex(z))
Homogeneous{S}(z::AbstractNonnative) where S<:Real = Homogeneous{S}(Complex(z))

function Sphere(z::Homogeneous) 
	if isfinite(z)
		Sphere(Complex(z)) 
	else
		Sphere(π/2,angle(z))
	end
end
Polar(z::Sphere) = Polar(abs(z),z.lon)

# Most other 1-argument and 2-argument base functions just get converted to regular complex
for f in [:cos,:sin,:tan,:sec,:csc,:cot,:acos,:asin,:atan,:asec,:acsc,:acot,:sincos,:sinpi,
	:cosh,:sinh,:tanh,:sech,:csch,:coth,:acosh,:asinh,:atanh,:asech,:acsch,:acoth,
	:exp,:exp10,:exp2,:expm1,:log,:log10,:log1p,:log2,:sqrt]
	quote
		import Base: $f 
		$f(z::AbstractNonnative) = $f(Complex(z))
	end |> eval
end

for f in [:log,:^]
	quote
		import Base: $f 
		$f(z::AbstractNonnative,w::AbstractNonnative) = $f(Complex(z),Complex(w))
	end |> eval
end

end # module

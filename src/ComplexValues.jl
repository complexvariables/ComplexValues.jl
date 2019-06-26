module ComplexValues

export inf,Polar,Spherical

# Individually overloaded operators
import Base: Complex,complex,float,iszero,isapprox,isinf,isfinite,one,zero
import Base: +,-,*,/,sign,inv,angle,abs,abs2,real,imag,conj,show

# Utilities
cleanangle(θ) = π - mod(π-θ,2π)  # map angle to equivalent in (-pi,pi]
Float = typeof(1.)  # default base type 

# Definitions of the types
include("spherical.jl")
include("polar.jl")
include("plotrecipes.jl")

AbstractComplex{T<:AbstractFloat} = Union{Complex{T},Polar{T},Spherical{T}}
AbstractNonnative{T<:AbstractFloat} = Union{Polar{T},Spherical{T}}
#AllValues = Union{Number,AbstractNonnative}

# +(u::AllValues,v::AllValues) = +(promote(u,v)...)
# -(u::AllValues,v::AllValues) = -(promote(u,v)...)
# *(u::AllValues,v::AllValues) = *(promote(u,v)...)
# /(u::AllValues,v::AllValues) = /(promote(u,v)...)
# /(u::AllValues,v::AllValues,args...) = isapprox(promote(u,v)...,args...)
#one(z::AbstractNonnative) = one(typeof(z))
#zero(z::AbstractNonnative) = zero(typeof(z))
inf(z::AbstractNonnative) = inf(typeof(z))
complex(z::AbstractNonnative) = z
float(z::AbstractNonnative) = z

# promotion rules and conversion boilerplate
import Base: promote_rule
promote_rule(::Union{Type{Complex{S}},Type{S}},::Type{Spherical{T}}) where {S<:Real,T<:AbstractFloat} = Spherical{promote_type(S,T)}
promote_rule(::Union{Type{Complex{S}},Type{S}},::Type{Polar{T}}) where {S<:Real,T<:AbstractFloat} = Polar{promote_type(S,T)}
promote_rule(::Type{Polar{S}},::Type{Spherical{T}}) where {S<:AbstractFloat,T<:AbstractFloat} = Polar{promote_type(S,T)}

# convert() boilerplate to invoke constructors
import Base.convert
convert(::Type{Complex{S}},z::AbstractNonnative) where S<:Real = convert(Complex{S},Complex(z))
convert(::Type{Polar{S}},z::AbstractNonnative) where S<:AbstractFloat = Polar{S}(z)
convert(::Type{Polar{S}},z::Number) where S<:AbstractFloat = Polar{S}(Complex(z))
convert(::Type{Spherical{S}},z::AbstractNonnative) where S<:AbstractFloat = Spherical{S}(z)
convert(::Type{Spherical{S}},z::Number) where S<:AbstractFloat = Spherical{S}(Complex(z))

# Fallback conversion is to use Complex as an intermediary. Types can overload this with specifc cases.
Polar{S}(z::AbstractNonnative) where S<:AbstractFloat = Polar{S}(Complex(z))
Spherical{S}(z::AbstractNonnative) where S<:AbstractFloat = Spherical{S}(Complex(z))

Spherical(z::Polar{T}) where {T<:AbstractFloat} = Spherical{T}(z)
Polar(z::Spherical) = Polar(abs(z),z.lon)

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

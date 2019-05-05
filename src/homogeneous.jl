struct Homogeneous{T<:Real} <: Number
    num::Complex{T}
    den::Complex{T}
end

# Constructors
Homogeneous{T}(z::Number) where {T<:Real} = isinf(z) ? Homogeneous{T}(sign(z),0) : Homogeneous{T}(Complex(z),one(Complex(z)))
Homogeneous(num::Number,den::Number) = Homogeneous(promote(num,den)...)
Homogeneous(num::Real,den::Real) = Homogeneous(Complex(num,zero(num)),Complex(den,zero(den)))
Homogeneous(z::Number) = Homogeneous(z,one(z))

one(::Type{Homogeneous{T}}) where T<:Real = Homogeneous{T}(one(T),one(T))
one(::Type{Homogeneous}) = one(Homogeneous{Float64})
zero(::Type{Homogeneous{T}}) where T<:Real = Homogeneous{T}(zero(T),one(T))
zero(::Type{Homogeneous}) = zero(Homogeneous{Float64})
inf(::Type{Homogeneous{T}}) where T<:Real = Homogeneous{T}(one(T),zero(T))
inf(::Type{Homogeneous}) = inf(Homogeneous{Float64})

# conversion into standard complex
Complex(w::Homogeneous{S}) where S = w.den==0 ? S(Inf) : w.num/w.den

# Basic arithmetic
+(u::Homogeneous,v::Homogeneous) = Homogeneous(u.num*v.den+u.den*v.num,u.den*v.den)
-(u::Homogeneous) = Homogeneous(-u.num,u.den)
-(u::Homogeneous,v::Homogeneous) = u + (-v)
*(u::Homogeneous,v::Homogeneous) = Homogeneous(u.num*v.num,u.den*v.den)
inv(u::Homogeneous) = Homogeneous(u.den,u.num)
/(u::Homogeneous,v::Homogeneous) = u * inv(v)

# Common complex overloads
angle(u::Homogeneous) = cleanangle(angle(u.num) - angle(u.den));
abs(u::Homogeneous) = abs(Complex(u))
abs2(u::Homogeneous) = abs2(Complex(u))
conj(u::Homogeneous) = Homogeneous(conj(u.num),conj(u.den))

isinf(u::Homogeneous) = iszero(u.den) & !iszero(u.num)
isfinite(u::Homogeneous) = !isinf(u)

show(io::IO,z::Homogeneous) = print(io,"( $(z.num) ) / ( $(z.den) )")
show(io::IO,::MIME"text/plain",z::Homogeneous) = print(io,"Homogeneous: ",z)

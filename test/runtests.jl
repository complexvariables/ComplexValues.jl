using ComplexValues
const Spherical = ComplexValues.Spherical
const Polar = ComplexValues.Polar

using Test

@testset "Constructions of Polar" begin
    @test Polar(-5 + 1im) isa Number
    @test Polar(1.0im) isa Number
    @test Polar(-2) isa Number
    @test Polar(10.0f0) isa Number
    @test Polar(2.0f0, pi) isa Number
    @test Polar(pi, pi) isa Number
    @test real_type(Polar(1, 2)) == Float64
    @test real_type(Polar{Float32}(1, 2)) == Float32
end

@testset "Constructions of Spherical" begin
    @test Spherical(-5 + 1im) isa Number
    @test Spherical(1.0im) isa Number
    @test Spherical(-2) isa Number
    @test Spherical(10.0f0) isa Number
    @test Spherical(2.0f0, pi) isa Number
    @test Spherical(pi / 2, pi) isa Number
    @test real_type(Spherical(1)) == Float64
    @test real_type(Spherical{Float32}(1)) == Float32
    @test S2coord(Spherical(1)) ≈ [1, 0, 0]
end

@testset "Conversions between Polar, Spherical in $T" for T in (Float64, Float32, BigFloat)
    for z in [-T(5) + 1im, T(1)*1im, -T(2), T(10), Polar(6, -T(pi) / 5), Spherical(1, T(1//2))]
        @test Polar(Spherical(z)) ≈ z
    end
    for z in [5 + 1im, 1im, -2, 10]
        zz = complex(T(real(z)),T(imag(z)))
        @test Polar(Spherical{T}(z)) ≈ zz
    end
end

@testset "Conversions in and out of Complex in $T" for T in (Float64, BigFloat)
    for z in [-5 + 1im, 1im, -2, 10, Polar(Inf, -T(pi) / 5), Spherical{T}(1, 1//2)]
        @test Polar(convert(Complex{T}, z)) ≈ Polar{T}(z)
        @test convert(Complex{T}, Polar{T}(z)) ≈ convert(Complex{T}, z)
        @test Spherical(convert(Complex{T}, z)) ≈ Spherical(z)
        @test convert(Complex{T}, Spherical(z)) ≈ convert(Complex{T}, z)
    end
end

@testset "Conversions between floating types" begin
    T = Float64
    for z in [-5 + 1im, 1im, -2, 10, Polar(Inf, -T(pi) / 5), Spherical{T}(1, 1//2)]
        @test convert(Polar{Float32}, z) ≈ Polar{Float32}(z)
        @test convert(Spherical{Float32}, z) ≈ Spherical{Float32}(z)
    end
end

@testset "Zero and infinity for $T,$S" for T in [Polar, Spherical], S = (Float64, BigFloat)
    z = T{S}(Inf)
    @test isinf(z)
    @test isinf(abs(z))
    @test iszero(1 / z)
    @test iszero(abs(inv(z)))
    @test iszero(Complex(4 / z))
    z = T{S}(0)
    @test iszero(z)
    @test isinf(3im / z)
    z = zero(T{S})
    @test iszero(z)
    @test isinf(3im / z)
end

@testset "Binary functions on $S, $T, $F" for S in [Polar, Spherical], T in [Polar, Spherical], F in (Float64, Float32, BigFloat)
    u = S(complex(F(3), F(5)))
    v = T(complex(F(-5), F(1)))
	ε = 100eps(F)
    @test Complex(u + v) ≈ Complex(u) + Complex(v) atol=ε rtol=ε
    @test Complex(u * v) ≈ Complex(u) * Complex(v) atol=ε rtol=ε
    @test Complex(u / v) ≈ Complex(u) / Complex(v) atol=ε rtol=ε
    @test Complex(u - v) ≈ Complex(u) - Complex(v) atol=ε rtol=ε
    @test Complex(u^v) ≈ Complex(u)^Complex(v) atol=ε rtol=ε
end

@testset "Unary functions on $T, $F" for T in [Polar, Spherical], F in (Float64, Float32, BigFloat)
    u = T(complex(F(3), F(5)))
    @test Complex(u - 4) ≈ Complex(u) - 4
    @test Complex(4 - u) ≈ 4 - Complex(u)
    @test Complex(cos(exp(u))) ≈ cos(exp(Complex(u)))
    @test Complex(sqrt(inv(u))) ≈ sqrt(inv(Complex(u)))
end

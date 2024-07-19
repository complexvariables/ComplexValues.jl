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
end

@testset "Constructions of Spherical" begin
    @test Spherical(-5 + 1im) isa Number
    @test Spherical(1.0im) isa Number
    @test Spherical(-2) isa Number
    @test Spherical(10.0f0) isa Number
    @test Spherical(2.0f0, pi) isa Number
    @test Spherical(pi / 2, pi) isa Number
    @test S2coord(Spherical(1)) ≈ [1, 0, 0]
end

@testset "Conversions between Polar, Spherical" begin
    for z in [-5 + 1im, 1.0im, -2, 10.0f0, Polar(Inf, -pi / 5), Spherical(1, 0.5)]
        @test Polar(Spherical(z)) ≈ z
    end
    for z in [-5 + 1im, 1.0im, -2, 10.0f0]
        @test Polar{Float64}(Spherical{Float64}(z)) ≈ z
    end
end

@testset "Conversions in and out of Complex" begin
    for z in [-5 + 1im, 1.0im, -2, 10.0f0, Polar(Inf, -pi / 5), Spherical(1, 0.5)]
        @test Polar(Complex(z)) ≈ Polar(z)
        @test Complex(Polar(z)) ≈ Complex(z)
        @test Spherical(Complex(z)) ≈ Spherical(z)
        @test Complex(Spherical(z)) ≈ Complex(z)
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

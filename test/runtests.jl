using ComplexValues
const Spherical = ComplexValues.Spherical
const Polar = ComplexValues.Polar

using Test

@testset "Constructions of Polar" begin
	@test Polar(-5+1im) isa Number
	@test Polar(1.0im) isa Number
	@test Polar(-2) isa Number
	@test Polar(10.0f0) isa Number
	@test Polar(2.0f0,pi) isa Number
	@test Polar(pi,pi) isa Number
end

@testset "Constructions of Spherical" begin
	@test Spherical(-5+1im) isa Number
	@test Spherical(1.0im) isa Number
	@test Spherical(-2) isa Number
	@test Spherical(10.0f0) isa Number
	@test Spherical(2.0f0,pi) isa Number
	@test Spherical(pi/2,pi) isa Number
end

@testset "Zero and infinity for $T" for T in [Polar,Spherical]
    z = inf(T)
    @test isinf(z)
    @test isinf(abs(z))
    @test iszero(1/z)
    @test iszero(abs(inv(z)))
    @test isinf(Complex(z))
    @test iszero(Complex(4/z))
    z = T(0)
    @test iszero(z)
    @test isinf(3im/z)
    z = zero(T)
    @test iszero(z)
    @test isinf(3im/z)
end

@testset "Binary functions on $S,$T" for S in [Polar,Spherical], T in [Polar,Spherical]
	u = S(3.0+5.0im)
	v = T(-5+1im)
	@test Complex(u+v) ≈ Complex(u)+Complex(v)
	@test Complex(u*v) ≈ Complex(u)*Complex(v)
	@test Complex(u/v) ≈ Complex(u)/Complex(v)
	@test Complex(u-v) ≈ Complex(u)-Complex(v)
	@test Complex(u^v) ≈ Complex(u)^Complex(v)
end

@testset "Unary functions on $T" for T in [Polar,Spherical]
    u = T(3.0+5.0im)
    @test Complex(u-4) ≈ Complex(u)-4
    @test Complex(4-u) ≈ 4-Complex(u)
    @test Complex(cos(exp(u))) ≈ cos(exp(Complex(u)))
    @test Complex(sqrt(inv(u))) ≈ sqrt(inv(Complex(u)))
end

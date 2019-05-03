using ComplexValue
const Homog = ComplexValue.Homogeneous
const Sphere = ComplexValue.Sphere
const Polar = ComplexValue.Polar

using Test
@testset "Binary functions on $S,$T" for S in [Polar,Sphere,Homog], T in [Polar,Sphere,Homog]
	u = S(3.0+5.0im)
	v = T(-5+1im)
	@test Complex(u+v) ≈ Complex(u)+Complex(v)
	@test Complex(u*v) ≈ Complex(u)*Complex(v)
	@test Complex(u/v) ≈ Complex(u)/Complex(v)
	@test Complex(u-v) ≈ Complex(u)-Complex(v)
	@test Complex(u^v) ≈ Complex(u)^Complex(v)
end 

@testset "Unary functions on $T" for T in [Polar,Sphere,Homog]
    u = T(3.0+5.0im)
    @test Complex(u-4) ≈ Complex(u)-4
    @test Complex(4-u) ≈ 4-Complex(u)
    @test Complex(cos(exp(u))) ≈ cos(exp(Complex(u)))
    @test Complex(sqrt(inv(u))) ≈ sqrt(inv(Complex(u)))
end

@testset "Zero and infinity for $T" for T in [Polar,Sphere,Homog]
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

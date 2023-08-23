# ComplexValues

This package provides two additional types for representing complex values in Julia: a `Polar` type for representation in polar coordinates, and a `Spherical` type for representation on the Riemann sphere. 

**Prior to version 0.3**, this package also provided some facility for making plots on the Riemann sphere. That capability (plus much more) now lies in the `ComplexPlots` package.

## Usage notes

- Either of the two new types can be converted to a built-in complex floating number via `Complex`.
- Promotion of any number along with a `Spherical` value results in `Spherical`. 
- Promotion of any built-in number type with a `Polar` results in `Polar`. 
- Standard unary and binary functions in `Base` are extended to work with the new types. 
- The type `AnyComplex{T<:AbstractFloat}` is defined (but not exported) as the union of the built-in `Complex{T}` together with `Polar{T}` and `Spherical{T}`. 

## Examples

```@repl 1
using ComplexValues
Polar(1im)
Polar.(exp.(1im*LinRange(0,2π,6)))
Spherical(Inf)
```
A `Spherical` value can be converted to a 3-vector of coordinates on the unit sphere $S^2$.
```@repl 1
Spherical(0)
S2coord(ans)
```

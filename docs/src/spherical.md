# Spherical

A `Spherical` value stores the latitude and azimuthal angles. For efficiency, the angles are not converted to any standard interval, though some operations on values do so. They can be accessed directly as the `lat` and `lon` (for longitude) fields.

Multiplicative inverse (`inv`) and `sign` of `Spherical` values exploit the structure of the representation. Otherwise, most operations are done by first converting to `Complex`.

The comparators `iszero`, `isinf`, `isfinite`, and `isapprox` are defined appropriately.

```@autodocs
Modules = [ComplexValues]
Order = [:type, :function]
Pages = ["spherical.jl"]
```

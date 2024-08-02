# Polar

A `Polar` value stores the complex modulus and azimuthal angle. For efficiency, the angle is not converted to any standard interval, though some operations on values do so. They can be accessed directly as `mod` and `ang` fields.

Multiplication, division, `abs`, `abs2`, and `sign` of `Polar` values exploit the structure of the representation and should be more efficient than for native complex equivalents. Otherwise, most operations are done by first converting to `Complex`.

The comparators `iszero`, `isinf`, `isfinite`, and `isapprox` are defined appropriately.

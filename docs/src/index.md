# ComplexValues

This package provides two additional types for representing complex values in Julia: a `Polar` type for representation in polar coordinates, and a `Spherical` type for representation on the Riemann sphere. Both types also affect plotting commands in the [Plots](https://github.com/JuliaPlots/Plots.jl) package.

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

### Plots using `Plots`

Plots of `Polar` type are as usual, but on polar axes.

```@example 1 
using Plots  
zc = cispi.(2*(0:500)/500);
plot(Polar.(0.5 .+ zc),legend=false)  
savefig("polar_circle.svg"); nothing # hide
```

![](polar_circle.svg)

```@example 1
zl = collect(LinRange(50-50im,-50+50im,601));
plot(Spherical.(zc/2),l=3,leg=false)  # plot on the Riemann sphere
plot!(Spherical.(-1 .+ zl),l=3)
savefig("sphere_plot.svg"); nothing # hide
```

![](sphere_plot.svg)

(Unfortunately, plotting backends and exports don't consistently support setting the aspect ratio in 3D. I've had success with `plotlyjs()` for interactive plots, though not when exporting them.)

### Plots using `Makie`

Vectors of complex values will be recognized and converted accordingly.

```@example 2
using ComplexValues, CairoMakie  
z = [complex(cospi(t), 0.6*sinpi(t)) for t in (0:200) / 100]
# force 1:1 aspect for real/imag parts
update_theme!(Axis = (autolimitaspect = 1,))
scatter(z, markersize=5)
save("makie_ellipse.svg", current_figure()); nothing # hide
```

![](makie_ellipse.svg)

Use `sphereplot` to plot on the Riemann sphere.

```@example 2
sphereplot(Spherical.(z), markersize=5, line=true)
save("makie_ellipse_sphere.svg", current_figure()); nothing # hide
```

![](makie_ellipse_sphere.svg)

Use `zplot` to make a plot of a complex function. Each location on a grid is colored to show phase and magnitude of the function value.

```@example 2
zplot(z -> (z^3 - 1) / sin(2im - z))
save("makie_zplot.svg", current_figure()); nothing # hide
```

![](makie_zplot.svg)


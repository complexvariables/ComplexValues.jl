export sphereplot, sphereplot!, zplot, zplot!, artist
using .Makie

# Allow plot of any complex vector
z_to_point(z::Complex{T} where T) = Point2f(reim(z)...)
z_to_point(z::Polar{T} where T) = Point2f(reim(z)...)
z_to_point(z::Spherical) = Point3f(S2coord(z)...)
Makie.convert_arguments(::PointBased, z::AbstractVector{<:AnyComplex}) = (z_to_point.(z), )

"""
    sphereplot(z; kw...)
    sphereplot!(ax, z; kw...)
Plot a vector of complex numbers on the Riemann sphere. Keyword arguments are:
* `sphere`: `false` to disable the sphere, or a tuple `(nlat, nlon)` to set the number of latitude and longitude lines.
* `markersize`: size of the markers
* `line`: `true` to connect the markers with lines
"""
function sphereplot(z::AbstractVector{<:Number}; kw...)
    fig = Figure()
    ax = Axis3(fig[1,1], aspect=(1, 1, 1), limits=((-1,1), (-1,1), (-1,1)))
    sphereplot!(ax, z; kw...)
    return fig
end

function sphereplot!(
    ax::Union{GridPosition,Axis3},
    z::AbstractVector{<:Number};
    sphere=(12,7), markersize=20, line=false
    )
    if !isnothing(sphere) && (sphere!=false)
        θ = range(0, 2π, 400)
        c, s = cos.(θ), sin.(θ)
        for φ in range(0, π, sphere[1]+1)[1:end-1]
            lines!(ax, cos(φ)*c, sin(φ)*c, s, color = :lightgray)
        end
        lines!(ax, c, 0*c, s, color = :darkgray)
        φ = range(0, 2π, 400)
        c, s = cos.(φ), sin.(φ)
        for θ in range(-π/2, π/2, sphere[2]+2)[2:end-1]
            lines!(ax, c*cos(θ), s*cos(θ), ones(size(c))*sin(θ), color = :lightgray)
        end
        lines!(ax, c, s, 0*s, color = :darkgray)
    end
    points = map(z) do z
            Point3f(S2coord(z)...)
    end
    if line
        scatterlines!(ax, points; markersize)
    else
        scatter!(ax, points; markersize)
    end
    Makie.hidedecorations!(ax)
    Makie.hidespines!(ax)
    return ax
end

"""
    artist(base=exp(1), colormap=Makie.ColorSchemes.cyclic_mygbm_30_95_c78_n256)
`artist(b)` returns a function that maps a complex number `z` to a color. The hue is
determined by the angle of `z`. The value (lightness) is determined by
    `mod(log(base, abs(z)), 1)`
You can optionally specify any colormap, though a cyclic one is strongly
recommended.
"""
function artist(base=exp(1), colormap=Makie.ColorSchemes.cyclic_mygbm_30_95_c78_n256)
    return function(z)
        s1 = mod(log(base, abs(z)), 1)
        s2 = mod2pi(angle(z)) / 2π
        col = convert(Makie.Colors.HSV, get(colormap, s2, (0, 1)))
        x = 0.6 + 0.4s1
        return Makie.Colors.HSVA(col.h, col.s, x*col.v, 1)
    end
end

"""
    zplot(f, z; coloring=artist())
    zplot(f, xlims=[-4, 4], ylims=[-4, 4], n=800; coloring=artist())
Plot a complex-valued function `f` evaluated over the points in matrix `z`, or on an
`n`×`n` grid over `xlims`×`ylims` in the complex plane. The method for coloring values
is given by the keyword argument `coloring`.

    zplot(z; coloring=artist())
Plot a matrix of complex values coloring according to the function given by the keyword
argument `coloring`. It is presumed that `z` results from evaluation on a grid in the
complex plane.

# Examples
```julia
using ComplexValues, CairoMakie
zplot(z -> (z^3 - 1) / sin(2im - z))
zplot(tanh)
zplot(tanh, coloring=artist(1.5))  # to see more magnitude contours
```
"""
function zplot(args...; kw...)
    fig = Figure(resolution=(1000, 1000))
    ax = Axis(fig[1,1], autolimitaspect=1)
    return Makie.FigureAxisPlot(fig, ax, zplot!(ax, args...; kw...))
end

function zplot!(
    ax::Union{GridPosition,Axis},
    x::AbstractMatrix{<:Number},
    y::AbstractMatrix{<:Number},
    z::AbstractMatrix{<:Number};
    coloring=artist()
    )
    s = coloring.(z)
    return surface!(ax, x, y, zero(x); color=s, shading=false)
end

function zplot!(ax::Union{GridPosition,Axis}, z::AbstractMatrix{<:Number}; kw...)
    return zplot!(ax, real(z), imag(z), z; kw...)
end

function zplot!(
    ax::Union{GridPosition,Axis},
    f::Function,
    xlims=(-4, 4),
    ylims=(-4, 4),
    n=800;
    kw...
    )
    x = [x for x in range(xlims..., 800), y in range(ylims..., n)]
    y = [y for x in range(xlims..., 800), y in range(ylims..., n)]
    return zplot!(ax, f, complex.(x, y); kw...)
end

function zplot!(
    ax::Union{GridPosition,Axis},
    f::Function,
    z::AbstractMatrix{<:AnyComplex};
    kw...
    )
    w = similar(z)
    Threads.@threads for i in eachindex(z)
        w[i] = f(z[i])
    end
    return zplot!(ax, real(z), imag(z), w; kw...)
end

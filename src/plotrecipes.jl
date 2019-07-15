using RecipesBase

@recipe function f(z::Array{Polar{T}}) where T
    projection --> :polar
    angle.(z),abs.(z)
end

@recipe function f(z::Array{Spherical{T}};sphere=true) where T
    delete!(plotattributes,:sphere) 
    markersize --> 1
    aspect_ratio --> 1

    @series begin
        x = [ cos(z.lat)*cos(z.lon) for z in z ]
        y = [ cos(z.lat)*sin(z.lon) for z in z ]
        z = [ sin(z.lat) for z in z ]
        x,y,z
    end

    function latcurves(n=7) 
        lats = π*(1-n:2:n-1)/(2n+2)
        ϕ = π*(-200:200)/200
        [(cos(θ)*cos.(ϕ),cos(θ)*sin.(ϕ),fill(sin(θ),length(ϕ))) for θ in lats]
    end
    
    function loncurves(n=12) 
        θ = π*(-100:100)/200
        longs = 2π*(0:n-1)/n
        [(cos.(θ)*cos(ϕ),cos.(θ)*sin(ϕ),sin.(θ)) for ϕ in longs]
    end    

    if sphere
        for c in latcurves()
            @series begin
                seriestype := :path3d
                color := :lightgray
                linestyle := :solid
                markershape := :none
                label := ""
                c[1],c[2],c[3]
            end
        end

        for c in loncurves()
            @series begin
                seriestype := :path3d
                color := :lightgray
                linestyle := :solid
                markershape := :none
                label := ""
                c[1],c[2],c[3]
            end
        end
    end

end

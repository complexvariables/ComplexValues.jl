push!(LOAD_PATH,"../src")
using Documenter, ComplexValues

makedocs(sitename="ComplexValues.jl",
    format = Documenter.HTML(),
    authors = "Toby Driscoll",
    pages = [
        "Overview" => "index.md",
        "Polar" => "polar.md",
        "Spherical" => "spherical.md"
		],
	modules = [ComplexValues],
    doctest = true
    )

deploydocs(
    repo = "github.com/complexvariables/ComplexValues.jl.git"
#    versions = ["v#.#"],
#    make = nothing
    )

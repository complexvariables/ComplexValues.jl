push!(LOAD_PATH,"../src")
using Documenter, ComplexValues

makedocs(sitename="ComplexValues",
    format = Documenter.HTML(),
    authors = "Toby Driscoll",
    pages = [
        "Home" => "index.md",
        "Polar" => "polar.md",
        "Spherical" => "spherical.md"
		],
	modules = [ComplexValues],
    doctest = true
    )

deploydocs(
    repo = "github.com/ComplexVariables/ComplexValues.jl.git"
#    versions = ["v#.#"],
#    make = nothing
    )

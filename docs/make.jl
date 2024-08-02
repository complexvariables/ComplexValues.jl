import Pkg; Pkg.update("ComplexValues")
using Documenter, ComplexValues

DocMeta.setdocmeta!(ComplexValues, :DocTestSetup, :(using ComplexValues); recursive=true)
makedocs(sitename="ComplexValues.jl",
    format = Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://complexvariables.github.io/ComplexRegions.jl",
        edit_link="master",
        assets=String[],
    ),
    authors = "Toby Driscoll <driscoll@udel.edu>",
    repo = Remotes.GitHub("complexvariables", "ComplexValues.jl"),
    pages = [
        "Overview" => "index.md",
        "Polar" => "polar.md",
        "Spherical" => "spherical.md",
        "API" => "api.md",
		],
	modules = [ComplexValues],
    doctest = true,
    warnonly = true,
    )

deploydocs(
    repo = "github.com/complexvariables/ComplexValues.jl",
    devbranch = "master"
    )

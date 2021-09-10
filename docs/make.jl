using MeanFilters
using Documenter

DocMeta.setdocmeta!(MeanFilters, :DocTestSetup, :(using MeanFilters); recursive=true)

makedocs(;
    modules=[MeanFilters],
    authors="Jan Weidner <jw3126@gmail.com> and contributors",
    repo="https://github.com/jw3126/MeanFilters.jl/blob/{commit}{path}#{line}",
    sitename="MeanFilters.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jw3126.github.io/MeanFilters.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jw3126/MeanFilters.jl",
)

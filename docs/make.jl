using ProToPortal
using Documenter

DocMeta.setdocmeta!(ProToPortal, :DocTestSetup, :(using ProToPortal); recursive = true)

makedocs(;
    modules = [ProToPortal],
    authors = "J S <49557684+svilupp@users.noreply.github.com> and contributors",
    sitename = "ProToPortal.jl",
    format = Documenter.HTML(;
        canonical = "https://svilupp.github.io/ProToPortal.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
        "API Reference" => "reference.md"
    ]
)

deploydocs(;
    repo = "github.com/svilupp/ProToPortal.jl",
    devbranch = "main"
)

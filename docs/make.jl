using ProToPortal
using Documenter, DocumenterVitepress

DocMeta.setdocmeta!(ProToPortal, :DocTestSetup, :(using ProToPortal); recursive = true)

makedocs(;
    modules = [ProToPortal],
    authors = "J S <49557684+svilupp@users.noreply.github.com> and contributors",
    repo = "https://github.com/svilupp/ProToPortal.jl/blob/{commit}{path}#{line}",
    sitename = "ProToPortal.jl",
    ## format = Documenter.HTML(;
    ##     canonical = "https://svilupp.github.io/ProToPortal.jl",
    ##     edit_link = "main",
    ##     assets = String[]
    ## ),
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "https://github.com/svilupp/ProToPortal.jl",
        devbranch = "main",
        devurl = "dev",
        deploy_url = "svilupp.github.io/ProToPortal.jl"
    ),
    warnonly = true, #Documenter.except(:missing_docs),
    draft = false,
    source = "src",
    build = "build",
    pages = [
        "Home" => "index.md",
        "Introduction" => "introduction.md",
        "API Reference" => "reference.md"
    ]
)

deploydocs(;
    repo = "github.com/svilupp/ProToPortal.jl",
    target = "build",
    push_preview = true,
    branch = "gh-pages",
    devbranch = "main"
)

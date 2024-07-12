using Pkg
Pkg.activate(".")
## Required to support semantic caching
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"
using ProToPortal
ProToPortal.launch(8000, "0.0.0.0"; async = false, cached = false, cache_verbose = false)
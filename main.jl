using Pkg
Pkg.activate(".")
using GenieFramework
ENV["GENIE_HOST"] = "0.0.0.0"
ENV["PORT"] = "8000"
ENV["GENIE_ENV"] = "prod"
## include("app.jl") # hack for hot-reloading when fixing things
Genie.Generator.write_secrets_file();
Genie.loadapp();
up(async=false);

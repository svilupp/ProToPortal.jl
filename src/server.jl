"""
    launch(
        port::Int = get(ENV, "PORT", 8000), host::String = get(
            ENV, "GENIE_HOST", "127.0.0.1");
        async::Bool = true, cached::Bool = true, cache_verbose::Bool = false)

Launches ProToPortal in the browser.

Defaults to: `http://127.0.0.1:8000`. 
This is a convenience wrapper around `Genie.up`, to customize the server configuration use `Genie.up()` and `Genie.config`.

# Arguments
- `port::Union{Int, String} = get(ENV, "PORT", "8000")`: The port to launch the server on.
- `host::String = get(ENV, "GENIE_HOST", "127.0.0.1")`: The host to launch the server on.
- `async::Bool = true`: Whether to launch the server asynchronously, ie, in the background.
- `cached::Bool = true`: Whether to use semantic caching of the requests.
- `cache_verbose::Bool = true`: Whether to print verbose information about the caching process.

If you want to remove the cache layer later, you can use `import HTTP; HTTP.poplayer!()`.
"""
function launch(
        port::Union{Int, String} = get(ENV, "PORT", "8000"),
        host::String = get(ENV, "GENIE_HOST", "127.0.0.1");
        async::Bool = true, cached::Bool = true, cache_verbose::Bool = true)
    ## Loads app.jl in the root directory
    Genie.loadapp(pkgdir(ProToPortal))

    ## Enables caching
    ENV["CACHES_VERBOSE"] = cache_verbose ? "true" : "false"
    if cached
        @info "Caching enabled globally (for all requests, see `CacheLayer` module for details). Remove with `HTTP.poplayer!()`"
        HTTP.pushlayer!(CacheLayer.cache_layer)
    end
    ## Convert to INT
    port_ = port isa Integer ? port : tryparse(Int, port)
    @assert port_ isa Integer "Port must be an integer. Provided: $port"
    up(port_, host; async)
end
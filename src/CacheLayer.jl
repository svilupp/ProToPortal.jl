## Define the new caching mechanism as a layer for HTTP
## See documentation [here](https://juliaweb.github.io/HTTP.jl/stable/client/#Quick-Examples)
"""
    CacheLayer

A module providing caching of LLM requests for ProToPortal.

It caches 3 URL paths: 
- `/v1/chat/completions` (for OpenAI API)
- `/v1/embeddings` (for OpenAI API)
- `/v1/rerank` (for Cohere API)

# How to use
You can use the layer directly
`CacheLayer.get(req)`

You can push the layer globally in all HTTP.jl requests
`HTTP.pushlayer!(CacheLayer.cache_layer)`

You can remove the layer later
`HTTP.poplayer!()`

"""
module CacheLayer

using SemanticCaches, HTTP
using PromptingTools: JSON3

const SEM_CACHE = SemanticCache()
const HASH_CACHE = HashCache()

function cache_layer(handler)
    return function (req; kw...)
        VERBOSE = Base.get(ENV, "CACHES_VERBOSE", "true") == "true"
        has_body = (req.body isa IOBuffer ||
                    (req.body isa AbstractVector && !isempty(req.body)))
        if req.method == "POST" && has_body
            body = JSON3.read(copy(req.body))
            ## chat/completions is for OpenAI, v1/messages is for Anthropic
            if occursin("v1/chat/completions", req.target) ||
               occursin("v1/messages", req.target)
                ## We're in chat completion endpoint
                temperature_str = haskey(body, :temperature) ? body[:temperature] : "-"
                cache_key = string("chat-", body[:model], "-", temperature_str)
                input = join([m["content"] for m in body[:messages]], " ")
            elseif occursin("v1/embeddings", req.target)
                cache_key = string("emb-", body[:model])
                ## We're in embedding endpoint
                input = join(body[:input], " ")
            elseif occursin("v1/rerank", req.target)
                cache_key = string("rerank-", body[:model], "-", body[:top_n])
                input = join([body[:query], body[:documents]...], " ")
            else
                ## Skip, unknown API 
                VERBOSE && @info "Skipping cache for $(req.method) $(req.target)"
                return handler(req; kw...)
            end
            ## Check the cache

            VERBOSE && @info "Check if we can cache this request ($(length(input)) chars)"
            active_cache = length(input) > 5000 ? HASH_CACHE : SEM_CACHE
            item = active_cache(
                cache_key, input; verbose = 2 * VERBOSE, min_similarity = 0.99) # change verbosity to 0 to disable detailed logs
            if !isvalid(item)
                VERBOSE && @info "Cache miss! Pinging the API"
                # pass the request along to the next layer by calling `cache_layer` arg `handler`
                resp = handler(req; kw...)
                item.output = resp
                # Let's remember it for the next time
                push!(active_cache, item)
            end
            ## Return the calculated or cached result
            return item.output
        end
        # pass the request along to the next layer by calling `cache_layer` arg `handler`
        # also pass along the trailing keyword args `kw...`
        return handler(req; kw...)
    end
end

# Create a new client with the auth layer added
HTTP.@client [cache_layer]

end # module
role4transcript(::PT.SystemMessage) = "System Instructions:"
role4transcript(::PT.UserMessage) = "User said:"
role4transcript(::PT.AIMessage) = "AI Assistant said:"

"Flattens the full conversation for critic to use"
function conversation2transcript(conversation)
    return map(x -> role4transcript(x) * "\n\n" * x.content, conversation) |>
           x -> join(x, "\n-----\n")
end

"Parses critic's response to get the suggestions and whether they requested to stop"
function parse_critic(msg::PT.AIMessage)
    ## Extract the suggestions
    suggestions = match(r"Suggestions[*]*:[\s\S]*?(?=Outcome:)"ms, msg.content)
    suggestions = "Improve your answer based on the following suggestions.\n\n" *
                  (!isnothing(suggestions) ? strip(replace(suggestions.match, "*" => "")) :
                   msg.content)

    ## Extract the requested outcome
    early_stop = match(r"Outcome:[\s*-]*([A-Za-z]+)", msg.content)
    early_stop = if !isnothing(early_stop)
        occursin("DONE", early_stop.captures[1])
    else
        false
    end
    return suggestions, early_stop
end

###

role4display(::PT.SystemMessage) = "System Instructions"
role4display(::PT.UserMessage) = "You said"
role4display(::PT.AIMessage) = "AI said"

function msg2display(msg::PT.AbstractMessage; id::Int)
    Dict(:id => id, :content => msg.content,
        :title => role4display(msg),
        :class => PT.isaimessage(msg) ? "bg-grey-3" : "",
        :message => msg)
end
function display2msg(display::Dict{Symbol, <:Any})
    return display[:message]
end
function display2msg(display::AbstractVector{<:Dict{Symbol, <:Any}})
    return identity.(display2msg.(display))
end
# Note

"Extracts the variables from the template name (if found)"
function template_variables(template::String)
    # pick the template with exact match
    tpl_metadatas = aitemplates(Symbol(template))
    idx = findfirst(x -> x.name == Symbol(template), tpl_metadatas)
    if isnothing(idx)
        [Dict{Symbol, Any}()]
    else
        tpl_metadata = tpl_metadatas[idx]
        [Dict(:id => id, :variable => String(sym), :content => "")
         for (id, sym) in enumerate(tpl_metadata.variables)]
    end
end

"Renders template displayed messages"
function render_template_messages(template::String)
    messages = PT.render(PT.NoSchema(), PT.AITemplate(Symbol(template)))
    display = [msg2display(msg; id)
               for (id, msg) in enumerate(messages)]
end

# update content field in the message
"Updates the provided message with the new content (creates a new object)"
function update_message(msg::T, content_new::AbstractString) where {T <: PT.AbstractMessage}
    return T(; [f => getfield(msg, f) for f in fieldnames(T)]..., content = content_new)
end

"Updates the message in the display, if needed"
function update_message!(display::Dict{Symbol, Any})
    id = display[:id]
    msg = display[:message]
    ## Re-type into PT.AbstractMessage
    if !(msg isa PT.AbstractMessage)
        msg = JSON3.read(JSON3.write(msg), PT.AbstractMessage)
        display[:message] = msg
    end
    if msg.content != display[:content]
        @info ">> Updating message $id ($(nameof(typeof(msg)))"
        display[:message] = update_message(msg, display[:content])
    end
    return display
end

"Returns rendered messages, check if messages need updating as we might have changed the `display`"
function render_messages(display, placeholders = Vector{Dict{Symbol, Any}}())
    ## shortcut if empty
    isempty(display) && return PT.AbstractMessage[]

    placeholder_kwargs = if !isempty(placeholders)
        (; [(Symbol(p[:variable]), p[:content]) for p in placeholders]...)
    else
        NamedTuple()
    end
    @info ">> Template plaholders: $(placeholder_kwargs)"
    ## check if display has been updated, if yes, change the message
    display = update_message!.(display)
    ## Render the conversation
    conv_rendered = PT.render(
        PT.NoSchema(), display2msg(display); placeholder_kwargs...)

    return conv_rendered
end

"Loads all conversations from a directory (or its sub-directories)"
function load_conversations_from_dir(dir::String)
    new_history = Dict{Symbol, Any}[]
    for (root, _, files) in walkdir(dir)
        for file in files
            if startswith(file, "conversation") && endswith(file, ".json")
                conv = PT.load_conversation(joinpath(root, file))
                file_clean = split(file, ".json")[begin] |>
                             x -> replace(x, "_" => " ") |> titlecase
                push!(new_history,
                    Dict(:name => file_clean, :label => "", :messages => conv))
            end
        end
    end
    return new_history
end

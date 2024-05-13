struct ConvRecord end

"Saves the current conversation to a history record and, optionally, also to the disk."
function PT.save_conversation(::ConvRecord,
        conv_displayed::Vector{T}; save::Bool = true, save_path::String = "",
        model::String = "", variables::Vector{Dict{Symbol, Any}} = Vector{Dict{
            Symbol, Any}}(),
        file_prefix::String = "conversation") where {T <: Dict{Symbol, <:Any}}
    timestamp = Dates.format(now(), "YYYYmmdd_HHMMSS")
    name = "Conv. @ $timestamp"
    ## update the chat with edits by the user
    conv_rendered = render_messages(conv_displayed, variables)
    # Conv. display is already up-to-date, no need to update it!
    label = !isempty(model) ? label_conversation(conv_rendered; model) : ""
    if save && !isempty(save_path)
        label_clean = replace(label, r"[:\s\"]+" => "_") |> lowercase
        ## save to disk + to chat history
        path = joinpath(
            save_path, "$(file_prefix)__$(timestamp)__$(label_clean).json")
        PT.save_conversation(path, conv_rendered)
        @info ">> Chat saved to $path"
    end
    record = Dict(:name => name, :label => label, :messages => conv_rendered)
    return record
end

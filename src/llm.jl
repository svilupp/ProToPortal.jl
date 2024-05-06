"Prepares the conversation for sending to the LLM"
function prepare_conversation(
        display::Vector{Dict{Symbol, Any}}, placeholders::Vector{Dict{
            Symbol, Any}} = Vector{Dict{Symbol, Any}}();
        question::String = "", template::String = "", system_prompt::String = "")
    conv = render_messages(display, placeholders)
    if template != ""
        @info "> Template submitted: $template"
    elseif length(conv) > 0 && PT.isusermessage(conv[end])
        @info "> Conversation re-submitted."
        ## if user provided some extra text in the question, append it
        ## no need to update display, we update it when we get response
        if !isempty(question)
            user_msg = conv[end]
            conv[end] = update_message(user_msg, user_msg.content * "\n" * question)
        end
    elseif isempty(conv)
        ## direct question, first question
        @info "> User asked: $question"
        push!(conv, PT.SystemMessage(system_prompt))
        push!(conv, PT.UserMessage(question))
    else
        ## direct question, follow up
        @info "> User asked: $question"
        push!(conv, PT.UserMessage(question))
    end
    return conv
end

"Code evaluator. Returns the evaluted code block (AICode) and the feedback string."
function evaluate_code(conv::AbstractVector{<:PT.AbstractMessage};
        prefix::String = "", header::String = "## Code Evaluation")
    @info ">> Evaluating code"
    cb = AICode(
        last(conv); prefix, skip_unsafe = true, capture_stdout = true)
    @info ">> Code Success: $(isvalid(cb))"

    ### Build the response
    io = IOBuffer()
    println(io, header, "\n")
    if isvalid(cb)
        println(io, "**Outcome:** Code is valid", "\n")
        println(io, "**Output:**\n $(cb.stdout)", "\n")
    else
        println(io, "**Outcome:** Code is not valid", "\n")
        println(io, "**Error:**\n $(cb.error)", "\n")
        code_feedback = aicodefixer_feedback(cb).feedback
        println(io, "**Feedback:**\n $(code_feedback)", "\n")
    end
    feedback = String(take!(io))
    return cb, feedback
end

# Convenience function for evaluating code from string
# AIMessage is the better input because it handles code extraction with a few fallbacks!
function evaluate_code(str::AbstractString;
        prefix::String = "", header::String = "## Code Evaluation")
    evaluate_code([PT.AIMessage(str)]; prefix, header)
end

"Constructs AIGenerate call that mimics if it was just executed"
function build_lazy_aicall(conv::AbstractVector{<:PT.AbstractMessage};
        model::String, max_retries::Int = 3, n_samples::Int = 2)
    result = AIGenerate(conv; model, config = AT.RetryConfig(; max_retries, n_samples))
    result.success = true
    result.samples.data = copy(conv)
    pop!(result.samples.data)
    node = AT.expand!(result.samples, conv; success = true)

    return result
end

"Runs one iteration of `airetry!`"
function autofix_code(
        result::AICall; prefix::String = "", max_retries::Int = 1, verbose::Bool = false)
    ## Auto-fixing
    function success_func(aicall)
        out = AICode(last_message(aicall); prefix) |> isvalid
        @info ">>> Retry condition check: $out"
        return out
    end
    feedback_func(aicall) = aicodefixer_feedback(aicall).feedback
    result = airetry!(success_func, result, feedback_func; max_retries, verbose)
    return result
end

"Sends the conversation to the LLM."
function send_to_model(
        conv::AbstractVector{<:PT.AbstractMessage}; model::String, temperature::Float64 = 0.7)
    @info ">> Sending $(length(conv)) messages to LLM with temp $temperature"
    result = aigenerate(conv; model, api_kwargs = (; temperature), return_all = true)
    return result
end
"Sends the conversation to the LLM."
function send_to_model(
        any_template::Symbol; model::String, temperature::Float64 = 0.7, kwargs...)
    @info ">> Sending AITemplate $(any_template) to LLM with temp $temperature"
    result = aigenerate(
        any_template; model, api_kwargs = (; temperature), return_all = true, kwargs...)
    return result
end
"Sends the conversation to the Auto-Critic Template for evaluation and suggestions"
function send_to_model(critic_template::Symbol,
        conv::AbstractVector{<:PT.AbstractMessage}; model::String, temperature::Float64 = 0.7)
    @info ">> Sending $(length(conv)) messages to the Auto-Critic with temp $temperature"
    result = aigenerate(Symbol(critic_template);
        transcript = conversation2transcript(conv),
        model, api_kwargs = (; temperature), return_all = true)
    return result
end

"Labels the conversation based on the transcript"
function label_conversation(conv; model::String)
    @info ">> Sending $(length(conv)) messages to LLM for labeling"
    transcript = ["$(nameof(typeof(msg))) said:\n" * msg.content for msg in conv] |>
                 x -> join(x, "\n---\n")
    msg = aigenerate(
        :ConversationLabeler; model, transcript)
    label = replace(msg.content, "Selected Theme:" => "") |> strip
    @info ">> Generated label for history file: $label"
    return label
end

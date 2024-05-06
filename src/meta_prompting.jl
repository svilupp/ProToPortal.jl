const META_PROMPT_FOLLOWUP = "Based on the information given, what are the most logical next steps or conclusions? Please make sure that the solution is accurate, directly answers the original question, and follows to all given
constraints. Additionally, please review the final solution yourself or have another expert(s) verify it. ALWAYS include ALL relevant INFORMATION in the expert instructions, as they have NO MEMORY and can NOT see previous outputs or conversations."

"""
    extract_expert_details(s::AbstractString)

Extracts the expert details from the meta prompting step.

Looks for ">>", triple quotes, and "EXPERT" to extract the expert details.

Returns: (success::Bool, expert::SubString{String}, persona::SubString{String}, task::SubString{String})
"""
function extract_expert_details(s::AbstractString)
    # Step 1: Extract the instruction block by catching everything after ">>"
    instruction_block_match = match(r">>(.*)|EXPERT(.*)"ms, s)
    instruction_block = instruction_block_match !== nothing ?
                        something(instruction_block_match.captures...) : ""
    if instruction_block == ""
        return (false, "", "",
            "Failed to call the expert. No expert instructions found. Ensure the correct formatting and try again.")
    end

    # Step 2: Detect the """ block (assuming there is only one)
    triple_quote_block_match = match(
        r"\"\"\"(.*?)\"\"\""ms, instruction_block)
    triple_quote_block = triple_quote_block_match !== nothing ?
                         triple_quote_block_match.captures[1] : ""
    if triple_quote_block == ""
        return (false, "", "",
            "Failed to call the expert. No expert instructions found. Ensure the correct formatting and try again.")
    end

    # Step 3: Extract the PERSONA and TASK within the block
    # Updated to capture everything up to "TASK" with optional spaces and colons
    expert = split(instruction_block, r":|\n")[begin] |>
             x -> replace(x, r"EXPERT[:]*" => "") |>
                  x -> endswith(x, ":") ? first(x, length(x) - 1) : x

    persona_pattern = r"PERSONA[\s:]*(.+)\s*TASK"ms
    task_pattern = r"TASK[\s:]*(.+)"ms

    persona_match = match(persona_pattern, triple_quote_block)
    task_match = match(task_pattern, triple_quote_block)

    persona = persona_match !== nothing ? persona_match.captures[1] :
              "You are a world-class $(strip(expert)), the absolute best in what your field."
    task = task_match !== nothing ? task_match.captures[1] : triple_quote_block

    return (true, strip(expert), strip(persona), strip(task))
end

"""
    extract_final_answer(s::AbstractString)

Extracts the final answer from the meta prompting step.

Looks for ">> FINAL ANSWER" and the inside quotes to extract the final answer.

Returns: (success::Bool, final_answer::SubString{String})
"""
function extract_final_answer(s::AbstractString)
    # Pattern to find the final answer block starting with ">> FINAL ANSWER"
    final_answer_pattern = r">>\s+FINAL ANSWER[:]{0,1}(.*)"ms

    # Match the pattern in the given string
    final_answer_match = match(final_answer_pattern, s)
    isnothing(final_answer_match) && return (false, "")

    # Extract the final answer if found, otherwise return an informative message
    final_answer_block = strip(final_answer_match.captures[1])
    inside_match = match(
        r"\"\"\"(.*?)\"\"\""ms, final_answer_block)
    final_answer = !isnothing(inside_match) ? inside_match.captures[1] : ""
    if final_answer == ""
        (false,
            "Failed to extract the final answer. No final answer found. Ensure the correct formatting and try again.")
    else
        (true, strip(final_answer))
    end
end

"""
    meta_prompt_step!(conv::AbstractVector{<:PT.AbstractMessage};
        counter::Int = 1, model::String = "gpt4", question::String = "",
        followup = META_PROMPT_FOLLOWUP, code_prefix::String = "")

Executes one meta-prompting round, ie, it calls the meta-expert who calls a sub-expert if needed or returns the final answer.

Returns: (early_stop::Bool, conv::AbstractVector{<:PT.AbstractMessage})
"""
function meta_prompt_step!(conv::AbstractVector{<:PT.AbstractMessage};
        counter::Int = 1, model::String = "gpt4", question::String = "",
        followup = META_PROMPT_FOLLOWUP, code_prefix::String = "")
    ## Start with the Meta-prompter
    conv = if isempty(conv)
        @info ">> Start meta-prompting loop, round: $(counter)"
        aigenerate(:MetaExpertAsk; model, return_all = true, ask = question)
    else
        @info ">> Meta-prompting loop, round: $(counter)"
        ## Get the follow-up
        aigenerate(conv; model, return_all = true)
    end
    last_str = PT.last_output(conv)
    ## Check if we're done
    early_stop, final_answer = extract_final_answer(last_str)
    if early_stop
        @info ">> Final answer detected!"
        return early_stop, conv
    end

    ## Iteration with the experts
    valid_expert, expert, persona, task = extract_expert_details(last_str)
    answer = if valid_expert
        @info ">> Calling an expert: $expert"
        expert_conv = aigenerate(
            :BlankSystemUser; system = persona, user = task, model, return_all = true)
        str = PT.last_output(expert_conv)
        ## Auto-detect any code and evaluate it
        feedback = if occursin(r"```julia\n", str) || count(r"```", str) >= 2
            @info ">> Detected code, evaluating it"
            _, feedback = evaluate_code(
                str; prefix = code_prefix, header = ">> CODE EVALUATION OUTPUT")
            string("\n\n", "-"^10, "\n", strip(feedback), "\n", "-"^10, "\n")
        else
            ""
        end
        expert_answer = "ROUND $(counter):\n\n>> EXPERT $expert OUTPUT:\n\"\"\"\n$(str)$(feedback)\n\"\"\"\n\n$(followup)"
    else
        "ROUND $(counter):\n\n$(task)"
    end
    push!(conv, PT.UserMessage(answer))

    return false, conv
end

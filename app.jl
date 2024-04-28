module App
using ProToPortal
using PromptingTools
const PT = PromptingTools
using PromptingTools.Experimental.AgentTools
const AT = PromptingTools.Experimental.AgentTools
using GenieFramework
using GenieSession
using GenieFramework.Genie.Requests: postpayload
@genietools

Stipple.Layout.add_script("https://cdn.tailwindcss.com")

#! CONFIGURATION
const HISTORY_DIR = joinpath(@__DIR__, "chat_history")
# Change if you don't want to auto-save conversations (after clicking "New chat")
const HISTORY_SAVE = true

@appname Portal

## The bellow logic drives all page behaviors
##
## Main entrypoint is chat_submit (sends conversations to LLM one or more times) and chat reset (save conversation to disk and reset all inputs).
##
## Key conversation unit are “displays”, which contain both the text user sees (“d[:content]”) but also the underpinning PT messages (“d[:message]”)
##
## chat_submit route does a few things
## - update messages in displays if user did some edits
## - prepare conversation chain to send to LLM
## - send to LLM
## - if code eval is on, append evaluation results (Julia only) as a usermessage
## - If aireply is on, run the fixing chain with airetry! for desired number of iterations
## - If auto-critic template is provided, generate faux-user response by critiquing LLM’s response through the eyes of the selected critic
## - If auto-reply message is provided, keep responding with pre-defined text for X number of times (useful for lazy models)
## - most steps end with write into conv_displayed to force updating the UI

@app begin
    # layout and page management
    @in left_drawer_open = true
    @in selected_page = "chat"
    @in ministate = true
    # configuration
    @in model = isempty(PT.GROQ_API_KEY) ? "gpt4t" : "gllama370"
    @in model_input = ""
    @in model_submit = false
    ## gllama3 - Llama3 8b on Groq, gllama370 - Llama3 70b on Groq, 
    ## claude-x are Opus/Sonnet/Haiku from Anthropic Claude3, tmixtral is Mixtral 8x7b on Together.ai, 
    ## ollama3 is Llama3 8b on Ollama
    @out model_options = ["gpt4t", "gpt3t", "gllama3", "gllama370",
        "ollama3", "claudeo", "claudes", "claudeh", "tmixtral"]
    @in system_prompt = "You are a helpful assistant."
    @in chat_temperature = 0.7
    @in chat_code_eval = false
    @in chat_code_prefix = ""
    @in chat_code_airetry = false
    @in chat_code_airetry_count = 3
    @in chat_code_n_samples = 2
    @in chat_auto_template = ""
    ## Let's add only templates with critic in the name
    @in chat_auto_template_options_all = PT.TEMPLATE_STORE |> keys |> collect .|> string |>
                                         tpl -> filter(x -> occursin("Critic", x), tpl)
    @in chat_auto_template_options = PT.TEMPLATE_STORE |> keys |> collect .|> string |>
                                     tpl -> filter(x -> occursin("Critic", x), tpl)
    @in chat_auto_reply = ""
    @in chat_auto_reply_count = 0
    # chat
    @in conv_displayed = Dict{Symbol, Any}[]
    # Enter text
    @in chat_question = ""
    @out chat_disabled = false
    # Select template
    @in chat_advanced_expanded = false
    @in chat_template_expanded = false
    @in chat_template_selected = ""
    @out chat_template_options_all = PT.TEMPLATE_STORE |> keys |> collect .|> string
    @in chat_template_options = PT.TEMPLATE_STORE |> keys |> collect .|> string
    @in chat_template_variables = Dict{Symbol, Any}[]
    @in chat_submit = false
    @in chat_reset = false
    @in chat_rm_last_msg = false
    # Template browser
    @in template_filter = ""
    @in template_submit = false
    @out templates = PT.AITemplateMetadata[]
    # History browser
    @in history_reload = false
    @in history_fork = false
    @out history = Dict{Symbol, Any}[]
    @in history_current_name = ""
    @out history_current = Dict{Symbol, Any}[]
    # Dashboard logic
    @onchange isready begin
        @info "> Dashboard is ready!"
    end
    @onbutton model_submit begin
        if !isempty(model_input)
            @info "> Added a new model: $model_input"
            model_options = push!(model_options, model_input)
            model = model_input
            model_input = ""
        end
    end
    @onchange chat_template_selected begin
        if chat_template_selected != ""
            @info "> Template Selected: $(chat_template_selected)"
            chat_disabled = true # disable chat entry
            chat_template_variables = template_variables(chat_template_selected)
            conv_displayed = render_template_messages(chat_template_selected)
        else
            # reset options
            chat_template_options = chat_template_options_all
            chat_template_variables = empty!(chat_template_variables)
            chat_disabled = false
        end
    end
    @onbutton chat_reset begin
        @info "> Chat Reset!"
        timestamp = Dates.format(now(), "YYYYmmdd_HHMMSS")
        name = "Conv. @ $timestamp"
        ## update the chat with edits by the user
        conv_rendered = render_messages(conv_displayed, chat_template_variables)
        # Conv. display is already up-to-date, no need to update it!
        label = label_conversation(conv_rendered; model = model)
        if HISTORY_SAVE
            label_clean = replace(label, r"[:\s\"]+" => "_") |> lowercase
            ## save to disk + to chat history
            path = joinpath(
                HISTORY_DIR, "conversation__$(timestamp)__$(label_clean).json")
            PT.save_conversation(path, conv_rendered)
            @info "> Chat saved to $path"
        end
        history = push!(history,
            Dict(:name => name, :label => label, :messages => conv_rendered))

        ## clean the chat
        conv_displayed = empty!(conv_displayed)
        chat_template_variables = empty!(chat_template_variables)
        chat_question, chat_auto_template, chat_template_selected = "", "", ""
        chat_disabled, chat_advanced_expanded, chat_template_expanded = false, false, false
        # set defaults again
        chat_code_airetry, chat_code_eval = false, false
        chat_code_prefix = ""
        chat_temperature = 0.7
    end
    @onbutton chat_submit begin
        chat_disabled = true
        # Active LLM block
        conv = prepare_conversation(conv_displayed,
            chat_template_variables; question = chat_question, system_prompt = system_prompt,
            template = chat_template_selected)
        conv_current = send_to_model(conv; model = model, temperature = chat_temperature)
        ## Re-build the display for user
        conv_displayed = [msg2display(msg; id)
                          for (id, msg) in enumerate(conv_current)]
        # remove template variables
        chat_template_variables = empty!(chat_template_variables)
        chat_question, chat_template_selected = "", ""
        # Note: keep the critic template enabled
        chat_disabled, chat_template_expanded, chat_advanced_expanded = false, false, false
        #######################
        ### AUTOMATED BEHAVIORS
        ## Provide code-feedback if code is enabled, skip airetry is enabled
        if chat_code_eval && !(chat_code_airetry && chat_code_airetry_count > 0)
            push!(conv_current,
                PT.UserMessage(evaluate_code(conv_current; prefix = chat_code_prefix)[2]))
            conv_displayed = [msg2display(msg; id) for (id, msg) in enumerate(conv_current)]
        end
        ## Check auto-reply via AIRETRY, via templated critic or via auto-reply message
        if chat_code_airetry && chat_code_airetry_count > 0
            @info "> Entered `airetry!` code-fixing loop (triggers fixing only if needed)"
            aicall = build_lazy_aicall(conv_current; model = model,
                max_retries = chat_code_airetry_count, n_samples = chat_code_n_samples)
            for i in 1:chat_code_airetry_count
                @info ">> Maybe code-fixing - Iteration $i // Total calls: $(aicall.config.calls), Total retries: $(aicall.config.retries)"
                aicall = autofix_code(
                    aicall; prefix = chat_code_prefix, max_retries = i, verbose = true)
                # explicitly write into the objects to trigger UI updates
                conv_displayed = [msg2display(msg; id)
                                  for (id, msg) in enumerate(aicall.conversation)]
                ## break if we're done
                aicall.success == true && break
            end
            outcome = aicall.success ? "Success" : "Failure"
            @info ">> Outcome: $outcome // Current convo. length: $(length(aicall.conversation)) messages and $(length(aicall.samples)) samples "
        elseif (chat_auto_template != "" || chat_auto_reply != "") &&
               chat_auto_reply_count > 0
            ## Path for automated replies
            reply, early_stop = if chat_auto_template != ""
                @info "> Auto-Reply Template Activated: $(chat_auto_template)"
                ## provide the transcript of convo so far to the critic
                critic_conv = send_to_model(
                    Symbol(chat_auto_template), conv_current; model = model,
                    temperature = chat_temperature)
                reply, early_stop = parse_critic(critic_conv[end])
            else
                @info "> Auto-Reply Message Activated: $(chat_auto_template)"
                chat_auto_reply, false
            end
            ## align conversation (not to have two user messages in a row)
            last_msg = conv_current[end]
            if PT.isusermessage(last_msg) && reply != ""
                ## concatenate messages
                conv_current[end] = update_message(
                    last_msg, last_msg.content * "\n\n" * reply)
            elseif reply != ""
                push!(conv_current, PT.UserMessage(reply))
            else
                # no reply text found! we stop
                early_stop = true
            end
            conv_displayed = [msg2display(msg; id) for (id, msg) in enumerate(conv_current)]
            ## if critic decided to early stop, stop
            if early_stop
                chat_auto_reply_count = 0
            else
                # trigger a new call
                chat_auto_reply_count = chat_auto_reply_count - 1
                chat_submit = true
            end
        end
    end
    @onbutton chat_rm_last_msg begin
        @info "> Deleting last turn!"
        pop!(conv_displayed)
        conv_displayed = conv_displayed
    end
    ### Template browsing behavior
    @onbutton template_submit begin
        @info "> Template filter: $template_filter"
        templates = aitemplates(template_filter)
    end
    # Select history to load
    @onchange history_current_name begin
        @info "> Requested history: $history_current_name"
        idx = findfirst(x -> x[:name] == history_current_name, history)
        if !isnothing(idx)
            history_current = [msg2display(msg; id)
                               for (id, msg) in enumerate(history[idx][:messages])]
        end
    end
    # Select history to load in the chat window (creates a copy, a true fork!)
    @onbutton history_fork begin
        @info "> Forking history: $history_current_name"
        conv_displayed = deepcopy(history_current)
        selected_page = "chat"
    end
    @onbutton history_reload begin
        @info "> Reloading history from $(HISTORY_DIR)"
        new_history = load_conversations_from_dir(HISTORY_DIR)
        @info "> Loaded $(length(new_history)) conversations from disk"
        history = new_history
        history_current = if length(history) > 0
            # Load the first convo
            [msg2display(msg; id) for (id, msg) in enumerate(history[1][:messages])]
        else
            # load empty
            Dict{Symbol, Any}[]
        end
    end
end
## TODO: add cost tracking on configuration pages + token tracking
## TODO: add RAG/knowledge loading from folder or URL
# Required for the JS events
@methods begin
    raw"""
    filterFn (val, update) {
        if (val === '') {
            update(() => {
            // reset to full option list
            this.chat_template_options = this.chat_template_options_all
            })
            return
        }

        update(() => {
            // filter down based on user provided input
            const needle = val.toLowerCase()
            this.chat_template_options = this.chat_template_options_all.filter(v => v.toLowerCase().indexOf(needle) > -1)
        })
        },
    filterFnAuto (val, update) {
        if (val === '') {
            update(() => {
            // reset to full option list
            this.chat_auto_template_options = this.chat_auto_template_options_all
            })
            return
        }

        update(() => {
            // filter down based on user provided input
            const needle = val.toLowerCase()
            this.chat_auto_template_options = this.chat_auto_template_options_all.filter(v => v.toLowerCase().indexOf(needle) > -1)
        })
        },
    copyToClipboard: function(index) {
        console.log(index);
        const str = this.conv_displayed[index].content; // extract the content of the element in position `index`
        const el = document.createElement('textarea');  // Create a <textarea> element
        el.value = str;                                 // Set its value to the string that you want copied
        el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
        el.style.position = 'absolute';                 
        el.style.left = '-9999px';                      // Move outside the screen to make it invisible
        document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
        el.select();                                    // Select the <textarea> content
        document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
        document.body.removeChild(el);                  // Remove the <textarea> element
    }
    """
end

route("/", named = :home) do
    authenticated!()
    model = @init()
    page(model, ui()) |> html
end
route("/login", method = POST, named = :login) do
    try
        user = postpayload(:username)
        pass = postpayload(:password)
        ## verify that the password is correct
        @assert pass == get(ENV, "SECRET_PASSWORD", "")
        authenticate(user, GenieSession.session(params()))
        redirect(:home)
    catch ex
        @warn "Authentication failed!"
        flash("Authentication failed! Please try again.")
        redirect(:show_login)
    end
end
route("/login", method = GET, named = :show_login) do
    ui_login() |> html
end
route("/logout", named = :success) do
    deauthenticate(GenieSession.session(params()))
    redirect(:show_login)
end

end # end of module

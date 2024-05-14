module App
using Base64
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
# Change if you want to save conversations to a specific folder
const HISTORY_DIR = get(ENV, "PROTO_HISTORY_DIR", joinpath(@__DIR__, "chat_history"))
# Change if you don't want to auto-save conversations (after clicking "New chat")
const HISTORY_SAVE = get(ENV, "PROTO_HISTORY_SAVE", true)

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
    ## @in chat_tracker_tokens_in = 0
    ## @in chat_tracker_tokens_out = 0
    ## @in chat_tracker_cost = 0.0
    @in model = isempty(PT.GROQ_API_KEY) ? "gpt4o" : "gllama370"
    @in model_input = ""
    @in model_submit = false
    ## gllama3 - Llama3 8b on Groq, gllama370 - Llama3 70b on Groq, 
    ## claude-x are Opus/Sonnet/Haiku from Anthropic Claude3, tmixtral is Mixtral 8x7b on Together.ai, 
    ## ollama3 is Llama3 8b on Ollama
    @out model_options = ["gpt4o", "gpt4t", "gpt3t", "gllama3", "gllama370",
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
    @in chat_edit_show = false
    @in chat_edit_content = ""
    @in chat_edit_save = false
    @in chat_edit_index = 0
    @in is_recording = false
    @in audio_chunks = []
    @in mediaRecorder = nothing
    @in channel_ = nothing
    # Enter text
    @in chat_question = ""
    @out chat_disabled = false
    @out chat_question_tokens = ""
    @out chat_convo_tokens = ""
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
    @in chat_fork = false
    # Meta Prompting
    @in meta_submit = false
    @in meta_reset = false
    @in meta_disabled = false
    @in meta_question = ""
    @in meta_rounds_max = 5
    @in meta_rounds_current = 0
    @in meta_displayed = Dict{Symbol, Any}[]
    @in meta_rm_last_msg = false
    ## Prompt Builder
    @in builder_apply = false
    @in builder_submit = false
    @in builder_reset = false
    @in builder_disabled = false
    @in builder_question = ""
    @in builder_tabs = Dict{Symbol, Any}[]
    @in builder_tab = "tab1"
    @in builder_detailed_view = false
    @in builder_model = isempty(PT.GROQ_API_KEY) ? "gpt4t" : "gllama370"
    @in builder_samples = 3
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
        isdir(HISTORY_DIR) || mkpath(HISTORY_DIR)
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
        record = save_conversation(ConvRecord(),
            conv_displayed; save = HISTORY_SAVE, save_path = HISTORY_DIR,
            variables = chat_template_variables, model = model)
        history = push!(history, record)
        ## clean the chat
        conv_displayed = empty!(conv_displayed)
        chat_template_variables = empty!(chat_template_variables)
        chat_question, chat_auto_template, chat_template_selected = "", "", ""
        chat_disabled, chat_advanced_expanded, chat_template_expanded = false, false, false
        # set defaults again
        chat_code_airetry, chat_code_eval = false, false
        chat_code_prefix, chat_temperature = "", 0.7
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
    @onbutton chat_fork begin
        @info "> Forking conversation (reset+load)!"
        conv_displayed_temp = deepcopy(conv_displayed)
        chat_reset = true
        conv_displayed = conv_displayed_temp
    end
    @onchange conv_displayed begin
        chat_convo_tokens = if isempty(conv_displayed)
            ""
        elseif PT.isaimessage(conv_displayed[end][:message])
            msg = conv_displayed[end][:message]
            "Tokens: $(sum(msg.tokens)), Cost: \$$(round(msg.cost;digits=2))"
        else
            ""
        end
    end
    ## Chat Speech-to-text
    @onchange fileuploads begin
        if !isempty(fileuploads)
            @info "File was uploaded: " fileuploads["path"]
            filename = base64encode(fileuploads["name"])
            try
                fn_new = fileuploads["path"] * ".wav"
                mv(fileuploads["path"], fn_new; force = true)
                chat_question = openai_whisper(fn_new)
                rm(fn_new; force = true)
                Base.run(__model__, "this.copyToClipboardText(this.chat_question);")
            catch e
                @error "Error processing file: $e"
                notify(__model__, "Error processing file: $(fileuploads["name"])")
            end
            fileuploads = Dict{AbstractString, AbstractString}()
        end
    end
    ### Meta-prompting
    @onbutton meta_submit begin
        meta_disabled = true
        if meta_rounds_current < meta_rounds_max
            # we skip prepare_conversation to avoid create user+system prompt when we start, just grab the messages
            conv_current = render_messages(meta_displayed)
            while meta_rounds_current < meta_rounds_max
                meta_rounds_current = meta_rounds_current + 1
                ## update conv, but indicate if it's final_answer
                early_stop, conv_current = meta_prompt_step!(
                    conv_current; counter = meta_rounds_current, model = model, question = meta_question)
                meta_displayed = [msg2display(msg; id)
                                  for (id, msg) in enumerate(conv_current)]
                early_stop && break
            end
        elseif meta_question != ""
            @info "> Meta-prompting follow up question!"
            conv = prepare_conversation(meta_displayed; question = meta_question)
            conv_current = send_to_model(conv; model = model)
            meta_displayed = [msg2display(msg; id)
                              for (id, msg) in enumerate(conv_current)]
        end
        meta_disabled, meta_question = false, ""
    end
    @onbutton meta_reset begin
        @info "> Meta-Prompting Reset!"
        record = save_conversation(ConvRecord(),
            meta_displayed; save = HISTORY_SAVE, save_path = HISTORY_DIR,
            model = model, file_prefix = "conversation__meta")
        history = push!(history, record)
        ## clean the messages
        meta_rounds_current = 0
        meta_displayed = empty!(meta_displayed)
        meta_disabled, meta_question, meta_rounds_current = false, "", 0
    end
    @onbutton meta_rm_last_msg begin
        @info "> Deleting last turn!"
        meta_rounds_current = meta_rounds_current - 1
        pop!(meta_displayed)
        meta_displayed = meta_displayed
    end
    ### Prompt Builder
    @onbutton builder_submit begin
        builder_disabled = true
        @info "> Prompt Builder Triggered - generating $(builder_samples) samples"
        first_run = isempty(builder_tabs)
        for i in 1:builder_samples
            if first_run
                ## Generate the first version
                conv_current = send_to_model(
                    :PromptGeneratorBasic; task = builder_question, model = builder_model)
                instructions, inputs = parse_builder(PT.last_message(conv_current))
                new_sample = Dict(:name => "tab$(i)",
                    :label => "Sample $(i)",
                    :instructions => instructions,
                    :inputs => inputs,
                    :display => [msg2display(msg; id)
                                 for (id, msg) in enumerate(conv_current)])
                ## add new sample
                builder_tabs = push!(builder_tabs, new_sample)
            else
                ## Generate the future iterations
                current_tab = builder_tabs[i]
                conv = prepare_conversation(
                    current_tab[:display]; question = builder_question)
                conv_current = send_to_model(
                    conv; model = builder_model)
                ## update the tab
                current_tab[:display] = [msg2display(msg; id)
                                         for (id, msg) in enumerate(conv_current)]
                instructions, inputs = parse_builder(PT.last_message(conv_current))
                current_tab[:instructions] = instructions
                current_tab[:inputs] = inputs
                builder_tabs[i] = current_tab
                builder_tabs = builder_tabs
            end
        end

        builder_disabled, builder_question = false, ""
    end
    @onbutton builder_reset begin
        @info "> Prompt Builder Reset!"
        builder_tabs = empty!(builder_tabs)
        builder_disabled, builder_question = false, ""
    end
    @onbutton builder_apply begin
        @info "> Applying Prompt Builder!"
        builder_msg = filter(x -> x[:name] == builder_tab, builder_tabs) |> only
        instructions, inputs = builder_msg[:instructions], builder_msg[:inputs]
        if isempty(instructions) && isempty(inputs)
            notify(__model__, "Parsing failed! Retry...")
        else
            conv_current = if isempty(inputs)
                notify(__model__, "Parsing failed! Expect bad results / edit as needed!")
                ## slap all instructions into user message
                [PT.SystemMessage(system_prompt), PT.UserMessage(instructions)]
            else
                ## turn into sytem and user message
                [PT.SystemMessage(instructions), PT.UserMessage(inputs)]
            end
            conv_displayed = [msg2display(msg; id)
                              for (id, msg) in enumerate(conv_current)]
            ## show the variables to fill in by the user -- use the last message / UserMessage
            chat_template_expanded = true
            chat_template_variables = [Dict(:id => id, :variable => String(sym),
                                           :content => "")
                                       for (id, sym) in enumerate(conv_current[end].variables)]
            ## change page to chat
            selected_page = "chat"
        end
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
### JAVASCRIPT SECTION ### 
# set focus to the first variable when it changes
@watch begin
    raw"""
    chat_template_variables() {
      this.$nextTick(() => {
        this.$refs.variables[0].focus();
      })
    }

    """
end
@methods begin
    raw"""
    buttonFunc(index) {
        console.log("buttonFunc",index);
        console.log("length", this.conv_displayed.length);
        if (this.conv_displayed.length==index) {
            console.log("woowza");
        }
    },
    // saves edits made in the chat dialog
    saveEdits(index) {
        this.chat_edit_show = false;
        this.conv_displayed[this.chat_edit_index].content = this.chat_edit_content;
        this.chat_edit_content = "";
    },
    updateLengthChat() {
        const tokens = Math.round(this.chat_question.length / 3.5);
        this.chat_question_tokens = `Approx. tokens: ${tokens}`;
    },
    focusTemplateSelect() {
        this.$nextTick(() => {
            this.$refs.tpl_select.focus();
        });
    },
    filterFn(val, update) {
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
    filterFnAuto(val, update) {
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
    copyToClipboard(index) {
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
    },
    copyToClipboardMeta(index) {
        const str = this.meta_displayed[index].content; // extract the content of the element in position `index`
        const el = document.createElement('textarea');  // Create a <textarea> element
        el.value = str;                                 // Set its value to the string that you want copied
        el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
        el.style.position = 'absolute';                 
        el.style.left = '-9999px';                      // Move outside the screen to make it invisible
        document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
        el.select();                                    // Select the <textarea> content
        document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
        document.body.removeChild(el);                  // Remove the <textarea> element
    },
    copyToClipboardText(str) {
        const el = document.createElement('textarea');  // Create a <textarea> element
        el.value = str;                                 // Set its value to the string that you want copied
        el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
        el.style.position = 'absolute';                 
        el.style.left = '-9999px';                      // Move outside the screen to make it invisible
        document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
        el.select();                                    // Select the <textarea> content
        document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
        document.body.removeChild(el);                  // Remove the <textarea> element
    },
    async toggleRecording() {
        if (!this.is_recording) {
          this.startRecording()
        } else {
          this.stopRecording()
        }
    },
    async startRecording() {
      navigator.mediaDevices.getUserMedia({ audio: true })
        .then(stream => {
          this.is_recording = true
          this.mediaRecorder = new MediaRecorder(stream);
          this.mediaRecorder.start();
          this.mediaRecorder.onstop = () => {
            const audioBlob = new Blob(this.audio_chunks, { type: 'audio/wav' });
            this.is_recording = false;

            // upload via uploader
            const file = new File([audioBlob], 'test.wav');
            this.$refs.uploader.addFiles([file], 'test.wav');
            this.$refs.uploader.upload(); // Trigger the upload
            console.log("Uploaded WAV");
            this.$refs.uploader.reset();
            this.audio_chunks=[];

          };
          this.mediaRecorder.ondataavailable = event => {
            this.audio_chunks.push(event.data);
          };
        })
        .catch(error => console.error('Error accessing microphone:', error));
    },
    stopRecording() {
      if (this.mediaRecorder) {
        this.mediaRecorder.stop();
      } else {
        console.error('MediaRecorder is not initialized');
      }
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

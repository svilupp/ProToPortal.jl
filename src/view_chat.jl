## Blocks of the CHAT tab
function tab_chat_settings()
    htmldiv([
            p("Generation Settings", class = "text-lg text-weight-bold pt-4"),
            p("Temperature (0=conservative, 2=crazy)"),
            slider(
                0.0:0.1:2, :chat_temperature, labelalways = true, snap = true,
                markers = 1, label = "Temperature"),
            ##,
            separator(),
            p("Code Evaluation", class = "text-lg text-weight-bold"),
            row([
                toggle("Auto-evaluate code", :chat_code_eval, color = "secondary"),
                toggle(
                    "Enable auto-fixing", :chat_code_airetry, color = "secondary"),
                textfield("# of Retries", class = "col-2 ml-6",
                    :chat_code_airetry_count, type = "number"),
                textfield("# of Samples", class = "col-2 ml-2",
                    :chat_code_n_samples, type = "number")
            ]),
            row(class = "pb-5",
                textfield("Code Prefix (Imports etc)", class = "col-8",
                    hint = "Eg, `using DataFrames`. It will be prepended to the code.", :chat_code_prefix)
            ),
            separator(),
            p("Auto-reply", class = "text-lg text-weight-bold "),
            row(class = "pb-4 col-12",
                [
                    textfield("# of Auto-Replys", class = "col-2",
                        :chat_auto_reply_count, type = "number"),
                    select(
                        :chat_auto_template, options = :chat_auto_template_options,
                        label = "Select Critic Template",
                        hint = "Template for auto-reply",
                        clearable = true,
                        useinput = true,
                        class = "pl-3 pb-4 col-9",
                        @on(:filter, "filterFnAuto")
                    )
                ]),
            row(class = "pb-5 col-12",
                textfield("Or use Auto-Reply Message",
                    hint = "A text that will be auto-sent to the AI model", :chat_auto_reply, class = "col-12"))
        ])
end

function tab_chat_templates()
    htmldiv([
        expansionitem(
        label = "Pick a template",
        class = "mt-2",
        dense = true,
        densetoggle = true,
        v__model = :chat_template_expanded,
        expandseparator = true,
        headerstyle = "bg-blue-1",
        [
            select(
                :chat_template_selected,
                options = :chat_template_options,
                label = "Template",
                clearable = true,
                useinput = true,
                class = "pb-4",
                @on(:filter, "filterFn")
            ),
            separator(),
            ##@iif("!!chat_template_variables.length")
            span(
                "Placeholders to fill out (will be injected into the below messages):",
            ),
            cell(@for("(item, index) in chat_template_variables"),
                key! = R"item.id",
                [
                    textfield(R"item.variable", v__model = "item.content",
                    @on("keyup.enter.ctrl", "chat_submit!=chat_submit")
                )
                ])
        ]
    )])
end

function tab_chat_messages()
    htmldiv(class = "mt-5 relative", @for("(item, index) in conv_displayed"),
        key! = R"item.name",
        [
            htmldiv([
                messagecard("{{item.content}}", title = "{{item.title}}";
                    card_props = [:class => R"item.class"]),
                quasar(:popup__edit,
                    v__model = "item.content",
                    v__slot = "scope",
                    buttons = true,
                    fit = true,
                    style != "{ width: '100%', height: '100%' }",
                    [
                        S.textarea(v__model = "scope.value",
                        style = "width: 100%; height: 100%; min-height: 400px;",
                        autofocus = "", @on("keyup.enter.ctrl", "scope.set"),
                        @on("keyup.enter.stop",
                            ""))
                    ])
            ]),
            btngroup(flat = true, class = "absolute bottom-0 right-0",
                [
                    btn(flat = true, round = true, size = "xs",
                    icon = "content_copy", @click("copyToClipboard(index)"))
                ])]
    )
end

function tab_chat_input()
    htmldiv(class = "input-group",
        [
            textfield("Enter your question here...", :chat_question,
                disable = :chat_disabled,
                type = "textarea",
                ## change to multi-line text area
                @on("keyup.enter.ctrl",
                    "chat_submit = !chat_submit")),
            row(
                [
                    btn("Submit", @click(:chat_submit), disable = :chat_submit, color="black"),
                    spinner( color = "primary", size = "3em", @iif(:chat_submit)),
                    btn("Delete last message",
                        icon = "delete", @click(:chat_rm_last_msg), color="black"),
                    btn("New Chat", icon = "refresh", @click(:chat_reset), color="black")]),
            separator(),
        ])
end

## The overall Chat tab

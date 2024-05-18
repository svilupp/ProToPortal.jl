## Blocks of the CHAT tab
function tab_builder_settings()
    htmldiv([
        expansionitem(
        label = "Builder settings",
        dense = true,
        densetoggle = true,
        expandseparator = true,
        class = "py-5",
        headerstyle = "bg-blue-1", [
            row(p("Prompt Builder Settings", class = "text-lg text-weight-bold pt-4")),
            row(cell([select(:builder_model, options = :model_options, label = "Model")])),
            row(class = "pt-4",
                cell([
                    p("Number of Samples"),
                    slider(
                        1:1:10, :builder_samples, labelalways = true, snap = true,
                        class = "ml-4, my-5",
                        markers = 1)])),
            row(cell([select(:builder_template, options = :builder_tpl_options,
                label = "Builder Template")]))
        ])
    ])
end

function tab_builder_messages()
    card(
        [
            tabgroup(:builder_tab,
                inlinelabel = true,
                dense = true,
                align = "justify",
                class = "mt-0 pt-0",
                [
                    tab(class = "mt-5 relative", @for("(tab, index) in builder_tabs"),
                    key! = R"index", label = R"tab.label", name = R"tab.name")]),
            tabpanels(:builder_tab,
                animated = true,
                swipeable = true,
                [
                    tabpanel(
                    @for("(tab, index) in builder_tabs"),
                    key! = R"index",
                    name = R"tab.name",
                    ## show only the last message!
                    [
                        toggle(
                            "Detailed View", :builder_detailed_view, color = "secondary"),
                        htmldiv(@iif(:builder_detailed_view),
                            messagecard("{{tab.display.at(-1).content}}";
                                title = "{{tab.display.at(-1).title}}",
                                card_props = [:class => R"tab.display.at(-1).class"])),
                        htmldiv(@iif(R"!builder_detailed_view"),
                            [
                                messagecard("{{tab.instructions}}",
                                    title = "System Instructions"),
                                messagecard("{{tab.inputs}}",
                                    title = "Inputs/Placeholders",
                                    card_props = [:class => "mt-5"])
                            ])
                    ])
                ]),
            tabgroup(:builder_tab,
                inlinelabel = true,
                dense = true,
                align = "justify",
                [
                    tab(class = "mt-5 relative", @for("(tab, index) in builder_tabs"),
                    key! = R"index", label = R"tab.label", name = R"tab.name")])
        ],
        ## show only if there is sth to show
        @iif("!!builder_tabs.length"))
end
function tab_builder_input()
    htmldiv(class = "input-group",
        [
            textfield("Enter your task here...", :builder_question,
                disable = :builder_disabled,
                type = "textarea",
                ## change to multi-line text area
                @on("keyup.enter.ctrl",
                    "builder_submit = true")),
            cell(class = "flex",
                [
                    btn("Submit", @click(:builder_submit), disable = :builder_submit),
                    spinner(
                        color = "primary",
                        size = "3em", @iif(:builder_submit)),
                    btn("Reset", @click(:builder_reset)),
                    btn("Apply In Chat", @click(:builder_apply))
                ])
        ])
end
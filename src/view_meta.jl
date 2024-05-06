## Blocks of the CHAT tab
function tab_meta_settings()
    htmldiv([
        expansionitem(
        label = "Meta-Prompting Settings",
        default__opened = true,
        dense = true,
        densetoggle = true,
        expandseparator = true,
        headerstyle = "bg-blue-1", [
            p("Meta-Prompting Settings", class = "text-lg text-weight-bold pt-4"),
            row([
                p("Rounds: Current: {{meta_rounds_current}}, Maximum: "),
                slider(
                    1:1:10, :meta_rounds_max, labelalways = true, snap = true,
                    class = "col-6 ml-4",
                    markers = 1)
            ])
        ])
    ])
end
function tab_meta_messages()
    htmldiv(class = "mt-5 relative", @for("(item, index) in meta_displayed"),
        key! = R"item.name",
        [
            htmldiv([
                messagecard("{{item.content}}", title = "{{item.title}}";
                card_props = [:class => R"item.class"])

            ## quasar(:popup__edit,
            ##     v__model = "item.content",
            ##     v__slot = "scope",
            ##     buttons = true,
            ##     fit = true,
            ##     style != "{ width: '100%', height: '100%' }",
            ##     [
            ##         S.textarea(v__model = "scope.value",
            ##         style = "width: 100%; height: 100%; min-height: 400px;",
            ##         autofocus = "", @on("keyup.enter.ctrl", "scope.set"),
            ##         @on("keyup.enter.stop",
            ##             ""))
            ##     ])
            ]),
            btngroup(flat = true, class = "absolute bottom-0 right-0",
                [
                    btn(flat = true, round = true, size = "xs",
                        icon = "content_copy", @click("copyToClipboardMeta(index)")),
                    ## show only for the last, no confirmation required
                    btn(flat = true, round = true, size = "xs",
                        icon = "delete", @iif("index == meta_displayed.length-1"),
                        @click(:meta_rm_last_msg)
                    )
                ])
        ]
    )
end
function tab_meta_input()
    htmldiv(class = "input-group",
        [
            textfield("Enter your question here...", :meta_question,
                disable = :meta_disabled,
                type = "textarea",
                ## change to multi-line text area
                @on("keyup.enter.ctrl",
                    "meta_submit = true")),
            cell(class = "flex",
                [
                    btn("Submit", @click(:meta_submit), disable = :meta_submit),
                    spinner(
                        color = "primary",
                        size = "3em", @iif(:meta_submit)),
                    btn("New Chat", @click(:meta_reset))
                ])
        ])
end
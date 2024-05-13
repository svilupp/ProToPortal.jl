## Individual Tabs
function tab_chat()
    # Note: tab_chat blocks are defined separately in src/view_chat.jl
    [
        h3("Chat"),
        tab_chat_settings(),
        tab_chat_templates(),
        separator(@iif("!!conv_displayed.length")),
        tab_chat_messages(),
        separator(@iif("!!conv_displayed.length")),
        tab_chat_input()
    ]
end
function tab_meta()
    [
        h3("Meta-Prompting"),
        tab_meta_settings(),
        separator(@iif("!!meta_displayed.length")),
        tab_meta_messages(),
        separator(@iif("!!meta_displayed.length")),
        tab_meta_input()
    ]
end
function tab_builder()
    [
        h3("Template Builder"),
        span(
            "Provide a task to build the template for, then click Apply In Chat to use it in Chat.";
            class = "text-sm italic"),
        tab_builder_settings(),
        tab_builder_messages(),
        tab_builder_input()
    ]
end
function tab_history()
    [
        h3("History of Old Conversations"),
        col(class = "flex",
            btn("Reload from Disk", @click(:history_reload), icon = "refresh")),
        separator(),
        list(@for("(item, index) in history"),
            key = R"item.id",
            item(
                [item_section(icon("chat"), :avatar)
                 item_section("{{item.name}} {{item.label}}")],
                :clickable,
                :v__ripple,
                @on("click", "history_current_name = item.name"))
        ),
        separator(),
        Html.div(class = "mt-5", @for("(item, index) in history_current"),
            key! = R"item.id",
            messagecard("{{item.content}}", title = "{{item.title}}")
        ),
        cell(class = "flex",
            [
                btn("Fork the conversation", @click(:history_fork),
                class = "btn btn-secondary")
            ])
    ]
end
function tab_templates()
    [
        h3("Template Browser"),
        textfield("Filter keywords", :template_filter,
            clearable = true, class = "mb-4",
            @on("keyup.enter",
                "template_submit = !template_submit")),
        separator(),
        Html.div(class = "mt-5", @for("item in templates"),
            [
                templatecard(; title = "{{item.name}}", subtitle = "{{item.description}}",
                metadata = "Version: {{item.version}}, Wordcount: {{item.wordcount}}, Placeholders: {{item.variables}}",
                system = "{{item.system_preview}}", user = "{{item.user_preview}}")
            ]
        )
    ]
end
function tab_config()
    [h3("Configuration"),
        row(class = "col-6", select(:model, options = :model_options, label = "Model")),
        row(class = "col-6 pb-5",
            textfield("Add a new model", :model_input, hint = "Confirm with ENTER",
                @on("keyup.enter", "model_submit = !model_submit"))),
        separator(),
        cell([
            textfield("Default System Prompt", :system_prompt,
            hint = "Will be sent to the AI model as the first instruction.")
        ])        ## TODO: stats - tokens + cost
    ]
end

## Page Container
function ui()
    layout(view = "hHh Lpr lff", title = "ProToPortal", head_content = "",
        [
            Genie.Assets.favicon_support(),
            ##    
            quasar(:header,
                style = "background:black",
                [toolbar(
                    [
                    btn(; dense = true, flat = true, round = true, icon = "menu",
                        @click("left_drawer_open = !left_drawer_open")),
                    toolbartitle("ProToPortal")
                ])]),
            drawer(bordered = "", fieldname = "left_drawer_open", side = "left",
                var":mini" = "ministate", var"@mouseover" = "ministate = false",
                var"@mouseout" = "ministate = true", var"mini-to-overlay" = true,
                width = "170", breakpoint = 200,
                class = "bg-black",
                list(bordered = true, separator = true,
                    [
                        item(
                            clickable = "", vripple = "", @click("selected_page = 'chat'"),
                            [
                                itemsection(avatar = true, icon("chat")),
                                itemsection("Chat")
                            ]),
                        item(clickable = "", vripple = "",
                            @click("selected_page = 'history'"),
                            [
                                itemsection(avatar = true, icon("history")),
                                itemsection("History")
                            ]),
                        item(clickable = "", vripple = "",
                            @click("selected_page = 'templates'"),
                            [
                                itemsection(avatar = true, icon("bolt")),
                                itemsection("Templates")
                            ]),
                        item(clickable = "", vripple = "",
                            @click("selected_page = 'config'"),
                            [
                                itemsection(avatar = true, icon("settings")),
                                itemsection("Configuration")
                            ]),
                        item([itemsection(avatar = true, icon("science")),
                            itemsection("EXPERIMENTAL")]),
                        item(
                            clickable = "", vripple = "", @click("selected_page = 'meta'"),
                            [
                                itemsection(avatar = true, icon("groups")),
                                itemsection("Meta-Prompting")
                            ]),
                        item(
                            clickable = "", vripple = "", @click("selected_page = 'builder'"),
                            [
                                itemsection(avatar = true, icon("construction")),
                                itemsection("Prompt Builder")
                            ])
                    ]
                )),
            page_container(class = "mx-8",
                [
                    Html.div(class = "", @iif("selected_page == 'chat'"), tab_chat()),
                    Html.div(class = "", @iif("selected_page == 'history'"), tab_history()),
                    Html.div(
                        class = "", @iif("selected_page == 'templates'"), tab_templates()),
                    Html.div(class = "", @iif("selected_page == 'config'"), tab_config()),
                    Html.div(class = "", @iif("selected_page == 'meta'"), tab_meta()),
                    Html.div(class = "", @iif("selected_page == 'builder'"), tab_builder())
                ]),
            quasar(:footer, reveal = true, bordered = false,
                class = "bg-white text-primary text-caption text-center",
                [
                    p([span("Powered by "),
                    a(href = "https://github.com/GenieFramework/Stipple.jl",
                        "Stipple.jl from the GenieFramework. "),
                    span("Icons by "), a(href = "https://icons8.com/about", "Icons8")])
                ])            ##
        ])
end

function ui_login()
    flash_string = flash_has_message() ?
                   "<div class=\"form-group alert alert-info\">$(flash())</div>" : ""

    """
    <h1 class="display-3">Login</h1>

    <div class="bs-callout bs-callout-primary">
        <p>
        Please authenticate in order to access the information.
        </p>
    </div>

    $flash_string

    <form method="POST" action="/login" class="" enctype="multipart/form-data">
        <div class="form-group">
        <label _for="auth_username">Username</label>
        <input type="text" id="auth_username" name="username" class="form-control" placeholder="User" />
        </div>

        <div class="form-group">
        <label _for="auth_password">Password</label>
        <input type="password" id="auth_password" name="password" class="form-control" placeholder="Password" />
        </div>

        <input type="submit" value="Login" class="btn btn-primary" />
    </form>
    """
end

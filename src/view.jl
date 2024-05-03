## Individual Tabs
function tab_chat()
    # Note: tab_chat blocks are defined separately in src/view_chat.jl
    [
        h3("Chat"),
        tab_chat_templates(),
        separator(@iif("!!conv_displayed.length")),
        tab_chat_messages(),
        separator(@iif("!!conv_displayed.length")),
        tab_chat_input()
    ]
end
function tab_history()
    [
        h3("History of Old Conversations"),
        col(class="flex",btn("Reload from Disk",@click(:history_reload), icon = "refresh")),
        separator(),
        list(@for("(item, index) in history"),
            key=R"item.id",
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
            btn("Fork the conversation", @click(:history_fork), class="btn btn-secondary"),
        ])
    ]
end
function tab_templates()
    [
        h3("Template Browser"),
        textfield("Filter keywords", :template_filter,
            clearable = true,class="mb-4",
            @on("keyup.enter",
                "template_submit = !template_submit")),
        separator(),
        Html.div(class = "mt-5", @for("item in templates"),
            [
                templatecard(; title = "{{item.name}}", subtitle = "{{item.description}}",
                metadata = "Version: {{item.version}}, Wordcount: {{item.wordcount}}, Placeholders: {{item.variables}}",
                system = "{{item.system_preview}}", user = "{{item.user_preview}}")
            ]
        ),
    ]
end
function tab_model_settings()
    [
            p("Model", class = "text-lg text-weight-bold "),
        row(class="col-6",select(:model, options = :model_options, label = "Model")),
        row(class="col-6 pb-5",textfield("Add a new model", :model_input, hint="Confirm with ENTER",@on("keyup.enter", "model_submit = !model_submit"))),
        separator(),
        cell([
            textfield("Default System Prompt",:system_prompt, hint="Will be sent to the AI model as the first instruction.")
        ]),
        ## TODO: stats - tokens + cost
        
        ]
end

function tab_config()
    [h3("Configuration"),
    Html.div(class="mt-5",@iif("selected_page == 'config-model'"),tab_model_settings()),
    Html.div(class="mt-5",@iif("selected_page == 'config-chat'"),tab_chat_settings())
    ]
end

## Page Container
function ui()
    layout(view = "hHh Lpr lff",title="ProToPortal", head_content = "",
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
                        expansionitem( label="Configuration", icon="settings", [
                                      item(clickable = "", vripple = "",
                                           @click("selected_page = 'config-model'"),
                                           [
                                            itemsection(class="pl-10","Model")
                                           ]),
                                      item(clickable = "", vripple = "",
                                           @click("selected_page = 'config-chat'"),
                                           [
                                            itemsection(class="pl-10","Chat")
                                           ])
                                     ]
                                     )
                    ]
                )),
            page_container(class = "mx-8",
                [
                    Html.div(class = "w-4/5 ml-auto mr-auto", @iif("selected_page == 'chat'"), tab_chat()),
                    Html.div(class = "w-4/5 ml-auto mr-auto", @iif("selected_page == 'history'"), tab_history()),
                    Html.div(
                       class = "w-4/5 ml-auto mr-auto", @iif("selected_page == 'templates'"), tab_templates()),
                    Html.div(class = "w-4/5 ml-auto mr-auto", @iif("selected_page.includes('config')"), tab_config())]),
                    
                    quasar(:footer,reveal=true,bordered=false,class="bg-white text-primary text-caption text-center",
                    [
                    p([span("Powered by "), a(href="https://github.com/GenieFramework/Stipple.jl","Stipple.jl from the GenieFramework. "),
                    span("Icons by "), a(href="https://icons8.com/about","Icons8")]),
                    ])
            ##
        ])
end

function ui_login()
    flash_string = flash_has_message() ?  "<div class=\"form-group alert alert-info\">$(flash())</div>" : ""

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

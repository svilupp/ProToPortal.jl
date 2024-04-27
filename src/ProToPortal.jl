module ProToPortal

using PromptingTools
const PT = PromptingTools
using PromptingTools: JSON3
using PromptingTools: AICode, last_message, last_output
using PromptingTools.Experimental.AgentTools: aicodefixer_feedback, airetry!, AICall,
                                              AIGenerate
const AT = PromptingTools.Experimental.AgentTools

using GenieFramework
using GenieSession
using GenieFramework.StippleUI.Layouts: layout
using GenieFramework.StippleUI.API: kw
const S = GenieFramework.StippleUI

export Genie, Server, up, down

export msg2display, display2msg, template_variables, update_message, update_message!
export render_messages, render_template_messages
export conversation2transcript, parse_critic, load_conversations_from_dir
include("utils.jl")

export flash, flash_has_message
include("flash.jl")

export messagecard, templatecard
include("components.jl")

include("view_chat.jl")

export ui, ui_login
include("view.jl")

export authenticate, deauthenticate, authenticated, authenticated!
include("authentication.jl")

export send_to_model, prepare_conversation, label_conversation, evaluate_code
export build_lazy_aicall, autofix_code
include("llm.jl")

function __init__()
    ## Load extra templates
    PT.load_templates!(joinpath(@__DIR__, "..", "templates"); remember_path = true) # add our custom ones
end

end #end of module

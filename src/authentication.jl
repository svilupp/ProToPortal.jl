# Source: GenieAuthetication.jl (to avoid the dependency on SearchLight)

const USER_ID_KEY = :__auth_user_id
const PARAMS_USERNAME_KEY = :username
const PARAMS_PASSWORD_KEY = :password

"""
Stores the user id on the session.
"""
function authenticate(user_id::Any, session::GenieSession.Session)::GenieSession.Session
    GenieSession.set!(session, USER_ID_KEY, user_id)
end
function authenticate(user_id::Union{String, Symbol, Int},
        params::Dict{Symbol, Any} = Genie.Requests.payload())::GenieSession.Session
    authenticate(user_id, params[:SESSION])
end

"""
    deauthenticate(session)
    deauthenticate(params::Dict{Symbol,Any})

Removes the user id from the session.
"""
function deauthenticate(session::GenieSession.Session)::GenieSession.Session
    Genie.Router.params!(:SESSION, GenieSession.unset!(session, USER_ID_KEY))
end
function deauthenticate(params::Dict = Genie.Requests.payload())::GenieSession.Session
    deauthenticate(get(params, :SESSION, nothing))
end

"""
    is_authenticated(session) :: Bool
    is_authenticated(params::Dict{Symbol,Any}) :: Bool

Returns `true` if a user id is stored on the session.
"""
function authenticated(session::Union{GenieSession.Session, Nothing})::Bool
    GenieSession.isset(session, USER_ID_KEY)
end
function authenticated(params::Dict = Genie.Requests.payload())::Bool
    authenticated(get(params, :SESSION, nothing))
end

function authenticated!(exception = Genie.Exceptions.ExceptionalResponse(Genie.Renderer.redirect(:show_login)))
    authenticated() || throw(exception)
end

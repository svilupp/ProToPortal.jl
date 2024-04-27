# original source: https://github.com/GenieFramework/GenieSession.jl/blob/main/src/Flash.jl

"""
    flash()

Returns the `flash` dict object associated with the current HTTP request.
"""
function flash()
    get(Genie.Requests.payload(), GenieSession.PARAMS_FLASH_KEY, "")
end

"""
    flash(value::Any) :: Nothing

Stores `value` onto the flash.
"""
function flash(value::Any)::Nothing
    GenieSession.set!(GenieSession.session(Genie.Requests.payload()),
        GenieSession.PARAMS_FLASH_KEY, value)
    Genie.Requests.payload()[GenieSession.PARAMS_FLASH_KEY] = value

    nothing
end

"""
    flash_has_message() :: Bool

Checks if there's any value on the flash storage
"""
function flash_has_message()::Bool
    !isempty(flash())
end

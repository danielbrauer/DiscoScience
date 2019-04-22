
local softErrorReporting = {}

local haveShownError = false

function softErrorReporting.showModError(message)
    if not haveShownError and not game.is_multiplayer() then
        game.show_message_dialog{text = {"", {message}, {"errors.please-report"}}}
        haveShownError = true
    end
end

return softErrorReporting

local softErrorReporting = {}

local haveShownError = false

function softErrorReporting.getCount(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function softErrorReporting.showModError(message)
    if not haveShownError and softErrorReporting.getCount(game.players) == 1 then
        game.show_message_dialog{text = {"", {message}, {"errors.please-report"}}}
        haveShownError = true
    end
end

return softErrorReporting
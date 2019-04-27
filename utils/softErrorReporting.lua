
softErrorReporting = {}

softErrorReporting.haveShownError = false

function softErrorReporting.showModError(message)
    if not softErrorReporting.haveShownError and not game.is_multiplayer() then
        game.show_message_dialog{text = {"", {message}, {"errors.please-report"}}}
        softErrorReporting.haveShownError = true
    end
end
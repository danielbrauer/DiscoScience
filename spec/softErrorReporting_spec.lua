require 'busted.runner'()

describe("softErrorReporting", function()

    setup(function()
        _G.game = require("spec.mocks.game")
        require("utils.softErrorReporting")
    end)

    before_each(function()
        softErrorReporting.haveShownError = false
        stub(game, "show_message_dialog")
        game.mockIsMultiplayer = false
    end)

    after_each(function()
        game.show_message_dialog:revert()
    end)

    describe("showModError", function()
        it("calls show_message_dialog", function()
            softErrorReporting.showModError("")
            assert.stub(game.show_message_dialog).was.called()
        end)

        it("only calls show_message_dialog once", function()
            softErrorReporting.showModError("")
            softErrorReporting.showModError("")
            assert.stub(game.show_message_dialog).was.called(1)
        end)

        it("doesn't call in multiplayer", function()
            game.mockIsMultiplayer = true
            softErrorReporting.showModError("")
            assert.stub(game.show_message_dialog).was_not_called()
        end)
    end)

end)
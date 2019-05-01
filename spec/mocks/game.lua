local game = {}

game.mockIsMultiplayer = false

game.is_multiplayer = function()
    return game.mockIsMultiplayer
end

game.show_message_dialog = function()
    assert.is_false(game.is_multiplayer())
end

return game
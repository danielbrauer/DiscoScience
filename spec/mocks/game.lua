local game = {}

game.mockIsMultiplayer = false

game.mockTechPrototypes = {}

game.reset = function()
    game.mockIsMultiplayer = false
    game.mockTechPrototypes = {}
end

game.is_multiplayer = function()
    return game.mockIsMultiplayer
end

game.show_message_dialog = function()
    assert.is_false(game.is_multiplayer())
end

game.get_filtered_technology_prototypes = function()
    return game.mockTechPrototypes
end

return game
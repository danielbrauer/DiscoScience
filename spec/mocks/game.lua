local game = {}

game.mockIsMultiplayer = false

game.mockTechPrototypes = {}

game.mockSurface = {}
game.mockSurface.find_entities_filtered = function(a)
    return {}
end

game.surfaces = {0,1}

game.forces = {}

game.get_surface = function(index)
    return game.mockSurface
end

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

return game
require("spec.mocks.game")

local prototypes = {}

prototypes.get_technology_filtered = function()
    return game.mockTechPrototypes
end

--FIXME: Need to mock the mod_data

return prototypes
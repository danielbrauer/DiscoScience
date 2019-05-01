feature("Disco Science", function()
    
    before_scenario(function()
        when(softErrorReporting, "showModError"):then_return(true)
    end)

    after_scenario(function()
        softErrorReporting.showModError:revert()
    end)
    
    scenario("Test unregistered lab", function()
        
        for index,player in pairs(game.connected_players) do
            local labPos = player.character.position
            labPos.x = labPos.x + 2
            local lab = player.character.surface.create_entity{name = "lab", position = labPos, force = game.forces.neutral, raise_built = false}
            script.raise_event(defines.events.script_raised_built, {created_entity = lab})
            -- labPos.x = labPos.x - 4
            -- local lab = player.character.surface.create_entity{name = "lab", position = labPos, force = game.forces.neutral, raise_built = false}
            -- script.raise_event(defines.events.script_raised_built, {created_entity = lab})
            break
        end
    end)
    
    scenario("Test Scenario", function()
        
        for index,player in pairs(game.connected_players) do
            local labPos = player.character.position
            labPos.x = labPos.x + 2
            local lab = player.character.surface.create_entity{name = "lab", position = labPos, force = player.force, raise_built = false}
            script.raise_event(defines.events.script_raised_built, {created_entity = lab})
            -- labPos.x = labPos.x - 4
            -- local lab = player.character.surface.create_entity{name = "lab", position = labPos, force = game.forces.neutral, raise_built = false}
            -- script.raise_event(defines.events.script_raised_built, {created_entity = lab})
            break
        end
    end)
end)
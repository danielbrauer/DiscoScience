feature("Disco Science", function()

    before_scenario(function()
        when(softErrorReporting, "showModError"):then_return(true)
        local entities = game.surfaces[1].find_entities()
        for _, entity in ipairs(entities) do
            entity.destroy()
        end
    end)

    after_scenario(function()
        softErrorReporting.showModError:revert()
    end)

    local create_lab = function(offset, force, raise_built)
        local labPos = {x=offset, y=0}
        return game.surfaces[1].create_entity{
            name = "lab",
            position = labPos,
            force = game.forces.neutral,
            raise_built = raise_built
        }
    end

    scenario("Lab with event", function()
        local lab = create_lab(2, game.forces.neutral, true)
        local animation = storage.labRendererData.labAnimations[lab.unit_number]
        assert(animation, "missing animation")
        assert(animation.target.entity.unit_number == lab.unit_number, "animation target incorrect")
        local labsForForce = storage.labRendererData.labsByForce[game.forces.neutral.index]
        assert(labsForForce, "Lab list doesn't exist")
        local _, newLab = next(labsForForce)
        assert(newLab, "New lab not in lab list")
        assert(newLab.unit_number == lab.unit_number, "Lab in lab list doesn't match new lab")
    end)

    scenario("Lab without event", function()
        local lab = create_lab(2, game.forces.neutral, false)
        local animation = storage.labRendererData.labAnimations[lab.unit_number]
        faketorio.log.info("animation: %s", {animation.valid})
        assert(animation, "missing animation")
        faketorio.log.info("target: %s", {animation.target.entity.valid})
        faketorio.log.info("lab: %s", {lab.valid})
        assert(animation.target.entity.unit_number == lab.unit_number, "animation target incorrect")
        local labsForForce = storage.labRendererData.labsByForce[game.forces.neutral.index]
        for _, lerb in pairs(labsForForce) do
            faketorio.log.info("lerb: %s", {lerb.valid})
        end
        assert(labsForForce, "Lab list doesn't exist")
        local _, newLab = next(labsForForce)
        assert(newLab, "New lab not in lab list")
        assert(newLab.unit_number == lab.unit_number, "Lab in lab list doesn't match new lab")
    end)
end)
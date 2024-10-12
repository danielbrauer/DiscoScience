local labColoring = {}

labColoring.colorMath = require("utils.colorMath")

local working = defines.entity_status.working
local low_power = defines.entity_status.low_power

local max = math.max
local random = math.random
local floor = math.floor

-- constants

local stride = 6

-- state

labColoring.state = nil

labColoring.colorForLab = nil

labColoring.linkState = function (state)
    labColoring.state = state
    if labColoring.state then
        local colorFunctions = labColoring.colorMath.colorFunctions
        labColoring.colorForLab = colorFunctions[labColoring.state.lastColorFunc]
    end
    return state
end

labColoring.initialState = {
    lastColorFunc = 1,
    direction = 1,
    meanderingTick = 0,
}

labColoring.configurationChanged = function ()
    labColoring.linkState(labColoring.initialState)
end

labColoring.chooseNewFunction = function()
    local colorFunctions = labColoring.colorMath.colorFunctions
    if #colorFunctions > 1 then
        local newColorFunc = random(1, #colorFunctions - 1)
        if newColorFunc >= labColoring.state.lastColorFunc then
            newColorFunc = newColorFunc + 1
        end
        labColoring.colorForLab = colorFunctions[newColorFunc]
        labColoring.state.lastColorFunc = newColorFunc
    end
end

labColoring.chooseNewDirection = function()
    if labColoring.state.meanderingTick > 0 then
        labColoring.state.direction = floor(random()*1.999)*2 - 1
    else
        labColoring.state.direction = 1
    end
end

labColoring.getInfoForForce = function (force, labRenderers, researchColor)
    local labsForForce = labRenderers.labsForForce(force.index)
    if labsForForce then
        local colors = researchColor.getColorsForResearch(force.current_research)
        local playerPosition = {x = 0, y = 0}
        if force.players[1] then
            playerPosition = force.players[1].position
        end
        return labsForForce, colors, playerPosition
    else
        return nil
    end
end

labColoring.updateRenderer = function (lab, colors, playerPosition, labRenderers, fcolor)
    local animation = labRenderers.getRenderObjects(lab)
    if lab.status == working or lab.status == low_power then
        if not animation.visible then
            animation.visible = true
        end
        labColoring.colorForLab(labColoring.state.meanderingTick, colors, playerPosition, lab.position, fcolor)
        animation.color = fcolor
    else
        if animation.visible then
            animation.visible = false
        end
    end
end

labColoring.updateRenderers = function (event, labRenderers, researchColor)
    labColoring.state.meanderingTick = max(0, labColoring.state.meanderingTick + labColoring.state.direction)
    local offset = event.tick % stride
    local fcolor = {r=0, g=0, b=0, a=0}
    for name, force in pairs(game.forces) do
        local labsForForce, colors, playerPosition = labColoring.getInfoForForce(force, labRenderers, researchColor)
        if labsForForce then
            for unitNumber, lab in pairs(labsForForce) do
                if unitNumber % stride == offset then
                    if not lab.valid then
                        softErrorReporting.showModError("errors.registered-lab-deleted")
                        labRenderers.reloadLabs()
                        return
                    end
                    labColoring.updateRenderer(lab, colors, playerPosition, labRenderers, fcolor)
                end
            end
        end
    end
end

return labColoring
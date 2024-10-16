local labColoring = {}

labColoring.colorMath = require("utils.colorMath")

local working = defines.entity_status.working
local low_power = defines.entity_status.low_power

local max = math.max
local random = math.random
local floor = math.floor

local getStride = function(hq)
    if hq then return 6 else return 20 end
end

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

labColoring.createInitialState = function()
    return {
        lastColorFunc = 1,
        direction = 1,
        meanderingTick = 0,
    }
end

labColoring.configurationChanged = function ()
    labColoring.linkState(labColoring.createInitialState())
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

labColoring.updateRenderer = function (lab, colors, hq, playerPosition, labRenderers, fcolor)
    local animation = labRenderers.getRenderObjects(lab)
    if lab.status == working or lab.status == low_power then
        if not animation.visible then
            animation.visible = true
        end
        if hq then
            labColoring.colorForLab(labColoring.state.meanderingTick, colors, playerPosition, lab.position, fcolor)
        else
            labColoring.colorMath.loopInterpolate(game.tick/40.0, colors, 1.5, fcolor)
        end
        animation.color = fcolor
    else
        if animation.visible then
            animation.visible = false
        end
    end
end

labColoring.updateRenderers = function (event, labRenderers, researchColor)
    local hq = settings.global["discoscience-high-quality"].value
    labColoring.state.meanderingTick = max(0, labColoring.state.meanderingTick + labColoring.state.direction)
    local stride = getStride(hq)
    local offset = event.tick % stride
    local fcolor = {r=0, g=0, b=0, a=0}
    local forceInfo = {}
    for name, force in pairs(game.forces) do
        local forceResearchColors = researchColor.getColorsForResearch(force.current_research)
        local playerPosition = {x = 0, y = 0}
        local _, firstConnectedPlayer = next(force.connected_players)
        if firstConnectedPlayer then
            playerPosition = firstConnectedPlayer.position
        end
        forceInfo[force.index] = {forceResearchColors, playerPosition}
    end
    for unitNumber, lab in pairs(labRenderers.getLabs()) do
        if unitNumber % stride == offset then
            if not lab.valid then
                softErrorReporting.showModError("errors.registered-lab-deleted")
                labRenderers.reloadLabs()
                return
            end
            local info = forceInfo[lab.force_index]
            labColoring.updateRenderer(lab, info[1], hq, info[2], labRenderers, fcolor)
        end
    end
end

return labColoring
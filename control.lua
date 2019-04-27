local set_color = rendering.set_color
local get_visible = rendering.get_visible
local set_visible = rendering.set_visible
local destroy = rendering.destroy
local is_valid = rendering.is_valid
local working = defines.entity_status.working
local low_power = defines.entity_status.low_power
local floor = math.floor
local random = math.random
local max = math.max

require("utils.softErrorReporting")

local colorMath = require("utils.colorMath")
local colorFunctions = colorMath.colorFunctions

local researchColor = require("core.researchColor")
local labRenderers = require("core.labRenderers")

-- global state

local labRendererData

local scalarState

-- constants

local stride = 6

local defaultScalarState = {
    lastColorFunc = 1,
    direction = 1,
    meanderingTick = 0,
}

local createData = function ()
    global.labRendererData = labRenderers.defaultData

    global.researchColorData = researchColor.defaultData

    global.scalarState = defaultScalarState
end

local linkData = function ()
    labRendererData = labRenderers.init(global.labRendererData)

    researchColor.init(global.researchColorData)

    scalarState = global.scalarState
    if scalarState then
        colorForLab = colorFunctions[scalarState.lastColorFunc % #colorFunctions + 1]
    end
end

local resetConfigDependents = function ()
    if global.labsByForce then -- Update from old, separate tables
        labRendererData = {
            labsByForce = {},
            labAnimations = global.labAnimations or {},
            labLights = global.labLights or {},
        }
        global.labRendererData = labRenderers.init(labRendererData)
        global.labsByForce = nil
        global.labAnimations = nil
        global.labLights = nil
    end
        
    global.researchColorData = researchColor.init(researchColor.defaultData)

    global.scalarState = defaultScalarState
    scalarState = global.scalarState
    scalarState.meanderingTick = game.tick
    
    colorForLab = colorFunctions[scalarState.lastColorFunc]
end

script.on_init(
    function ()
        createData()
        linkData()
        labRenderers.reloadLabs()
        researchColor.loadIngredientColors()
    end
)

script.on_load(
    function ()
        linkData()
    end
)

script.on_configuration_changed(
    function ()
        resetConfigDependents()
        labRenderers.reloadLabs()
        researchColor.loadIngredientColors()
    end
)

script.on_event(
    {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity
    },
    function (event)
        labRenderers.addLab(event.created_entity)
    end
)

script.on_event(
    {
        defines.events.script_raised_built,
        defines.events.script_raised_revive
    },
    function (event)
        labRenderers.addLab(event.entity)
    end
)

script.on_event(
    {
        defines.events.on_entity_died,
        defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.script_raised_destroy
    },
    function (event)
        labRenderers.removeLab(event.entity)
    end
)

script.on_event(
    {defines.events.on_forces_merged},
    function (event)
        labRenderers.reloadLabs()
    end
)

script.on_nth_tick(
    60,
    function (event)
        if #colorFunctions > 1 then
            local newColorFunc = random(1, #colorFunctions - 1)
            if newColorFunc >= scalarState.lastColorFunc then
                newColorFunc = newColorFunc + 1
            end
            colorForLab = colorFunctions[newColorFunc]
            scalarState.lastColorFunc = newColorFunc
        end
        if scalarState.meanderingTick > 0 then
            scalarState.direction = floor(random()*1.999)*2 - 1
        else
            scalarState.direction = 1
        end
    end
)

script.on_event(
    {defines.events.on_tick},
    function (event)
        scalarState.meanderingTick = max(0, scalarState.meanderingTick + scalarState.direction)
        local offset = event.tick % stride
        local fcolor = {r=0, g=0, b=0, a=0}
        for name, force in pairs(game.forces) do
            local labsForForce = labRendererData.labsByForce[force.index]
            if labsForForce then
                local colors = researchColor.getColorsForResearch(force.current_research)
                local playerPosition = {x = 0, y = 0}
                if force.players[1] then
                    playerPosition = force.players[1].position
                end
                for index, lab in pairs(labsForForce) do
                    if index % stride == offset then
                        if not lab.valid then
                            softErrorReporting.showModError("errors.registered-lab-deleted")
                            labRenderers.reloadLabs()
                            return
                        end
                        local animation, light = labRenderers.getRenderObjects(lab)
                        if lab.status == working or lab.status == low_power then
                            if not get_visible(animation) then
                                set_visible(animation, true)
                                set_visible(light, true)
                            end
                            colorForLab(scalarState.meanderingTick, colors, playerPosition, lab.position, fcolor)
                            set_color(animation, fcolor)
                            set_color(light, fcolor)
                        else
                            if get_visible(animation) then
                                set_visible(animation, false)
                                set_visible(light, false)
                            end
                        end
                    end
                end
            end
        end
    end
)
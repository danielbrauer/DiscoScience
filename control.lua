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

local colorMath = require("utils.colorMath")
local colorFunctions = colorMath.colorFunctions

local softErrorReporting = require("utils.softErrorReporting")

-- global state

local labsByForce
local labAnimations
local labLights

local researchColors
local ingredientColors

local scalarState

-- constants

local unrecognizedColor = {r = 1.0, g = 0.0, b = 1.0}
local defaultColors = {unrecognizedColor}

local stride = 6

local defaultScalarState = {
    lastColorFunc = 1,
    direction = 1,
    meanderingTick = 0,
}

local loadIngredientColors = function ()
    global.ingredientColors = {["unrecognized"] = unrecognizedColor}
    ingredientColors = global.ingredientColors
    local index = 1
    while true do
        local prototype = game.entity_prototypes["DiscoScience-colors-"..index]
        if not prototype then break end
        local pair = loadstring(prototype.order)
        for name, color in pairs(pair()) do
            ingredientColors[name] = color
        end
        index = index + 1
    end
end

local createData = function ()
    global.labsByForce = {}
    global.labAnimations = {}
    global.labLights = {}

    global.researchColors = {}
    global.ingredientColors = {}

    global.scalarState = defaultScalarState
end

local linkData = function ()
    labAnimations = global.labAnimations
    labLights = global.labLights
    labsByForce = global.labsByForce

    researchColors = global.researchColors
    ingredientColors = global.ingredientColors

    scalarState = global.scalarState
    if scalarState then
        colorForLab = colorFunctions[scalarState.lastColorFunc % #colorFunctions + 1]
    end
end

local createAnimation = function (entity)
    labAnimations[entity.unit_number] = rendering.draw_animation({
        animation = "discoscience/lab-storm",
        surface = entity.surface,
        target = entity,
        render_layer = "higher-object-under",
        animation_offset = floor(random()*300)
    })
end

local createLight = function (entity)
    labLights[entity.unit_number] = rendering.draw_light({
        sprite = "utility/light_medium",
        surface = entity.surface,
        target = entity,
        intensity = 0.75,
        size = 8,
        color = {r = 1.0, g = 1.0, b = 1.0}
    })
end

local addLab = function (entity)
    if not entity or not entity.valid then
        softErrorReporting.showModError("errors.unregistered-entity-created")
        return
    end
    if entity.type == "lab" then
        if not labsByForce[entity.force.index] then
            labsByForce[entity.force.index] = {}
        end
        local labUnitNumber = entity.unit_number
        if labsByForce[entity.force.index][labUnitNumber] then
            softErrorReporting.showModError("errors.lab-registered-twice")
            return
        end
        labsByForce[entity.force.index][labUnitNumber] = entity
        if not labAnimations[labUnitNumber] then
            createAnimation(entity)
        end
        if not labLights[labUnitNumber] then
            createLight(entity)
        end
    end
end

local reloadLabs = function ()
    global.labsByForce = {}
    labsByForce = global.labsByForce
    for index, lab in ipairs(game.surfaces[1].find_entities_filtered({type = "lab"})) do
        addLab(lab)
    end
end

local resetConfigDependents = function ()
    global.researchColors = {}
    researchColors = global.researchColors

    global.scalarState = defaultScalarState
    scalarState = global.scalarState
    scalarState.meanderingTick = game.tick
    
    colorForLab = colorFunctions[scalarState.lastColorFunc]
end

script.on_init(
    function ()
        createData()
        linkData()
        reloadLabs()
        loadIngredientColors()
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
        reloadLabs()
        loadIngredientColors()
    end
)

local getColorsForResearch = function (tech)
    if not tech then
        return defaultColors
    else
        local techName = tech.prototype.name;
        if not researchColors[techName] then
            local colors = {}
            for index, ingredient in pairs(tech.research_unit_ingredients) do
                colors[index] = ingredientColors[ingredient.name]
                if not colors[index] then
                    colors[index] = ingredientColors.unrecognized
                end
            end
            if #colors == 0 then
                colors = defaultColors
            end
            researchColors[techName] = colors
        end
        return researchColors[techName]
    end
end

local removeLab = function (entity)
    if entity.type == "lab" then
        local labUnitNumber = entity.unit_number
        labAnimations[labUnitNumber] = nil
        labLights[labUnitNumber] = nil
        if labsByForce[entity.force.index] then
            local removed = false
            if labsByForce[entity.force.index][labUnitNumber] then
                labsByForce[entity.force.index][labUnitNumber] = nil
            else
                softErrorReporting.showModError("errors.unregistered-lab-deleted")
            end
        else
            softErrorReporting.showModError("errors.unregistered-lab-deleted")
        end 
    end
end

local getRenderObjects = function(entity)
    local labUnitNumber = entity.unit_number
    if not is_valid(labAnimations[labUnitNumber]) then
        createAnimation(entity)
        softErrorReporting.showModError("errors.render-object-destroyed")
    end
    if not is_valid(labLights[labUnitNumber]) then
        createLight(entity)
        softErrorReporting.showModError("errors.render-object-destroyed")
    end
    return labAnimations[labUnitNumber], labLights[labUnitNumber]
end

script.on_event(
    {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity
    },
    function (event)
        addLab(event.created_entity)
    end
)

script.on_event(
    {
        defines.events.script_raised_built,
        defines.events.script_raised_revive
    },
    function (event)
        addLab(event.entity)
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
        removeLab(event.entity)
    end
)

script.on_event(
    {defines.events.on_forces_merged},
    function (event)
        reloadLabs()
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
            if labsByForce[force.index] then
                local colors = getColorsForResearch(force.current_research)
                local playerPosition = {x = 0, y = 0}
                if force.players[1] then
                    playerPosition = force.players[1].position
                end
                for index, lab in pairs(labsByForce[force.index]) do
                    if index % stride == offset then
                        if not lab.valid then
                            softErrorReporting.showModError("errors.registered-lab-deleted")
                            reloadLabs()
                            return
                        end
                        local animation, light = getRenderObjects(lab)
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
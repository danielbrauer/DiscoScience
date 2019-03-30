--control.lua

local set_color = rendering.set_color
local get_visible = rendering.get_visible
local set_visible = rendering.set_visible
local destroy = rendering.destroy
local working = defines.entity_status.working
local low_power = defines.entity_status.low_power
local floor = math.floor
local modf = math.modf
local min = math.min

local labsByForce = nil
local labAnimations = nil
local labLights = nil

local researchColors = {}
local ingredientColors =
{
    ["automation-science-pack"] = {r = 1.0, g = 0.1, b = 0.1},
    ["logistic-science-pack"] =   {r = 0.1, g = 1.0, b = 0.1},
    ["chemical-science-pack"] =   {r = 0.2, g = 0.2, b = 1.0},
    ["military-science-pack"] =   {r = 1.0, g = 0.5, b = 0.0},
    ["production-science-pack"] = {r = 0.8, g = 0.1, b = 0.8},
    ["utility-science-pack"] =    {r = 1.0, g = 0.9, b = 0.1},
    ["space-science-pack"] =      {r = 0.8, g = 0.8, b = 0.8},
    ["unrecognized"] =            {r = 1.0, g = 1.0, b = 1.0},
}

local getColorsForResearch = function (tech)
    if not tech then
        return {}
    else
        if not researchColors[tech] then
            local colors = {}
            for index, ingredient in pairs(tech.research_unit_ingredients) do
                colors[index] = ingredientColors[ingredient.name]
                if not colors[index] then
                    colors[index] = ingredientColors.unrecognized
                end
            end
            researchColors[tech] = colors
        end
        return researchColors[tech]
    end
end

local lerpColor = function (x, a, b, out)
    out.r = a.r + (b.r - a.r) * x
    out.g = a.g + (b.g - a.g) * x
    out.b = a.b + (b.b - a.b) * x
end

local addLab = function (entity)
    if entity.type == "lab" then
        if not labsByForce[entity.force.index] then
            labsByForce[entity.force.index] = {}
        end
        table.insert(labsByForce[entity.force.index], entity)
        if not labAnimations[entity.unit_number] then
            labAnimations[entity.unit_number] = rendering.draw_animation({
                animation = "discoscience/lab-storm",
                surface = entity.surface,
                target = entity,
                render_layer = "higher-object-under",
                animation_offset = floor(math.random()*300)
            })
            set_visible(labAnimations[entity.unit_number], false)
            labLights[entity.unit_number] = rendering.draw_light({
                sprite = "utility/light_medium",
                surface = entity.surface,
                target = entity,
                intensity = 0.75,
                size = 8,
                color = {r = 1.0, g = 1.0, b = 1.0}
            })
            set_visible(labLights[entity.unit_number], false)
        end
    end
end

local removeLab = function (entity)
    if entity.type == "lab" then
        if labAnimations[entity.unit_number] then
            labAnimations[entity.unit_number] = nil
            labLights[entity.unit_number] = nil
        end
        if labsByForce[entity.force.index] then
            for index, lab in ipairs(labsByForce[entity.force.index]) do
                if lab == entity then
                    table.remove(labsByForce[entity.force.index], index)
                    return
                end
            end
        end
    end
end

local createData = function ()
    global.labAnimations = {}
    global.labLights = {}
end

local linkData = function ()
    labAnimations = global.labAnimations
    labLights = global.labLights
end

script.on_init(
    function ()
        createData()
        linkData()
    end
)

script.on_load(
    function ()
        linkData()
    end
)

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

local reloadLabs = function ()
    labsByForce = {}
    for index, lab in ipairs(game.surfaces[1].find_entities_filtered({type = "lab"})) do
        addLab(lab)
    end
end

script.on_event(
    {defines.events.on_forces_merged},
    function (event)
        reloadLabs()
    end
)

script.on_event(
    {defines.events.on_tick},
    function (event)
        if not labsByForce then
            reloadLabs()
        end
        local oddness = event.tick % 5
        local fcolor = {r=0, g=0, b=0, a=0}
        for name, force in pairs(game.forces) do
            if labsByForce[force.index] then
                local colors = getColorsForResearch(force.current_research)
                for index, lab in pairs(labsByForce[force.index]) do
                    if index % 5 == oddness then
                        local unitNumber = lab.unit_number;
                        local animation = labAnimations[unitNumber]
                        local light = labLights[unitNumber]
                        if lab.status == working or lab.status == low_power then
                            if not get_visible(animation) then
                                set_visible(animation, true)
                                set_visible(light, true)
                            end
                            local t = event.tick + unitNumber
                            local index1 = floor(t/60.0)
                            local index2 = index1 + 1
                            local color1 = colors[index1 % #colors + 1]
                            local color2 = colors[index2 % #colors + 1]
                            local dummy, x = modf(t/60.0)
                            x = min(x*5, 1)
                            lerpColor(x, color1, color2, fcolor)
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
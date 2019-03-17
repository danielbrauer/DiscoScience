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

local labs = nil
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
    ["space-science-pack"] =      {r = 0.8, g = 0.8, b = 0.8}
}

local getColorsForResearch = function (tech)
    if tech == nil then
        return {}
    else
        if researchColors[tech] == nil then
            local colors = {}
            for index, ingredient in pairs(tech.research_unit_ingredients) do
                colors[index] = ingredientColors[ingredient.name]
            end
            researchColors[tech] = colors
        end
        return researchColors[tech]
    end
end

local lerp = function (x, a, b)
    return a + (b - a) * x
end

local lerpColor = function (x, a, b)
    return {
        r = lerp(x, a.r, b.r),
        g = lerp(x, a.g, b.g),
        b = lerp(x, a.b, b.b)
    }
end

local addLab = function (entity)
    if entity.type == "lab" then
        table.insert(labs, entity)
        labAnimations[entity.unit_number] = rendering.draw_animation({
            animation = "discoscience/lab-storm",
            surface = entity.surface,
            target = entity,
            render_layer = "higher-object-under",
            -- animation_offset = math.random()*300,
            -- animation_speed = 0.9 + math.random()*0.2
        })
        labLights[entity.unit_number] = rendering.draw_light({
            sprite = "utility/light_medium",
            surface = entity.surface,
            target = entity,
            intensity = 0.75,
            size = 8,
            color = {r = 1.0, g = 1.0, b = 1.0}
        })
    end
end

local removeLab = function (entity)
    if entity.type == "lab" then
        if not labAnimations[entity.unit_number] == nil then
            -- destroy(labAnimations[entity.unit_number])
            labAnimations[entity.unit_number] = nil
            labLights[entity.unit_number] = nil
        end
        for index, lab in ipairs(labs) do
            if lab == entity then
                table.remove(labs, index)
                return
            end
        end
    end
end

script.on_init(
    function ()
        global.labAnimations = {}
        global.labLights = {}
    end
)

script.on_load(
    function ()
        labAnimations = global.labAnimations
        labLights = global.labLights
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

script.on_event(
    {defines.events.on_tick},
    function (event)
        if labs == nil then
            labs = game.surfaces[1].find_entities_filtered({type = "lab"})
        end

        for index, lab in ipairs(labs) do
            local labAnimation = labAnimations[lab.unit_number]
            local labLight = labLights[lab.unit_number]
            if lab.status == working or lab.status == low_power then
                if not get_visible(labAnimation) then
                    set_visible(labAnimation, true)
                    set_visible(labLight, true)
                end
                local colors = getColorsForResearch(lab.force.current_research)
                local t = event.tick + lab.unit_number
                local index1 = floor(t/60.0)
                local index2 = index1 + 1
                local color1 = colors[index1%#colors + 1]
                local color2 = colors[index2%#colors + 1]
                local dummy, x = modf(t/60.0)
                x = min(x*5, 1)
                local fcolor = lerpColor(x, color1, color2)
                set_color(labAnimation, fcolor)
                set_color(labLight, fcolor)
            else
                if get_visible(labAnimation) then
                    set_visible(labAnimation, false)
                    set_visible(labLight, false)
                end
            end
        end
    end
)
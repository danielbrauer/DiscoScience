require "utils.softErrorReporting"

local labRenderers = {}

local draw_animation = rendering.draw_animation
local floor = math.floor
local random = math.random

-- state

labRenderers.state = nil

labRenderers.linkState = function (state)
    labRenderers.state = state
    return state
end

labRenderers.createInitialState = function()
    return {
        labs = {},
        labAnimations = {},
        labScales = {
            ["lab"] = 1,
        }
    }
end

labRenderers.setLabScale = function (name, scale)
    labRenderers.state.labScales[name] = scale
end

labRenderers.createAnimation = function (entity)
    local scale = labRenderers.state.labScales[entity.name]
    labRenderers.state.labAnimations[entity.unit_number] = draw_animation({
        animation = "discoscience/lab-storm",
        surface = entity.surface,
        target = entity,
        x_scale = scale,
        y_scale = scale,
        render_layer = "higher-object-under",
        animation_offset = floor(random()*300),
        visible = false,
    })
end

labRenderers.isCompatibleLab = function (entity)
    if not entity.type == "lab" then return false end
    for name, _ in pairs(labRenderers.state.labScales) do
        if entity.name == name then return true end
    end
    return false
end

labRenderers.addLab = function (entity)
    if not entity or not entity.valid then
        softErrorReporting.showModError("errors.unregistered-entity-created")
        return
    end
    if labRenderers.isCompatibleLab(entity) then
        local labUnitNumber = entity.unit_number
        if labRenderers.state.labs[labUnitNumber] then
            softErrorReporting.showModError("errors.lab-registered-twice")
            return
        end
        labRenderers.state.labs[labUnitNumber] = entity
        if not labRenderers.state.labAnimations[labUnitNumber] then
            labRenderers.createAnimation(entity)
        end
    end
    script.register_on_object_destroyed(entity)
end

labRenderers.reloadLabs = function ()
    labRenderers.state.labs = {}
    labRenderers.state.labAnimations = {}
    rendering.clear("DiscoScience")
    for surfaceIndex in pairs(game.surfaces) do
        local surface = game.get_surface(surfaceIndex)
        for index, lab in ipairs(surface.find_entities_filtered({type = "lab"})) do
            labRenderers.addLab(lab)
        end
    end
end

labRenderers.removeLab = function (labUnitNumber)
    labRenderers.state.labAnimations[labUnitNumber] = nil
    if labRenderers.state.labs[labUnitNumber] then
        labRenderers.state.labs[labUnitNumber] = nil
    else
        softErrorReporting.showModError("errors.unregistered-lab-deleted")
    end
end

labRenderers.getLabs = function()
    return labRenderers.state.labs
end

labRenderers.getRenderObjects = function(entity)
    local labUnitNumber = entity.unit_number
    if not labRenderers.state.labAnimations[labUnitNumber].valid then
        labRenderers.createAnimation(entity)
    end
    return labRenderers.state.labAnimations[labUnitNumber]
end

return labRenderers
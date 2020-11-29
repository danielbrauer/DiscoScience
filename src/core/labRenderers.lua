require "utils.softErrorReporting"

local labRenderers = {}

local draw_animation = rendering.draw_animation
local is_valid = rendering.is_valid
local floor = math.floor
local random = math.random

-- state

labRenderers.state = nil

labRenderers.init = function (state)
    labRenderers.state = state
    return state
end

labRenderers.initialState = {
    labsByForce = {},
    labAnimations = {},
    labScales = {
        ["lab"] = 1,
    },
}

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
        if not labRenderers.state.labsByForce[entity.force.index] then
            labRenderers.state.labsByForce[entity.force.index] = {}
        end
        local labUnitNumber = entity.unit_number
        if labRenderers.state.labsByForce[entity.force.index][labUnitNumber] then
            softErrorReporting.showModError("errors.lab-registered-twice")
            return
        end
        labRenderers.state.labsByForce[entity.force.index][labUnitNumber] = entity
        if not labRenderers.state.labAnimations[labUnitNumber] then
            labRenderers.createAnimation(entity)
        end
    end
end

labRenderers.reloadLabs = function ()
    labRenderers.state.labsByForce = {}
    labRenderers.state.labAnimations = {}
    rendering.clear("DiscoScience")
    for index, lab in ipairs(game.surfaces[1].find_entities_filtered({type = "lab"})) do
        labRenderers.addLab(lab)
    end
end

labRenderers.removeLab = function (entity)
    if labRenderers.isCompatibleLab(entity) then
        local labUnitNumber = entity.unit_number
        labRenderers.state.labAnimations[labUnitNumber] = nil
        local labsForForce = labRenderers.state.labsByForce[entity.force.index]
        if labsForForce then
            if labsForForce[labUnitNumber] then
                labsForForce[labUnitNumber] = nil
            else
                softErrorReporting.showModError("errors.unregistered-lab-deleted")
            end
        else
            softErrorReporting.showModError("errors.unregistered-lab-deleted")
        end
    end
end

labRenderers.labsForForce = function (forceIndex)
    return labRenderers.state.labsByForce[forceIndex]
end

labRenderers.getRenderObjects = function(entity)
    local labUnitNumber = entity.unit_number
    if not is_valid(labRenderers.state.labAnimations[labUnitNumber]) then
        labRenderers.createAnimation(entity)
        softErrorReporting.showModError("errors.render-object-destroyed")
    end
    return labRenderers.state.labAnimations[labUnitNumber]
end

return labRenderers
local labRenderers = {}

local draw_animation = rendering.draw_animation
local draw_light = rendering.draw_light
local is_valid = rendering.is_valid
local floor = math.floor
local random = math.random

labRenderers.data = {}

labRenderers.init = function (data)
    labRenderers.data = data
    return data
end

labRenderers.defaultData = {
    labsByForce = {},
    labAnimations = {},
    labLights = {},
}

labRenderers.createAnimation = function (entity)
    labRenderers.data.labAnimations[entity.unit_number] = draw_animation({
        animation = "discoscience/lab-storm",
        surface = entity.surface,
        target = entity,
        render_layer = "higher-object-under",
        animation_offset = floor(random()*300)
    })
end

labRenderers.createLight = function (entity)
    labRenderers.data.labLights[entity.unit_number] = draw_light({
        sprite = "utility/light_medium",
        surface = entity.surface,
        target = entity,
        intensity = 0.75,
        size = 8,
        color = {r = 1.0, g = 1.0, b = 1.0}
    })
end

labRenderers.addLab = function (entity)
    if not entity or not entity.valid then
        softErrorReporting.showModError("errors.unregistered-entity-created")
        return
    end
    if entity.type == "lab" then
        if not labRenderers.data.labsByForce[entity.force.index] then
            labRenderers.data.labsByForce[entity.force.index] = {}
        end
        local labUnitNumber = entity.unit_number
        if labRenderers.data.labsByForce[entity.force.index][labUnitNumber] then
            softErrorReporting.showModError("errors.lab-registered-twice")
            return
        end
        labRenderers.data.labsByForce[entity.force.index][labUnitNumber] = entity
        if not labRenderers.data.labAnimations[labUnitNumber] then
            labRenderers.createAnimation(entity)
        end
        if not labRenderers.data.labLights[labUnitNumber] then
            labRenderers.createLight(entity)
        end
    end
end

labRenderers.reloadLabs = function ()
    labRenderers.data.labsByForce = {}
    for index, lab in ipairs(game.surfaces[1].find_entities_filtered({type = "lab"})) do
        labRenderers.addLab(lab)
    end
end

labRenderers.removeLab = function (entity)
    if entity.type == "lab" then
        local labUnitNumber = entity.unit_number
        labRenderers.data.labAnimations[labUnitNumber] = nil
        labRenderers.data.labLights[labUnitNumber] = nil
        local labsForForce = labRenderers.data.labsByForce[entity.force.index]
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

labRenderers.getRenderObjects = function(entity)
    local labUnitNumber = entity.unit_number
    if not is_valid(labRenderers.data.labAnimations[labUnitNumber]) then
        labRenderers.createAnimation(entity)
        softErrorReporting.showModError("errors.render-object-destroyed")
    end
    if not is_valid(labRenderers.data.labLights[labUnitNumber]) then
        labRenderers.createLight(entity)
        softErrorReporting.showModError("errors.render-object-destroyed")
    end
    return labRenderers.data.labAnimations[labUnitNumber], labRenderers.data.labLights[labUnitNumber]
end

return labRenderers
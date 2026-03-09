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

-- Data validation

--- Return nil to get it removed from the data lookup
local function validateLabData(lab, data)
    local labPrototype = prototypes.entity[lab]
    -- These are logs so stale data in the mod-data isn't a crashable offense
    if not labPrototype then
        log("Given lab data for non-existent lab: "..lab.."\t"..serpent.line(data))
        return nil
    end
    if labPrototype.type ~= "lab" then
        log("Given lab data for a non-lab entity: "..lab)
        return nil
    end

    --FIXME: This has to wait for 2.1: https://forums.factorio.com/132999
    -- if type(data.animation) ~= "string"
    -- or not helpers.is_valid_animation_path(data.animation) then
    --     error("Given animation name is not a valid animation: "..lab.." -> "..serpent.line(data.animation))
    -- end

    if not data.scale then
        data.scale = 1
    elseif type(data.scale) ~= "number" then
        error("Given animation scale is not a number: "..lab.." -> "..serpent.line(data.scale))
    end

    return data
end

local labData = prototypes.mod_data["discoscience-lab-data"].data
for lab, data in pairs(labData) do
    labData[lab] = validateLabData(lab, data)
end

labRenderers.createInitialState = function()
    return {
        labs = {},
        labAnimations = {},
        labData = labData,
    }
end

labRenderers.setLabScale = function (name, scale)
    if not scale then
        labRenderers.state.labData[name] = nil
        return
    elseif type(scale) ~= "number" then
        error("Given animation scale is not a number: "..serpent.line(scale))
    end

    local labData = labRenderers.state.labData[name]
    if not labData then
        labRenderers.state.labData[name] = {
            animation = "discoscience-lab-storm",
            scale = scale,
        }
    else
        labData.scale = scale
    end
end

labRenderers.createAnimation = function (entity)
    local labData = labRenderers.state.labData[entity.name]
    labRenderers.state.labAnimations[entity.unit_number] = draw_animation({
        animation = labData.animation,
        surface = entity.surface,
        target = entity,
        x_scale = labData.scale,
        y_scale = labData.scale,
        render_layer = "higher-object-under",
        animation_offset = floor(random()*300),
        visible = false,
    })
end

labRenderers.isCompatibleLab = function (entity)
    if not entity.type == "lab" then return false end
    return labRenderers.state.labData[entity.name] and true or false
end

labRenderers.addLab = function (entity)
    if not entity or not entity.valid then
        return
    end
    if labRenderers.isCompatibleLab(entity) then
        local labUnitNumber = entity.unit_number
        if labRenderers.state.labs[labUnitNumber] then
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
    labRenderers.state.labs[labUnitNumber] = nil
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
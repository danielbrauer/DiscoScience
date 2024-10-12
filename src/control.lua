
require("utils.softErrorReporting")

local researchColor = require("core.researchColor")
local labRenderers = require("core.labRenderers")
local labColoring = require("core.labColoring")

-- constants

local colorSwitchFrequency = 60

-- Track whether state is linked, in order to be able to avoid remote callbacks
-- before proper initialization (when a dependent mod is initialised later in a game)

local initialized = false

local registerWithRuinsEvent = function()
    if remote.interfaces["AbandonedRuins"] then
        script.on_event(remote.call("AbandonedRuins", "get_on_entity_force_changed_event"), function(event)
            labRenderers.changeLabForce(event.entity, event.force)
        end)
    end
end

local initState = function ()
    storage.labRendererData = labRenderers.initialState
    storage.researchColorData = researchColor.initialState
    storage.labColoringData = labColoring.initialState
end

local linkState = function ()
    labRenderers.linkState(storage.labRendererData)
    researchColor.linkState(storage.researchColorData)
    labColoring.linkState(storage.labColoringData)
    registerWithRuinsEvent()
    initialized = true
end

local removeOldData = function ()
    storage.scalarState = nil
    storage.labsByForce = nil
    storage.labAnimations = nil
end

local init = function()
    initState()
    linkState()
    registerWithRuinsEvent()
    labRenderers.reloadLabs()
end

local remoteSetLabScale = function(name, scale)
    if not initialized then
        return
    end
    labRenderers.setLabScale(name, scale)
    labRenderers.reloadLabs()
end

local remoteSetIngredientColor = function(name, color)
    if not initialized then
        return
    end
    researchColor.setIngredientColor(name, color)
end

local remoteGetIngredientColor = function(name)
    if not initialized then
        return
    end
    return researchColor.getIngredientColor(name)
end

remote.add_interface(
    "DiscoScience",
    {
        setLabScale = remoteSetLabScale,
        setIngredientColor = remoteSetIngredientColor,
        getIngredientColor = remoteGetIngredientColor
    }
)

script.on_init(
    function ()
        init()
    end
)

script.on_load(
    function ()
        linkState()
    end
)

script.on_configuration_changed(
    function ()
        removeOldData()
        labColoring.configurationChanged()
        init()
    end
)

script.on_event(
    {
        defines.events.on_script_trigger_effect
    },
    function (event)
        log(event.target_entity.unit_number)
        log(event.target_entity.prototype.has_flag("get-by-unit-number"))
        labRenderers.addLab(event.target_entity)
    end
)

script.on_event(
    {
        defines.events.on_object_destroyed
    },
    function (event)
        if event.type ~= defines.target_type.entity then return end
        log(event.useful_id)
        labRenderers.removeLab(event.useful_id)
    end
)

script.on_event(
    {defines.events.on_forces_merged},
    function (event)
        labRenderers.reloadLabs()
    end
)

script.on_nth_tick(
    colorSwitchFrequency,
    function (event)
        labColoring.chooseNewFunction()
        labColoring.chooseNewDirection()
    end
)

script.on_event(
    {defines.events.on_tick},
    function (event)
        researchColor.validateIngredientColors()
        labColoring.updateRenderers(event, labRenderers, researchColor)
    end
)
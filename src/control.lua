
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

local createData = function ()
    global.labRendererData = labRenderers.initialState
    global.researchColorData = researchColor.initialState
    global.labColoringData = labColoring.initialState
end

local linkData = function ()
    labRenderers.init(global.labRendererData)
    researchColor.init(global.researchColorData)
    labColoring.init(global.labColoringData)
    registerWithRuinsEvent()
    initialized = true
end

local removeOldData = function ()
    global.scalarState = nil
    global.labsByForce = nil
    global.labAnimations = nil
end

local init = function()
    createData()
    linkData()
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
        linkData()
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
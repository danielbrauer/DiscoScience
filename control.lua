
require("utils.softErrorReporting")

local researchColor = require("core.researchColor")
local labRenderers = require("core.labRenderers")
local labColoring = require("core.labColoring")

-- constants

local colorSwitchFrequency = 60

local createData = function ()
    global.labRendererData = labRenderers.initialState

    global.researchColorData = researchColor.initialState

    global.labColoringData = labColoring.initialState
end

local linkData = function ()
    labRenderers.init(global.labRendererData)

    researchColor.init(global.researchColorData)

    labColoring.init(global.labColoringData)
end

local resetConfigDependents = function ()
    if global.labsByForce then -- Update from old, separate tables
        global.labRendererData = {
            labsByForce = {},
            labAnimations = global.labAnimations or {},
            labLights = global.labLights or {},
        }
        labRenderers.init(global.labRendererData)
        global.labsByForce = nil
        global.labAnimations = nil
        global.labLights = nil
    end
        
    global.researchColorData = researchColor.init(researchColor.initialState)

    if global.scalarState then -- Remove state from old location
        global.scalarState = nil
    end

    global.labColoringData = labColoring.init(labColoring.initialState)
    global.labColoringData.meanderingTick = colorSwitchFrequency -- to avoid going negative
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
    colorSwitchFrequency,
    function (event)
        labColoring.switchPattern()
    end
)

script.on_event(
    {defines.events.on_tick},
    function (event)
        labColoring.updateRenderers(event, labRenderers, researchColor)
    end
)
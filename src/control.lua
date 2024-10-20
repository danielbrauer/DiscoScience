
require("utils.softErrorReporting")

local researchColor = require("core.researchColor")
local labRenderers = require("core.labRenderers")
local labColoring = require("core.labColoring")

-- constants

local colorSwitchFrequency = 60

-- Track whether state is linked, in order to be able to avoid remote callbacks
-- before proper initialization (when a dependent mod is initialised later in a game)

local initialized = false

local initState = function ()
    storage.labRendererData = labRenderers.createInitialState()
    storage.researchColorData = researchColor.createInitialState()
    storage.labColoringData = labColoring.createInitialState()
end

local linkState = function ()
    labRenderers.linkState(storage.labRendererData)
    researchColor.linkState(storage.researchColorData)
    labColoring.linkState(storage.labColoringData)
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
        getIngredientColor = remoteGetIngredientColor,
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
        labRenderers.addLab(event.target_entity)
    end
)

script.on_event(
    {
        defines.events.on_object_destroyed
    },
    function (event)
        if event.type ~= defines.target_type.entity then return end
        labRenderers.removeLab(event.useful_id)
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

-- local testIndex = 0

-- local cleanForTesting = function()
--     local entities = game.surfaces[1].find_entities()
--     for _, entity in ipairs(entities) do
--         entity.destroy()
--     end
--     initState()
-- end

-- local tests = {
--     function()
--         local lab = game.surfaces[1].create_entity{
--             name = "lab",
--             position = {x=0, y=0},
--             force = game.forces.neutral,
--             raise_built = true
--         }
--         assert(labRenderers.state.labAnimations, "Missing labAnimations")
--         local _, animation = next(labRenderers.state.labAnimations)
--         assert(animation, "Missing animation")
--         assert(animation.target.entity.unit_number == lab.unit_number, "Animation not targeted")
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(indexedLab.unit_number == lab.unit_number, "Recorded wrong unit")
--         lab.destroy()
--     end,
--     function()
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(not indexedLab, "Still tracking lab")
--         local _, animation = next(labRenderers.state.labAnimations)
--         assert(not animation, "Still tracking animation")
--         cleanForTesting()
--     end,
--     function()
--         local lab = game.surfaces[1].create_entity{
--             name = "lab",
--             position = {x=0, y=0},
--             force = game.forces.neutral,
--             raise_built = false
--         }
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(indexedLab.unit_number == lab.unit_number, "Recorded wrong unit")
--         lab.destroy()
--     end,
--     function()
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(not indexedLab, "Still tracking lab")
--         local _, animation = next(labRenderers.state.labAnimations)
--         assert(not animation, "Still tracking animation")
--         cleanForTesting()
--     end,
--     function()
--         local lab = game.surfaces[1].create_entity{
--             name = "lab",
--             position = {x=0, y=0},
--             force = game.forces.neutral,
--             raise_built = true
--         }
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(indexedLab.unit_number == lab.unit_number, "Recorded wrong unit")
--         local p = game.get_player(1)
--         p.mine_entity(lab)
--     end,
--     function()
--         local _, indexedLab = next(labRenderers.state.labs)
--         assert(not indexedLab, "Still tracking lab")
--         cleanForTesting()
--     end,
-- }

-- script.on_event(
--     {defines.events.on_tick},
--     function (event)
--         if testIndex == 0 then
--             log("DiscoScience testing started!")
--             local p = game.get_player(1)
--             p.exit_cutscene()
--             cleanForTesting()
--         elseif tests[testIndex] then
--             log("Running test " .. testIndex .. "/" .. #tests)
--             tests[testIndex]()
--         else
--             log("DiscoScience testing finished")
--             script.on_event({defines.events.on_tick}, nil)
--         end
--         testIndex = testIndex + 1
--     end
-- )
require 'busted.runner'()

package.path = "/Applications/factorio.app/Contents/data/core/lualib/?.lua;" .. package.path

require("spec.asserts")

describe("labColoring", function()
    local labColoring
    local researchColor
    local labRenderers
    local fakeRandom
    local oldRandom

    local researchColors = {{r=1, g=1, b=1}}

    local researchColor = {}
    researchColor.getColorsForResearch = function(tech)
        return researchColors
    end

    local force0 = {
        index = 0,
    }

    local position10 = {x = 10, y = 10}

    local force1 = {
        index = 1,
        players = {
            {
                position = position10,
            },
        },
    }

    local force1WithoutPlayer = {
        index = 1,
        players = {},
    }

    local normalLab = {
        type = "lab",
        name = "lab",
        valid = true,
        unit_number = 0,
        force = force1,
    }

    local someState = {
        lastColorFunc = 2,
        direction = 1,
        meanderingTick = 0,
    }

    setup(function()
        _G.rendering = require("spec.mocks.rendering")
        _G.defines = require("spec.mocks.defines")
        _G.serpent = require("serpent")
        labRenderers = require("core.labRenderers")

        oldRandom = math.random
        fakeRandom = require("spec.mocks.fakeRandom")
        math.random = fakeRandom.random
        labColoring = require("core.labColoring")
    end)

    before_each(function()
        labColoring.init({
            lastColorFunc = 1,
            direction = 1,
            meanderingTick = 0,
        })
        labRenderers.init({
            labsByForce = {},
            labAnimations = {},
            labLights = {},
            labScales = {
                ["lab"] = 1,
            },
        })
        assert.same(labRenderers.state, labRenderers.initialState)
        rendering.resetMock()
        labRenderers.addLab(normalLab)
    end)

    teardown(function()
        math.random = oldRandom
        labColoring = nil
        labRenderers = nil
    end)

    it("has the same initial state", function()
        assert.same(labColoring.state, labColoring.initialState)
    end)

    describe("init", function()

        it("doesn't change colorFunc index", function()
            labColoring.init(someState)
            assert.equal(2, labColoring.state.lastColorFunc)
        end)
    end)

    describe("configurationChanged", function()

        it("resets colorFunc index", function()
            labColoring.init(someState)
            labColoring.configurationChanged()
            assert.equal(1, labColoring.state.lastColorFunc)
        end)

        it("doesn't change colorFunc index", function()
            labColoring.state.lastColorFunc = 16
            labColoring.init(labColoring.state)
            assert.equal(16, labColoring.state.lastColorFunc)
        end)
    end)

    describe("chooseNewFunction", function()
        it("doesn't choose the same one twice", function()
            fakeRandom.fakeValue = 1
            labColoring.chooseNewFunction()
            assert.not_equal(1, labColoring.state.lastColorFunc)
        end)

        it("stays in range", function()
            for v = 1, #labColoring.colorMath.colorFunctions - 1 do
                fakeRandom.fakeValue = v
                labColoring.chooseNewFunction()
                assert.in_range(1, #labColoring.colorMath.colorFunctions, labColoring.state.lastColorFunc)
            end
        end)
    end)

    describe("chooseNewDirection", function()
        it("produces positive and negative, unit directions", function()
            labColoring.state.meanderingTick = 1
            for r = 0, 1, 0.05 do
                fakeRandom.fakeValue = r
                labColoring.chooseNewDirection()
                assert.equal(1, math.abs(labColoring.state.direction))
                assert.in_range(-1, 1, labColoring.state.direction)
            end
        end)
    end)

    describe("getInfoForForce", function()
        it("returns correct data for a given force", function()
            local labsByForce, colors, playerPosition = labColoring.getInfoForForce(force1, labRenderers, researchColor)
            assert.contains_same(normalLab, labsByForce)
            assert.same(researchColors, colors)
            assert.same(force1.players[1].position, playerPosition)
        end)

        it("returns zero position if force has no players", function()
            local labsByForce, colors, playerPosition = labColoring.getInfoForForce(force1WithoutPlayer, labRenderers, researchColor)
            assert.same({x=0, y=0}, playerPosition)
        end)

        it("returns nil if no renderers", function()
            local labsByForce = labColoring.getInfoForForce(force0, labRenderers, researchColor)
            assert.is_nil(labsByForce)
        end)
    end)
end)
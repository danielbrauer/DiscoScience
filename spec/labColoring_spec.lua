require 'busted.runner'()

package.path = "/Applications/factorio.app/Contents/data/core/lualib/?.lua;" .. package.path

require("spec.asserts")

describe("labColoring", function()
    local labColoring
    local fakeRandom
    local oldRandom
  
    setup(function()
        _G.rendering = require("spec.mocks.rendering")
        _G.defines = require("spec.mocks.defines")
        
        oldRandom = math.random
        fakeRandom = require("spec.mocks.fakeRandom")
        math.random = fakeRandom.random
        labColoring = require("core.labColoring")
    end)

    before_each(function()
        labColoring.state = {
            lastColorFunc = 1,
            direction = 1,
            meanderingTick = 0,
        }
        rendering.resetMock()
    end)
  
    teardown(function()
        math.random = oldRandom
        labColoring = nil
    end)

    it("has the same initial state", function()
        assert.same(labColoring.state, labColoring.initialState)
    end)

    describe("init", function()
        local shortFuncList = {
            f1 = function() end,
        }

        it("clamps colorFunc index into range", function()
            labColoring.state.lastColorFunc = 2
            labColoring.init(labColoring.initialState)
            assert.equal(1, labColoring.state.lastColorFunc)
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
end)
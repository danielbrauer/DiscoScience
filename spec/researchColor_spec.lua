require 'busted.runner'()

require("spec.asserts")

describe("researchColor", function()
    local researchColor

    setup(function()
        _G.game = require("spec.mocks.game")
        if not _G.loadstring then
            _G.loadstring = load
        end
        researchColor = require("core.researchColor")
    end)

    before_each(function()
        researchColor.init({
            researchColors = {},
            ingredientColors = {},
        })
    end)

    it("has the same initial state", function()
        assert.same(researchColor.state, researchColor.initialState)
    end)

    describe("loadIngredientColors", function()
        local flyingText = {
            order = "do local _={test={b=0.0,g=1.0,r=1.0}};return _;end"
        }
        it("deserializes ingredient colors from flying text", function()
            _G.game.entity_prototypes = {
                ["DiscoScience-colors-1"] = flyingText
            }
            researchColor.loadIngredientColors()
            assert.same(researchColor.state.ingredientColors["test"], {r = 1.0, g = 1.0, b = 0.0})
        end)
    end)

    describe("getColorsForResearch", function()
        local ingredientColors = {
            ["ingredientR"] = {r = 1.0, g = 0.0, b = 0.0},
            ["ingredientG"] = {r = 0.0, g = 1.0, b = 0.0},
            ["ingredientB"] = {r = 0.0, g = 0.0, b = 1.0},
        }
        local tech = {
            prototype = {
                name = "test-tech",
            },
            research_unit_ingredients = {
                { name = "ingredientR" },
                { name = "ingredientB" },
            },
        }

        it("gets a color array for research", function()
            researchColor.state.ingredientColors = ingredientColors
            local researchColors = researchColor.getColorsForResearch(tech)
            assert.equal(2, #researchColors)
            assert.contains_same(ingredientColors["ingredientR"], researchColors)
            assert.contains_same(ingredientColors["ingredientB"], researchColors)
            assert.is_not.contains_same(ingredientColors["ingredientG"], researchColors)
        end)

        it("only assembles ingredients for a given research once", function()
            spy.on(researchColor, "assembleColorsForResearch")
            local researchColors = researchColor.getColorsForResearch(tech)
            assert.spy(researchColor.assembleColorsForResearch).was_called(1)
            researchColors = researchColor.getColorsForResearch(tech)
            assert.spy(researchColor.assembleColorsForResearch).was_called(1)
            researchColor.assembleColorsForResearch:revert()
        end)

        it("returns default color if research is nil", function()
            local researchColors = researchColor.getColorsForResearch(nil)
            assert.same(researchColors, researchColor.defaultColors)
        end)

        local techWithoutIngredients = {
            prototype = {
                name = "no-ingredients",
            },
            research_unit_ingredients = {},
        }

        it("returns default color if research has zero ingredients", function()
            local researchColors = researchColor.getColorsForResearch(techWithoutIngredients)
            assert.same(researchColors, researchColor.defaultColors)
        end)
    end)

end)
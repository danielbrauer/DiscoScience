require 'busted.runner'()

require("spec.asserts")

describe("researchColor", function()
    local researchColor

    setup(function()
        _G.serpent = require("serpent")
        _G.game = require("spec.mocks.game")
        _G.prototypes = require("spec.mocks.prototypes")
        _G.log = function() end
        researchColor = require("core.researchColor")
    end)

    before_each(function()
        researchColor.linkState(researchColor.createInitialState())
        assert.same(researchColor.state, researchColor.createInitialState())
        game.reset()
    end)

    describe("setIngredientColor", function()

        it("adds a new entry", function()
            researchColor.setIngredientColor("ingred", {r=0, g=1, b=0})
            assert.same({r=0, g=1, b=0}, researchColor.state.ingredientColors["ingred"])
        end)

        it("modifies an existing entry", function()
            researchColor.setIngredientColor("ingred", {r=0, g=1, b=0})
            researchColor.setIngredientColor("ingred", {r=1, g=0, b=0})
            assert.same({r=1, g=0, b=0}, researchColor.state.ingredientColors["ingred"])
        end)

        it("removes an existing entry", function()
            researchColor.setIngredientColor("ingred", {r=0, g=1, b=0})
            assert.same({r=0, g=1, b=0}, researchColor.state.ingredientColors["ingred"])
            researchColor.setIngredientColor("ingred", nil)
            assert.is_nil(researchColor.state.ingredientColors["ingred"])
        end)
    end)

    describe("validateIngredientColors", function()
        local techsWithABCD = {
            techA = {
                research_unit_ingredients = {
                    A = {name = "A"},
                    B = {name = "B"},
                }
            },
            techB = {
                research_unit_ingredients = {
                    C = {name = "C"},
                    D = {name = "D"},
                }
            }
        }

        it("sets validated", function()
            assert.is_false(researchColor.state.validated)
            researchColor.validateIngredientColors()
            assert.is_true(researchColor.state.validated)
        end)

        it("finds a present ingredient", function()
            game.mockTechPrototypes = techsWithABCD
            researchColor.setIngredientColor("A", {r = 0, g = 1, b = 1})
            researchColor.setIngredientColor("B", {r = 0, g = 1, b = 1})
            researchColor.setIngredientColor("C", {r = 0, g = 1, b = 1})
            researchColor.setIngredientColor("D", {r = 0, g = 1, b = 1})
            local missing = researchColor.validateIngredientColors()
            assert.is_nil(next(missing))
        end)

        it("finds missing ingredient", function()
            game.mockTechPrototypes = techsWithABCD
            researchColor.setIngredientColor("A", {r = 0, g = 1, b = 1})
            researchColor.setIngredientColor("B", {r = 0, g = 1, b = 1})
            researchColor.setIngredientColor("C", {r = 0, g = 1, b = 1})
            local missing = researchColor.validateIngredientColors()
            assert.equal("D", next(missing))
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
        local techWithMissing = {
            prototype = {
                name = "test-tech2",
            },
            research_unit_ingredients = {
                { name = "ingredientB" },
                { name = "ingredientX" },
                { name = "ingredientR" },
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

        it("skips missing colors", function()
            researchColor.state.ingredientColors = ingredientColors
            local researchColors = researchColor.getColorsForResearch(techWithMissing)
            assert.equal(2, #researchColors)
            assert.contains_same(ingredientColors["ingredientR"], researchColors)
            assert.contains_same(ingredientColors["ingredientB"], researchColors)
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
require 'busted.runner'()

describe("colorMapping", function()
    local colorMapping
    local ingredientName = "automation-science-pack"
    local unrecognizedIconName = "__base__/graphics/icons/unrecognized.png"
    local simpleData = {
        technology = {
            ["logistic-science-pack"] = {
                unit =
                {
                    ingredients = {{"automation-science-pack", 1}},
                },
            }
        },
        tool = {
            ["automation-science-pack"] = {
              name = "automation-science-pack",
              icon = "__base__/graphics/icons/automation-science-pack.png",
            },
        }
    }
    local unrecognizedIconData = {
        technology = {
            ["logistic-science-pack"] = {
                unit =
                {
                    ingredients = {{"automation-science-pack", 1}},
                },
            }
        },
        tool = {
            ["automation-science-pack"] = {
              name = "automation-science-pack",
              icon = unrecognizedIconName,
            },
        }
    }
    local missingIconData = {
        technology = {
            ["logistic-science-pack"] = {
                unit =
                {
                    ingredients = {{"automation-science-pack", 1}},
                },
            }
        },
        tool = {
            ["automation-science-pack"] = {
              name = "automation-science-pack",
            },
        }
    }

    setup(function()
        _G.serpent = require("serpent")
        if not _G.loadstring then
            _G.loadstring = load
        end
        colorMapping = require("prototypes.colorMapping")
    end)

    teardown(function()
        colorMapping = nil
    end)

    describe("mapIngredientColors", function()
        it("maps a color to an ingredient", function()
            local ingredientColors = colorMapping.mapIngredientColors(simpleData)
            assert.not_nil(ingredientColors["automation-science-pack"])
        end)

        it("records unmapped ingredients", function()
            local ingredientColors, missingColors = colorMapping.mapIngredientColors(unrecognizedIconData)
            assert.is_nil(next(ingredientColors))
            assert.is_true(missingColors[unrecognizedIconName])
        end)

        it("records missing icons", function()
            local ingredientColors, _, missingIcons = colorMapping.mapIngredientColors(missingIconData)
            assert.is_nil(next(ingredientColors))
            assert.is_true(missingIcons["automation-science-pack"])
        end)
    end)

    describe("mappingAsFlyingTexts", function()
        it("creates flying-text for an ingredient", function()
            local color = {r = 1.0, g = 1.0, b = 0.0}
            local flyingTexts = colorMapping.mappingAsFlyingTexts({
                ["test"] = color
            })
            local _, flyingText = next(flyingTexts)
            assert.not_nil(flyingText)
            local pair = loadstring(flyingText.order)
            local deserialized = pair()
            assert.same(deserialized["test"], color)
        end)
    end)

end)
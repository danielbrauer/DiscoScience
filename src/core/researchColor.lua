local researchColor = {}

-- constants

researchColor.defaultColors = { {r = 1.0, g = 0.0, b = 1.0} }

-- state

researchColor.state = {}

researchColor.init = function (state)
    researchColor.state = state
    return state
end

researchColor.initialState = {
    researchColors = {},
    ingredientColors = {},
}

researchColor.addIngredientColor = function(ingredient, color)
    researchColor.state.ingredientColors[ingredient.name] = color
end

researchColor.assembleColorsForResearch = function (tech)
    local colors = {}
    for index, ingredient in pairs(tech.research_unit_ingredients) do
        local ingredientColor = researchColor.state.ingredientColors[ingredient.name]
        if ingredientColor then
            colors[#colors + 1] = ingredientColor
        end
    end
    if #colors == 0 then
        colors = researchColor.defaultColors
    end
    return colors
end

researchColor.getColorsForResearch = function (tech)
    if not tech then
        return researchColor.defaultColors
    else
        local techName = tech.prototype.name;
        if not researchColor.state.researchColors[techName] then
            researchColor.state.researchColors[techName] = researchColor.assembleColorsForResearch(tech)
        end
        return researchColor.state.researchColors[techName]
    end
end

return researchColor
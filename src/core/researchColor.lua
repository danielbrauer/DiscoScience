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

researchColor.loadIngredientColors = function ()
    local index = 1
    while true do
        local prototype = game.entity_prototypes["DiscoScience-colors-"..index]
        if not prototype then break end
        local pair = loadstring(prototype.order)
        for name, color in pairs(pair()) do
            researchColor.state.ingredientColors[name] = color
        end
        index = index + 1
    end
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
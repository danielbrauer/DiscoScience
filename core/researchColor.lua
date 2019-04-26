local researchColor = {}

researchColor.unrecognizedColor = {r = 1.0, g = 0.0, b = 1.0}
researchColor.defaultColors = {unrecognizedColor}

researchColor.colorData = {}

researchColor.init = function (data)
    researchColor.colorData = data
end

researchColor.defaultData = {
    researchColors = {},
    ingredientColors = {}
}

researchColor.loadIngredientColors = function ()
    researchColor.colorData.ingredientColors = {["unrecognized"] = researchColor.unrecognizedColor}
    local index = 1
    while true do
        local prototype = game.entity_prototypes["DiscoScience-colors-"..index]
        if not prototype then break end
        local pair = loadstring(prototype.order)
        for name, color in pairs(pair()) do
            researchColor.colorData.ingredientColors[name] = color
        end
        index = index + 1
    end
end

researchColor.getColorsForResearch = function (tech)
    if not tech then
        return defaultColors
    else
        local techName = tech.prototype.name;
        if not researchColor.colorData.researchColors[techName] then
            local colors = {}
            for index, ingredient in pairs(tech.research_unit_ingredients) do
                colors[index] = researchColor.colorData.ingredientColors[ingredient.name]
                if not colors[index] then
                    colors[index] = researchColor.colorData.ingredientColors.unrecognized
                end
            end
            if #colors == 0 then
                colors = defaultColors
            end
            researchColor.colorData.researchColors[techName] = colors
        end
        return researchColor.colorData.researchColors[techName]
    end
end

return researchColor
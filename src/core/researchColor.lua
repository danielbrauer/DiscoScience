local researchColor = {}

-- constants

researchColor.defaultColors = { {r = 1.0, g = 0.0, b = 1.0} }

-- state

researchColor.state = {}

researchColor.validated = false

researchColor.init = function (state)
    researchColor.state = state
    return state
end

researchColor.initialState = {
    validated = false,
    researchColors = {},
    ingredientColors = {
        ["automation-science-pack"] = {r = 1.0, g = 0.1, b = 0.1},
        ["logistic-science-pack"] =   {r = 0.1, g = 1.0, b = 0.1},
        ["chemical-science-pack"] =   {r = 0.2, g = 0.2, b = 1.0},
        ["production-science-pack"] = {r = 0.8, g = 0.1, b = 0.8},
        ["military-science-pack"] =   {r = 1.0, g = 0.5, b = 0.0},
        ["utility-science-pack"] =    {r = 1.0, g = 0.9, b = 0.1},
        ["space-science-pack"] =      {r = 0.8, g = 0.8, b = 0.8},
    },
}

researchColor.setIngredientColor = function(name, color)
    researchColor.state.ingredientColors[name] = color
end

researchColor.validateIngredientColors = function()
    if researchColor.state.validated then
        return
    end
    researchColor.state.validated = true
    local techPrototypes = game.get_filtered_technology_prototypes({})
    local notFound = {}
    for _, tech in pairs(techPrototypes) do
        for _, ingredient in pairs(tech.research_unit_ingredients) do
            local found = false
            for name, _ in pairs(researchColor.state.ingredientColors) do
                if name == ingredient.name then
                    found = true
                end
            end
            if not (found or notFound[ingredient.name]) then
                notFound[ingredient.name] = true
            end
        end
    end
    if not (next(notFound) == nil) then
        local foundNames = "Disco Science encountered the following ingredients with no registered color: "
        for name, _ in pairs(notFound) do
            foundNames = foundNames.."\n"..name
        end
        log(foundNames)
    end
    return notFound
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
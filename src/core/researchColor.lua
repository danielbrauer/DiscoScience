local researchColor = {}

-- constants

researchColor.defaultColors = { {r = 1.0, g = 0.0, b = 1.0} }

-- state

researchColor.state = {}

researchColor.validated = false

researchColor.linkState = function (state)
    researchColor.state = state
    return state
end

researchColor.initialState = {
    validated = false,
    researchColors = {},
    ingredientColors = {
        ["automation-science-pack"] =      {r = 0.91, g = 0.16, b = 0.20},
        ["logistic-science-pack"] =        {r = 0.29, g = 0.97, b = 0.31},
        ["chemical-science-pack"] =        {r = 0.28, g = 0.93, b = 0.95},
        ["production-science-pack"] =      {r = 0.83, g = 0.06, b = 0.92},
        ["military-science-pack"] =        {r = 0.50, g = 0.10, b = 0.50},
        ["utility-science-pack"] =         {r = 0.96, g = 0.93, b = 0.30},
        ["space-science-pack"] =           {r = 0.80, g = 0.80, b = 0.80},
        ["agricultural-science-pack"] =    {r = 0.84, g = 0.84, b = 0.15},
        ["metallurgic-science-pack"] =     {r = 0.99, g = 0.50, b = 0.04},
        ["electromagnetic-science-pack"] = {r = 0.89, g = 0.00, b = 0.56},
        ["cryogenic-science-pack"] =       {r = 0.14, g = 0.18, b = 0.74},
        ["promethium-science-pack"] =      {r = 0.10, g = 0.10, b = 0.50},
    },
}

researchColor.setIngredientColor = function(name, color)
    researchColor.state.ingredientColors[name] = color
end

researchColor.getIngredientColor = function(name)
    return researchColor.state.ingredientColors[name]
end

researchColor.validateIngredientColors = function()
    if researchColor.state.validated then
        return
    end
    researchColor.state.validated = true
    local techPrototypes = prototypes.get_technology_filtered({})
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
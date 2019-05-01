local colorMapping = {}

colorMapping.iconColors =
{
    ["__base__/graphics/icons/automation-science-pack.png"] =                {r = 1.0, g = 0.1, b = 0.1},
    ["__base__/graphics/icons/logistic-science-pack.png"] =                  {r = 0.1, g = 1.0, b = 0.1},
    ["__base__/graphics/icons/chemical-science-pack.png"] =                  {r = 0.2, g = 0.2, b = 1.0},
    ["__base__/graphics/icons/military-science-pack.png"] =                  {r = 1.0, g = 0.5, b = 0.0},
    ["__base__/graphics/icons/production-science-pack.png"] =                {r = 0.8, g = 0.1, b = 0.8},
    ["__base__/graphics/icons/utility-science-pack.png"] =                   {r = 1.0, g = 0.9, b = 0.1},
    ["__base__/graphics/icons/space-science-pack.png"] =                     {r = 0.8, g = 0.8, b = 0.8},
    ["__bobtech__/graphics/icons/science-pack-gold.png"] =                   {r = 1.0, g = 0.9, b = 0.1},
    ["__bobtech__/graphics/icons/logistic-science-pack.png"] =               {r = 1.0, g = 0.0, b = 1.0},
    ["__bobtech__/graphics/icons/alien-science-pack.png"] =                  {r = 1.0, g = 0.0, b = 0.6},
    ["__bobtech__/graphics/icons/alien-science-pack-blue.png"] =             {r = 0.3, g = 0.3, b = 1.0},
    ["__bobtech__/graphics/icons/alien-science-pack-green.png"] =            {r = 0.2, g = 1.0, b = 0.2},
    ["__bobtech__/graphics/icons/alien-science-pack-orange.png"] =           {r = 1.0, g = 0.6, b = 0.1},
    ["__bobtech__/graphics/icons/alien-science-pack-purple.png"] =           {r = 1.0, g = 0.2, b = 1.0},
    ["__bobtech__/graphics/icons/alien-science-pack-red.png"] =              {r = 1.0, g = 0.2, b = 0.2},
    ["__bobtech__/graphics/icons/alien-science-pack-yellow.png"] =           {r = 1.0, g = 1.0, b = 0.2},
    ["__ScienceCostTweakerM__/graphics/bobmods/logistic-science-pack.png"] = {r = 1.0, g = 0.0, b = 1.0},
    ["__ScienceCostTweakerM__/graphics/bobmods/gold-science-pack.png"] =     {r = 1.0, g = 1.0, b = 0.1},
    ["__ScienceCostTweakerM__/graphics/bobmods/alien-science-pack.png"] =    {r = 1.0, g = 0.0, b = 0.6},
    ["__pycoalprocessing__/graphics/icons/science-pack-1.png"] =             {r = 1.0, g = 0.12,b = 0.18},
    ["__pycoalprocessing__/graphics/icons/science-pack-2.png"] =             {r = 0.16,g = 0.5, b = 0.0},
    ["__pycoalprocessing__/graphics/icons/science-pack-3.png"] =             {r = 0.35,g = 0.64,b = 0.84},
    ["__pyfusionenergy__/graphics/icons/production-science-pack.png"] =      {r = 0.66,g = 1.0, b = 0.33},
    ["__pyhightech__/graphics/icons/high-tech-science-pack.png"] =           {r = 0.91,g = 0.86,b = 0.24},
}
colorMapping.ingredientColors = {}

colorMapping.mapIngredientColors = function(rawData)
    local ingredientColors = {}
    local missingColors = {}
    local missingIcons = {}
    for _, tech in pairs(rawData["technology"]) do
        for _, ingredientPair in ipairs(tech.unit.ingredients) do
            local ingredientName = ingredientPair[1]
            local ingredient = rawData.tool[ingredientName]
            if not ingredientColors[ingredientName] and not missingIcons[ingredientName] then
                if ingredient.icon then
                    ingredientColors[ingredientName] = colorMapping.iconColors[ingredient.icon]
                    if not ingredientColors[ingredientName] and not missingColors[ingredient.icon] then
                        missingColors[ingredient.icon] = true
                    end
                elseif not missingIcons[ingredientName] then
                    missingIcons[ingredientName] = true
                end
            end
        end
    end
    return ingredientColor, missingColors, missingIcons
end

colorMapping.mappingAsFlyingTexts = function(ingredientColors)
    local index = 1
    local flyingTexts = {}
    for name, color in pairs(ingredientColors) do
        table.insert(
            flyingTexts, 
            {
                type = "flying-text",
                name = "DiscoScience-colors-"..index,
                time_to_live = 1,
                speed = 1,
                order = serpent.dump({[name] = color})
            }
        )
        index = index + 1
    end
    return flyingTexts
end

return colorMapping
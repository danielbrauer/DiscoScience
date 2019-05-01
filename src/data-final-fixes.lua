local colorMapping = require("prototypes.colorMapping")

local ingredientColors, missingColors, missingIcons = colorMapping.mapIngredientColors(data.raw)

if next(missingColors) ~= nil then
    log("Missing colours for the following icons: "..serpent.block(missingColors))
end

if next(missingIcons) ~= nil then
    log("The following ingredients have no icons: "..serpent.block(missingIcons))
end

local flyingTexts = colorMapping.mappingAsFlyingTexts(ingredientColors)

data:extend(flyingTexts)
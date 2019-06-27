local animations = require("prototypes.animations")

local compatibleLabs = require("prototypes.compatibleLabs")

for _, name in pairs(compatibleLabs.names) do
    local lab = data.raw["lab"][name]
    if lab then
        animations.removeAnimationAndLight(lab)
    end
end

data:extend{animations.labStorm}

local colorMapping = require("prototypes.colorMapping")

local ingredientColors, missingColors, missingIcons = colorMapping.mapIngredientColors(data.raw)

if next(missingColors) ~= nil then
    log("Missing colours for the following icons: "..serpent.block(missingColors))
end

if next(missingIcons) ~= nil then
    log("The following ingredients have no icons: "..serpent.block(missingIcons))
end

local flyingTexts = colorMapping.mappingAsFlyingTexts(ingredientColors)

if next(flyingTexts) ~= nil then
    data:extend(flyingTexts)
end
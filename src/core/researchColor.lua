---@class ResearchColor
local researchColor = {}

-- constants

---@type Color.0[]
researchColor.defaultColors = { {r = 1.0, g = 0.0, b = 1.0} }

-- state

-- researchColor.state = {}

---@param state ResearchColorState
---@return ResearchColorState
researchColor.linkState = function (state)
    researchColor.state = state
    return state
end

--- data validation
local ingredientColors = prototypes.mod_data["discoscience-science-colors"].data --[[@as table<data.ItemID, Color>]]

---@param color Color
---@return Color.0?
function researchColor.validateColor(color)
    ---@type Color.0
    local possibleColor = {
        r = color.r or color[1],
        g = color.g or color[2],
        b = color.b or color[3],
        a = color.a or color[4],
    }
    local is_255, has_value, outside_bounds = false, false, false
    for _, value in pairs(possibleColor) do
        has_value = true
        if value < 0 or value > 255 then
            outside_bounds = true
            break
        end
        if value > 1 then is_255 = true end
    end

    if outside_bounds or not has_value then
        return nil
    end

    if is_255 then
        for key, value in pairs(possibleColor) do
            possibleColor[key] = value / 255
        end
    end

    local alpha = possibleColor.a or 1

    return {
        r = (possibleColor.r or 0) * alpha,
        g = (possibleColor.g or 0) * alpha,
        b = (possibleColor.b or 0) * alpha,
    }
end

---@param item data.ItemID
---@param color Color
---@return Color.0? validated_color return nil to get it removed from the color lookup
local function validateSciencePack(item, color)
    local item_prototype = prototypes.item[item]

    -- These are logs so stale data in the mod-data isn't a crashable offense
    if not item_prototype then
        log("Given a color for a non-existent item: "..item.." - "..serpent.line(color))
        return nil
    end
    if item_prototype.type ~= "tool" then
        log("Given item was not a science pack: "..item.." - "..serpent.line(color))
        return nil
    end

    local valid_color = researchColor.validateColor(color)
    if not valid_color then
        error("Given item color was not a valid color: "..item.." - "..serpent.line(color))
    end
    return valid_color
end

for item, color in pairs(ingredientColors) do
    ingredientColors[item] = validateSciencePack(item, color)
end


researchColor.createInitialState = function()
    ---@class ResearchColorState
    ---@field validated boolean
    ---@field researchColors table<data.TechnologyID, Color.0[]>
    ---@field ingredientColors table<data.ItemID, Color.0>
    return {
        validated = false,
        researchColors = {},
        ingredientColors = ingredientColors,
    }
end

---@param name data.ItemID
---@param color Color.0
researchColor.setIngredientColor = function(name, color)
    local valid_color = researchColor.validateColor(color)
    if not valid_color then error("Invalid color given") end
    researchColor.state.ingredientColors[name] = valid_color
end

---@param name data.ItemID
---@return Color.0
researchColor.getIngredientColor = function(name)
    return researchColor.state.ingredientColors[name]
end

researchColor.validateIngredientColors = function()
    if researchColor.state.validated then
        return
    end
    researchColor.state.validated = true
    local techPrototypes = prototypes.get_technology_filtered({}) -- NOTE: HUH? Why not just prototypes.technology
    ---@type table<data.ItemID, true>
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


---@param tech LuaTechnology
---@return Color.0[]
researchColor.assembleColorsForResearch = function (tech)
    ---@type Color.0[]
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

---@param tech LuaTechnology?
---@return Color.0[]
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
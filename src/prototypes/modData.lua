---@class LabData
---@field scale? double
---@field animation string Name of an animation prototype

data:extend{
    {
        type = "mod-data",
        name = "discoscience-lab-data",
        data_type = "ds-lab-data",
        ---@type table<data.EntityID, LabData>
        data = {},
    },
    {
        type = "mod-data",
        name = "discoscience-science-colors",
        data_type = "ds-science-colors",
        ---@type table<data.ItemID, Color>
        data = {
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
        }
    }
}
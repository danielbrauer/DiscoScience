local math2d = require("math2d")
local distance = math2d.position.distance

local floor = math.floor
local modf = math.modf
local min = math.min
local cos = math.cos
local atan2 = math.atan2
local abs = math.abs
local pi = math.pi
local random = math.random

local colorMath = {}

function colorMath.lerpColor(x, a, b, out)
    out.r = a.r + (b.r - a.r) * x
    out.g = a.g + (b.g - a.g) * x
    out.b = a.b + (b.b - a.b) * x
end

function colorMath.loopInterpolate(t, colors, blendHardness, output)
    local index1, x = modf(t)
    local index2 = index1 + 1
    local color1 = colors[index1 % #colors + 1]
    local color2 = colors[index2 % #colors + 1]
    x = min(x*blendHardness, 1)
    colorMath.lerpColor(x, color1, color2, output)
end

colorMath.colorFunctions = {
    function (tick, colors, playerPosition, labPosition, fcolor)
        local r = distance(playerPosition, labPosition)
        local t = r/8 + tick/40
        colorMath.loopInterpolate(t, colors, 1.5, fcolor)
    end,
    function (tick, colors, playerPosition, labPosition, fcolor)
        local theta = atan2(labPosition.y - playerPosition.y, labPosition.x - playerPosition.x)
        local t = ((theta/pi) * 0.5 + 0.5) * #colors + tick/30
        colorMath.loopInterpolate(t, colors, 2, fcolor)
    end,
    function (tick, colors, playerPosition, labPosition, fcolor)
        local t = abs(labPosition.x - playerPosition.x)/10 + tick/30
        colorMath.loopInterpolate(t, colors, 2, fcolor)
    end,
    function (tick, colors, playerPosition, labPosition, fcolor)
        local t = abs(labPosition.y - playerPosition.y)/10 + tick/30
        colorMath.loopInterpolate(t, colors, 2, fcolor)
    end,
    function (tick, colors, playerPosition, labPosition, fcolor)
        local t = abs(labPosition.x - playerPosition.x + labPosition.y - playerPosition.y)/10 + tick/30
        colorMath.loopInterpolate(t, colors, 2, fcolor)
    end,
    function (tick, colors, playerPosition, labPosition, fcolor)
        local t = abs(floor((labPosition.x - playerPosition.x)/9) + floor((labPosition.y - playerPosition.y)/8)) + tick/10
        colorMath.loopInterpolate(t, colors, 5, fcolor)
    end,
}

return colorMath
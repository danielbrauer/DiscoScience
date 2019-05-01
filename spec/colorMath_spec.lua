require 'busted.runner'()

package.path = "/Applications/factorio.app/Contents/data/core/lualib/?.lua;" .. package.path

local say = require("say")

local function color_is_normal(state, arguments)
  local has_key = false

  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  for _, channel in ipairs("r", "g", "b") do
    if not arguments[1][channel] then return false end
    if not arguments[1][channel] >= 0 then return false end
    if not arguments[1][channel] <= 1 then return false end
  end

  return true
end

say:set("assertion.color_is_normal.positive", "Expected %s \nto be a valid color")
say:set("assertion.color_is_normal.negative", "Expected %s \nto not to be a valid color")
assert:register("assertion", "color_is_normal", color_is_normal, "assertion.color_is_normal.positive", "assertion.color_is_normal.negative")

describe("colorMath", function()
    local colorMath
    local fcolor =     {r = 0.0, g = 0.0, b = 0.0}
    local color0 =     {r = 0.0, g = 0.0, b = 0.0}
    local color1 =     {r = 1.0, g = 1.0, b = 1.0}
    local colorRed =   {r = 1.0, g = 0.0, b = 0.0}
    local colorGreen = {r = 0.0, g = 1.0, b = 0.0}
    local colorBlue =  {r = 0.0, g = 0.0, b = 1.0}
    local colors = {
        colorRed,
        colorGreen,
        colorBlue,
    }
  
    setup(function()
        colorMath = require("utils.colorMath")
    end)
  
    teardown(function()
        colorMath = nil
    end)

    describe("lerpColor", function()
    
        it("interpolates linearly", function()
            colorMath.lerpColor(0.0, color0, color1, fcolor)
            assert.are.same(fcolor, color0)
            colorMath.lerpColor(1.0, color0, color1, fcolor)
            assert.are.same(fcolor, color1)
            colorMath.lerpColor(0.5, color0, color1, fcolor)
            assert.are.same(fcolor, {r = 0.5, g = 0.5, b = 0.5})
        end)
    end)

    describe("loopInterpolate", function()

        it("ranges from zero to #colors", function()
            colorMath.loopInterpolate(0.0, colors, 1.0, fcolor)
            assert.are.same(fcolor, colorRed)
            colorMath.loopInterpolate(1.0, colors, 1.0, fcolor)
            assert.are.same(fcolor, colorGreen)
            colorMath.loopInterpolate(2.0, colors, 1.0, fcolor)
            assert.are.same(fcolor, colorBlue)
        end)

        it("wraps around", function()
            colorMath.loopInterpolate(3.0, colors, 1.0, fcolor)
            assert.are.same(fcolor, colorRed)
        end)
    end)

    describe("colorFunctions", function()
        local negativePosition = {x = -10000, y = -10000}
        local positivePosition = {x = 10000, y = 10000}
        local zeroPosition = {x = 0, y = 0}
        local positionPairs = {
            {zeroPosition, zeroPosition},
            {negativePosition, negativePosition},
            {positivePosition, positivePosition},
            {positivePosition, negativePosition},
            {negativePosition, positivePosition},
        }
        local positiveNumbers = {
            0,
            0.5,
            1,
            100000,
        }

        it("all return positive results if t is positive", function()
            for _, func in ipairs(colorMath.colorFunctions) do
                for _, pair in ipairs(positionPairs) do
                    for _, number in ipairs(positiveNumbers) do
                        func(number, colors, pair[1], pair[2], fcolor)
                        assert.color_is_normal(fcolor)
                    end
                end
            end
        end)
    end)
end)
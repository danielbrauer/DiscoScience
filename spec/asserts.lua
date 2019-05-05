local say = require("say")
local assert = require("luassert")
local util = require("luassert.util")

local function in_range(state, arguments)
    if arguments[3] < arguments[1] then return false end
    if arguments[3] > arguments[2] then return false end
    return true
end

say:set("assertion.in_range.positive", "Expected between %s and %s \nbut was %s")
say:set("assertion.in_range.negative", "Expected outside %s and %s \nnbut was %s")
assert:register("assertion", "in_range", in_range, "assertion.in_range.positive", "assertion.in_range.negative")


local function color_is_normal(state, arguments)
  
    if not type(arguments[1]) == "table" or #arguments ~= 1 then
      return false
    end
  
    for _, channel in ipairs("r", "g", "b") do
      if not arguments[1][channel] then return false end
      assert.in_range(arguments[1], 0, 1)
    end
  
    return true
  end
  
  say:set("assertion.color_is_normal.positive", "%s is not a valid color")
  say:set("assertion.color_is_normal.negative", "%s is a valid color")
  assert:register("assertion", "color_is_normal", color_is_normal, "assertion.color_is_normal.positive", "assertion.color_is_normal.negative")
  
local function contains_same(state, arguments)
    assert.is_table(arguments[2])
    local found = false
    for _, value in pairs(arguments[2]) do
        if util.deepcompare(value, arguments[1]) then
            return true
        end
    end
    return false
end

say:set("assertion.contains_same.positive", "Expected same as %s \nbut found no instances in %s")
say:set("assertion.contains_same.negative", "Expected nothing like %s \nbut found one in %s")
assert:register("assertion", "contains_same", contains_same, "assertion.contains_same.positive", "assertion.contains_same.negative")
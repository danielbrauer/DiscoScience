require 'busted.runner'()

describe("animations", function()
    local animations
  
    setup(function()
        _G.util = {by_pixel = function(x, y) return 1 end}
        animations = require("prototypes.animations")
    end)
  
    teardown(function()
        animations = nil
    end)

    describe("removeAnimationAndLight", function()
        it("sets animation and zeroes light", function()
            local lab = {
                type = "lab",
                name = "lab",
                valid = true,
                on_animation = {"on_animation"},
                off_animation = {"off_animation"},
                light = {intensity = 10, size = 8, color = {r = 1, g = 1, b = 1}},
                unit_number = 0,
                force = force0,
            }
            animations.removeAnimationAndLight(lab)
            assert.same(lab.on_animation, lab.off_animation)
            assert.equal(0, lab.light.intensity)
            assert.equal(0, lab.light.size)
            assert.equal(0, lab.light.color.r)
            assert.equal(0, lab.light.color.g)
            assert.equal(0, lab.light.color.b)
        end)
    end)
end)
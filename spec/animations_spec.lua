require 'busted.runner'()

describe("animations", function()
    local animations

    setup(function()
        _G.util = {by_pixel = function(x, y) return 1 end}
        animations = require("src.prototypes.labChanges")
    end)

    teardown(function()
        animations = nil
    end)

    describe("removeAnimation", function()
        it("sets animation", function()
            local lab = {
                type = "lab",
                name = "lab",
                valid = true,
                on_animation = {"on_animation"},
                off_animation = {"off_animation"},
                unit_number = 0,
                force = force0,
            }
            animations.removeAnimation(lab)
            assert.same(lab.on_animation, lab.off_animation)
        end)
    end)
end)
local animations = require("prototypes.animations")

_G.DiscoScience = {}

_G.DiscoScience.prepareLab = function (lab)
    animations.removeAnimation(lab)
end

animations.removeAnimation(data.raw["lab"]["lab"])

data:extend{animations.labStorm}
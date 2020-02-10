local animations = require("prototypes.animations")

_G.DiscoScience = {}

_G.DiscoScience.addLab = function (lab)
    animations.removeAnimationAndLight(lab)
end

animations.removeAnimationAndLight(data.raw["lab"]["lab"])

data:extend{animations.labStorm}
local labChanges = require("prototypes.labChanges")

_G.DiscoScience = {}

_G.DiscoScience.prepareLab = function (lab)
    labChanges.prepareLab(lab)
end

labChanges.prepareLab(data.raw["lab"]["lab"])

data:extend{labChanges.labStorm}
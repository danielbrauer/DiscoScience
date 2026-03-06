require("prototypes.modData")
local labChanges = require("prototypes.labChanges")

_G.DiscoScience = {}

_G.DiscoScience.prepareLab = function (lab)
    labChanges.prepareLab(lab)
end

-- Note, this instance doesn't require the two arguments, but as an example it should.
labChanges.prepareLab(data.raw["lab"]["lab"], "discoscience-lab-storm", 1)

data:extend{labChanges.labStorm}
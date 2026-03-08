require("prototypes.modData")
local labChanges = require("prototypes.labChanges")

_G.DiscoScience = {}

_G.DiscoScience.prepareLab = labChanges.prepareLab

-- Note, this instance doesn't require the two arguments, but as an example it should.
labChanges.prepareLab(data.raw["lab"]["lab"], {
    animation = "discoscience-lab-storm",
    scale = 1,
})

data:extend{labChanges.labStorm}
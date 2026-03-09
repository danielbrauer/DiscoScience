require("prototypes.modData")
local labChanges = require("prototypes.labChanges")

_G.DiscoScience = {}

_G.DiscoScience.prepareLab = labChanges.prepareLab

-- Note, this instance doesn't require the full data argument because it is the defaults
-- But because it's an example, it should show what you can set.
labChanges.prepareLab(data.raw["lab"]["lab"], {
    animation = "discoscience-lab-storm",
    scale = 1,
})

data:extend{labChanges.labStorm}
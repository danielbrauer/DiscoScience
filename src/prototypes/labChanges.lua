local labChanges = {}

local labData = data.raw["mod-data"]["discoscience-lab-data"].data

---@param lab data.LabPrototype
---@param animation? string
---@param scale? double
labChanges.prepareLab = function (lab, animation, scale)
    labData[lab.name] = {
        animation = animation or "discoscience-lab-storm",
        scale = scale or 1,
    }

    lab.on_animation = lab.off_animation
    lab.created_effect = {
        type = "direct",
        action_delivery = {
            type = "instant",
            source_effects = {
                {
                    type = "script",
                    effect_id = "ds-create-lab",
                },
            }
        }
    }
end

labChanges.labStorm =
{
    type = "animation",
    name = "discoscience-lab-storm",
    filename = "__DiscoScience__/graphics/lab-storm.png",
    blend_mode = "additive",
    draw_as_glow = true,
    width = 106,
    height = 100,
    frame_count = 33,
    line_length = 11,
    animation_speed = 1 / 3,
    shift = util.by_pixel(-1, 1),
    hr_version =
    {
        filename = "__DiscoScience__/graphics/hr-lab-storm.png",
        blend_mode = "additive",
        draw_as_glow = true,
        width = 216,
        height = 194,
        frame_count = 33,
        line_length = 11,
        animation_speed = 1 / 3,
        shift = util.by_pixel(0, 0),
        scale = 0.5
    }
}

return labChanges
local labChanges = {}

local labData = data.raw["mod-data"]["discoscience-lab-data"].data

---@param lab data.LabPrototype
---@param data? LabData
labChanges.prepareLab = function (lab, data)
    if not data then
        data = {
            animation = "discoscience-lab-storm",
            scale = 1
        }
    else
        if not data.animation then
            data.animation = "discoscience-lab-storm"
        end
        if not data.scale then
            data.scale = 1
        end
    end

    labData[lab.name] = data

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

return labChanges
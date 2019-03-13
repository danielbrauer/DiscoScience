--data.lua

local lab = data.raw["lab"]["lab"]

lab.on_animation = lab.off_animation

local labStorm =
{
    type = "animation",
    name = "discoscience/lab-storm",
    filename = "__DiscoScience__/graphics/lab-storm.png",
    width = 98,
    height = 87,
    frame_count = 33,
    line_length = 11,
    animation_speed = 1 / 3,
    premul_alpha = false,
    shift = util.by_pixel(0, 1.5),
    hr_version =
    {
        filename = "__DiscoScience__/graphics/hr-lab-storm.png",
        width = 194,
        height = 174,
        frame_count = 33,
        line_length = 11,
        animation_speed = 1 / 3,
        premul_alpha = false,
        shift = util.by_pixel(0, 1.5),
        scale = 0.5
    }
}

data:extend{labStorm}
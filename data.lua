--data.lua

local lab = data.raw["lab"]["lab"]

local oldAnim = lab.on_animation

lab.on_animation =
{
    layers =
    {
        {
        filename = "__base__/graphics/entity/lab/lab.png",
        width = 98,
        height = 87,
        frame_count = 33,
        line_length = 11,
        animation_speed = 1 / 3,
        shift = util.by_pixel(0, 1.5),
        hr_version =
        {
            width = 194,
            height = 174,
            frame_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5,
            stripes =
            {
                {
                    filename = "__base__/graphics/entity/lab/hr-lab.png",
                    width_in_frames = 11,
                    height_in_frames = 2
                },
                {
                    filename = "__base__/graphics/entity/lab/hr-lab-red.png",
                    width_in_frames = 11,
                    height_in_frames = 1
                }
            }
        }
        },
        {
        filename = "__base__/graphics/entity/lab/lab-integration.png",
        width = 122,
        height = 81,
        frame_count = 1,
        line_length = 1,
        repeat_count = 33,
        animation_speed = 1 / 3,
        shift = util.by_pixel(0, 15.5),
        hr_version =
        {
            filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
        }
        },
        {
        filename = "__base__/graphics/entity/lab/lab-shadow.png",
        width = 122,
        height = 68,
        frame_count = 1,
        line_length = 1,
        repeat_count = 33,
        animation_speed = 1 / 3,
        shift = util.by_pixel(13, 11),
        draw_as_shadow = true,
        hr_version =
        {
            filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
        }
        }
    }
}
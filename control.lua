--control.lua

labAnimations = {}

script.on_event(
    {defines.events.on_tick},
    function (e)
        if e.tick % 300 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second

            labs = game.surfaces[1].find_entities_filtered({type = "lab"})
            for index, lab in ipairs(labs) do
                if labAnimations[lab.unit_number] == nil then
                    labAnimations[lab.unit_number] = rendering.draw_animation({
                        animation = "discoscience/lab-storm",
                        surface = lab.surface,
                        target = lab.position,
                        render_layer = "higher-object-under",
                        -- animation_offset = math.random()*300,
                        -- animation_speed = 0.9 + math.random()*0.2
                    })
                end
                -- rendering.draw_light({
                --     intensity = 0.75,
                --     size = 8,
                --     color = {r = 1.0, g = 1.0, b = 1.0}
                -- })
            end
        end
        if e.tick %60 == 0 then
            for labUnitNumber, anim in pairs(labAnimations) do
                -- rendering.set_visible(anim, e.tick %120 == 0)
                rendering.set_color(anim, {r = math.random(), g = math.random(), b = math.random()})
            end
        end
    end
)
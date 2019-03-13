--control.lua


script.on_event(
    {defines.events.on_tick},
    function (e)
        if e.tick % 300 == 0 then --common trick to reduce how often this runs, we don't want it running every tick, just 1/second

            labs = game.surfaces[1].find_entities_filtered({type = "lab"})
            for index, lab in ipairs(labs) do
                rendering.draw_animation({
                    animation = "discoscience/lab-storm",
                    surface = lab.surface,
                    target = lab.position
                })
            end
        end
    end
)
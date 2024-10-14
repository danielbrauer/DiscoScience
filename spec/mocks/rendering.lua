local rendering = {}

rendering.objectId = 0

rendering.objects = {}

rendering.resetMock = function()
    rendering.objectId = 0
    rendering.objects = {}
end

rendering.clear = function(modName)
    rendering.objects = {}
end

rendering.createObjectMock = function(table)
    local object = {
        id = rendering.objectId,
        unit_number = table.target.unit_number,
        visible = true,
        scale = table.scale,
        x_scale = table.x_scale,
        y_scale = table.y_scale,
        color = {r=1, g=1, b=1},
        valid = true,
    }
    rendering.objects[object.id] = object

    rendering.objectId = rendering.objectId + 1

    return object

end

rendering.draw_animation = function(table)
    return rendering.createObjectMock(table)
end

rendering.draw_light = function(table)
    return rendering.createObjectMock(table)
end

rendering.destroy = function(id)
    rendering.objects[id].valid = false
    rendering.objects[id] = nil
end

rendering.get_visible = function(id)
    return rendering.objects[id].visible
end

rendering.set_visible = function(id, visible)
    rendering.objects[id].visible = visible
end

rendering.set_color = function(id, color)
    rendering.objects[id].color = color
end

rendering.get_scale = function(id)
    return rendering.objects[id].scale
end

rendering.get_x_scale = function(id)
    return rendering.objects[id].x_scale
end

rendering.get_y_scale = function(id)
    return rendering.objects[id].y_scale
end

rendering.entityDestroyed = function(unit_number)
    for id, object in pairs(rendering.objects) do
        if object.unit_number == unit_number then
            rendering.objects[id] = nil
        end
    end
end

return rendering
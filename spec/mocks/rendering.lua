local rendering = {}

rendering.objectId = 0

rendering.objects = {}

rendering.resetMock = function()
    rendering.objectId = 0
    rendering.objects = {}
end

rendering.createObjectMock = function(table)
    local object = {
        id = rendering.objectId,
        unit_number = table.target.unit_number,
    }
    rendering.objects[object.id] = object

    rendering.objectId = rendering.objectId + 1
    
    return object.id

end

rendering.draw_animation = function(table)
    return rendering.createObjectMock(table)
end

rendering.draw_light = function(table)
    return rendering.createObjectMock(table)
end

rendering.is_valid = function(id)
    return rendering.objects[id] ~= nil
end

rendering.destroy = function(id)
    rendering.objects[id] = nil
end

rendering.entityDestroyed = function(unit_number)
    for id, object in pairs(rendering.objects) do
        if object.unit_number == unit_number then
            rendering.objects[id] = nil
        end
    end
end

return rendering
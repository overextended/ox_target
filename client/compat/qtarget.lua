local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qtarget_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local function convert(options)
    local distance = options.distance
    options = options.options

    for _, v in pairs(options) do
        v.onSelect = v.action
        v.action = nil
        v.distance = v.distance or distance
        v.name = v.name or v.label

        if v.event and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
        end
    end

    return options
end

exportHandler('AddBoxZone', function(name, center, length, width, options, targetoptions)
    return target.addBoxZone({
        name = name,
        coords = center,
        size = vec3(width, length, math.abs(options.maxZ - options.minZ)),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
    })
end)

exportHandler('AddPolyZone', function(name, points, options, targetoptions)
    return target.addBoxZone({
        name = name,
        points = points,
        thickness = math.abs(options.maxZ - options.minZ),
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)

exportHandler('AddCircleZone', function(name, center, radius, options, targetoptions)
    return target.addSphereZone({
        name = name,
        coords = center,
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)

exportHandler('RemoveZone', function(id)
    if Zones then
        if type(id) == 'string' then
            for _, v in pairs(Zones) do
                if v.name == id then
                    return v:remove()
                end
            end
        end

        if Zones[id] then
            Zones[id]:remove()
        end
    end
end)

exportHandler('AddTargetEntity', function(entities, options)
    target.addEntity(entities, convert(options))
end)

exportHandler('RemoveTargetEntity', function(entities, labels)
    target.removeEntity(entities, labels)
end)

exportHandler('AddTargetModel', function(models, options)
    target.addModel(models, convert(options))
end)

exportHandler('RemoveTargetModel', function(models, labels)
    target.removeModel(models, labels)
end)

exportHandler('Ped', function(options)
    target.addGlobalPed(convert(options))
end)

exportHandler('RemovePed', function(labels)
    target.removeGlobalPed(labels)
end)

exportHandler('Vehicle', function(options)
    target.addGlobalVehicle(convert(options))
end)

exportHandler('RemoveVehicle', function(labels)
    target.removeGlobalVehicle(labels)
end)

exportHandler('Object', function(options)
    target.addGlobalObject(convert(options))
end)

exportHandler('RemoveObject', function(labels)
    target.removeGlobalObject(labels)
end)

exportHandler('Player', function(options)
    target.addGlobalPlayer(convert(options))
end)

exportHandler('RemovePlayer', function(labels)
    target.removeGlobalPlayer(labels)
end)
local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qtarget_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

---@param options table
---@return table
local function convert(options)
    local distance = options.distance
    options = options.options

    for _, v in pairs(options) do
        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.groups = v.job
        v.items = v.item or v.required_item

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
            v.type = nil
        end

        v.action = nil
        v.job = nil
        v.item = nil
        v.required_item = nil
    end

    return options
end

exportHandler('AddBoxZone', function(name, center, length, width, options, targetoptions)
    return lib.zones.box({
        name = name,
        coords = center,
        size = vec3(width, length, math.abs(options.maxZ - options.minZ)),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('AddPolyZone', function(name, points, options, targetoptions)
    local newPoints = table.create(#points, 0)
    local thickness = math.abs(options.maxZ - options.minZ)

    for i = 1, #points do
        local point = points[i]
        newPoints[i] = vec3(point.x, point.y, options.maxZ - (thickness / 2))
    end

    return lib.zones.poly({
        name = name,
        points = newPoints,
        thickness = thickness,
        debug = options.debugPoly,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('AddCircleZone', function(name, center, radius, options, targetoptions)
    return lib.zones.sphere({
        name = name,
        coords = center,
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('RemoveZone', function(id)
    if Zones then
        if type(id) == 'string' then
            for _, v in pairs(Zones) do
                if v.name == id then
                    v:remove()
                end
            end
        end

        if Zones[id] then
            Zones[id]:remove()
        end
    end
end)

exportHandler('AddTargetBone', function(bones, options)
    if type(bones) ~= 'table' then bones = { bones } end
    options = convert(options)

    for k, v in pairs(options) do
        ---@type string | function | nil
        local canInteract = v.canInteract

        if canInteract then
            canInteract = msgpack.pack(canInteract)
            canInteract = msgpack.unpack(canInteract)
        end

        function v.canInteract(entity, distance, data)
            for i = 1, #bones do
                local boneId = GetEntityBoneIndexByName(entity, bones[i])

                if boneId ~= -1 then
                    return not canInteract or canInteract(entity, distance, data)
                end
            end
        end
    end

    exports.ox_target:addGlobalVehicle(options)
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
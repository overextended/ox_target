local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qb-target_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

---@param options table
---@return table
local function convert(options)
    local distance = options.distance
    options = options.options

    -- People may pass options as a hashmap (or mixed, even)
    for k, v in pairs(options) do
        if type(k) ~= 'number' then
            table.insert(options, v)
        end
    end

    for id, v in pairs(options) do
        if type(id) ~= 'number' then
            options[id] = nil
            goto continue
        end

        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.items = v.item
        v.icon = v.icon
        v.groups = v.job

        local groupType = type(v.groups)
        if groupType == 'nil' then
            v.groups = {}
            groupType = 'table'
        end
        if groupType == 'string' then
            local val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end
        elseif groupType == 'table' then
            local val = {}
            if table.type(v.groups) ~= 'array' then
                for k in pairs(v.groups) do
                    val[#val + 1] = k
                end
                v.groups = val
                val = nil
            end

            val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end
        end

        if type(v.groups) == 'table' and table.type(v.groups) == 'empty' then
            v.groups = nil
        end

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
        v.gang = nil
        v.citizenid = nil
        v.item = nil
        v.qtarget = true

        ::continue::
    end

    return options
end

local api = require 'client.api'

exportHandler('AddBoxZone', function(name, center, length, width, options, targetoptions)
    local z = center.z

    if not options.minZ then
        options.minZ = -100
    end

    if not options.maxZ then
        options.maxZ = 800
    end

    if not options.useZ then
        z = z + math.abs(options.maxZ - options.minZ) / 2
        center = vec3(center.x, center.y, z)
    end

    return api.addBoxZone({
        name = name,
        coords = center,
        size = vec3(width, length, (options.useZ or not options.maxZ) and center.z or math.abs(options.maxZ - options.minZ)),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
    })
end)

exportHandler('AddPolyZone', function(name, points, options, targetoptions)
    local newPoints = table.create(#points, 0)
    local thickness = math.abs(options.maxZ - options.minZ)

    for i = 1, #points do
        local point = points[i]
        newPoints[i] = vec3(point.x, point.y, options.maxZ - (thickness / 2))
    end

    return api.addPolyZone({
        name = name,
        points = newPoints,
        thickness = thickness,
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)

exportHandler('AddCircleZone', function(name, center, radius, options, targetoptions)
    return api.addSphereZone({
        name = name,
        coords = center,
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
    })
end)

exportHandler('RemoveZone', function(id)
    api.removeZone(id, true)
end)

exportHandler('AddTargetBone', function(bones, options)
    if type(bones) ~= 'table' then bones = { bones } end
    options = convert(options)

    for _, v in pairs(options) do
        v.bones = bones
    end

    exports.ox_target:addGlobalVehicle(options)
end)

exportHandler('AddTargetEntity', function(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    options = convert(options)

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            api.addEntity(NetworkGetNetworkIdFromEntity(entity), options)
        else
            api.addLocalEntity(entity, options)
        end
    end
end)

exportHandler('RemoveTargetEntity', function(entities, labels)
    if type(entities) ~= 'table' then entities = { entities } end

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            api.removeEntity(NetworkGetNetworkIdFromEntity(entity), labels)
        else
            api.removeLocalEntity(entity, labels)
        end
    end
end)

exportHandler('AddTargetModel', function(models, options)
    api.addModel(models, convert(options))
end)

exportHandler('RemoveTargetModel', function(models, labels)
    api.removeModel(models, labels)
end)

exportHandler('AddGlobalPed', function(options)
    api.addGlobalPed(convert(options))
end)

exportHandler('RemoveGlobalPed', function(labels)
    api.removeGlobalPed(labels)
end)

exportHandler('AddGlobalVehicle', function(options)
    api.addGlobalVehicle(convert(options))
end)

exportHandler('RemoveGlobalVehicle', function(labels)
    api.removeGlobalVehicle(labels)
end)

exportHandler('AddGlobalObject', function(options)
    api.addGlobalObject(convert(options))
end)

exportHandler('RemoveGlobalObject', function(labels)
    api.removeGlobalObject(labels)
end)

exportHandler('AddGlobalPlayer', function(options)
    api.addGlobalPlayer(convert(options))
end)

exportHandler('RemoveGlobalPlayer', function(labels)
    api.removeGlobalPlayer(labels)
end)

local utils = require 'client.utils'

exportHandler('AddEntityZone', function()
    utils.warn('AddEntityZone is not supported by ox_target - try using addEntity/addLocalEntity.')
end)

exportHandler('RemoveTargetBone', function()
    utils.warn('RemoveTargetBone is not supported by ox_target.')
end)
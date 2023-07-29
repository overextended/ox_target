AddEventHandler('ox_target:debug', function(data)
    if data.entity and GetEntityType(data.entity) > 0 then
        data.archetype = GetEntityArchetypeName(data.entity)
        data.model = GetEntityModel(data.entity)
    end

	print(json.encode(data, {indent=true}))
end)

if GetConvarInt('ox_target:debug', 0) ~= 1 then return end

local ox_target = exports.ox_target
local drawZones = true

ox_target:addBoxZone({
    coords = vec3(442.5363, -1017.666, 28.85637),
    size = vec3(3, 3, 3),
    rotation = 45,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'box',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-cube',
            label = locale('debug_box'),
        }
    }
})

ox_target:addSphereZone({
    coords = vec3(440.5363, -1015.666, 28.85637),
    radius = 3,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'sphere',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-circle',
            label = locale('debug_sphere'),
        }
    }
})

ox_target:addModel(`police`, {
    {
        name = 'police',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-handcuffs',
        label = locale('debug_police_car'),
    }
})

ox_target:addGlobalPed({
    {
        name = 'ped',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-male',
        label = locale('debug_ped'),
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-car',
        label = locale('debug_vehicle'),
    }
})

ox_target:addGlobalObject({
    {
        name = 'object',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-bong',
        label = locale('debug_object'),
    }
})
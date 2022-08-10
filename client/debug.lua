Debug = GetConvarInt('ox_target:debug', 1) == 1
if not Debug then return end

AddEventHandler('ox_target:debug', function(data)
	print(json.encode(data, {indent=true}))
end)

local ox_target = exports.ox_target
local drawZones = false

ox_target:AddBoxZone({
    coords = vec3(442.5363, -1017.666, 28.65637),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    interactionDistance = 10,
    drawSprite = true,
    options = {
        {
            name = 'test',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-cube',
            label = '(Debug) Box',
        }
    }
})

ox_target:AddSphereZone({
    coords = vec3(440.5363, -1015.666, 27.65637),
    radius = 1,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'test',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-circle',
            label = '(Debug) Sphere',
        }
    }
})

ox_target:AddModel(`police`, {
    {
        name = 'police',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-handcuffs',
        label = 'Police car',
    }
})

ox_target:AddGlobalPed({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-male',
        label = '(Debug) Ped',
    }
})

ox_target:AddGlobalVehicle({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-car',
        label = '(Debug) Vehicle',
    }
})

ox_target:AddGlobalObject({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-bong',
        label = '(Debug) Object',
    }
})

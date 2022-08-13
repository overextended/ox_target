Debug = GetConvarInt('ox_target:debug', 0) == 1
if not Debug then return end

AddEventHandler('ox_target:debug', function(data)
	print(json.encode(data, {indent=true}))
end)

local ox_target = exports.ox_target
local drawZones = true

ox_target:addBoxZone({
    coords = vec3(442.5363, -1017.666, 28.85637),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = drawZones,
    interactionDistance = 10,
    drawSprite = true,
    options = {
        {
            name = 'box',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-cube',
            label = '(Debug) Box',
            canInteract = function(entity, coords, distance)
                return true
            end
        }
    }
})

ox_target:addSphereZone({
    coords = vec3(440.5363, -1015.666, 28.85637),
    radius = 1,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'sphere',
            event = 'ox_target:debug',
            icon = 'fa-solid fa-circle',
            label = '(Debug) Sphere',
            canInteract = function(entity, coords, distance)
                return true
            end
        }
    }
})

ox_target:addModel(`police`, {
    {
        name = 'police',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-handcuffs',
        label = 'Police car',
        canInteract = function(entity, coords, distance)
            return true
        end
    }
})

ox_target:addGlobalPed({
    {
        name = 'ped',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-male',
        label = '(Debug) Ped',
        canInteract = function(entity, coords, distance)
            return true
        end
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-car',
        label = '(Debug) Vehicle',
        canInteract = function(entity, coords, distance)
            return true
        end
    }
})

ox_target:addGlobalObject({
    {
        name = 'object',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-bong',
        label = '(Debug) Object',
        canInteract = function(entity, coords, distance)
            return true
        end
    }
})

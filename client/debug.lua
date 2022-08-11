Debug = GetConvarInt('ox_target:debug', 1) == 1
if not Debug then return end

AddEventHandler('ox_target:debug', function(data)
	print(json.encode(data, {indent=true}))
end)

local ox_target = exports.ox_target
local drawZones = false

ox_target:addBoxZone({
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
            canInteract = function(entity)
                return true
            end
        }
    }
})

ox_target:addSphereZone({
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
            canInteract = function(entity)
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
        canInteract = function(entity)
            return true
        end
    }
})

ox_target:addGlobalPed({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-male',
        label = '(Debug) Ped',
        canInteract = function(entity)
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
        canInteract = function(entity)
            return true
        end
    }
})

ox_target:addGlobalObject({
    {
        name = 'vehicle',
        event = 'ox_target:debug',
        icon = 'fa-solid fa-bong',
        label = '(Debug) Object',
        canInteract = function(entity)
            return true
        end
    }
})

if GetConvarInt('ox_target:defaults', 1) ~= 1 then return end
local ox_target = exports.ox_target

local function toggleDoor(vehicle, door)
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
            SetVehicleDoorShut(vehicle, door, false)
        else
            SetVehicleDoorOpen(vehicle, door, false)
        end
    end
end

ox_target:addGlobalVehicle({
    {
        name = 'ox_target:driverF',
        icon = 'fa-solid fa-car-side',
        label = 'Toggle front driver door',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'seat_dside_f')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.72
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 0)
        end
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'ox_target:passengerF',
        icon = 'fa-solid fa-car-side',
        label = 'Toggle front passenger door',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'seat_pside_f')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.72
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 1)
        end
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'ox_target:driverR',
        icon = 'fa-solid fa-car-side',
        label = 'Toggle rear driver door',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'seat_dside_r')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.72
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 2)
        end
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'ox_target:passengerR',
        icon = 'fa-solid fa-car-side',
        label = 'Toggle rear passenger door',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'seat_pside_r')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.72
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 3)
        end
    }
})


ox_target:addGlobalVehicle({
    {
        name = 'ox_target:bonnet',
        icon = 'fa-solid fa-car',
        label = 'Toggle hood',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'bonnet')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.9
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 4)
        end
    }
})

ox_target:addGlobalVehicle({
    {
        name = 'ox_target:trunk',
        icon = 'fa-solid fa-car-rear',
        label = 'Toggle trunk',
        canInteract = function(name, entity, coords, distance)
            local boneId = GetEntityBoneIndexByName(entity, 'boot')
            return boneId ~= -1 and #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 0.9
        end,
        onSelect = function(name, entity, coords, distance)
            toggleDoor(entity, 5)
        end
    }
})

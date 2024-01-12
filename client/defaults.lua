if GetConvarInt('ox_target:defaults', 1) ~= 1 then return end

local api = require 'client.api'
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local GetVehicleDoorLockStatus = GetVehicleDoorLockStatus

local bones = {
    [0] = 'dside_f',
    [1] = 'pside_f',
    [2] = 'dside_r',
    [3] = 'pside_r'
}

local function toggleDoor(vehicle, door)
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
            SetVehicleDoorShut(vehicle, door, false)
        else
            SetVehicleDoorOpen(vehicle, door, false, false)
        end
    end
end

local function canInteractWithDoor(entity, coords, door, boneId)
    if GetVehicleDoorLockStatus(entity) > 1 then return end

    local boneName = bones[door]
    if not boneName or boneId then
        if IsVehicleDoorDamaged(entity, 4) then return end
        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.9
    end


    boneId = GetEntityBoneIndexByName(entity, 'door_' .. boneName)

    if IsVehicleDoorDamaged(entity, door) then return end

    if boneId ~= -1 then
        return #(coords - GetEntityBonePosition_2(entity, boneId)) < 0.5 or
            #(coords - GetEntityBonePosition_2(entity, GetEntityBoneIndexByName(entity, 'seat_' .. boneName))) < 0.72
    end
end

local function onSelectDoor(data, door)
    local entity = data.entity
    local owner = NetworkGetEntityOwner(entity)
    if owner == cache.playerId then
        toggleDoor(entity, door)
    else
        TriggerServerEvent('ox_target:toggleEntityDoor', VehToNet(entity), door)
    end
end

RegisterNetEvent('ox_target:toggleEntityDoor', function(netId, door)
    local entity = NetToVeh(netId)
    toggleDoor(entity, door)
end)

api.addGlobalVehicle({
    {
        name = 'ox_target:driverF',
        icon = 'fa-solid fa-car-side',
        label = locale('toggle_front_driver_door'),
        bones = { 'door_dside_f', 'seat_dside_f' },
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 0)
        end,
        onSelect = function(data)
            onSelectDoor(data, 0)
        end
    },
    {
        name = 'ox_target:passengerF',
        icon = 'fa-solid fa-car-side',
        label = locale('toggle_front_passenger_door'),
        bones = { 'door_pside_f', 'seat_pside_f' },
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 1)
        end,
        onSelect = function(data)
            onSelectDoor(data, 1)
        end
    },
    {
        name = 'ox_target:driverR',
        icon = 'fa-solid fa-car-side',
        label = locale('toggle_rear_driver_door'),
        bones = { 'door_dside_r', 'seat_dside_r' },
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 2)
        end,
        onSelect = function(data)
            onSelectDoor(data, 2)
        end
    },
    {
        name = 'ox_target:passengerR',
        icon = 'fa-solid fa-car-side',
        label = locale('toggle_rear_passenger_door'),
        bones = { 'door_pside_r', 'seat_pside_r' },
        canInteract = function(entity, distance, coords, name)
            return canInteractWithDoor(entity, coords, 3)
        end,
        onSelect = function(data)
            onSelectDoor(data, 3)
        end
    },
    {
        name = 'ox_target:bonnet',
        icon = 'fa-solid fa-car',
        label = locale('toggle_hood'),
        bones = 'bonnet',
        canInteract = function(entity, distance, coords, name, boneId)
            return canInteractWithDoor(entity, coords, 4, boneId)
        end,
        onSelect = function(data)
            onSelectDoor(data, 4)
        end
    },
    {
        name = 'ox_target:trunk',
        icon = 'fa-solid fa-car-rear',
        label = locale('toggle_trunk'),
        bones = 'boot',
        canInteract = function(entity, distance, coords, name, boneId)
            return canInteractWithDoor(entity, coords, 4, boneId)
        end,
        onSelect = function(data)
            onSelectDoor(data, 5)
        end
    }
})

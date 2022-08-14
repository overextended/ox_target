exports('addBoxZone', function(data)
    return lib.zones.box(data).id
end)

exports('addSphereZone', function(data)
    return lib.zones.sphere(data).id
end)

---@param target table
---@param options table
---@param resource string
local function addTarget(target, options, resource)
    for i = 1, #options do
        options[i].resource = resource or 'ox_target'
        table.insert(target, options[i])
    end
end

---@param target table
---@param options table
---@param resource string
local function removeTarget(target, options, resource)
    if type(options) ~= 'table' then options = { options } end

    for k, v in pairs(target) do
        for i = 1, #options do
            local name = options[i]

            if v.resource == (resource or 'ox_target') and v.name == name then
                table.remove(target, k)
            end
        end
    end
end

local Peds = {}

exports('addGlobalPed', function(options)
    addTarget(Peds, options, GetInvokingResource())
end)

exports('removeGlobalPed', function(options)
    removeTarget(Peds, options, GetInvokingResource())
end)

local Vehicles = {}

exports('addGlobalVehicle', function(options)
    addTarget(Vehicles, options, GetInvokingResource())
end)

exports('removeGlobalVehicle', function(options)
    removeTarget(Vehicles, options, GetInvokingResource())
end)

local Objects = {}

exports('addGlobalObject', function(options)
    addTarget(Objects, options, GetInvokingResource())
end)

exports('removeGlobalObject', function(options)
    removeTarget(Objects, options, GetInvokingResource())
end)

local Players = {}

exports('addGlobalPlayer', function(options)
    addTarget(Players, options, GetInvokingResource())
end)

exports('removeGlobalPlayer', function(options)
    removeTarget(Players, options, GetInvokingResource())
end)

local Models = {}

exports('addModel', function(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local model = arr[i]
        model = type(model) == 'string' and joaat(model) or model

        if not Models[model] then
            Models[model] = {}
        end

        addTarget(Models[model], options, GetInvokingResource())
    end
end)

exports('addModel', function(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local model = arr[i]
        model = type(model) == 'string' and joaat(model) or model

        if Models[model] then
            removeTarget(Models[model], options, GetInvokingResource())
        end
    end
end)

local Entities = {}

exports('addEntity', function(arr, options)
    arr = type(arr) ~= 'table' and { arr } or arr

    for i = 1, #arr do
        local netId = arr[i]

        if not Entities[netId] then
            Entities[netId] = {}
        end

        if NetworkDoesNetworkIdExist(netId) then
            addTarget(Entities[netId], options, GetInvokingResource())
        end
    end
end)

exports('removeEntity', function(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local netId = arr[i]

        if Entities[netId] then
            removeTarget(Entities[netId], options, GetInvokingResource())
        end
    end
end)

local LocalEntities = {}

exports('addLocalEntity', function(arr, options)
    arr = type(arr) ~= 'table' and { arr } or arr

    for i = 1, #arr do
        local entity = arr[i]

        if not LocalEntities[entity] then
            LocalEntities[entity] = {}
        end

        if DoesEntityExist(entity) then
            addTarget(LocalEntities[entity], options, GetInvokingResource())
        else
            print(("No entity with id '%s' exists."):format(entity))
        end
    end
end)

exports('removeLocalEntity', function(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local entity = arr[i]

        if LocalEntities[entity] then
            removeTarget(LocalEntities[entity], options, GetInvokingResource())
        end
    end
end)

local function removeResourceTargets(resource, options)
    for i = 1, #options do
        local target = options[i]

        for k, v in pairs(target) do
            if v.resource == resource then
                table.remove(target, k)
            end
        end
    end
end

AddEventHandler('onClientResourceStop', function(resource)
    local options = { Peds, Vehicles, Objects, Players, Models, Entities, LocalEntities, Zones }

    removeResourceTargets(resource, options)

    for k, v in pairs(Models) do
        removeResourceTargets(resource, v)
    end

    for k, v in pairs(Entities) do
        removeResourceTargets(resource, v)
    end

    for k, v in pairs(LocalEntities) do
        removeResourceTargets(resource, v)
    end
end)

local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity

function GetEntityOptions(entity, _type, model)
    if _type == 1 then
        if IsPedAPlayer(entity) then
            return {
                global = Players
            }
        end
    end

    local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
    local global

    if _type == 1 then
        global = Peds
    elseif _type == 2 then
        global = Vehicles
    elseif _type == 3 then
        global = Objects
    end

    return {
        global = global,
        model = Models[model],
        entity = netId and Entities[netId] or nil,
        localEntity = LocalEntities[entity],
    }
end

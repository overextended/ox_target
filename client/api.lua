exports('addBoxZone', function(data)
    return lib.zones.box(data).id
end)

exports('addSphereZone', function(data)
    return lib.zones.sphere(data).id
end)

exports('removeZone', function(id)
    Zones[id]:remove()
end)

---@param target table
---@param add table
---@param resource string
local function addTarget(target, add, resource)
    local num = #target
    for i = 1, #add do
        num += 1
        add[i].resource = resource or 'ox_target'
        target[num] = add[i]
    end
end

---@param target table
---@param remove table
---@param resource string
local function removeTarget(target, remove, resource)
    if type(remove) ~= 'table' then remove = { remove } end

    for i = #target, 1, -1 do
        local option = target[i]

        if option.resource == resource then
            for j = #remove, 1, -1 do
                if option.name == remove[j] then
                    table.remove(target, j)
                end
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

exports('removeModel', function(arr, options)
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

local function removeResourceTargets(resource, target)
    for i = 1, #target do
        local options = target[i]

        for j = #options, 1, -1 do
            if options[j].resource == resource then
                table.remove(options, j)
            end
        end
    end
end

AddEventHandler('onClientResourceStop', function(resource)
    local options = { Peds, Vehicles, Objects, Players, Models, Entities, LocalEntities }

    removeResourceTargets(resource, options)

    if Zones then
        for k, v in pairs(Zones) do
            v:remove()
        end
    end

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

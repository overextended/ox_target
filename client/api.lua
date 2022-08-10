exports('addBoxZone', function(data)
    return lib.zones.box(data).id
end)

exports('addSphereZone', function(data)
    return lib.zones.sphere(data).id
end)

---@param target table
---@param options table
---@param resource string
local function addGlobal(target, options, resource)
    for i = 1, #options do
        options[i].resource = resource or 'ox_target'
        table.insert(target, options[i])
    end
end

local Peds = {}

exports('addGlobalPed', function(options)
    addGlobal(Peds, options, GetInvokingResource())
end)

local Vehicles = {}

exports('addGlobalVehicle', function(options)
    addGlobal(Vehicles, options, GetInvokingResource())
end)

local Objects = {}

exports('addGlobalObject', function(options)
    addGlobal(Objects, options, GetInvokingResource())
end)

local Players = {}

exports('addGlobalPlayer', function(options)
    addGlobal(Objects, options, GetInvokingResource())
end)

---@param target table
---@param options table
---@param resource string
local function addTarget(target, options, resource)
    if not target.options then
        target.options = {}
    end

    for i = 1, #options do
        options[i].resource = resource
        table.insert(target.options, options[i])
    end
end

local Models = {}

exports('addModel', function(arr, options)
    arr = type(arr) ~= 'table' and { arr } or arr

    for i = 1, #arr do
        local model = arr[i]
        model = type(model) == 'string' and joaat(model) or model

        if not Models[model] then
            Models[model] = {}
        end

        addTarget(Models[model], options, GetInvokingResource())
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

exports('remove', function(tbl, index, name)
    if not name then
        index, name = nil, index
    end

    local target = index and _ENV[tbl][index] or _ENV[tbl]
    local resource = GetInvokingResource() or 'ox_target'

    for k, v in pairs(target) do
        if v.name == 'name' and v.resource == resource then
            table.remove(target, k)
        end
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
        global = { global },
        model = Models[model],
        entity = netId and Entities[netId] or nil,
        localEntity = LocalEntities[entity],
    }
end

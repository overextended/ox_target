target = setmetatable({}, {
    __newindex = function(self, index, value)
        rawset(self, index, value)
        exports(index, value)
    end
})

function target.addBoxZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.box(data).id
end

function target.addSphereZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.sphere(data).id
end

function target.removeZone(id)
    Zones[id]:remove()
end

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

function target.addGlobalPed(options)
    addTarget(Peds, options, GetInvokingResource())
end

function target.removeGlobalPed(options)
    removeTarget(Peds, options, GetInvokingResource())
end

local Vehicles = {}

function target.addGlobalVehicle(options)
    addTarget(Vehicles, options, GetInvokingResource())
end

function target.removeGlobalVehicle(options)
    removeTarget(Vehicles, options, GetInvokingResource())
end

local Objects = {}

function target.addGlobalObject(options)
    addTarget(Objects, options, GetInvokingResource())
end

function target.removeGlobalObject(options)
    removeTarget(Objects, options, GetInvokingResource())
end

local Players = {}

function target.addGlobalPlayer(options)
    addTarget(Players, options, GetInvokingResource())
end

function target.removeGlobalPlayer(options)
    removeTarget(Players, options, GetInvokingResource())
end

local Models = {}

function target.addModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local model = arr[i]
        model = type(model) == 'string' and joaat(model) or model

        if not Models[model] then
            Models[model] = {}
        end

        addTarget(Models[model], options, GetInvokingResource())
    end
end

function target.removeModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local model = arr[i]
        model = type(model) == 'string' and joaat(model) or model

        if Models[model] then
            removeTarget(Models[model], options, GetInvokingResource())
        end
    end
end

local Entities = {}

function target.addEntity(arr, options)
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
end

function target.removeEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local netId = arr[i]

        if Entities[netId] then
            removeTarget(Entities[netId], options, GetInvokingResource())
        end
    end
end

local LocalEntities = {}

function target.addLocalEntity(arr, options)
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
end

function target.removeLocalEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end

    for i = 1, #arr do
        local entity = arr[i]

        if LocalEntities[entity] then
            removeTarget(LocalEntities[entity], options, GetInvokingResource())
        end
    end
end

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
        for _, v in pairs(Zones) do
            if v.resource == resource then
                v:remove()
            end
        end
    end

    for _, v in pairs(Models) do
        removeResourceTargets(resource, v)
    end

    for _, v in pairs(Entities) do
        removeResourceTargets(resource, v)
    end

    for _, v in pairs(LocalEntities) do
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
local api = setmetatable({}, {
    __newindex = function(self, index, value)
        rawset(self, index, value)
        exports(index, value)
    end
})

---@param data table
---@return number
function api.addPolyZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.poly(data).id
end

---@param data table
---@return number
function api.addBoxZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.box(data).id
end

---@param data table
---@return number
function api.addSphereZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.sphere(data).id
end

---@param id number
function api.removeZone(id)
    local zone = Zones?[id]

    if not zone then
        return warn(('attempted to remove a zone that does not exists (id: %s)'):format(id))
    end

    zone:remove()
end

---Throws a formatted type error
---@param variable string
---@param expected string
---@param received string
local function typeError(variable, expected, received)
    error(("expected %s to have type '%s' (received %s)"):format(variable, expected, received))
end

---@param target table
---@param options table
---@param resource string
local function addTarget(target, options, resource)
    local optionsType = type(options)

    if optionsType ~= 'table' then
        typeError('options', 'table', optionsType)
    end

    local tableType = table.type(options)

    if tableType ~= 'array' then
        typeError('options', 'array', ('%s table'):format(tableType))
    end

    local num = #target

    for i = 1, #options do
        num += 1
        options[i].resource = resource or 'ox_target'
        target[num] = options[i]
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
                    table.remove(target, i)
                end
            end
        end
    end
end

local peds = {}

---@param options table
function api.addGlobalPed(options)
    addTarget(peds, options, GetInvokingResource())
end

---@param options table
function api.removeGlobalPed(options)
    removeTarget(peds, options, GetInvokingResource())
end

local vehicles = {}

---@param options table
function api.addGlobalVehicle(options)
    addTarget(vehicles, options, GetInvokingResource())
end

---@param options table
function api.removeGlobalVehicle(options)
    removeTarget(vehicles, options, GetInvokingResource())
end

function api.getVehicle()
    return vehicles
end

local objects = {}

---@param options table
function api.addGlobalObject(options)
    addTarget(objects, options, GetInvokingResource())
end

---@param options table
function api.removeGlobalObject(options)
    removeTarget(objects, options, GetInvokingResource())
end

local players = {}

---@param options table
function api.addGlobalPlayer(options)
    addTarget(players, options, GetInvokingResource())
end

---@param options table
function api.removeGlobalPlayer(options)
    removeTarget(players, options, GetInvokingResource())
end

local models = {}

---@param arr number | number[]
---@param options table
function api.addModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local model = arr[i]
        model = tonumber(model) or joaat(model)

        if not models[model] then
            models[model] = {}
        end

        addTarget(models[model], options, resource)
    end
end

function api.getModels()
    return models
end

---@param arr number | number[]
---@param options? table
function api.removeModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local model = arr[i]
        model = tonumber(model) or joaat(model)

        if models[model] then
            if options then
                removeTarget(models[model], options, resource)
            end

            if not options or #models[model] == 0 then
                models[model] = nil
            end
        end
    end
end

local entities = {}

---@param arr number | number[]
---@param options table
function api.addEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local netId = arr[i]

        if NetworkDoesNetworkIdExist(netId) then
            if not entities[netId] then
                entities[netId] = {}

                if not Entity(NetworkGetEntityFromNetworkId(netId)).state.hasTargetOptions then
                    TriggerServerEvent('ox_target:setEntityHasOptions', netId)
                end
            end

            addTarget(entities[netId], options, resource)
        end
    end
end

---@param arr number | number[]
---@param options? table
function api.removeEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local netId = arr[i]

        if entities[netId] then
            if options then
                removeTarget(entities[netId], options, resource)
            end

            if not options or #entities[netId] == 0 then
                entities[netId] = nil
            end
        end
    end
end

function api.getEntities()
    return entities
end

RegisterNetEvent('ox_target:removeEntity', api.removeEntity)

local localEntities = {}

---@param arr number | number[]
---@param options table
function api.addLocalEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local entityId = arr[i]

        if DoesEntityExist(entityId) then
            if not localEntities[entityId] then
                localEntities[entityId] = {}
            end

            addTarget(localEntities[entityId], options, resource)
        else
            print(("No entity with id '%s' exists."):format(entityId))
        end
    end
end

---@param arr number | number[]
---@param options? table
function api.removeLocalEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local entity = arr[i]

        if localEntities[entity] then
            if options then
                removeTarget(localEntities[entity], options, resource)
            end

            if not options or #localEntities[entity] == 0 then
                localEntities[entity] = nil
            end
        end
    end
end

function api.getLocalEntities()
    return localEntities
end

CreateThread(function()
    while true do
        Wait(60000)

        for entityId in pairs(localEntities) do
            if not DoesEntityExist(entityId) then
                localEntities[entityId] = nil
            end
        end
    end
end)

---@param resource string
---@param target table
local function removeResourceGlobals(resource, target)
    for i = 1, #target do
        local options = target[i]

        for j = #options, 1, -1 do
            if options[j].resource == resource then
                table.remove(options, j)
            end
        end
    end
end

---@param resource string
---@param target table
local function removeResourceTargets(resource, target)
    for i = 1, #target do
        local tbl = target[i]

        for key, options in pairs(tbl) do
            for j = #options, 1, -1 do
                if options[j].resource == resource then
                    table.remove(options, j)
                end
            end

            if #options == 0 then
                tbl[key] = nil
            end
        end
    end
end

---@param resource string
AddEventHandler('onClientResourceStop', function(resource)
    removeResourceGlobals(resource, { peds, vehicles, objects, players })
    removeResourceTargets(resource, { models, entities, localEntities })

    if Zones then
        for _, v in pairs(Zones) do
            if v.resource == resource then
                v:remove()
            end
        end
    end
end)

local NetworkGetEntityIsNetworked = NetworkGetEntityIsNetworked
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity

---@param entity number
---@param _type number
---@param model number
---@return table
function api.getEntityOptions(entity, _type, model)
    if _type == 1 then
        if IsPedAPlayer(entity) then
            return {
                global = players
            }
        end
    end

    local netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity)
    local global

    if _type == 1 then
        global = peds
    elseif _type == 2 then
        global = vehicles
    else
        global = objects
    end

    return {
        global = global,
        model = models[model],
        entity = netId and entities[netId] or nil,
        localEntity = localEntities[entity],
    }
end

local state = require 'client.state'

function api.disableTargeting(value)
    if value then
        state.setActive(false)
    end

    state.setDisabled(value)
end

return api

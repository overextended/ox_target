target = setmetatable({}, {
    __newindex = function(self, index, value)
        rawset(self, index, value)
        exports(index, value)
    end
})

---@param data table
---@return number
function target.addPolyZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.poly(data).id
end

---@param data table
---@return number
function target.addBoxZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.box(data).id
end

---@param data table
---@return number
function target.addSphereZone(data)
    data.resource = GetInvokingResource()
    return lib.zones.sphere(data).id
end

---@param id number
function target.removeZone(id)
    local zone = Zones?[id]

    if not zone then
        return warn(('attempted to remove a zone that does not exists (id: %s)'):format(id))
    end

    zone:remove()
end

---@param target table
---@param options table
---@param resource string
local function addTarget(target, options, resource)
    local optionsType = type(options)

    if optionsType ~= 'table' then
        TypeError('options', 'table', optionsType)
    end

    local tableType = table.type(options)

    if tableType ~= 'array' then
        TypeError('options', 'array', ('%s table'):format(tableType))
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

local Peds = {}

---@param options table
function target.addGlobalPed(options)
    addTarget(Peds, options, GetInvokingResource())
end

---@param options table
function target.removeGlobalPed(options)
    removeTarget(Peds, options, GetInvokingResource())
end

local Vehicles = {}

---@param options table
function target.addGlobalVehicle(options)
    addTarget(Vehicles, options, GetInvokingResource())
end

---@param options table
function target.removeGlobalVehicle(options)
    removeTarget(Vehicles, options, GetInvokingResource())
end

local Objects = {}

---@param options table
function target.addGlobalObject(options)
    addTarget(Objects, options, GetInvokingResource())
end

---@param options table
function target.removeGlobalObject(options)
    removeTarget(Objects, options, GetInvokingResource())
end

local Players = {}

---@param options table
function target.addGlobalPlayer(options)
    addTarget(Players, options, GetInvokingResource())
end

---@param options table
function target.removeGlobalPlayer(options)
    removeTarget(Players, options, GetInvokingResource())
end

local Models = {}

---@param arr number | number[]
---@param options table
function target.addModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local model = arr[i]
        model = tonumber(model) or joaat(model)

        if not Models[model] then
            Models[model] = {}
        end

        addTarget(Models[model], options, resource)
    end
end

---@param arr number | number[]
---@param options? table
function target.removeModel(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local model = arr[i]
        model = tonumber(model) or joaat(model)

        if Models[model] then
            if options then
                removeTarget(Models[model], options, resource)
            end

            if not options or #Models[model] == 0 then
                Models[model] = nil
            end
        end
    end
end

local Entities = {}

---@param arr number | number[]
---@param options table
function target.addEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local netId = arr[i]

        if NetworkDoesNetworkIdExist(netId) then
            if not Entities[netId] then
                Entities[netId] = {}
            end

            addTarget(Entities[netId], options, resource)
        end
    end
end

---@param arr number | number[]
---@param options? table
function target.removeEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local netId = arr[i]

        if Entities[netId] then
            if options then
                removeTarget(Entities[netId], options, resource)
            end

            if not options or #Entities[netId] == 0 then
                Entities[netId] = nil
            end
        end
    end
end

local LocalEntities = {}

---@param arr number | number[]
---@param options table
function target.addLocalEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local entity = arr[i]

        if DoesEntityExist(entity) then
            if not LocalEntities[entity] then
                LocalEntities[entity] = {}
            end

            addTarget(LocalEntities[entity], options, resource)
        else
            print(("No entity with id '%s' exists."):format(entity))
        end
    end
end

---@param arr number | number[]
---@param options? table
function target.removeLocalEntity(arr, options)
    if type(arr) ~= 'table' then arr = { arr } end
    local resource = GetInvokingResource()

    for i = 1, #arr do
        local entity = arr[i]

        if LocalEntities[entity] then
            if options then
                removeTarget(LocalEntities[entity], options, resource)
            end

            if not options or #LocalEntities[entity] == 0 then
                LocalEntities[entity] = nil
            end
        end
    end
end

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
    removeResourceGlobals(resource, { Peds, Vehicles, Objects, Players })
    removeResourceTargets(resource, { Models, Entities, LocalEntities })

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
    else
        global = Objects
    end

    return {
        global = global,
        model = Models[model],
        entity = netId and Entities[netId] or nil,
        localEntity = LocalEntities[entity],
    }
end
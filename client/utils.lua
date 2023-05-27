local utils = {}

local api = require 'client.api'
local state = require 'client.state'
local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial

---@param flag number
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function utils.raycastFromCamera(flag)
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 10
    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
        flag, cache.ped, 4)

    while true do
        Wait(0)
        local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

        if retval ~= 1 then
            ---@diagnostic disable-next-line: return-type-mismatch
            return hit, entityHit, endCoords, surfaceNormal, materialHash
        end
    end
end

function utils.getTexture()
    return lib.requestStreamedTextureDict('shared'), 'emptydot_32'
end

if GetConvarInt('ox_target:drawSprite', 1) == 1 then
    local SetDrawOrigin = SetDrawOrigin
    local DrawSprite = DrawSprite
    local ClearDrawOrigin = ClearDrawOrigin
    local colour = vector(255, 255, 255, 255)
    local hover = vector(98, 135, 236, 255)
    local inRange
    local width = 0.02
    local height = width * GetAspectRatio(false)

    ---@param coords vector3
    ---@return CZone[] | false | nil, CZone?
    function utils.getNearbyZones(coords)
        if not Zones then return end

        inRange = {}
        local n = 0
        local newZone

        for _, zone in pairs(Zones) do
            local contains = zone:contains(coords)

            if zone.drawSprite ~= false and (contains or (zone.distance or 7) < 7) then
                zone.colour = contains and hover or nil
                n += 1
                inRange[n] = zone
            end

            if not newZone and contains then
                newZone = zone
            end
        end



        return n > 0 and inRange, newZone
    end


    function utils.getNearbyTarget(coords)
        coords = coords or GetEntityCoords(PlayerPedId())
        inRange = {}

        local n = 0
        local targetData  = getTargetData();
        local activated   = getActivated();
        local isActive    = state.isActive();

        local getDistance = function(obj) 
            return #(GetEntityCoords(PlayerPedId())-GetEntityCoords(obj))
        end

        local models = api.getModels();
        for _, obj in pairs(GetGamePool("CObject")) do
            local distance = getDistance(obj)
            local model = GetEntityModel(obj);

            if (DoesEntityExist(obj) and models[model] and (distance < 7)) then
                local data = models[model];

                local isHover = obj == targetData?.entity and activated

                n += 1;
                inRange[n] = {
                    drawSprite = data?.drawSprite or  true,
                    colour = isHover and (data?.hover or hover) or (data?.colour or colour),
                    coords = GetEntityCoords(obj)
                }
            end
        end
        
        local entities = api.getLocalEntities();
        for obj, data in pairs(entities) do
            local distance = getDistance(obj)
            if (DoesEntityExist(obj) and (distance < 7)) then
                local isHover = obj == targetData?.entity and activated

                n += 1;
                inRange[n] = {
                    drawSprite = data?.drawSprite or  true,
                    colour = isHover and (data?.hover or hover) or (data?.colour or colour),
                    coords = GetEntityCoords(obj)
                }
            end
        end

        local vehicles = api.getVehicle();
        for _, vehicle in pairs(GetGamePool("CVehicle")) do
            local distance = getDistance(vehicle)
            
            if (DoesEntityExist(vehicle) and (distance < 7)) then
                local isHover =  targetData?.entity == vehicle and activated 

                if (isHover) then  
                end

                n += 1;
                inRange[n] = {
                    drawSprite = data?.drawSprite or  true,
                    colour = isHover and (data?.hover or hover) or (data?.colour or colour),
                    coords = GetEntityCoords(vehicle)
                }
            end
        end
        
    end

    function utils.drawZoneSprites(dict, texture)
        utils.getNearbyTarget()
        
        if (not inRange) then return end;

        for i = 1, #inRange do
            local zone = inRange[i]
            local spriteColour = zone.colour or colour

            if zone.drawSprite ~= false then
                SetDrawOrigin(zone.coords.x, zone.coords.y, zone.coords.z)
                DrawSprite(dict, texture, 0, 0, width, height, 0, spriteColour.r, spriteColour.g, spriteColour.b, spriteColour.a)
            end
        end

        ClearDrawOrigin()
    end
else
    ---@param coords vector3
    ---@return CZone?
    function utils.getCurrentZone(coords)
        if not Zones then return end

        for _, zone in pairs(Zones) do
            if zone:contains(coords) then
                return zone
            end
        end
    end
end

function utils.hasExport(export)
    local resource, exportName = string.strsplit('.', export)

    return pcall(function()
        return exports[resource][exportName]
    end)
end

local playerItems

function utils.getItems()
    if not playerItems then
        playerItems = {}
    end

    return playerItems
end

if utils.hasExport('ox_inventory.Items') then
    playerItems = setmetatable({}, {
        __index = function(self, index)
            self[index] = exports.ox_inventory:Search('count', index) or 0
            return self[index]
        end
    })

    AddEventHandler('ox_inventory:itemCount', function(name, count)
        playerItems[name] = count
    end)
end

---@param filter string | string[] | table<string, number>
---@param hasAny boolean?
---@return boolean
function utils.hasPlayerGotItems(filter, hasAny)
    if not playerItems then return true end

    local _type = type(filter)

    if _type == 'string' then
        return (playerItems[filter] or 0) > 0
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, amount in pairs(filter) do
                local hasItem = (playerItems[name] or 0) >= amount

                if hasAny then
                    if hasItem then return true end
                elseif not hasItem then
                    return false
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local hasItem = (playerItems[filter[i]] or 0) > 0

                if hasAny then
                    if hasItem then return true end
                elseif not hasItem then
                    return false
                end
            end
        end
    end

    return not hasAny
end

---stub
---@param filter string | string[] | table<string, number>
---@return boolean
function utils.hasPlayerGotGroup(filter)
    return true
end

return utils

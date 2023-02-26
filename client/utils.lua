lib.locale()

---Throws a formatted type error
---@param variable string
---@param expected string
---@param received string
function TypeError(variable, expected, received)
    error(("expected %s to have type '%s' (received %s)"):format(variable, expected, received))
end

local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial

---@param flag number
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function RaycastFromCamera(flag)
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

if GetConvarInt('ox_target:drawSprite', 1) == 1 then
    local SetDrawOrigin = SetDrawOrigin
    local DrawSprite = DrawSprite
    local ClearDrawOrigin = ClearDrawOrigin
    local dict = 'shared'
    local texture = 'emptydot_32'
    local colour = { 155, 155, 155, 175 }
    local hover = { 98, 135, 236, 255 }

    function DrawSprites()
        local inRange
        local width = 0.02
        local height = width * GetAspectRatio()

        lib.requestStreamedTextureDict(dict)

        ---@param coords vector3
        ---@return CZone[] | false | nil, CZone?
        return function(coords)
            if Zones then
                inRange = {}
                local n = 0
                local newZone

                for _, zone in pairs(Zones) do
                    local contains = zone:contains(coords)

                    if zone.drawSprite ~= false and (contains or (zone.distance or 7) < 7) then
                        zone.colour = contains and hover or colour
                        n += 1
                        inRange[n] = zone
                    end

                    if not newZone and contains then
                        newZone = zone
                    end
                end

                return n > 0 and inRange, newZone
            end
        end, function()
            for i = 1, #inRange do
                local zone = inRange[i]

                if zone.drawSprite ~= false then
                    SetDrawOrigin(zone.coords.x, zone.coords.y, zone.coords.z)
                    DrawSprite(dict, texture, 0, 0, width, height, 0, zone.colour[1], zone.colour[2], zone.colour[3], zone.colour[4])
                end
            end

            ClearDrawOrigin()
        end
    end
else
    function DrawSprites() end

    ---@param coords vector3
    ---@return CZone?
    function GetCurrentZone(coords)
        if Zones then
            for _, zone in pairs(Zones) do
                if zone:contains(coords) then
                    return zone
                end
            end
        end
    end
end

local playerItems = PlayerItems

if playerItems and GetResourceState('ox_inventory') ~= 'missing' then
    setmetatable(playerItems, {
        __index = function(self, index)
            self[index] = exports.ox_inventory:Search('count', index) or 0
            return self[index]
        end
    })

    AddEventHandler('ox_inventory:itemCount', function(name, count)
        playerItems[name] = count
    end)
end

function PlayerHasItems(filter, hasAny)
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

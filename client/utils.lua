local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial

---@param flag? number Defaults to -1
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function RaycastFromCamera(flag)
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 10
    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
        flag or -1, cache.ped, 7)

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

        return function(coords)
            inRange = {}
            local n = 0

            for _, zone in pairs(Zones) do
                if zone.drawSprite ~= false and zone.distance < 7 then
                    zone.colour = zone:contains(coords) and hover or colour
                    n += 1
                    inRange[n] = zone
                end
            end

            return n > 0 and inRange
        end, function(coords)
            for i = 1, #inRange do
                local zone = inRange[i]

                if zone.drawSprite ~= false and zone.distance < 7 then
                    local drawSprite = zone:contains(coords) and hover or colour

                    SetDrawOrigin(zone.coords.x, zone.coords.y, zone.coords.z)
                    DrawSprite(dict, texture, 0, 0, width, height, 0, drawSprite[1], drawSprite[2], drawSprite[3], drawSprite[4])
                    ClearDrawOrigin()
                end
            end
        end
    end
else function DrawSprites() end end

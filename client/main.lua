local RaycastFromCamera = RaycastFromCamera
local isActive = false
local isDisabled = false

exports('disableTargeting', function(state)
    if state then
        isActive = false
    end

    isDisabled = state
end)

local function enableTargeting()
    if isDisabled or isActive or IsNuiFocused() then return end

    isActive = true
    local getNearbyZones, drawSprites = DrawSprites()
    local nearbyZones
    local lastEntity

    while isActive do
        local entityHit, endCoords, surfaceNormal, materialHash = RaycastFromCamera()
        local entityType

        if lastEntity ~= entityHit then
            entityType = entityHit ~= 0 and GetEntityType(entityHit)

            if Debug then
                if lastEntity then
                    SetEntityDrawOutline(lastEntity, false)
                end

                if entityType ~= 0 then
                    SetEntityDrawOutline(entityHit, true)
                end

                lastEntity = entityHit
            end
        end

        if getNearbyZones then
            nearbyZones = getNearbyZones(endCoords)
        end

        for i = 1, 20 do
            DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24,
                100, false, false, 0, true, false, false, false)

            if nearbyZones then
                drawSprites(endCoords)
            end

            if i ~= 20 then Wait(0) end
        end
    end

    if lastEntity then
        SetEntityDrawOutline(lastEntity, false)
    end
end

---@param forceDisable boolean
local function disableTargeting(forceDisable)
    isActive = false
end

-- Toggle ox_target, instead of holding the hotkey
local toggleHotkey = GetConvarInt('ox_target:toggleHotkey', 0) == 1

-- Default keybind to toggle targeting (https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard)
local hotkey = GetConvar('ox_target:defaultHotkey', 'LMENU')

if toggleHotkey then
    RegisterCommand('ox_target', function() return isActive and disableTargeting() or enableTargeting() end)
	RegisterKeyMapping("ox_target", "Toggle targeting", "keyboard", hotkey)
else
    RegisterCommand('+ox_target', function() CreateThread(enableTargeting) end)
    RegisterCommand('-ox_target', disableTargeting)
    RegisterKeyMapping('+ox_target', 'Toggle targeting', 'keyboard', hotkey)
end
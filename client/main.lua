local isActive = false
local isDisabled = false

exports('disableTargeting', function(state)
    if state then
        isActive = false
    end

    isDisabled = state
end)

local hasFocus = false

local function setNuiFocus(state, cursor)
    if state then SetCursorLocation(0.5, 0.5) end

    hasFocus = state
    SetNuiFocus(state, cursor or false)
    SetNuiFocusKeepInput(state)
end

local DrawSprites = DrawSprites
local RaycastFromCamera = RaycastFromCamera
local GetEntityType = GetEntityType
local GetEntityModel = GetEntityModel
local GetEntityOptions = GetEntityOptions
local SendNUIMessage = SendNUIMessage
local IsDisabledControlJustPressed = IsDisabledControlJustPressed
local DisableControlAction = DisableControlAction
local options

local function enableTargeting()
    if isDisabled or isActive or IsNuiFocused() then return end
    SendNUIMessage({ event = 'visible', state = true })

    isActive = true
    local getNearbyZones, drawSprites = DrawSprites()
    local nearbyZones, lastEntity, entityType, entityModel

    while isActive do
        local entityHit, endCoords, surfaceNormal, materialHash = RaycastFromCamera()

        if lastEntity ~= entityHit then
            entityType = entityHit ~= 0 and GetEntityType(entityHit)
            local success, result = pcall(GetEntityModel, entityHit)

            if success then
                entityModel = result
            end

            if entityType == 0 and entityModel then
                entityType = 3
            end

            if Debug then
                if lastEntity then
                    SetEntityDrawOutline(lastEntity, false)
                end

                if entityType ~= 1 then
                    SetEntityDrawOutline(entityHit, true)
                end

                lastEntity = entityHit
            end

            options = GetEntityOptions(entityHit, entityType, entityModel)
        end

        if options then
            SendNUIMessage({
                event = 'setTarget',
                options = options
            })
        end

        if getNearbyZones then
            nearbyZones = getNearbyZones(endCoords)
        end

        for i = 1, 20 do
            DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42,
                24,
                100, false, false, 0, true, false, false, false)

            if nearbyZones then
                drawSprites(endCoords)
            end

            if options and not hasFocus and IsDisabledControlJustPressed(0, 25) then
                setNuiFocus(true, true)
            end

            if hasFocus then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
            end

            DisablePlayerFiring(cache.playerId, true)

            if i ~= 20 then Wait(0) end
        end
    end

    if lastEntity then
        SetEntityDrawOutline(lastEntity, false)
    end

    setNuiFocus(false)
    SendNUIMessage({ event = 'visible', state = false })
    options = nil
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

RegisterNUICallback('select', function(data, cb)
    cb(1)
    local selection = options?[data[1]][data[2]]
    isActive = false

    if selection then
        if selection.export then
            local resource, method = string.strsplit('.', selection.export)
            exports[resource](nil, method, selection)
        end

        if selection.event then
            TriggerEvent(selection.event, selection)
        end
    end
end)

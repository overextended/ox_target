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

local RaycastFromCamera = RaycastFromCamera
local GetEntityType = GetEntityType
local HasEntityClearLosToEntity = HasEntityClearLosToEntity
local SendNuiMessage = SendNuiMessage
local GetCurrentZone = GetCurrentZone
local GetEntityModel = GetEntityModel
local GetEntityOptions = GetEntityOptions
local IsDisabledControlJustPressed = IsDisabledControlJustPressed
local DisableControlAction = DisableControlAction
local options

local function enableTargeting()
    if isDisabled or isActive or IsNuiFocused() then return end
    SendNuiMessage('{"event": "visible", "state": true}')

    isActive = true
    local getNearbyZones, drawSprites = DrawSprites()
    local currentZone, nearbyZones, lastEntity, entityType, entityModel
    local flag = 30

    while isActive do
        if not options then
            if flag == 30 then flag = -1 else flag = 30 end
        end

        local hit, entityHit, endCoords, surfaceNormal, materialHash = RaycastFromCamera(flag)
        local newOptions

        if lastEntity ~= entityHit then
            if hit then
                if flag == 30 and entityHit then
                    entityHit = HasEntityClearLosToEntity(entityHit, cache.ped, 7) and entityHit or 0
                end

                entityType = entityHit ~= 0 and GetEntityType(entityHit)
                local success, result = pcall(GetEntityModel, entityHit)
                entityModel = success and result

                if entityType == 0 and entityModel then
                    entityType = 3
                else SendNuiMessage('{"event": "leftTarget"}') end

                newOptions = entityType > 0 and GetEntityOptions(entityHit, entityType, entityModel)
            else SendNuiMessage('{"event": "leftTarget"}') end

            if Debug then
                if lastEntity then
                    SetEntityDrawOutline(lastEntity, false)
                end

                if entityType ~= 1 then
                    SetEntityDrawOutline(entityHit, true)
                end
            end

            lastEntity = entityHit
        end

        if getNearbyZones then
            nearbyZones, currentZone, newOptions = getNearbyZones(endCoords, currentZone, newOptions)
        elseif not newOptions then
            currentZone, newOptions = GetCurrentZone(endCoords, currentZone)
        end

        if newOptions and next(newOptions) then
            options = newOptions
            SendNuiMessage(json.encode({
                event = 'setTarget',
                options = options
            }, { sort_keys=true }))
        end

        for i = 1, 20 do
            if Debug then
                DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42,
                    24,
                    100, false, false, 0, true, false, false, false)
            end

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
    SendNuiMessage('{"event": "visible", "state": false}')
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

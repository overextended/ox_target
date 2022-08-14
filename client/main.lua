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
local DisablePlayerFiring = DisablePlayerFiring
local options
local currentTarget = {}

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
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - endCoords)

        if hit and distance < 7 then
            local newOptions

            if lastEntity ~= entityHit then
                if flag == 30 and entityHit then
                    entityHit = HasEntityClearLosToEntity(entityHit, cache.ped, 7) and entityHit or 0
                end

                entityType = entityHit ~= 0 and GetEntityType(entityHit)
                local success, result = pcall(GetEntityModel, entityHit)
                entityModel = success and result

                if entityType == 0 and entityModel then
                    entityType = 3
                else SendNuiMessage('{"event": "leftTarget"}') end

                if entityType > 0 then
                    newOptions = GetEntityOptions(entityHit, entityType, entityModel)
                elseif options then
                    options = table.wipe(options)
                end

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

            if newOptions or options then
                if currentZone then
                    currentTarget.zone = Zones[currentZone]
                else
                    currentTarget.entity = entityHit
                end

                currentTarget.coords = endCoords
                currentTarget.distance = distance

                for k, v in pairs(newOptions or options) do
                    for i = 1, #v do
                        local option = v[i]

                        if option.canInteract then
                            local hide = not option.canInteract(entityHit, distance, endCoords, option.name)

                            if not newOptions and hide ~= option.hide then
                                newOptions = options
                            end

                            v[i].hide = hide
                        end
                    end
                end

                if newOptions and next(newOptions) then
                    options = newOptions
                    SendNuiMessage(json.encode({
                        event = 'setTarget',
                        options = options
                    }, { sort_keys=true }))
                end
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
        elseif lastEntity then
            if Debug then SetEntityDrawOutline(lastEntity, false) end
            SendNuiMessage('{"event": "leftTarget"}')
            options, lastEntity = nil, nil
        else Wait(50) end
    end

    if lastEntity and Debug then
        SetEntityDrawOutline(lastEntity, false)
    end

    setNuiFocus(false)
    SendNuiMessage('{"event": "visible", "state": false}')
    table.wipe(currentTarget)
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

local function getResponse(option, server)
    local response = {
        name = option.name,
        entity = currentTarget.entity,
        zone = currentTarget.zone,
        coords = currentTarget.coords,
        distance = currentTarget.distance,
    }

    if server and response.entity then
        response.entity = NetworkGetNetworkIdFromEntity(response.entity)
    end

    return response
end

RegisterNUICallback('select', function(data, cb)
    cb(1)
    local option = options?[data[1]][data[2]]

    if option then
        if option.onSelect then
            option.onSelect(getResponse(option))
        elseif option.event then
            TriggerEvent(option.event, getResponse(option))
        elseif option.serverEvent then
            TriggerServerEvent(option.serverEvent, getResponse(option, true))
        elseif option.command then
            ExecuteCommand(option.command)
        end
    end

    isActive = false
end)

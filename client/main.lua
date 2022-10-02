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
local PlayerHasGroups = PlayerHasGroups or function() return true end
local PlayerHasItems = PlayerHasItems or function() return true end
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetWorldPositionOfEntityBone = GetWorldPositionOfEntityBone
local GetEntityModel = GetEntityModel
local GetEntityOptions = GetEntityOptions
local IsDisabledControlJustPressed = IsDisabledControlJustPressed
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local options
local currentTarget = {}

-- Toggle ox_target, instead of holding the hotkey
local toggleHotkey = GetConvarInt('ox_target:toggleHotkey', 0) == 1

local function enableTargeting()
    if isDisabled or isActive or IsNuiFocused() or IsPauseMenuActive() then return end
    SendNuiMessage('{"event": "visible", "state": true}')

    isActive = true
    local getNearbyZones, drawSprites = DrawSprites()
    local currentZone, nearbyZones, lastEntity, entityType, entityModel
    local flag = 1

    while isActive do
        local hit, entityHit, endCoords = RaycastFromCamera(flag)

        if not hit then
            flag = flag == 26 and 1 or 26
            hit, entityHit, endCoords = RaycastFromCamera(flag)
        end

        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - endCoords)

        if hit and distance < 7 then
            local newOptions

            if lastEntity ~= entityHit then
                if flag ~= 1 and entityHit then
                    entityHit = HasEntityClearLosToEntity(entityHit, cache.ped, 7) and entityHit or 0
                end

                entityType = entityHit ~= 0 and GetEntityType(entityHit)

                if entityType then
                    local success, result = pcall(GetEntityModel, entityHit)
                    entityModel = success and result

                    if entityType == 0 and entityModel then
                        entityType = 3
                    else SendNuiMessage('{"event": "leftTarget"}') end

                    if entityModel then
                        newOptions = GetEntityOptions(entityHit, entityType, entityModel)
                    elseif options then
                        table.wipe(options)
                    end

                    if Debug then
                        if lastEntity then
                            SetEntityDrawOutline(lastEntity, false)
                        end

                        if entityType ~= 1 then
                            SetEntityDrawOutline(entityHit, true)
                        end
                    end
                end
            end

            if getNearbyZones then
                ---@type CZone[]?, CZone?
                nearbyZones, currentZone = getNearbyZones(endCoords, currentZone)
            else
                ---@type CZone?
                currentZone = GetCurrentZone(endCoords, currentZone)
            end

            options = newOptions or options or {}

            if currentZone then
                if (not newOptions and currentZone.id ~= currentTarget?.zone) or (lastEntity ~= entityHit) then
                    newOptions = options
                end

                currentTarget.zone = currentZone.id
                options.zone = currentZone.options
            elseif currentTarget.zone then
                currentTarget.zone = nil
                options.zone = nil
            end

            lastEntity = entityHit
            currentTarget.entity = entityHit
            currentTarget.coords = endCoords
            currentTarget.distance = distance
            local hidden = 0
            local totalOptions = 0

            for _, v in pairs(options) do
                local optionCount = #v
                totalOptions += optionCount

                for i = 1, optionCount do
                    local option = v[i]
                    local hide

                    if option.distance and distance > option.distance then
                        hide = true
                    end

                    if option.groups and not PlayerHasGroups(option.groups) then
                        hide = true
                    end

                    if option.items and not PlayerHasItems(option.items) then
                        hide = true
                    end

                    local bone = option.bones

                    if bone then
                        local _type = type(bone)

                        if _type == 'string' then
                            local boneId = GetEntityBoneIndexByName(entityHit, bone)

                            if boneId ~= -1 and #(endCoords - GetWorldPositionOfEntityBone(entityHit, boneId)) <= 1 then
                                bone = boneId
                            else
                                hide = true
                            end
                        elseif _type == 'table' then
                            local closestBone, boneDistance

                            for j = 1, #bone do
                                local boneId = GetEntityBoneIndexByName(entityHit, bone[j])

                                if boneId ~= -1 then
                                    local dist = #(endCoords - GetWorldPositionOfEntityBone(entityHit, boneId))

                                    if dist <= (boneDistance or 1) then
                                        closestBone = boneId
                                        boneDistance = dist
                                    end
                                end
                            end

                            if closestBone then
                                bone = closestBone
                            else
                                hide = true
                            end
                        end
                    end

                    if not hide and option.canInteract then
                        hide = not option.canInteract(entityHit, distance, endCoords, option.name, bone)
                    end

                    if not newOptions and v[i].hide ~= hide then
                        newOptions = options
                    end

                    v[i].hide = hide

                    if hide then hidden += 1 end
                end
            end

            if newOptions and next(newOptions) then
                options = newOptions

                if hidden == totalOptions then
                    SendNuiMessage('{"event": "leftTarget"}')
                else
                    SendNuiMessage(json.encode({
                        event = 'setTarget',
                        options = options
                    }, { sort_keys=true }))
                end
            end

            for i = 1, 15 do
                if not isActive then break end

                if Debug then
                    ---@diagnostic disable-next-line: param-type-mismatch
                    DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24, 100, false, false, 0, true, false, false, false)
                end

                if nearbyZones then
                    drawSprites(endCoords)
                end

                DisablePlayerFiring(cache.playerId, true)
                DisableControlAction(0, 25, true)

                if hasFocus then
                    DisableControlAction(0, 1, true)
                    DisableControlAction(0, 2, true)

                    if options and IsDisabledControlJustPressed(0, 25) then
                        setNuiFocus(false, false)
                    end
                elseif options and IsDisabledControlJustPressed(0, 25) then
                    setNuiFocus(true, true)
                end

                if i ~= 20 then Wait(0) end
            end
        elseif lastEntity then
            if Debug then SetEntityDrawOutline(lastEntity, false) end
            if options then table.wipe(options) end
            SendNuiMessage('{"event": "leftTarget"}')
            lastEntity = nil
        else Wait(50) end

        if not options or not next(options) then
            flag = flag == 26 and 1 or 26
        end

        if toggleHotkey and IsPauseMenuActive() then
            isActive = false
        end
    end

    if lastEntity and Debug then
        SetEntityDrawOutline(lastEntity, false)
    end

    setNuiFocus(false)
    SendNuiMessage('{"event": "visible", "state": false}')
    table.wipe(currentTarget)
    options = nil
end

local function disableTargeting()
    isActive = false
end

-- Default keybind to toggle targeting (https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard)
local hotkey = GetConvar('ox_target:defaultHotkey', 'LMENU')

if toggleHotkey then
    RegisterCommand('ox_target', function()
        if isActive then
            return disableTargeting()
        end

        return enableTargeting()
    end, false)

    RegisterKeyMapping("ox_target", "Toggle targeting", "keyboard", hotkey)
else
    RegisterCommand('+ox_target', function() CreateThread(enableTargeting) end, false)
    RegisterCommand('-ox_target', disableTargeting, false)
    RegisterKeyMapping('+ox_target', 'Toggle targeting', 'keyboard', hotkey)
end

local function getResponse(option, server)
    local response = table.clone(option)
    response.entity = currentTarget.entity
    response.zone = currentTarget.zone
    response.coords = currentTarget.coords
    response.distance = currentTarget.distance

    if server and response.entity then
        response.entity = NetworkGetNetworkIdFromEntity(response.entity)
    end

    response.icon = nil
    response.groups = nil
    response.items = nil
    response.canInteract = nil
    response.onSelect = nil
    response.export = nil
    response.event = nil
    response.serverEvent = nil
    response.command = nil

    return response
end

RegisterNUICallback('select', function(data, cb)
    cb(1)
    setNuiFocus(false)

    local option = options?[data[1]][data[2]]

    if option then
        if option.onSelect then
            option.onSelect(option.qtarget and currentTarget.entity or getResponse(option))
        elseif option.export then
            exports[option.resource][option.export](nil, getResponse(option))
        elseif option.event then
            TriggerEvent(option.event, getResponse(option))
        elseif option.serverEvent then
            TriggerServerEvent(option.serverEvent, getResponse(option, true))
        elseif option.command then
            ExecuteCommand(option.command)
        end
    end

    if IsNuiFocused() then
        isActive = false
    end
end)
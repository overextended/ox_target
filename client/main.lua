if not lib.checkDependency('ox_lib', '3.0.0', true) then return end

lib.locale()

local utils = require 'client.utils'
local state = require 'client.state'
local getEntityOptions = require 'client.api'.getEntityOptions

require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'
require 'client.compat.qb-target'

if utils.hasExport('ox_core.GetPlayerData') then
    require 'client.framework.ox'
elseif utils.hasExport('es_extended.getSharedObject') then
    require 'client.framework.esx'
elseif utils.hasExport('qb-core.GetCoreObject') then
    require 'client.framework.qb'
end

local raycastFromCamera, getNearbyZones, drawZoneSprites, getCurrentZone, hasPlayerGotItems, hasPlayerGotGroup in utils
local SendNuiMessage = SendNuiMessage
local GetEntityCoords = GetEntityCoords
local GetEntityType = GetEntityType
local HasEntityClearLosToEntity = HasEntityClearLosToEntity
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local next = next
local GetEntityModel = GetEntityModel
local IsDisabledControlJustPressed = IsDisabledControlJustPressed
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local options = {}
local currentTarget = {}


-- Toggle ox_target, instead of holding the hotkey
local toggleHotkey = GetConvarInt('ox_target:toggleHotkey', 0) == 1
local mouseButton = GetConvarInt('ox_target:leftClick', 1) == 1 and 24 or 25
local debug = GetConvarInt('ox_target:debug', 0) == 1

local function startTargeting()
    if state.isDisabled() or state.isActive() or IsNuiFocused() or IsPauseMenuActive() then return end

    state.setActive(true)

    local flag = 511
    local hit, entityHit, endCoords, distance, currentZone, nearbyZones, lastEntity, entityType, entityModel, hasTick, hasTarget

    while state.isActive() do
        local playerCoords = GetEntityCoords(cache.ped)
        hit, entityHit, endCoords = raycastFromCamera(flag)
        distance = #(playerCoords - endCoords)

        if entityHit ~= 0 and entityHit ~= lastEntity then
            local success, result = pcall(GetEntityType, entityHit)
            entityType = success and result or 0
        end

        if entityType == 0 then
            local _flag = flag == 511 and 26 or 511
            local _hit, _entityHit, _endCoords = raycastFromCamera(_flag)
            local _distance = #(playerCoords - _endCoords)

            if _distance < distance then
                flag, hit, entityHit, endCoords, distance = _flag, _hit, _entityHit, _endCoords, _distance

                if entityHit ~= 0 then
                    local success, result = pcall(GetEntityType, entityHit)
                    entityType = success and result or 0
                end
            end
        end

        if hit and distance < 7 then
            local newOptions
            local lastZone = currentZone

            if getNearbyZones then
                nearbyZones, currentZone = getNearbyZones(endCoords)
            else
                currentZone = getCurrentZone(endCoords)
            end

            if lastZone ~= currentZone or entityHit ~= lastEntity then
                if next(options) then
                    table.wipe(options)
                    SendNuiMessage('{"event": "leftTarget"}')
                end

                if flag ~= 511 then
                    entityHit = HasEntityClearLosToEntity(entityHit, cache.ped, 7) and entityHit or 0
                end

                if lastEntity ~= entityHit and debug then
                    if lastEntity then
                        SetEntityDrawOutline(lastEntity, false)
                    end

                    if entityType ~= 1 then
                        SetEntityDrawOutline(entityHit, true)
                    end
                end

                if entityHit ~= 0 then
                    local success, result = pcall(GetEntityModel, entityHit)
                    entityModel = success and result

                    if entityModel then
                        newOptions = getEntityOptions(entityHit, entityType, entityModel)
                    end
                end
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

                    if option.groups and not hasPlayerGotGroup(option.groups) then
                        hide = true
                    end

                    if option.items and not hasPlayerGotItems(option.items, option.anyItem) then
                        hide = true
                    end

                    local bone = option.bones

                    if bone then
                        local _type = type(bone)

                        if _type == 'string' then
                            local boneId = GetEntityBoneIndexByName(entityHit, bone)

                            if boneId ~= -1 and #(endCoords - GetEntityBonePosition_2(entityHit, boneId)) <= 2 then
                                bone = boneId
                            else
                                hide = true
                            end
                        elseif _type == 'table' then
                            local closestBone, boneDistance

                            for j = 1, #bone do
                                local boneId = GetEntityBoneIndexByName(entityHit, bone[j])

                                if boneId ~= -1 then
                                    local dist = #(endCoords - GetEntityBonePosition_2(entityHit, boneId))

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
                        local success, resp = pcall(option.canInteract, entityHit, distance, endCoords, option.name, bone)
                        hide = not success or not resp
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
                    hasTarget = false
                    SendNuiMessage('{"event": "leftTarget"}')
                else
                    hasTarget = true
                    SendNuiMessage(json.encode({
                        event = 'setTarget',
                        options = options
                    }, { sort_keys=true }))
                end
            end
        else
            if hasTarget then
                hasTarget = false
                SendNuiMessage('{"event": "leftTarget"}')
            end

            if lastEntity then
                if debug then SetEntityDrawOutline(lastEntity, false) end
                if options then table.wipe(options) end

                lastEntity = nil
            else
                Wait(50)
            end
        end

        if toggleHotkey and IsPauseMenuActive() then
            state.setActive(false)
        end

        if not hasTick then
            hasTick = true
            local dict, texture = utils.getTexture()

            CreateThread(function()
                while state.isActive() do
                    if debug then
                        ---@diagnostic disable-next-line: param-type-mismatch
                        DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24, 100, false, false, 0, true, false, false, false)
                    end

                    if nearbyZones then
                        drawZoneSprites(dict, texture)
                    end

                    DisablePlayerFiring(cache.playerId, true)
                    DisableControlAction(0, 25, true)
                    DisableControlAction(0, 140, true) 
                    DisableControlAction(0, 141, true) 
                    DisableControlAction(0, 142, true) 

                    if state.isNuiFocused() then
                        DisableControlAction(0, 1, true)
                        DisableControlAction(0, 2, true)

                        if not hasTarget or options and IsDisabledControlJustPressed(0, 25) then
                            state.setNuiFocus(false, false)
                        end
                    elseif hasTarget and IsDisabledControlJustPressed(0, mouseButton) then
                        state.setNuiFocus(true, true)
                    end

                    Wait(0)
                end

                SetStreamedTextureDictAsNoLongerNeeded(dict)
            end)
        end

        if not hasTarget then
            flag = flag == 511 and 26 or 511
        end

        Wait(60)
    end

    if lastEntity and debug then
        SetEntityDrawOutline(lastEntity, false)
    end

    state.setNuiFocus(false)
    SendNuiMessage('{"event": "visible", "state": false}')
    table.wipe(currentTarget)
    table.wipe(options)
end

do
    ---@type CKeybind
    local keybind = {
        name = 'ox_target',
        defaultKey = GetConvar('ox_target:defaultHotkey', 'LMENU'),
        defaultMapper = 'keyboard',
        description = locale('toggle_targeting'),
    }

    if toggleHotkey then
        function keybind:onPressed()
            if state.isActive() then
                return state.setActive(false)
            end

            return startTargeting()
        end
    else
        keybind.onPressed = startTargeting

        function keybind:onReleased()
            state.setActive(false)
        end
    end

    lib.addKeybind(keybind)
end

local function getResponse(option, server)
    local response = table.clone(option)
    response.entity = currentTarget.entity
    response.zone = currentTarget.zone
    response.coords = currentTarget.coords
    response.distance = currentTarget.distance

    if server then
        response.entity = response.entity ~= 0 and NetworkGetEntityIsNetworked(response.entity) and NetworkGetNetworkIdFromEntity(response.entity) or 0
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
    state.setNuiFocus(false)

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
        state.setActive(false)
    end
end)

local ESX = exports.es_extended:getSharedObject()
local utils = require 'client.utils'
local groups = { 'job', 'job2' }
local playerGroups = {}
local playerItems = utils.getItems()
local usingOxInventory = utils.hasExport('ox_inventory.Items')

local function setPlayerData(playerData)
    table.wipe(playerGroups)
    table.wipe(playerItems)

    for i = 1, #groups do
        local group = groups[i]
        local data = playerData[group]

        if data then
            playerGroups[group] = data
        end
    end

    if usingOxInventory or not playerData.inventory then return end

    for _, v in pairs(playerData.inventory) do
        if v.count > 0 then
            playerItems[v.name] = v.count
        end
    end
end

if ESX.PlayerLoaded then
    setPlayerData(ESX.PlayerData)
end

RegisterNetEvent('esx:playerLoaded', function(data)
    if source == '' then return end
    setPlayerData(data)
end)

RegisterNetEvent('esx:setJob', function(job)
    if source == '' then return end
    playerGroups.job = job
end)

RegisterNetEvent('esx:setJob2', function(job)
    if source == '' then return end
    playerGroups.job2 = job
end)

RegisterNetEvent('esx:addInventoryItem', function(name, count)
    playerItems[name] = count
end)

RegisterNetEvent('esx:removeInventoryItem', function(name, count)
    playerItems[name] = count
end)

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local _type = type(filter)
    for i = 1, #groups do
        local group = groups[i]

        if _type == 'string' then
            local data = playerGroups[group]

            if filter == data?.name then
                return true
            end
        elseif _type == 'table' then
            local tabletype = table.type(filter)

            if tabletype == 'hash' then
                for name, grade in pairs(filter) do
                    local data = playerGroups[group]

                    if data?.name == name and grade <= data.grade then
                        return true
                    end
                end
            elseif tabletype == 'array' then
                for j = 1, #filter do
                    local name = filter[j]
                    local data = playerGroups[group]

                    if data?.name == name then
                        return true
                    end
                end
            end
        end
    end
end

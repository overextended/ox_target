if GetResourceState('qb-core') == 'missing' then return end
local QBCore = exports['qb-core']:GetCoreObject()

local success, result = pcall(function()
    return QBCore.Functions.GetPlayerData()
end)

local playerData = success and result or {}
local usingOxInventory = GetResourceState('ox_inventory') ~= 'missing'
PlayerItems = {}

local function setPlayerItems()
    if not playerData?.items then return end

    table.wipe(PlayerItems)

    for _, item in pairs(playerData.items) do
        PlayerItems[item.name] = (PlayerItems[item.name] or 0) + item.amount
    end
end

if not usingOxInventory then
    setPlayerItems()
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    playerData = QBCore.Functions.GetPlayerData()
    if not usingOxInventory then setPlayerItems() end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    if source == '' then return end

    playerData = val

    if not usingOxInventory then setPlayerItems() end
end)

function PlayerHasGroups(filter)
    local _type = type(filter)

    if _type == 'string' then
        local job = playerData.job.name == filter
        local gang = playerData.gang.name == filter
        local citizenId = playerData.citizenid == filter

        if job or gang or citizenId then
            return true
        end
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local job = playerData.job.name == name
                local gang = playerData.gang.name == name
                local citizenId = playerData.citizenid == name

                if job and grade <= playerData.job.grade.level or gang and grade <= playerData.gang.grade.level or citizenId then
                    return true
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local job = playerData.job.name == name
                local gang = playerData.gang.name == name
                local citizenId = playerData.citizenid == name

                if job or gang or citizenId then
                    return true
                end
            end
        end
    end
end

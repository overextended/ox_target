local playerGroups = exports.ox_core.GetPlayerData()?.groups or {}

AddEventHandler('ox:playerLoaded', function(data)
    playerGroups = data.groups
end)

RegisterNetEvent('ox:setGroup', function(name, grade)
    if source == '' then return end
    playerGroups[name] = grade
end)

local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local _type = type(filter)

    if _type == 'string' then
        local grade = playerGroups[filter]

        if grade then
            return true
        end
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local playerGrade = playerGroups[name]

                if playerGrade and grade <= playerGrade then
                    return true
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local grade = playerGroups[name]

                if grade then
                    return true
                end
            end
        end
    end
end

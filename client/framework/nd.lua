local NDCore = exports["ND_Core"]

local playerGroups = NDCore:getPlayer()?.groups or {}

RegisterNetEvent("ND:characterLoaded", function(data)
    playerGroups = data.groups
end)

RegisterNetEvent("ND:updateCharacter", function(data)
    if source == '' then return end
    playerGroups = data.groups or {}
end)

local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local _type = type(filter)

    if _type == 'string' then
        local group = playerGroups[filter]

        if group then
            return true
        end
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local playerGrade = playerGroups[name]?.rank

                if playerGrade and grade <= playerGrade then
                    return true
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local group = playerGroups[name]

                if group then
                    return true
                end
            end
        end
    end
end

if GetResourceState('ox_core') == 'missing' then return end

local success, result = pcall(function()
    return exports.ox_core.GetPlayerData().groups
end)

local playerGroups = success and result or {}

AddEventHandler('ox:playerLoaded', function(data)
    playerGroups = data.groups
end)

RegisterNetEvent('ox:setGroup', function(name, grade)
    if source == '' then return end
    playerGroups[name] = grade
end)

function PlayerHasGroups(filter)
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

local playerItems = setmetatable({}, {
    __index = function(self, index)
        self[index] = exports.ox_inventory:Search('count', index) or 0
        return self[index]
    end
})

AddEventHandler('ox_inventory:itemCount', function(name, count)
    playerItems[name] = count
end)

function PlayerHasItems(filter)
    local _type = type(filter)

    if _type == 'string' then
        if playerItems[filter] < 1 then return end
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, amount in pairs(filter) do
                if playerItems[name] < amount then return end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if playerItems[filter[i]] < 1 then return end
            end
        end
    end

    return true
end
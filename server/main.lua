lib.versionCheck('overextended/ox_target')
lib.checkDependency('ox_lib', '3.0.0', true)

---@type table<number, number>
local entityStates = {}

---@param netId number
RegisterNetEvent('ox_target:setEntityHasOptions', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local stateBag = Entity(NetworkGetEntityFromNetworkId(netId))
    stateBag.state.hasTargetOptions = true
    entityStates[entity] = netId
end)

AddEventHandler('entityRemoved', function(entity)
    local netid = entityStates[entity]
    if not netid then return end
    TriggerClientEvent('ox_target:removeEntity', -1, netid)
end)

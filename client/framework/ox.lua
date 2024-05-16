if not lib.checkDependency('ox_core', '0.21.3', true) then return end

local Ox = require '@ox_core.lib.init' --[[@as OxClient]]
local utils = require 'client.utils'
local player = Ox.GetPlayer()

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    return player.getGroup(filter)
end

local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qb-target_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

---@param options table
---@return table
local function convert(options)
    local distance = options.distance
    options = options.options

    -- People may pass options as a hashmap (or mixed, even)
    for k, v in pairs(options) do
        if type(k) ~= 'number' then
            table.insert(options, v)
        end
    end

    for id, v in pairs(options) do
        if type(id) ~= 'number' then
            options[id] = nil
            goto continue
        end

        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.items = v.item
        v.groups = v.job

        local groupType = type(v.groups)
        if groupType == 'nil' then
            v.groups = {}
            groupType = 'table'
        end
        if groupType == 'string' then
            local val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {v.groups, type(val) == 'table' and table.unpack(val) or val}
            end
        elseif groupType == 'table' then
            local val = {}
            if table.type(v.groups) ~= 'array' then
                for k in pairs(v.groups) do
                    val[#val + 1] = k
                end
                v.groups = val
                val = nil
            end

            val = v.gang
            if type(v.gang) == 'table' then
                if table.type(v.gang) ~= 'array' then
                    val = {}
                    for k in pairs(v.gang) do
                        val[#val + 1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end

            val = v.citizenid
            if type(v.citizenid) == 'table' then
                if table.type(v.citizenid) ~= 'array' then
                    val = {}
                    for k in pairs(v.citizenid) do
                        val[#val+1] = k
                    end
                end
            end

            if val then
                v.groups = {table.unpack(v.groups), type(val) == 'table' and table.unpack(val) or val}
            end
        end

        if type(v.groups) == 'table' and table.type(v.groups) == 'empty' then
            v.groups = nil
        end

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
            v.type = nil
        end

        v.action = nil
        v.job = nil
        v.gang = nil
        v.citizenid = nil
        v.item = nil
        v.qtarget = true

        ::continue::
    end

    return options
end

exportHandler('AddBoxZone', function(name, center, length, width, options, targetoptions)
    local z = center.z

    if not options.useZ then
        if options.maxZ == nil or options.minZ == nil then
            z = z
        else
            z = z + math.abs(options.maxZ - options.minZ) / 2
        end
        center = vec3(center.x, center.y, z)
    end

    return lib.zones.box({
        name = name,
        coords = center,
        size = vec3(width, length, (options.useZ or not options.maxZ) and center.z or math.abs(options.maxZ - options.minZ)),
        debug = options.debugPoly,
        rotation = options.heading,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('AddPolyZone', function(name, points, options, targetoptions)
    local newPoints = table.create(#points, 0)
    local thickness = math.abs(options.maxZ - options.minZ)

    for i = 1, #points do
        local point = points[i]
        newPoints[i] = vec3(point.x, point.y, options.maxZ - (thickness / 2))
    end

    return lib.zones.poly({
        name = name,
        points = newPoints,
        thickness = thickness,
        debug = options.debugPoly,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('AddEntityZone', function(name, entity, radius, options, targetoptions)
    local center = GetEntityCoords(entity)
    local radius = radius or 1

    return lib.zones.sphere({
        name = name,
        coords = vec3(center.x, center.y, center.z),
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('AddCircleZone', function(name, center, radius, options, targetoptions)
    return lib.zones.sphere({
        name = name,
        coords = center,
        radius = radius,
        debug = options.debugPoly,
        options = convert(targetoptions),
        resource = GetInvokingResource(),
    }).id
end)

exportHandler('RemoveZone', function(id)
    if Zones then
        if type(id) == 'string' then
            for _, v in pairs(Zones) do
                if v.name == id then
                    v:remove()
                end
            end
        end

        if Zones[id] then
            Zones[id]:remove()
        end
    end
end)

exportHandler('AddTargetBone', function(bones, options)
    if type(bones) ~= 'table' then bones = { bones } end
    options = convert(options)

    for _, v in pairs(options) do
        v.bones = bones
    end

    exports.ox_target:addGlobalVehicle(options)
end)

exportHandler('AddTargetEntity', function(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    options = convert(options)

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            target.addEntity(NetworkGetNetworkIdFromEntity(entity), options)
        else
            target.addLocalEntity(entity, options)
        end
    end
end)

exportHandler('RemoveTargetEntity', function(entities, labels)
    if type(entities) ~= 'table' then entities = { entities } end

    for i = 1, #entities do
        local entity = entities[i]

        if NetworkGetEntityIsNetworked(entity) then
            target.removeEntity(NetworkGetNetworkIdFromEntity(entity), labels)
        else
            target.removeLocalEntity(entity, labels)
        end
    end
end)

exportHandler('SpawnPed', function(data)
	local spawnedped
	local key, value = next(data)
	if type(value) == 'table' and type(key) ~= 'string' then
		for _, v in pairs(data) do
			if v.spawnNow then
				lib.requestModel(v.model)

				if type(v.model) == 'string' then v.model = joaat(v.model) end

				if v.minusOne then
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w or 0.0, v.networked or false, true)
				else
					spawnedped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w or 0.0, v.networked or false, true)
				end

				if v.freeze then
					FreezeEntityPosition(spawnedped, true)
				end

				if v.invincible then
					SetEntityInvincible(spawnedped, true)
				end

				if v.blockevents then
					SetBlockingOfNonTemporaryEvents(spawnedped, true)
				end

				if v.animDict and v.anim then
					lib.requestAnimDict(v.animDict)

					TaskPlayAnim(spawnedped, v.animDict, v.anim, 8.0, 0, -1, v.flag or 1, 0, false, false, false)
				end

				if v.scenario then
					SetPedCanPlayAmbientAnims(spawnedped, true)
					TaskStartScenarioInPlace(spawnedped, v.scenario, 0, true)
				end

				if v.pedrelations and type(v.pedrelations.groupname) == 'string' then
					if type(v.pedrelations.groupname) ~= 'string' then error(v.pedrelations.groupname .. ' is not a string') end

					local pedgrouphash = joaat(v.pedrelations.groupname)

					if not DoesRelationshipGroupExist(pedgrouphash) then
						AddRelationshipGroup(v.pedrelations.groupname)
					end

					SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
					if v.pedrelations.toplayer then
						SetRelationshipBetweenGroups(v.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
					end

					if v.pedrelations.toowngroup then
						SetRelationshipBetweenGroups(v.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
					end
				end

				if v.weapon then
					if type(v.weapon.name) == 'string' then v.weapon.name = joaat(v.weapon.name) end

					if IsWeaponValid(v.weapon.name) then
						SetCanPedEquipWeapon(spawnedped, v.weapon.name, true)
						GiveWeaponToPed(spawnedped, v.weapon.name, v.weapon.ammo, v.weapon.hidden or false, true)
						SetPedCurrentWeaponVisible(spawnedped, not v.weapon.hidden or false, true)
					end
				end

				if v.target then
                    local options = v.target
					if v.target.useModel then
                        target.addModel(v.model, convert(options))
					else
                        target.addLocalEntity(spawnedped, convert(options))
					end
				end

				v.currentpednumber = spawnedped

				if v.action then
					v.action(v)
				end
			end

		end
	else
		if data.spawnNow then
			lib.requestModel(data.model)

			if type(data.model) == 'string' then data.model = joaat(data.model) end

			if data.minusOne then
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, data.networked or false, true)
			else
				spawnedped = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.w, data.networked or false, true)
			end

			if data.freeze then
				FreezeEntityPosition(spawnedped, true)
			end

			if data.invincible then
				SetEntityInvincible(spawnedped, true)
			end

			if data.blockevents then
				SetBlockingOfNonTemporaryEvents(spawnedped, true)
			end

			if data.animDict and data.anim then
				lib.requestAnimDict(data.animDict)

				TaskPlayAnim(spawnedped, data.animDict, data.anim, 8.0, 0, -1, data.flag or 1, 0, false, false, false)
			end

			if data.scenario then
				SetPedCanPlayAmbientAnims(spawnedped, true)
				TaskStartScenarioInPlace(spawnedped, data.scenario, 0, true)
			end

			if data.pedrelations then
				if type(data.pedrelations.groupname) ~= 'string' then error(data.pedrelations.groupname .. ' is not a string') end

				local pedgrouphash = joaat(data.pedrelations.groupname)

				if not DoesRelationshipGroupExist(pedgrouphash) then
					AddRelationshipGroup(data.pedrelations.groupname)
				end

				SetPedRelationshipGroupHash(spawnedped, pedgrouphash)
				if data.pedrelations.toplayer then
					SetRelationshipBetweenGroups(data.pedrelations.toplayer, pedgrouphash, joaat('PLAYER'))
				end

				if data.pedrelations.toowngroup then
					SetRelationshipBetweenGroups(data.pedrelations.toowngroup, pedgrouphash, pedgrouphash)
				end
			end

			if data.weapon then
				if type(data.weapon.name) == 'string' then data.weapon.name = joaat(data.weapon.name) end

				if IsWeaponValid(data.weapon.name) then
					SetCanPedEquipWeapon(spawnedped, data.weapon.name, true)
					GiveWeaponToPed(spawnedped, data.weapon.name, data.weapon.ammo, data.weapon.hidden or false, true)
					SetPedCurrentWeaponVisible(spawnedped, not data.weapon.hidden or false, true)
				end
			end

			if data.target then
                local options = data.target
				if data.target.useModel then
					target.addModel(data.model, convert(options))
				else
					target.addLocalEntity(spawnedped, convert(options))
				end
			end

			data.currentpednumber = spawnedped
			
			if data.action then
				data.action(data)
			end
		end

		return spawnedped
	end
end)

exportHandler('AddTargetModel', function(models, options)
    target.addModel(models, convert(options))
end)

exportHandler('RemoveTargetModel', function(models, labels)
    target.removeModel(models, labels)
end)

exportHandler('AddGlobalPed', function(options)
    target.addGlobalPed(convert(options))
end)

exportHandler('RemoveGlobalPed', function(labels)
    target.removeGlobalPed(labels)
end)

exportHandler('AddGlobalVehicle', function(options)
    target.addGlobalVehicle(convert(options))
end)

exportHandler('RemoveGlobalVehicle', function(labels)
    target.removeGlobalVehicle(labels)
end)

exportHandler('AddGlobalObject', function(options)
    target.addGlobalObject(convert(options))
end)

exportHandler('RemoveGlobalObject', function(labels)
    target.removeGlobalObject(labels)
end)

exportHandler('AddGlobalPlayer', function(options)
    target.addGlobalPlayer(convert(options))
end)

exportHandler('RemoveGlobalPlayer', function(labels)
    target.removeGlobalPlayer(labels)
end)

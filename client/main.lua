local RaycastFromCamera = RaycastFromCamera

CreateThread(function()
    local drawSprites = DrawSprites and DrawSprites()
    local lastEntity

    while true do
        local entityHit, endCoords, surfaceNormal, materialHash = RaycastFromCamera()

        for i = 1, 20 do
            DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24,
                100, false, false, 0, true, false, false, false)

            if drawSprites then
                drawSprites(Zones, endCoords)
            end

            if Debug then
                if lastEntity ~= entityHit then
                    if lastEntity then
                        SetEntityDrawOutline(lastEntity, false)
                    end

                    if GetEntityType(entityHit) ~= 0 then
                        SetEntityDrawOutline(entityHit, true)
                    end

                    lastEntity = entityHit
                end
            end

            if i ~= 20 then Wait(0) end
        end
    end
end)

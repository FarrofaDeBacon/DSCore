--[[
    Double Sync Framework - Server Events
    Eventos do servidor
]]

-- ============================================
-- EVENTOS DE PLAYER
-- ============================================

-- Jogador spawnou
RegisterNetEvent('ds-core:server:playerSpawned', function()
    local source = source
    local player = DS.GetPlayer(source)
    
    if player then
        -- Atualizar posição
        local ped = GetPlayerPed(source)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            player.PlayerData.position = vector3(coords.x, coords.y, coords.z)
        end
    end
end)

-- Jogador morreu
RegisterNetEvent('ds-core:server:onPlayerDeath', function()
    local source = source
    local player = DS.GetPlayer(source)
    
    if player then
        player.Functions.SetMetaData('isdead', true)
        
        DS.Log('death', source, player.PlayerData.citizenid, 'Player died', {})
    end
end)

-- Respawn solicitado
RegisterNetEvent('ds-core:server:requestRespawn', function()
    local source = source
    local player = DS.GetPlayer(source)
    
    if player then
        player.Functions.SetMetaData('isdead', false)
        
        -- Escolher local de respawn aleatório
        local respawnLocations = Config.Respawn.RespawnLocations
        local location = respawnLocations[math.random(#respawnLocations)]
        
        TriggerClientEvent('ds-core:client:spawn', source, location.coords)
    end
end)

-- ============================================
-- AUTO-SAVE
-- ============================================
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutos
        
        for source, player in pairs(DS.Players) do
            -- Atualizar posição antes de salvar
            local ped = GetPlayerPed(source)
            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)
                player.PlayerData.position = vector3(coords.x, coords.y, coords.z)
            end
            
            player.Functions.Save()
        end
        
        DS.Debug('Auto-save executado para ' .. DS.TableLength(DS.Players) .. ' jogadores')
    end
end)

-- Função auxiliar para contar elementos da tabela
function DS.TableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

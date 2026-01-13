--[[
    Double Sync Framework - Server Commands
    Comandos administrativos
]]

-- ============================================
-- COMANDOS DE ECONOMIA
-- ============================================

-- Adicionar dinheiro
RegisterCommand('addmoney', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        DS.Print('warning', 'Jogador ' .. source .. ' tentou usar /addmoney sem permissão')
        return
    end
    
    local targetId = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    
    if not targetId or not moneyType or not amount then
        print('Uso: /addmoney [id] [tipo] [quantidade]')
        print('Tipos: cash, bank, gold')
        return
    end
    
    local player = DS.GetPlayer(targetId)
    if player then
        player.Functions.AddMoney(moneyType, amount, 'Admin command')
        DS.Print('success', 'Adicionado $' .. amount .. ' (' .. moneyType .. ') para ' .. player.PlayerData.name)
    else
        DS.Print('error', 'Jogador não encontrado: ' .. targetId)
    end
end, true)

-- Remover dinheiro
RegisterCommand('removemoney', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    
    if not targetId or not moneyType or not amount then
        print('Uso: /removemoney [id] [tipo] [quantidade]')
        return
    end
    
    local player = DS.GetPlayer(targetId)
    if player then
        player.Functions.RemoveMoney(moneyType, amount, 'Admin command')
        DS.Print('success', 'Removido $' .. amount .. ' (' .. moneyType .. ') de ' .. player.PlayerData.name)
    else
        DS.Print('error', 'Jogador não encontrado: ' .. targetId)
    end
end, true)

-- Setar dinheiro
RegisterCommand('setmoney', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    
    if not targetId or not moneyType or not amount then
        print('Uso: /setmoney [id] [tipo] [quantidade]')
        return
    end
    
    local player = DS.GetPlayer(targetId)
    if player then
        local current = player.Functions.GetMoney(moneyType)
        if amount > current then
            player.Functions.AddMoney(moneyType, amount - current, 'Admin set')
        else
            player.Functions.RemoveMoney(moneyType, current - amount, 'Admin set')
        end
        DS.Print('success', 'Dinheiro de ' .. player.PlayerData.name .. ' setado para $' .. amount)
    end
end, true)

-- ============================================
-- COMANDOS DE JOB
-- ============================================

-- Setar job
RegisterCommand('setjob', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    
    if not targetId or not jobName then
        print('Uso: /setjob [id] [job] [grade]')
        print('Jobs: unemployed, sheriff, doctor, farmer, miner, lumberjack, hunter, blacksmith, saloon, stablehand')
        return
    end
    
    local player = DS.GetPlayer(targetId)
    if player then
        local success = player.Functions.SetJob(jobName, grade)
        if success then
            DS.Print('success', 'Job de ' .. player.PlayerData.name .. ' alterado para ' .. jobName .. ' (grade ' .. grade .. ')')
        else
            DS.Print('error', 'Job ou grade inválido')
        end
    else
        DS.Print('error', 'Jogador não encontrado: ' .. targetId)
    end
end, true)

-- ============================================
-- COMANDOS DE ADMIN
-- ============================================

-- Teleportar para jogador
RegisterCommand('goto', function(source, args)
    if source == 0 then return end
    if not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1])
    if not targetId then
        print('Uso: /goto [id]')
        return
    end
    
    local targetPed = GetPlayerPed(targetId)
    if targetPed and targetPed ~= 0 then
        local coords = GetEntityCoords(targetPed)
        TriggerClientEvent('ds-core:client:spawn', source, vector4(coords.x, coords.y, coords.z, 0.0))
    end
end, true)

-- Trazer jogador
RegisterCommand('bring', function(source, args)
    if source == 0 then return end
    if not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1])
    if not targetId then
        print('Uso: /bring [id]')
        return
    end
    
    local myPed = GetPlayerPed(source)
    if myPed and myPed ~= 0 then
        local coords = GetEntityCoords(myPed)
        TriggerClientEvent('ds-core:client:spawn', targetId, vector4(coords.x, coords.y, coords.z, 0.0))
    end
end, true)

-- Reviver jogador
RegisterCommand('revive', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1]) or source
    
    local player = DS.GetPlayer(targetId)
    if player then
        player.Functions.SetMetaData('isdead', false)
        TriggerClientEvent('ds-core:client:revive', targetId)
        DS.Print('success', 'Jogador ' .. player.PlayerData.name .. ' revivido')
    end
end, true)

-- Kickar jogador
RegisterCommand('kick', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'Sem motivo especificado'
    
    if not targetId then
        print('Uso: /kick [id] [motivo]')
        return
    end
    
    DropPlayer(targetId, 'Você foi expulso: ' .. reason)
    DS.Print('warning', 'Jogador ' .. targetId .. ' expulso: ' .. reason)
end, true)

-- ============================================
-- COMANDOS DE DEBUG
-- ============================================

-- Listar jogadores online
RegisterCommand('players', function(source)
    DS.Print('info', '=== JOGADORES ONLINE ===')
    for src, player in pairs(DS.Players) do
        print('[' .. src .. '] ' .. player.PlayerData.name .. ' (' .. player.PlayerData.citizenid .. ')')
    end
    DS.Print('info', '========================')
end, true)

-- Info do jogador
RegisterCommand('playerinfo', function(source, args)
    local targetId = tonumber(args[1]) or source
    
    local player = DS.GetPlayer(targetId)
    if player then
        print('=== PLAYER INFO ===')
        print('Source: ' .. player.PlayerData.source)
        print('CitizenId: ' .. player.PlayerData.citizenid)
        print('Nome: ' .. player.PlayerData.name)
        print('Job: ' .. player.PlayerData.job.name .. ' (' .. player.PlayerData.job.grade .. ')')
        print('Cash: $' .. player.Functions.GetMoney('cash'))
        print('Bank: $' .. player.Functions.GetMoney('bank'))
        print('Gold: ' .. player.Functions.GetMoney('gold'))
        print('===================')
    else
        print('Jogador não encontrado')
    end
end, true)

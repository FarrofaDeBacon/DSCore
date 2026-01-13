--[[
    Double Sync Framework - Server Main
    Script principal do servidor
]]

DS.Players = {}

-- ============================================
-- INICIALIZAÇÃO
-- ============================================
CreateThread(function()
    MySQL.ready(function()
        DS.Print('success', 'Conexão com banco de dados estabelecida')
        
        -- Criar tabelas se não existirem
        DS.Database.Init()
    end)
end)

-- ============================================
-- CONEXÃO DE JOGADORES
-- ============================================
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local license = DS.GetLicense(source)
    
    deferrals.defer()
    Wait(0)
    
    deferrals.update('Verificando licença...')
    
    if not license then
        deferrals.done('Não foi possível identificar sua licença.')
        return
    end
    
    deferrals.update('Carregando dados...')
    Wait(500)
    
    deferrals.done()
    DS.Print('info', 'Jogador conectando: ' .. name .. ' (License: ' .. license .. ')')
end)

-- Jogador entrou
AddEventHandler('playerJoining', function()
    local source = source
    local name = GetPlayerName(source)
    
    DS.Print('info', 'Jogador entrou: ' .. name .. ' [' .. source .. ']')
end)

-- Jogador desconectou
AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = DS.GetPlayer(source)
    
    if player then
        -- Salvar dados antes de desconectar
        player.Functions.Save()
        
        -- Remover da lista de jogadores
        DS.Players[source] = nil
        
        DS.Print('info', 'Jogador desconectou: ' .. player.PlayerData.name .. ' (' .. reason .. ')')
    end
end)

-- ============================================
-- EXPORTS
-- ============================================
exports('GetPlayer', function(source)
    return DS.GetPlayer(source)
end)

exports('GetPlayers', function()
    return DS.Players
end)

exports('CreatePlayer', function(source, citizenid, charData)
    return DS.CreatePlayer(source, citizenid, charData)
end)

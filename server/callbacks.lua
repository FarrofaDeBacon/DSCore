--[[
    Double Sync Framework - Server Callbacks
    Sistema de callbacks server-side
]]

DS.ServerCallbacks = {}
local callbackRequestId = 0
local clientCallbacks = {}

-- ============================================
-- REGISTRAR CALLBACKS
-- ============================================

-- Registrar callback no servidor
function DS.CreateCallback(name, cb)
    DS.ServerCallbacks[name] = cb
    DS.Debug('Callback registrado: ' .. name)
end

-- ============================================
-- TRIGGER CALLBACKS
-- ============================================

-- Receber request de callback do cliente
RegisterNetEvent('ds-core:server:triggerCallback', function(name, requestId, ...)
    local source = source
    
    if DS.ServerCallbacks[name] then
        DS.ServerCallbacks[name](source, function(...)
            TriggerClientEvent('ds-core:client:callbackResponse', source, requestId, ...)
        end, ...)
    else
        DS.Debug('Callback não encontrado: ' .. name)
        TriggerClientEvent('ds-core:client:callbackResponse', source, requestId, nil)
    end
end)

-- Resposta de callback do cliente
RegisterNetEvent('ds-core:server:callbackResponse', function(requestId, ...)
    if clientCallbacks[requestId] then
        clientCallbacks[requestId](...)
        clientCallbacks[requestId] = nil
    end
end)

-- Trigger callback para o cliente
function DS.TriggerClientCallback(source, name, cb, ...)
    callbackRequestId = callbackRequestId + 1
    local currentId = callbackRequestId
    
    clientCallbacks[currentId] = cb
    TriggerClientEvent('ds-core:client:triggerCallback', source, name, currentId, ...)
end

-- ============================================
-- CALLBACKS PADRÃO
-- ============================================

-- Obter dados do jogador
DS.CreateCallback('ds-core:getPlayerData', function(source, cb)
    local player = DS.GetPlayer(source)
    if player then
        cb(player.PlayerData)
    else
        cb(nil)
    end
end)

-- Verificar dinheiro
DS.CreateCallback('ds-core:getMoney', function(source, cb, moneyType)
    local player = DS.GetPlayer(source)
    if player then
        cb(player.Functions.GetMoney(moneyType))
    else
        cb(0)
    end
end)

-- Obter job
DS.CreateCallback('ds-core:getJob', function(source, cb)
    local player = DS.GetPlayer(source)
    if player then
        cb(player.PlayerData.job)
    else
        cb(nil)
    end
end)

-- Verificar se jogador existe
DS.CreateCallback('ds-core:playerExists', function(source, cb, citizenid)
    local result = MySQL.scalar.await('SELECT 1 FROM ds_players WHERE citizenid = ?', { citizenid })
    cb(result ~= nil)
end)

-- Obter lista de jogadores online
DS.CreateCallback('ds-core:getPlayers', function(source, cb)
    local players = {}
    for src, player in pairs(DS.Players) do
        table.insert(players, {
            source = src,
            citizenid = player.PlayerData.citizenid,
            name = player.PlayerData.name,
            charinfo = player.PlayerData.charinfo
        })
    end
    cb(players)
end)

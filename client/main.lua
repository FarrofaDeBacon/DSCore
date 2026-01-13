--[[
    Double Sync Framework - Client Main
    Client main script
]]

local PlayerData = {}
local isLoggedIn = false

-- ============================================
-- INITIALIZATION
-- ============================================
CreateThread(function()
    while not DS do
        Wait(100)
    end
    DS.Debug('Client core inicializado')
end)

-- ============================================
-- PLAYER DATA
-- ============================================

-- Get player data
function DS.GetPlayerData()
    return PlayerData
end

-- Set player data
function DS.SetPlayerData(data)
    PlayerData = data
end

-- Check if logged in
function DS.IsLoggedIn()
    return isLoggedIn
end

-- ============================================
-- EXPORTS
-- ============================================
exports('GetPlayerData', function()
    return PlayerData
end)

-- ============================================
-- EVENTS
-- ============================================

-- Receive player data from server
RegisterNetEvent('ds-core:client:setPlayerData', function(data)
    PlayerData = data
    isLoggedIn = true
    DS.Debug('PlayerData recebido: ' .. PlayerData.citizenid)
end)

-- Update specific data
RegisterNetEvent('ds-core:client:updatePlayerData', function(key, value)
    if PlayerData then
        PlayerData[key] = value
        DS.Debug('PlayerData atualizado: ' .. key)
    end
end)

-- Logout
RegisterNetEvent('ds-core:client:logout', function()
    PlayerData = {}
    isLoggedIn = false
    DS.Debug('Jogador deslogado')
end)

-- ============================================
-- STATE BAGS (Modern synchronization)
-- ============================================
AddStateBagChangeHandler('ds:playerdata', nil, function(bagName, key, value, _unused, replicated)
    if bagName == ('player:' .. GetPlayerServerId(PlayerId())) then
        if value then
            PlayerData = value
            isLoggedIn = true
            DS.Debug('PlayerData sincronizado via StateBag')
        end
    end
end)

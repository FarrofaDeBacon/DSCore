--[[
    Double Sync Framework - Client Events
    Client events
]]

-- ============================================
-- MONEY EVENTS
-- ============================================
RegisterNetEvent('ds-core:client:moneyUpdate', function(moneyType, amount, action)
    local PlayerData = DS.GetPlayerData()
    if PlayerData.money then
        PlayerData.money[moneyType] = amount
        DS.SetPlayerData(PlayerData)
        
        local symbol = action == 'add' and '+' or '-'
        local formatted = DS.FormatMoney(math.abs(amount))
        DS.Notify(symbol .. formatted, action == 'add' and 'success' or 'info')
    end
end)

-- ============================================
-- JOB EVENTS
-- ============================================
RegisterNetEvent('ds-core:client:jobUpdate', function(job)
    local PlayerData = DS.GetPlayerData()
    if PlayerData then
        PlayerData.job = job
        DS.SetPlayerData(PlayerData)
        DS.Notify(_L('job_changed', job.label), 'info')
    end
end)

-- ============================================
-- NEEDS EVENTS
-- ============================================
RegisterNetEvent('ds-core:client:needsUpdate', function(needs)
    local PlayerData = DS.GetPlayerData()
    if PlayerData then
        PlayerData.metadata = PlayerData.metadata or {}
        PlayerData.metadata.hunger = needs.hunger
        PlayerData.metadata.thirst = needs.thirst
        PlayerData.metadata.stamina = needs.stamina
        DS.SetPlayerData(PlayerData)
    end
end)

-- ============================================
-- SPAWN/RESPAWN EVENTS
-- ============================================
RegisterNetEvent('ds-core:client:spawn', function(coords)
    DS.FadeOut(500)
    Wait(500)
    
    DS.TeleportPlayer(coords)
    
    Wait(500)
    DS.FadeIn(500)
    
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.charinfo then
        DS.Notify(_L('player_spawned', PlayerData.charinfo.firstname), 'success')
    end
end)

-- Death event
RegisterNetEvent('ds-core:client:onDeath', function()
    DS.Notify(_L('player_died'), 'error')
    
    -- Start respawn timer
    local respawnTime = Config.Respawn.Timer
    
    CreateThread(function()
        for i = respawnTime, 0, -1 do
            DS.DrawText(0.5, 0.5, _L('respawn_in', i), 0.5)
            Wait(1000)
        end
        
        -- Auto respawn after timer
        TriggerServerEvent('ds-core:server:requestRespawn')
    end)
end)

-- ============================================
-- CLIENT CALLBACKS
-- ============================================
DS.ClientCallbacks = {}

-- Register client-side callback
function DS.RegisterClientCallback(name, cb)
    DS.ClientCallbacks[name] = cb
end

-- Receive callback request from server
RegisterNetEvent('ds-core:client:triggerCallback', function(name, requestId, ...)
    if DS.ClientCallbacks[name] then
        local result = DS.ClientCallbacks[name](...)
        TriggerServerEvent('ds-core:server:callbackResponse', requestId, result)
    end
end)

-- Trigger callback to server
local callbackId = 0
local callbackResults = {}

function DS.TriggerCallback(name, cb, ...)
    callbackId = callbackId + 1
    local currentId = callbackId
    
    callbackResults[currentId] = cb
    TriggerServerEvent('ds-core:server:triggerCallback', name, currentId, ...)
end

-- Receive callback response from server
RegisterNetEvent('ds-core:client:callbackResponse', function(requestId, ...)
    if callbackResults[requestId] then
        callbackResults[requestId](...)
        callbackResults[requestId] = nil
    end
end)

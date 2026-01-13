--[[
    Double Sync Framework - Server Player Spawner
    Handles first spawn and character selection trigger
]]

-- ============================================
-- PLAYER SPAWN HANDLER
-- ============================================

AddEventHandler('playerJoining', function()
    local source = source
    
    -- Wait a bit for player to fully connect
    Wait(2000)
    
    -- Trigger character selection
    TriggerClientEvent('ds-core:client:openCharacterSelect', source)
end)

-- Alternative: Using playerConnecting for earlier trigger
-- This ensures character selection opens right after loading
RegisterNetEvent('ds-core:server:playerLoaded', function()
    local source = source
    local license = DS.GetLicense(source)
    
    if not license then
        DropPlayer(source, 'Could not identify your license')
        return
    end
    
    -- Check if banned
    local banInfo = DS.Database.IsBanned(license)
    if banInfo then
        local reason = banInfo.reason or 'No reason provided'
        DropPlayer(source, 'You are banned: ' .. reason)
        return
    end
    
    -- Trigger character selection
    TriggerClientEvent('ds-core:client:openCharacterSelect', source)
end)

-- ============================================
-- AUTO-TRIGGER ON RESOURCE START (Development)
-- ============================================

-- When resource starts, open character select for all connected players
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- For all connected players, trigger character selection
    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        if source then
            Wait(1000)
            TriggerClientEvent('ds-core:client:openCharacterSelect', source)
        end
    end
end)

--[[
    Double Sync Framework - Server Needs Module
    Hunger, thirst, and stamina decay system
]]

local NeedsLoop = nil

-- ============================================
-- NEEDS UPDATE
-- ============================================

-- Update player needs
function DS.UpdatePlayerNeeds(source)
    local player = DS.GetPlayer(source)
    if not player then return end
    
    local metadata = player.PlayerData.metadata
    if not metadata then return end
    
    -- Skip if dead
    if metadata.isdead then return end
    
    local needsConfig = Config.Needs
    if not needsConfig.Enabled then return end
    
    -- Decay hunger
    if needsConfig.Hunger.Enabled then
        local hunger = (metadata.hunger or 100) - needsConfig.Hunger.DecayRate
        hunger = math.max(0, hunger)
        player.Functions.SetMetaData('hunger', hunger)
        
        -- Apply damage if too hungry
        if hunger <= needsConfig.Hunger.DamageThreshold then
            TriggerClientEvent('ds-core:client:applyDamage', source, needsConfig.Hunger.DamageAmount, 'hunger')
        end
    end
    
    -- Decay thirst
    if needsConfig.Thirst.Enabled then
        local thirst = (metadata.thirst or 100) - needsConfig.Thirst.DecayRate
        thirst = math.max(0, thirst)
        player.Functions.SetMetaData('thirst', thirst)
        
        -- Apply damage if too thirsty
        if thirst <= needsConfig.Thirst.DamageThreshold then
            TriggerClientEvent('ds-core:client:applyDamage', source, needsConfig.Thirst.DamageAmount, 'thirst')
        end
    end
    
    -- Send update to client
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        hunger = metadata.hunger,
        thirst = metadata.thirst,
        stamina = metadata.stamina
    })
end

-- ============================================
-- NEEDS MODIFICATION
-- ============================================

-- Add hunger
function DS.AddHunger(source, amount)
    local player = DS.GetPlayer(source)
    if not player then return false end
    
    local current = player.Functions.GetMetaData('hunger') or 0
    local newValue = math.min(100, current + amount)
    player.Functions.SetMetaData('hunger', newValue)
    
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        hunger = newValue
    })
    
    return true
end

-- Remove hunger
function DS.RemoveHunger(source, amount)
    local player = DS.GetPlayer(source)
    if not player then return false end
    
    local current = player.Functions.GetMetaData('hunger') or 100
    local newValue = math.max(0, current - amount)
    player.Functions.SetMetaData('hunger', newValue)
    
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        hunger = newValue
    })
    
    return true
end

-- Add thirst
function DS.AddThirst(source, amount)
    local player = DS.GetPlayer(source)
    if not player then return false end
    
    local current = player.Functions.GetMetaData('thirst') or 0
    local newValue = math.min(100, current + amount)
    player.Functions.SetMetaData('thirst', newValue)
    
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        thirst = newValue
    })
    
    return true
end

-- Remove thirst
function DS.RemoveThirst(source, amount)
    local player = DS.GetPlayer(source)
    if not player then return false end
    
    local current = player.Functions.GetMetaData('thirst') or 100
    local newValue = math.max(0, current - amount)
    player.Functions.SetMetaData('thirst', newValue)
    
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        thirst = newValue
    })
    
    return true
end

-- Set needs
function DS.SetNeeds(source, hunger, thirst, stamina)
    local player = DS.GetPlayer(source)
    if not player then return false end
    
    if hunger then player.Functions.SetMetaData('hunger', math.max(0, math.min(100, hunger))) end
    if thirst then player.Functions.SetMetaData('thirst', math.max(0, math.min(100, thirst))) end
    if stamina then player.Functions.SetMetaData('stamina', math.max(0, math.min(100, stamina))) end
    
    TriggerClientEvent('ds-core:client:needsUpdate', source, {
        hunger = player.Functions.GetMetaData('hunger'),
        thirst = player.Functions.GetMetaData('thirst'),
        stamina = player.Functions.GetMetaData('stamina')
    })
    
    return true
end

-- ============================================
-- NEEDS LOOP
-- ============================================

CreateThread(function()
    if not Config.Needs.Enabled then return end
    
    while true do
        Wait(Config.Needs.UpdateInterval)
        
        for source, player in pairs(DS.Players) do
            DS.UpdatePlayerNeeds(source)
        end
        
        DS.Debug('Needs updated for ' .. DS.TableLength(DS.Players) .. ' players')
    end
end)

-- ============================================
-- EVENTS
-- ============================================

-- Handle item use for food/drink
RegisterNetEvent('ds-core:server:useItem', function(itemName)
    local source = source
    local player = DS.GetPlayer(source)
    if not player then return end
    
    local item = DS.GetItem(itemName)
    if not item or not item.useable then return end
    
    -- Check if consumable
    if item.name == 'bread' or item.name == 'apple' or item.name == 'meat_cooked' then
        DS.AddHunger(source, 25)
        player.Functions.Notify(_L('item_used', item.label), 'success')
    elseif item.name == 'water' then
        DS.AddThirst(source, 35)
        player.Functions.Notify(_L('item_used', item.label), 'success')
    end
end)

-- ============================================
-- COMMANDS
-- ============================================

-- Set hunger command
RegisterCommand('sethunger', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        print('Usage: /sethunger [id] [amount]')
        return
    end
    
    DS.SetNeeds(targetId, amount, nil, nil)
    DS.Print('success', 'Hunger set to ' .. amount .. ' for player ' .. targetId)
end, true)

-- Set thirst command
RegisterCommand('setthirst', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId or not amount then
        print('Usage: /setthirst [id] [amount]')
        return
    end
    
    DS.SetNeeds(targetId, nil, amount, nil)
    DS.Print('success', 'Thirst set to ' .. amount .. ' for player ' .. targetId)
end, true)

-- Feed player command (resets hunger and thirst)
RegisterCommand('feed', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1]) or source
    
    DS.SetNeeds(targetId, 100, 100, 100)
    DS.Print('success', 'Player ' .. targetId .. ' fed and hydrated')
end, true)

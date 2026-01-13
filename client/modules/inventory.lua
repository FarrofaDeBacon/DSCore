--[[
    Double Sync Framework - Client Inventory Module
    Client-side inventory handling
]]

local isInventoryOpen = false
local playerItems = {}

-- ============================================
-- INVENTORY UI
-- ============================================

function DS.OpenInventory()
    if isInventoryOpen then return end
    
    -- Get inventory from server
    DS.TriggerCallback('ds-core:getInventory', function(items, maxSlots, maxWeight)
        playerItems = items or {}
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            items = playerItems,
            maxSlots = maxSlots or 40,
            maxWeight = maxWeight or 50
        })
        
        isInventoryOpen = true
        DS.Debug('Inventory opened')
    end)
end

function DS.CloseInventory()
    if not isInventoryOpen then return end
    
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    
    isInventoryOpen = false
    DS.Debug('Inventory closed')
end

function DS.IsInventoryOpen()
    return isInventoryOpen
end

-- ============================================
-- NUI CALLBACKS
-- ============================================

-- Close inventory
RegisterNUICallback('close', function(data, cb)
    DS.CloseInventory()
    cb('ok')
end)

-- Move item
RegisterNUICallback('moveItem', function(data, cb)
    TriggerServerEvent('ds-core:server:moveItem', data.item, data.fromSlot, data.toSlot, data.fromType, data.toType)
    cb('ok')
end)

-- Use item
RegisterNUICallback('useItem', function(data, cb)
    local item = data.item
    if not item then cb('error') return end
    
    -- Play animation based on item type
    DS.UseConsumable(item.name)
    
    -- Request server to use item
    TriggerServerEvent('ds-core:server:useItem', item.name, item.slot)
    cb('ok')
end)

-- Drop item
RegisterNUICallback('dropItem', function(data, cb)
    local item = data.item
    if not item then cb('error') return end
    
    TriggerServerEvent('ds-core:server:dropItem', item.name, item.slot, item.count or 1)
    cb('ok')
end)

-- Give item
RegisterNUICallback('giveItem', function(data, cb)
    local item = data.item
    if not item then cb('error') return end
    
    -- Get nearby player
    local nearbyPlayers = DS.GetNearbyPlayers(3.0)
    if #nearbyPlayers == 0 then
        DS.HUDNotify('No players nearby', 'error')
        cb('error')
        return
    end
    
    -- Give to first nearby player
    local target = nearbyPlayers[1]
    TriggerServerEvent('ds-core:server:giveItem', item.name, item.slot, item.count or 1, target.serverId)
    cb('ok')
end)

-- ============================================
-- EVENTS
-- ============================================

-- Update inventory
RegisterNetEvent('ds-core:client:updateInventory', function(items)
    playerItems = items
    if isInventoryOpen then
        SendNUIMessage({
            action = 'update',
            items = items
        })
    end
end)

-- ============================================
-- KEY BINDING
-- ============================================
RegisterCommand('+inventory', function()
    if DS.IsLoggedIn() then
        if isInventoryOpen then
            DS.CloseInventory()
        else
            DS.OpenInventory()
        end
    end
end, false)

RegisterCommand('-inventory', function() end, false)

RegisterKeyMapping('+inventory', 'Open Inventory', 'keyboard', 'i')

-- ============================================
-- EXPORTS
-- ============================================
exports('OpenInventory', DS.OpenInventory)
exports('CloseInventory', DS.CloseInventory)
exports('IsInventoryOpen', DS.IsInventoryOpen)

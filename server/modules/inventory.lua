--[[
    Double Sync Framework - Server Inventory Module
    Server-side inventory management
]]

DS.Inventories = {}

-- ============================================
-- INVENTORY MANAGEMENT
-- ============================================

-- Get player inventory
function DS.GetInventory(source)
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return {} end
    
    if not DS.Inventories[citizenid] then
        DS.LoadInventory(citizenid)
    end
    
    return DS.Inventories[citizenid] or {}
end

-- Load inventory from database
function DS.LoadInventory(citizenid)
    local result = MySQL.query.await('SELECT items FROM ds_inventory WHERE citizenid = ?', { citizenid })
    
    if result and result[1] then
        DS.Inventories[citizenid] = json.decode(result[1].items) or {}
    else
        DS.Inventories[citizenid] = {}
        MySQL.insert('INSERT INTO ds_inventory (citizenid, items) VALUES (?, ?)', { citizenid, '[]' })
    end
    
    return DS.Inventories[citizenid]
end

-- Save inventory to database
function DS.SaveInventory(citizenid)
    local items = DS.Inventories[citizenid] or {}
    MySQL.update('UPDATE ds_inventory SET items = ? WHERE citizenid = ?', { json.encode(items), citizenid })
end

-- Get citizenid from source
function DS.GetCitizenIdFromSource(source)
    local player = DS.GetPlayer(source)
    if player then
        return player.PlayerData.citizenid
    end
    return nil
end

-- ============================================
-- ITEM OPERATIONS
-- ============================================

-- Add item to inventory
function DS.AddItem(source, itemName, amount, slot, metadata)
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return false end
    
    local itemInfo = DS.GetItem(itemName)
    if not itemInfo then 
        DS.Debug('Item not found: ' .. itemName)
        return false 
    end
    
    amount = amount or 1
    
    if not DS.Inventories[citizenid] then
        DS.LoadInventory(citizenid)
    end
    
    -- Find existing stack or empty slot
    local inventory = DS.Inventories[citizenid]
    local targetSlot = slot
    
    if not targetSlot then
        -- Try to stack first
        for _, item in ipairs(inventory) do
            if item.name == itemName and item.count < (itemInfo.maxStack or 100) then
                local canAdd = math.min(amount, (itemInfo.maxStack or 100) - item.count)
                item.count = item.count + canAdd
                amount = amount - canAdd
                
                if amount <= 0 then
                    DS.SaveInventory(citizenid)
                    TriggerClientEvent('ds-core:client:updateInventory', source, inventory)
                    return true
                end
            end
        end
        
        -- Find empty slot
        local usedSlots = {}
        for _, item in ipairs(inventory) do
            usedSlots[item.slot] = true
        end
        
        for i = 0, 39 do
            if not usedSlots[i] then
                targetSlot = i
                break
            end
        end
    end
    
    if targetSlot == nil then
        DS.Debug('No empty slot found')
        return false
    end
    
    -- Add new item
    table.insert(inventory, {
        name = itemName,
        label = itemInfo.label,
        count = amount,
        slot = targetSlot,
        weight = itemInfo.weight or 0,
        rarity = itemInfo.rarity or 'common',
        description = itemInfo.description or '',
        metadata = metadata or {}
    })
    
    DS.SaveInventory(citizenid)
    TriggerClientEvent('ds-core:client:updateInventory', source, inventory)
    
    DS.Debug('Added ' .. amount .. 'x ' .. itemName .. ' to player ' .. source)
    return true
end

-- Remove item from inventory
function DS.RemoveItem(source, itemName, amount, slot)
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return false end
    
    amount = amount or 1
    local inventory = DS.Inventories[citizenid] or {}
    
    for i, item in ipairs(inventory) do
        if item.name == itemName and (slot == nil or item.slot == slot) then
            if item.count > amount then
                item.count = item.count - amount
            else
                table.remove(inventory, i)
            end
            
            DS.SaveInventory(citizenid)
            TriggerClientEvent('ds-core:client:updateInventory', source, inventory)
            
            DS.Debug('Removed ' .. amount .. 'x ' .. itemName .. ' from player ' .. source)
            return true
        end
    end
    
    return false
end

-- Check if player has item
function DS.HasItem(source, itemName, amount)
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return false end
    
    amount = amount or 1
    local inventory = DS.Inventories[citizenid] or {}
    local total = 0
    
    for _, item in ipairs(inventory) do
        if item.name == itemName then
            total = total + item.count
        end
    end
    
    return total >= amount
end

-- Get item count
function DS.GetItemCount(source, itemName)
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return 0 end
    
    local inventory = DS.Inventories[citizenid] or {}
    local total = 0
    
    for _, item in ipairs(inventory) do
        if item.name == itemName then
            total = total + item.count
        end
    end
    
    return total
end

-- ============================================
-- CALLBACKS
-- ============================================

DS.CreateCallback('ds-core:getInventory', function(source, cb)
    local inventory = DS.GetInventory(source)
    cb(inventory, 40, 50) -- items, maxSlots, maxWeight
end)

-- ============================================
-- EVENTS
-- ============================================

-- Move item
RegisterNetEvent('ds-core:server:moveItem', function(item, fromSlot, toSlot, fromType, toType)
    local source = source
    local citizenid = DS.GetCitizenIdFromSource(source)
    if not citizenid then return end
    
    local inventory = DS.Inventories[citizenid]
    if not inventory then return end
    
    -- Find and update item slot
    for _, invItem in ipairs(inventory) do
        if invItem.slot == fromSlot then
            invItem.slot = toSlot
            break
        end
    end
    
    DS.SaveInventory(citizenid)
    TriggerClientEvent('ds-core:client:updateInventory', source, inventory)
end)

-- Drop item
RegisterNetEvent('ds-core:server:dropItem', function(itemName, slot, count)
    local source = source
    DS.RemoveItem(source, itemName, count, slot)
    
    -- Could create ground item here
    local player = DS.GetPlayer(source)
    if player then
        player.Functions.Notify(_L('item_dropped'), 'info')
    end
end)

-- Give item
RegisterNetEvent('ds-core:server:giveItem', function(itemName, slot, count, targetId)
    local source = source
    
    if DS.HasItem(source, itemName, count) then
        DS.RemoveItem(source, itemName, count, slot)
        DS.AddItem(targetId, itemName, count)
        
        local player = DS.GetPlayer(source)
        local target = DS.GetPlayer(targetId)
        
        if player then player.Functions.Notify(_L('item_given'), 'success') end
        if target then target.Functions.Notify(_L('item_received'), 'success') end
    end
end)

-- ============================================
-- COMMANDS
-- ============================================

RegisterCommand('giveitem', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1])
    local itemName = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not targetId or not itemName then
        print('Usage: /giveitem [id] [item] [amount]')
        return
    end
    
    if DS.AddItem(targetId, itemName, amount) then
        DS.Print('success', 'Gave ' .. amount .. 'x ' .. itemName .. ' to player ' .. targetId)
    else
        DS.Print('error', 'Failed to give item')
    end
end, true)

RegisterCommand('clearinv', function(source, args)
    if source > 0 and not DS.HasPermission(source, 'admin') then return end
    
    local targetId = tonumber(args[1]) or source
    local citizenid = DS.GetCitizenIdFromSource(targetId)
    
    if citizenid then
        DS.Inventories[citizenid] = {}
        DS.SaveInventory(citizenid)
        TriggerClientEvent('ds-core:client:updateInventory', targetId, {})
        DS.Print('success', 'Cleared inventory for player ' .. targetId)
    end
end, true)

-- ============================================
-- EXPORTS
-- ============================================
exports('AddItem', DS.AddItem)
exports('RemoveItem', DS.RemoveItem)
exports('HasItem', DS.HasItem)
exports('GetItemCount', DS.GetItemCount)
exports('GetInventory', DS.GetInventory)

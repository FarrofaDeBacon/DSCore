--[[
    Double Sync Framework - Items Definition
    Server items definition
]]

DS.Items = {
    -- ============================================
    -- CONSUMABLES
    -- ============================================
    ['bread'] = {
        name = 'bread',
        label = 'Pão',
        weight = 100,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Um pão fresco',
        image = 'bread.png'
    },
    
    ['water'] = {
        name = 'water',
        label = 'Água',
        weight = 200,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Garrafa de água fresca',
        image = 'water.png'
    },
    
    ['apple'] = {
        name = 'apple',
        label = 'Maçã',
        weight = 80,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Uma maçã suculenta',
        image = 'apple.png'
    },
    
    ['meat_raw'] = {
        name = 'meat_raw',
        label = 'Carne Crua',
        weight = 500,
        type = 'item',
        useable = false,
        unique = false,
        description = 'Carne crua, precisa ser cozida',
        image = 'meat_raw.png'
    },
    
    ['meat_cooked'] = {
        name = 'meat_cooked',
        label = 'Carne Assada',
        weight = 400,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Carne assada deliciosa',
        image = 'meat_cooked.png'
    },
    
    -- ============================================
    -- MEDICAL
    -- ============================================
    ['bandage'] = {
        name = 'bandage',
        label = 'Bandagem',
        weight = 50,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Bandagem para curar ferimentos leves',
        image = 'bandage.png'
    },
    
    ['health_tonic'] = {
        name = 'health_tonic',
        label = 'Tônico de Saúde',
        weight = 150,
        type = 'item',
        useable = true,
        unique = false,
        description = 'Tônico que restaura saúde',
        image = 'health_tonic.png'
    },
    
    -- ============================================
    -- MATERIALS
    -- ============================================
    ['wood'] = {
        name = 'wood',
        label = 'Madeira',
        weight = 1000,
        type = 'item',
        useable = false,
        unique = false,
        description = 'Tora de madeira',
        image = 'wood.png'
    },
    
    ['iron_ore'] = {
        name = 'iron_ore',
        label = 'Minério de Ferro',
        weight = 1500,
        type = 'item',
        useable = false,
        unique = false,
        description = 'Minério de ferro bruto',
        image = 'iron_ore.png'
    },
    
    ['gold_ore'] = {
        name = 'gold_ore',
        label = 'Minério de Ouro',
        weight = 2000,
        type = 'item',
        useable = false,
        unique = false,
        description = 'Minério de ouro bruto',
        image = 'gold_ore.png'
    },
    
    ['leather'] = {
        name = 'leather',
        label = 'Couro',
        weight = 800,
        type = 'item',
        useable = false,
        unique = false,
        description = 'Couro curtido',
        image = 'leather.png'
    },
    
    -- ============================================
    -- TOOLS
    -- ============================================
    ['pickaxe'] = {
        name = 'pickaxe',
        label = 'Picareta',
        weight = 2000,
        type = 'item',
        useable = true,
        unique = true,
        description = 'Picareta para mineração',
        image = 'pickaxe.png'
    },
    
    ['axe'] = {
        name = 'axe',
        label = 'Machado',
        weight = 2500,
        type = 'item',
        useable = true,
        unique = true,
        description = 'Machado para cortar madeira',
        image = 'axe.png'
    },
    
    ['fishing_rod'] = {
        name = 'fishing_rod',
        label = 'Vara de Pesca',
        weight = 1000,
        type = 'item',
        useable = true,
        unique = true,
        description = 'Vara para pescar',
        image = 'fishing_rod.png'
    }
}

-- ============================================
-- ITEM FUNCTIONS
-- ============================================

-- Get item info
function DS.GetItem(itemName)
    return DS.Items[itemName]
end

-- Check if item exists
function DS.ItemExists(itemName)
    return DS.Items[itemName] ~= nil
end

-- Add new item
function DS.AddItem(itemName, itemData)
    if DS.Items[itemName] then
        DS.Debug('Item já existe: ' .. itemName)
        return false
    end
    DS.Items[itemName] = itemData
    DS.Debug('Item adicionado: ' .. itemName)
    return true
end

-- Get all items
function DS.GetAllItems()
    return DS.Items
end

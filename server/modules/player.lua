--[[
    Double Sync Framework - Server Player Module
    Player management on server side
]]

-- ============================================
-- PLAYER LOADING
-- ============================================

-- Load existing player from database
function DS.LoadPlayer(source, citizenid)
    local charData = DS.Database.LoadPlayer(citizenid)
    
    if charData then
        return DS.CreatePlayer(source, citizenid, charData)
    end
    
    return nil
end

-- Create new character
function DS.CreateNewCharacter(source, charinfo)
    local license = DS.GetLicense(source)
    
    -- Check character limit
    local existingChars = DS.Database.GetCharactersByLicense(license)
    if #existingChars >= Config.MaxCharacters then
        DS.Print('warning', 'Player ' .. source .. ' reached character limit')
        return nil
    end
    
    -- Generate unique citizenid
    local citizenid
    repeat
        citizenid = DS.GenerateCitizenId()
    until not DS.Database.CitizenIdExists(citizenid)
    
    -- Default character data
    local charData = {
        charinfo = charinfo,
        money = {},
        job = { name = 'unemployed', label = 'Unemployed', grade = 0 },
        gang = { name = 'none', label = 'None', grade = 0 },
        position = Config.DefaultSpawn,
        metadata = {
            hunger = 100,
            thirst = 100,
            stamina = 100,
            isdead = false,
            ishandcuffed = false,
            group = Config.Admin.DefaultGroup
        }
    }
    
    -- Set default money from config
    for moneyType, data in pairs(Config.Money.Types) do
        charData.money[moneyType] = data.default
    end
    
    -- Create player object
    local player = DS.CreatePlayer(source, citizenid, charData)
    
    if player then
        -- Save immediately
        player.Functions.Save()
        DS.Print('success', 'New character created: ' .. citizenid)
    end
    
    return player
end

-- ============================================
-- CHARACTER SELECTION
-- ============================================

-- Get characters for selection
function DS.GetPlayerCharacters(source)
    local license = DS.GetLicense(source)
    return DS.Database.GetCharactersByLicense(license)
end

-- Select character
function DS.SelectCharacter(source, citizenid)
    local license = DS.GetLicense(source)
    
    -- Verify character belongs to this license
    local chars = DS.Database.GetCharactersByLicense(license)
    local valid = false
    
    for _, char in ipairs(chars) do
        if char.citizenid == citizenid then
            valid = true
            break
        end
    end
    
    if not valid then
        DS.Print('error', 'Invalid character selection: ' .. citizenid)
        return nil
    end
    
    return DS.LoadPlayer(source, citizenid)
end

-- Delete character
function DS.DeleteCharacter(source, citizenid)
    local license = DS.GetLicense(source)
    
    -- Verify ownership
    local chars = DS.Database.GetCharactersByLicense(license)
    local valid = false
    
    for _, char in ipairs(chars) do
        if char.citizenid == citizenid then
            valid = true
            break
        end
    end
    
    if valid then
        DS.Database.DeleteCharacter(citizenid)
        DS.Print('info', 'Character deleted: ' .. citizenid)
        return true
    end
    
    return false
end

-- ============================================
-- SERVER CALLBACKS FOR CHARACTER
-- ============================================

-- Get player characters
DS.CreateCallback('ds-core:getCharacters', function(source, cb)
    local characters = DS.GetPlayerCharacters(source)
    cb(characters)
end)

-- Create new character
DS.CreateCallback('ds-core:createCharacter', function(source, cb, charinfo)
    local player = DS.CreateNewCharacter(source, charinfo)
    if player then
        cb(true, player.PlayerData)
    else
        cb(false, nil)
    end
end)

-- Select character
DS.CreateCallback('ds-core:selectCharacter', function(source, cb, citizenid)
    local player = DS.SelectCharacter(source, citizenid)
    if player then
        cb(true, player.PlayerData)
    else
        cb(false, nil)
    end
end)

-- Delete character
DS.CreateCallback('ds-core:deleteCharacter', function(source, cb, citizenid)
    local success = DS.DeleteCharacter(source, citizenid)
    cb(success)
end)

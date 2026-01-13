--[[
    Double Sync Framework - Character NUI Handler
    Client-side NUI communication
]]

local isUIOpen = false
local currentCharacters = {}

-- ============================================
-- OPEN/CLOSE UI
-- ============================================

function DS.OpenCharacterUI()
    if isUIOpen then return end
    
    -- Get characters from server
    DS.TriggerCallback('ds-core:getCharacters', function(characters)
        currentCharacters = characters or {}
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            characters = currentCharacters,
            maxCharacters = Config.MaxCharacters
        })
        
        isUIOpen = true
        DS.Debug('Character UI opened')
    end)
end

function DS.CloseCharacterUI()
    if not isUIOpen then return end
    
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    
    isUIOpen = false
    DS.Debug('Character UI closed')
end

-- ============================================
-- NUI CALLBACKS
-- ============================================

-- Select character
RegisterNUICallback('selectCharacter', function(data, cb)
    local citizenid = data.citizenid
    
    DS.TriggerCallback('ds-core:selectCharacter', function(success, playerData)
        if success then
            DS.CloseCharacterUI()
            
            -- Spawn player at last position or default
            local spawnCoords = playerData.position or Config.DefaultSpawn
            TriggerEvent('ds-core:client:spawn', spawnCoords)
            
            DS.Debug('Character selected: ' .. citizenid)
        else
            SendNUIMessage({
                action = 'error',
                message = 'Failed to load character'
            })
        end
    end, citizenid)
    
    cb('ok')
end)

-- Create character
RegisterNUICallback('createCharacter', function(data, cb)
    local charinfo = data.charinfo
    
    DS.TriggerCallback('ds-core:createCharacter', function(success, playerData)
        if success then
            SendNUIMessage({
                action = 'characterCreated',
                character = {
                    citizenid = playerData.citizenid,
                    charinfo = playerData.charinfo,
                    job = playerData.job,
                    money = playerData.money
                }
            })
            
            DS.Debug('Character created: ' .. playerData.citizenid)
        else
            SendNUIMessage({
                action = 'error',
                message = 'Failed to create character'
            })
        end
    end, charinfo)
    
    cb('ok')
end)

-- Delete character
RegisterNUICallback('deleteCharacter', function(data, cb)
    local citizenid = data.citizenid
    
    DS.TriggerCallback('ds-core:deleteCharacter', function(success)
        if success then
            SendNUIMessage({
                action = 'characterDeleted',
                citizenid = citizenid
            })
            
            DS.Debug('Character deleted: ' .. citizenid)
        else
            SendNUIMessage({
                action = 'error',
                message = 'Failed to delete character'
            })
        end
    end, citizenid)
    
    cb('ok')
end)

-- ============================================
-- EVENTS
-- ============================================

-- Open character selection on player join (before spawn)
RegisterNetEvent('ds-core:client:openCharacterSelect', function()
    DS.OpenCharacterUI()
end)

-- Revive event handler
RegisterNetEvent('ds-core:client:revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        PlayerData.metadata.isdead = false
    end
end)

-- ============================================
-- COMMANDS (DEBUG)
-- ============================================
RegisterCommand('charselect', function()
    DS.OpenCharacterUI()
end, false)

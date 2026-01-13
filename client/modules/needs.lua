--[[
    Double Sync Framework - Client Needs Module
    Client-side needs handling and effects
]]

local needsWarningCooldown = {
    hunger = 0,
    thirst = 0
}

-- ============================================
-- DAMAGE HANDLER
-- ============================================

RegisterNetEvent('ds-core:client:applyDamage', function(amount, reason)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    
    SetEntityHealth(ped, math.max(0, health - amount))
    
    -- Show warning
    if reason == 'hunger' and GetGameTimer() > needsWarningCooldown.hunger then
        DS.HUDNotify(_L('hungry'), 'warning')
        needsWarningCooldown.hunger = GetGameTimer() + 30000 -- 30 sec cooldown
    elseif reason == 'thirst' and GetGameTimer() > needsWarningCooldown.thirst then
        DS.HUDNotify(_L('thirsty'), 'warning')
        needsWarningCooldown.thirst = GetGameTimer() + 30000
    end
end)

-- ============================================
-- VISUAL EFFECTS
-- ============================================

local effectsActive = false

CreateThread(function()
    while true do
        Wait(5000)
        
        if DS.IsLoggedIn() then
            local PlayerData = DS.GetPlayerData()
            if PlayerData and PlayerData.metadata then
                local hunger = PlayerData.metadata.hunger or 100
                local thirst = PlayerData.metadata.thirst or 100
                
                -- Apply screen effects when very low
                if hunger <= 15 or thirst <= 15 then
                    if not effectsActive then
                        effectsActive = true
                        -- Could add timecycle modifier or screen effect here
                    end
                else
                    if effectsActive then
                        effectsActive = false
                        -- Remove effects
                    end
                end
            end
        end
    end
end)

-- ============================================
-- STAMINA HANDLING
-- ============================================

-- Client-side stamina regeneration
CreateThread(function()
    while true do
        Wait(1000)
        
        if DS.IsLoggedIn() and Config.Needs.Stamina.Enabled then
            local PlayerData = DS.GetPlayerData()
            if PlayerData and PlayerData.metadata then
                local ped = PlayerPedId()
                
                -- Check if player is moving
                local isMoving = IsPedRunning(ped) or IsPedSprinting(ped)
                
                if not isMoving then
                    -- Regenerate stamina
                    local currentStamina = PlayerData.metadata.stamina or 100
                    if currentStamina < 100 then
                        local newStamina = math.min(100, currentStamina + Config.Needs.Stamina.RegenRate)
                        PlayerData.metadata.stamina = newStamina
                        DS.UpdateHUDStatus('stamina', newStamina)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- ITEM USE HANDLER
-- ============================================

-- Use consumable item
function DS.UseConsumable(itemName)
    -- Play animation based on item
    local item = DS.GetItem(itemName)
    if not item then return false end
    
    if item.name == 'water' then
        DS.PlayPreset('drink')
    elseif item.name == 'bread' or item.name == 'apple' or item.name == 'meat_cooked' then
        DS.PlayPreset('eat')
    elseif item.name == 'bandage' or item.name == 'health_tonic' then
        DS.PlayPreset('heal')
    end
    
    -- Notify server
    TriggerServerEvent('ds-core:server:useItem', itemName)
    
    return true
end

-- ============================================
-- EXPORTS
-- ============================================

exports('UseConsumable', DS.UseConsumable)

--[[
    Double Sync Framework - HUD Client Handler
    Client-side HUD NUI communication
]]

local isHUDVisible = false
local hudUpdateInterval = 1000 -- Update every 1 second

-- ============================================
-- HUD VISIBILITY
-- ============================================

function DS.ShowHUD()
    if isHUDVisible then return end
    
    SendNUIMessage({ action = 'show' })
    isHUDVisible = true
    DS.Debug('HUD shown')
end

function DS.HideHUD()
    if not isHUDVisible then return end
    
    SendNUIMessage({ action = 'hide' })
    isHUDVisible = false
    DS.Debug('HUD hidden')
end

function DS.IsHUDVisible()
    return isHUDVisible
end

-- ============================================
-- HUD UPDATES
-- ============================================

-- Update money display
function DS.UpdateHUDMoney(moneyType, amount)
    SendNUIMessage({
        action = 'updateMoney',
        moneyType = moneyType,
        amount = amount
    })
end

-- Update all money
function DS.UpdateHUDAllMoney(money)
    SendNUIMessage({
        action = 'updateAllMoney',
        money = money
    })
end

-- Update single status
function DS.UpdateHUDStatus(status, value)
    SendNUIMessage({
        action = 'updateStatus',
        status = status,
        value = value
    })
end

-- Update all status
function DS.UpdateHUDAllStatus(health, hunger, thirst, stamina)
    SendNUIMessage({
        action = 'updateAllStatus',
        health = health,
        hunger = hunger,
        thirst = thirst,
        stamina = stamina
    })
end

-- Update player info
function DS.UpdateHUDPlayer(name, job)
    SendNUIMessage({
        action = 'updatePlayer',
        name = name,
        job = job
    })
end

-- Show notification
function DS.HUDNotify(message, type)
    type = type or 'info'
    SendNUIMessage({
        action = 'notify',
        message = message,
        type = type
    })
end

-- ============================================
-- AUTO UPDATE LOOP
-- ============================================

CreateThread(function()
    while true do
        Wait(hudUpdateInterval)
        
        if isHUDVisible and DS.IsLoggedIn() then
            local ped = PlayerPedId()
            local PlayerData = DS.GetPlayerData()
            
            if PlayerData then
                -- Update health
                local health = GetEntityHealth(ped)
                local maxHealth = GetEntityMaxHealth(ped)
                local healthPercent = math.floor((health / maxHealth) * 100)
                
                -- Update stamina
                local stamina = 100 - GetPlayerSprintStaminaDrained(PlayerId())
                
                -- Get metadata
                local hunger = 100
                local thirst = 100
                
                if PlayerData.metadata then
                    hunger = PlayerData.metadata.hunger or 100
                    thirst = PlayerData.metadata.thirst or 100
                end
                
                -- Send to NUI
                DS.UpdateHUDAllStatus(healthPercent, hunger, thirst, stamina)
                
                -- Update money
                if PlayerData.money then
                    DS.UpdateHUDAllMoney(PlayerData.money)
                end
            end
        end
    end
end)

-- ============================================
-- EVENTS
-- ============================================

-- Show HUD when player spawns
RegisterNetEvent('ds-core:client:spawn', function()
    Wait(1000)
    
    local PlayerData = DS.GetPlayerData()
    if PlayerData then
        -- Update player info
        local name = 'Unknown'
        if PlayerData.charinfo then
            name = (PlayerData.charinfo.firstname or '') .. ' ' .. (PlayerData.charinfo.lastname or '')
        end
        
        local jobLabel = 'Unemployed'
        if PlayerData.job then
            jobLabel = PlayerData.job.label or 'Unemployed'
        end
        
        DS.UpdateHUDPlayer(name, jobLabel)
        DS.ShowHUD()
    end
end)

-- Hide HUD on death
RegisterNetEvent('ds-core:client:onDeath', function()
    DS.HideHUD()
end)

-- Update HUD on money change
RegisterNetEvent('ds-core:client:moneyUpdate', function(moneyType, amount, action)
    DS.UpdateHUDMoney(moneyType, amount)
    
    -- Show notification
    local symbol = action == 'add' and '+' or '-'
    local formatted = DS.FormatMoney(math.abs(amount))
    DS.HUDNotify(symbol .. formatted, action == 'add' and 'success' or 'info')
end)

-- Update HUD on job change
RegisterNetEvent('ds-core:client:jobUpdate', function(job)
    if job then
        DS.UpdateHUDPlayer(nil, job.label or 'Unemployed')
    end
end)

-- ============================================
-- COMMANDS (DEBUG)
-- ============================================
RegisterCommand('showhud', function()
    DS.ShowHUD()
end, false)

RegisterCommand('hidehud', function()
    DS.HideHUD()
end, false)

RegisterCommand('testnotify', function(source, args)
    local msg = table.concat(args, ' ') or 'Test notification'
    DS.HUDNotify(msg, 'success')
end, false)

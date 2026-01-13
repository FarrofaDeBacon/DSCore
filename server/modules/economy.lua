--[[
    Double Sync Framework - Server Economy Module
    Economy management system
]]

-- ============================================
-- MONEY FUNCTIONS (GLOBAL)
-- ============================================

-- Add money to player by source
function DS.AddMoney(source, moneyType, amount, reason)
    local player = DS.GetPlayer(source)
    if player then
        return player.Functions.AddMoney(moneyType, amount, reason)
    end
    return false
end

-- Remove money from player by source
function DS.RemoveMoney(source, moneyType, amount, reason)
    local player = DS.GetPlayer(source)
    if player then
        return player.Functions.RemoveMoney(moneyType, amount, reason)
    end
    return false
end

-- Get money from player by source
function DS.GetMoney(source, moneyType)
    local player = DS.GetPlayer(source)
    if player then
        return player.Functions.GetMoney(moneyType)
    end
    return 0
end

-- ============================================
-- TRANSFER MONEY
-- ============================================

function DS.TransferMoney(fromSource, toSource, moneyType, amount)
    local fromPlayer = DS.GetPlayer(fromSource)
    local toPlayer = DS.GetPlayer(toSource)
    
    if not fromPlayer or not toPlayer then
        return false, 'player_not_found'
    end
    
    if fromPlayer.Functions.GetMoney(moneyType) < amount then
        return false, 'insufficient_funds'
    end
    
    fromPlayer.Functions.RemoveMoney(moneyType, amount, 'Transfer to ' .. toPlayer.PlayerData.name)
    toPlayer.Functions.AddMoney(moneyType, amount, 'Transfer from ' .. fromPlayer.PlayerData.name)
    
    DS.Log('economy', fromSource, fromPlayer.PlayerData.citizenid, 'Money transfer', {
        to = toPlayer.PlayerData.citizenid,
        type = moneyType,
        amount = amount
    })
    
    return true, 'success'
end

-- ============================================
-- CALLBACKS
-- ============================================

-- Check if player can afford
DS.CreateCallback('ds-core:canAfford', function(source, cb, moneyType, amount)
    local player = DS.GetPlayer(source)
    if player then
        cb(player.Functions.GetMoney(moneyType) >= amount)
    else
        cb(false)
    end
end)

-- Get all money types
DS.CreateCallback('ds-core:getAllMoney', function(source, cb)
    local player = DS.GetPlayer(source)
    if player then
        cb(player.PlayerData.money)
    else
        cb({})
    end
end)

-- ============================================
-- PAYCHECK SYSTEM
-- ============================================

local paycheckInterval = 30 * 60 * 1000 -- 30 minutes

CreateThread(function()
    while true do
        Wait(paycheckInterval)
        
        for source, player in pairs(DS.Players) do
            local job = player.PlayerData.job
            
            -- Check if player is on duty (if applicable)
            local shouldPay = true
            local jobData = DS.GetJob(job.name)
            
            if jobData and not jobData.offDutyPay and not job.onduty then
                shouldPay = false
            end
            
            if shouldPay then
                local gradeData = DS.GetJobGrade(job.name, job.grade)
                if gradeData and gradeData.payment > 0 then
                    player.Functions.AddMoney('bank', gradeData.payment, 'Paycheck: ' .. job.label)
                    player.Functions.Notify(_L('money_received', DS.FormatMoney(gradeData.payment)), 'success')
                end
            end
        end
        
        DS.Debug('Paychecks distributed')
    end
end)

--[[
    Double Sync Framework - Client Functions
    Client utility functions
]]

-- ============================================
-- NOTIFICAÇÕES
-- ============================================
function DS.Notify(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    -- Usar sistema nativo de notificação do RDR2
    local feed = Citizen.InvokeNative(0xE7E1E32B48B2B5C7)
    Citizen.InvokeNative(0x049D5C615BD38BAD, feed, CreateVarString(10, 'LITERAL_STRING', message), true, true)
    
    DS.Debug('Notificação: [' .. type .. '] ' .. message)
end

-- ============================================
-- UI HELPERS
-- ============================================

-- Draw text on screen
function DS.DrawText(x, y, text, scale, font)
    scale = scale or 0.35
    font = font or 1
    
    local str = CreateVarString(10, 'LITERAL_STRING', text)
    SetTextScale(scale, scale)
    SetTextFontForCurrentCommand(font)
    SetTextColor(255, 255, 255, 255)
    SetTextCentre(true)
    DisplayText(str, x, y)
end

-- Draw 3D text
function DS.DrawText3D(coords, text, scale)
    scale = scale or 0.35
    
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if onScreen then
        DS.DrawText(_x, _y, text, scale)
    end
end

-- ============================================
-- PED HELPERS
-- ============================================

-- Get player ped
function DS.GetPlayerPed()
    return PlayerPedId()
end

-- Get player coords
function DS.GetPlayerCoords()
    return GetEntityCoords(PlayerPedId())
end

-- Check if player is dead
function DS.IsPlayerDead()
    return IsEntityDead(PlayerPedId())
end

-- Get player heading
function DS.GetPlayerHeading()
    return GetEntityHeading(PlayerPedId())
end

-- Teleport player
function DS.TeleportPlayer(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then
        SetEntityHeading(ped, coords.w)
    end
end

-- ============================================
-- CAMERA
-- ============================================

-- Fade out
function DS.FadeOut(duration)
    duration = duration or 500
    DoScreenFadeOut(duration)
    while not IsScreenFadedOut() do
        Wait(10)
    end
end

-- Fade in
function DS.FadeIn(duration)
    duration = duration or 500
    DoScreenFadeIn(duration)
    while not IsScreenFadedIn() do
        Wait(10)
    end
end

-- ============================================
-- PROMPTS (Interactive buttons)
-- ============================================
local ActivePrompts = {}

function DS.CreatePrompt(id, text, key, holdTime)
    if ActivePrompts[id] then
        return ActivePrompts[id]
    end
    
    local prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    local str = CreateVarString(10, 'LITERAL_STRING', text)
    
    Citizen.InvokeNative(0xB5352B7494A08258, prompt, key)
    Citizen.InvokeNative(0x5DD02A8318420DD7, prompt, str)
    
    if holdTime then
        Citizen.InvokeNative(0x94073D5CA3F16B7B, prompt, true)
        Citizen.InvokeNative(0xF4A5C4509BF923B1, prompt, holdTime)
    end
    
    Citizen.InvokeNative(0x8A0FB4D03A630D21, prompt, true)
    Citizen.InvokeNative(0x71215ACCFDE075EE, prompt, 0)
    
    ActivePrompts[id] = prompt
    return prompt
end

function DS.DeletePrompt(id)
    if ActivePrompts[id] then
        Citizen.InvokeNative(0x00EDE88D4D13CF59, ActivePrompts[id])
        ActivePrompts[id] = nil
    end
end

function DS.IsPromptPressed(id)
    if ActivePrompts[id] then
        return Citizen.InvokeNative(0x21E60E230086697F, ActivePrompts[id])
    end
    return false
end

function DS.IsPromptCompleted(id)
    if ActivePrompts[id] then
        return Citizen.InvokeNative(0xE0F65F0640EF0617, ActivePrompts[id])
    end
    return false
end

-- ============================================
-- PROGRESSBAR
-- ============================================
function DS.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, onComplete, onCancel)
    -- Implementação básica de progressbar
    -- Pode ser substituída por sistemas mais avançados (ox_lib, etc)
    
    local startTime = GetGameTimer()
    local endTime = startTime + duration
    local cancelled = false
    
    -- Tocar animação se especificado
    if animation then
        DS.PlayAnim(animation.dict, animation.anim, animation.flags or 1, duration)
    end
    
    CreateThread(function()
        while GetGameTimer() < endTime do
            if canCancel and IsControlJustPressed(0, 0x4CC0E2FE) then -- Backspace
                cancelled = true
                break
            end
            
            local progress = (GetGameTimer() - startTime) / duration * 100
            DS.DrawText(0.5, 0.9, label .. ' (' .. math.floor(progress) .. '%)', 0.4)
            
            Wait(0)
        end
        
        -- Parar animação
        if animation then
            DS.StopAnim()
        end
        
        if cancelled then
            if onCancel then onCancel() end
        else
            if onComplete then onComplete() end
        end
    end)
end

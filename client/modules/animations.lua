--[[
    Double Sync Framework - Animations Module
    Sistema avançado de animações
]]

local currentAnim = nil
local currentDict = nil
local animCancelled = false

-- ============================================
-- CARREGAMENTO DE DICIONÁRIOS
-- ============================================

-- Carregar dicionário de animação
function DS.RequestDict(dict, timeout)
    timeout = timeout or Config.Animations.LoadTimeout
    
    if HasAnimDictLoaded(dict) then
        return true
    end
    
    RequestAnimDict(dict)
    
    local startTime = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() - startTime > timeout then
            DS.Debug('Timeout ao carregar dicionário: ' .. dict)
            return false
        end
        Wait(10)
    end
    
    DS.Debug('Dicionário carregado: ' .. dict)
    return true
end

-- Liberar dicionário
function DS.ReleaseDict(dict)
    if HasAnimDictLoaded(dict) then
        RemoveAnimDict(dict)
        DS.Debug('Dicionário liberado: ' .. dict)
    end
end

-- ============================================
-- TOCAR ANIMAÇÕES
-- ============================================

-- Tocar animação
function DS.PlayAnim(dict, anim, flags, duration, blendIn, blendOut, props)
    local ped = PlayerPedId()
    
    -- Valores padrão
    flags = flags or 0
    duration = duration or Config.Animations.DefaultDuration
    blendIn = blendIn or Config.Animations.DefaultBlendIn
    blendOut = blendOut or Config.Animations.DefaultBlendOut
    
    -- Carregar dicionário
    if not DS.RequestDict(dict) then
        DS.Debug('Falha ao carregar dicionário para animação')
        return false
    end
    
    -- Guardar referência
    currentDict = dict
    currentAnim = anim
    animCancelled = false
    
    -- Attachar props se especificado
    local attachedProps = {}
    if props then
        for _, prop in ipairs(props) do
            local propHash = GetHashKey(prop.model)
            RequestModel(propHash)
            while not HasModelLoaded(propHash) do
                Wait(10)
            end
            
            local obj = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, prop.bone or 0),
                prop.x or 0.0, prop.y or 0.0, prop.z or 0.0,
                prop.rx or 0.0, prop.ry or 0.0, prop.rz or 0.0,
                true, true, false, true, 1, true)
            
            table.insert(attachedProps, obj)
        end
    end
    
    -- Tocar animação
    TaskPlayAnim(ped, dict, anim, blendIn, blendOut, duration, flags, 0.0, false, false, false, '', false)
    DS.Debug('Tocando animação: ' .. dict .. ' -> ' .. anim)
    
    -- Thread para monitorar cancelamento
    CreateThread(function()
        while currentAnim == anim and not animCancelled do
            -- Verificar tecla de cancelamento
            if IsControlJustPressed(0, Config.Animations.CancelKey) then
                DS.StopAnim()
                DS.Notify(_L('animation_cancelled'), 'info')
                break
            end
            
            -- Verificar se animação terminou naturalmente
            if duration > 0 and not IsEntityPlayingAnim(ped, dict, anim, 3) then
                break
            end
            
            Wait(100)
        end
        
        -- Limpar props
        for _, obj in ipairs(attachedProps) do
            DeleteObject(obj)
        end
    end)
    
    return true
end

-- Parar animação atual
function DS.StopAnim()
    local ped = PlayerPedId()
    
    if currentDict and currentAnim then
        StopAnimTask(ped, currentDict, currentAnim, 1.0)
        DS.ReleaseDict(currentDict)
    end
    
    ClearPedTasks(ped)
    
    animCancelled = true
    currentDict = nil
    currentAnim = nil
    
    DS.Debug('Animação parada')
end

-- Verificar se está tocando animação
function DS.IsPlayingAnim()
    return currentAnim ~= nil
end

-- Obter animação atual
function DS.GetCurrentAnim()
    return currentDict, currentAnim
end

-- ============================================
-- PRESETS DE ANIMAÇÃO
-- ============================================

-- Tocar preset de animação
function DS.PlayPreset(presetName)
    local preset = AnimationsConfig.Presets[presetName]
    if not preset then
        DS.Debug('Preset não encontrado: ' .. presetName)
        return false
    end
    
    return DS.PlayAnim(preset.dict, preset.anim, preset.flags, preset.duration, nil, nil, preset.props)
end

-- ============================================
-- SCENARIOS
-- ============================================

-- Tocar scenario
function DS.PlayScenario(scenario, duration)
    local ped = PlayerPedId()
    
    TaskStartScenarioInPlace(ped, GetHashKey(scenario), duration or -1, true, false, false, false)
    currentAnim = scenario
    
    DS.Debug('Tocando scenario: ' .. scenario)
    
    -- Thread para monitorar cancelamento
    CreateThread(function()
        while currentAnim == scenario and not animCancelled do
            if IsControlJustPressed(0, Config.Animations.CancelKey) then
                DS.StopAnim()
                DS.Notify(_L('animation_cancelled'), 'info')
                break
            end
            Wait(100)
        end
    end)
    
    return true
end

-- ============================================
-- EMOTES
-- ============================================

-- Sistema de emotes
DS.Emotes = {
    ['wave'] = { preset = 'wave' },
    ['greet'] = { preset = 'greet' },
    ['sit'] = { preset = 'sit_ground' },
    ['smoke'] = { preset = 'smoke' },
    ['drink'] = { preset = 'drink' },
    ['eat'] = { preset = 'eat' }
}

function DS.PlayEmote(emoteName)
    local emote = DS.Emotes[emoteName]
    if not emote then
        DS.Debug('Emote não encontrado: ' .. emoteName)
        return false
    end
    
    if emote.preset then
        return DS.PlayPreset(emote.preset)
    elseif emote.scenario then
        return DS.PlayScenario(emote.scenario)
    end
    
    return false
end

-- ============================================
-- COMANDOS DE TESTE
-- ============================================
RegisterCommand('testanim', function(source, args)
    if args[1] and args[2] then
        DS.PlayAnim(args[1], args[2], tonumber(args[3]) or 1, tonumber(args[4]) or -1)
    else
        print('Uso: /testanim [dicionário] [animação] [flags] [duração]')
    end
end, false)

RegisterCommand('stopanim', function()
    DS.StopAnim()
end, false)

RegisterCommand('emote', function(source, args)
    if args[1] then
        DS.PlayEmote(args[1])
    else
        print('Emotes disponíveis: wave, greet, sit, smoke, drink, eat')
    end
end, false)

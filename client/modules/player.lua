--[[
    Double Sync Framework - Client Player Module
    Gerenciamento do jogador no cliente
]]

-- ============================================
-- CACHE DO JOGADOR
-- ============================================
local PlayerCache = {
    coords = nil,
    heading = nil,
    health = nil,
    isDead = false,
    isInVehicle = false,
    lastUpdate = 0
}

-- Atualizar cache a cada frame (otimizado)
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        
        PlayerCache.coords = GetEntityCoords(ped)
        PlayerCache.heading = GetEntityHeading(ped)
        PlayerCache.health = GetEntityHealth(ped)
        PlayerCache.isDead = IsEntityDead(ped)
        PlayerCache.isInVehicle = IsPedOnMount(ped) or IsPedInAnyVehicle(ped, false)
        PlayerCache.lastUpdate = GetGameTimer()
        
        Wait(100) -- Atualiza 10 vezes por segundo
    end
end)

-- Obter cache do jogador
function DS.GetPlayerCache()
    return PlayerCache
end

-- ============================================
-- FUNÇÕES DE PLAYER DATA
-- ============================================

-- Obter dinheiro
function DS.GetMoney(moneyType)
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.money then
        return PlayerData.money[moneyType] or 0
    end
    return 0
end

-- Obter job
function DS.GetPlayerJob()
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.job then
        return PlayerData.job
    end
    return nil
end

-- Verificar se tem job específico
function DS.HasJob(jobName)
    local job = DS.GetPlayerJob()
    return job and job.name == jobName
end

-- Verificar se é lei (sheriff, etc)
function DS.IsLeo()
    local job = DS.GetPlayerJob()
    if job then
        return DS.IsLeoJob(job.name)
    end
    return false
end

-- Verificar se é médico
function DS.IsMedic()
    local job = DS.GetPlayerJob()
    if job then
        return DS.IsMedicalJob(job.name)
    end
    return false
end

-- ============================================
-- NECESSIDADES
-- ============================================

-- Obter fome
function DS.GetHunger()
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        return PlayerData.metadata.hunger or 100
    end
    return 100
end

-- Obter sede
function DS.GetThirst()
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        return PlayerData.metadata.thirst or 100
    end
    return 100
end

-- Obter stamina
function DS.GetStamina()
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        return PlayerData.metadata.stamina or 100
    end
    return 100
end

-- ============================================
-- SPAWN E RESPAWN
-- ============================================

-- Spawnar jogador
function DS.SpawnPlayer(coords)
    local ped = PlayerPedId()
    
    -- Fade out
    DS.FadeOut(500)
    Wait(1000)
    
    -- Teleportar
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then
        SetEntityHeading(ped, coords.w)
    end
    
    -- Esperar modelo carregar
    Wait(500)
    
    -- Fade in
    DS.FadeIn(500)
    
    -- Notificar servidor
    TriggerServerEvent('ds-core:server:playerSpawned')
end

-- Respawnar jogador
function DS.RespawnPlayer()
    local respawnLocations = Config.Respawn.RespawnLocations
    local randomLocation = respawnLocations[math.random(#respawnLocations)]
    
    DS.SpawnPlayer(vector4(randomLocation.coords.x, randomLocation.coords.y, randomLocation.coords.z, randomLocation.coords.w or 0.0))
    
    -- Reviver
    local ped = PlayerPedId()
    ResurrectPed(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end

-- ============================================
-- MORTE
-- ============================================
local deathCheckInterval = 1000
local lastDeathCheck = 0

CreateThread(function()
    while true do
        Wait(deathCheckInterval)
        
        if DS.IsLoggedIn() then
            local ped = PlayerPedId()
            local isDead = IsEntityDead(ped)
            
            if isDead and not PlayerCache.isDead then
                PlayerCache.isDead = true
                TriggerEvent('ds-core:client:onDeath')
                TriggerServerEvent('ds-core:server:onPlayerDeath')
            elseif not isDead and PlayerCache.isDead then
                PlayerCache.isDead = false
            end
        end
    end
end)

-- ============================================
-- IDENTIFICAÇÃO
-- ============================================

-- Obter CitizenId
function DS.GetCitizenId()
    local PlayerData = DS.GetPlayerData()
    if PlayerData then
        return PlayerData.citizenid
    end
    return nil
end

-- Obter nome completo
function DS.GetFullName()
    local PlayerData = DS.GetPlayerData()
    if PlayerData and PlayerData.charinfo then
        return (PlayerData.charinfo.firstname or '') .. ' ' .. (PlayerData.charinfo.lastname or '')
    end
    return 'Desconhecido'
end

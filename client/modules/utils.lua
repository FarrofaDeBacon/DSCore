--[[
    Double Sync Framework - Client Utils
    Utilitários gerais do cliente
]]

-- ============================================
-- KEY BINDINGS (Hashes de teclas comuns)
-- ============================================
DS.Keys = {
    E = 0xDFF812F9,
    Q = 0xDE794E3E,
    G = 0x760A9C6F,
    X = 0x8CC9CD42,
    F = 0xB2F377E8,
    R = 0xE30CD707,
    H = 0x24978A28,
    L = 0x80F28E95,
    Z = 0x26E9DC00,
    TAB = 0xB238FE0B,
    ENTER = 0xC7B5340A,
    BACKSPACE = 0x4CC0E2FE,
    SPACE = 0xD9D0E1C0,
    SHIFT = 0x8FFC75D6,
    CTRL = 0xF84FA74F,
    ALT = 0x9720FCEE,
    SCROLL_UP = 0xA5BDCD3C,
    SCROLL_DOWN = 0x3F5A6FE9,
    MOUSE_LEFT = 0x07CE1E61,
    MOUSE_RIGHT = 0xF84FA74F
}

-- ============================================
-- RAYCASTING
-- ============================================

-- Raycast do jogador
function DS.Raycast(distance, flags)
    distance = distance or 10.0
    flags = flags or 1
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local endCoords = coords + forward * distance
    
    local ray = StartExpensiveSynchronousShapeTestLosProbe(
        coords.x, coords.y, coords.z,
        endCoords.x, endCoords.y, endCoords.z,
        flags, ped, 0
    )
    
    local _, hit, hitCoords, _, entity = GetShapeTestResult(ray)
    return hit, hitCoords, entity
end

-- Raycast da câmera
function DS.RaycastFromCamera(distance, flags)
    distance = distance or 50.0
    flags = flags or -1
    
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    
    local dir = DS.RotationToDirection(camRot)
    local endCoords = camPos + dir * distance
    
    local ray = StartExpensiveSynchronousShapeTestLosProbe(
        camPos.x, camPos.y, camPos.z,
        endCoords.x, endCoords.y, endCoords.z,
        flags, PlayerPedId(), 0
    )
    
    local _, hit, hitCoords, _, entity = GetShapeTestResult(ray)
    return hit, hitCoords, entity
end

-- ============================================
-- MATH HELPERS
-- ============================================

-- Rotação para direção
function DS.RotationToDirection(rotation)
    local radian = math.pi / 180
    local z = math.abs(math.cos(rotation.x * radian))
    
    return vector3(
        -math.sin(rotation.z * radian) * z,
        math.cos(rotation.z * radian) * z,
        math.sin(rotation.x * radian)
    )
end

-- Distância entre dois pontos
function DS.Distance(p1, p2)
    return #(vector3(p1.x, p1.y, p1.z) - vector3(p2.x, p2.y, p2.z))
end

-- Verificar se está perto de coordenadas
function DS.IsNear(coords, distance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return DS.Distance(playerCoords, coords) <= distance
end

-- ============================================
-- ENTITY HELPERS
-- ============================================

-- Verificar se entidade é válida
function DS.IsEntityValid(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

-- Obter entidade mais próxima
function DS.GetClosestEntity(entities, coords)
    coords = coords or GetEntityCoords(PlayerPedId())
    local closest = nil
    local closestDist = math.huge
    
    for _, entity in pairs(entities) do
        if DS.IsEntityValid(entity) then
            local dist = DS.Distance(coords, GetEntityCoords(entity))
            if dist < closestDist then
                closest = entity
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

-- ============================================
-- PED HELPERS
-- ============================================

-- Obter peds próximos
function DS.GetNearbyPeds(radius)
    radius = radius or 10.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local peds = {}
    
    local handle, ped = FindFirstPed()
    local success = true
    
    while success do
        if ped ~= PlayerPedId() then
            local pedCoords = GetEntityCoords(ped)
            if DS.Distance(playerCoords, pedCoords) <= radius then
                table.insert(peds, ped)
            end
        end
        success, ped = FindNextPed(handle)
    end
    
    EndFindPed(handle)
    return peds
end

-- Obter jogadores próximos
function DS.GetNearbyPlayers(radius)
    radius = radius or 10.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local players = {}
    
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)
            local pedCoords = GetEntityCoords(ped)
            if DS.Distance(playerCoords, pedCoords) <= radius then
                table.insert(players, {
                    id = playerId,
                    ped = ped,
                    serverId = GetPlayerServerId(playerId)
                })
            end
        end
    end
    
    return players
end

-- ============================================
-- BLIPS
-- ============================================

-- Criar blip
function DS.CreateBlip(coords, sprite, color, label, scale)
    sprite = sprite or 1
    color = color or 1
    scale = scale or 0.8
    
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
    Citizen.InvokeNative(0x74F74D3207ED525C, blip, sprite, true)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, color)
    Citizen.InvokeNative(0xE2590F4F76D583C5, blip, scale)
    
    if label then
        local str = CreateVarString(10, 'LITERAL_STRING', label)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, str)
    end
    
    return blip
end

-- Remover blip
function DS.RemoveBlip(blip)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

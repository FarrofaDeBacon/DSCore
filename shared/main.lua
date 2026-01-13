--[[
    Double Sync Framework - Shared Main
    Framework main object
]]

DS = {}
DS.Players = {}
DS.Functions = {}
DS.Callbacks = {}
DS.ServerCallbacks = {}

-- ============================================
-- FRAMEWORK INFO
-- ============================================
DS.Version = '1.0.0'
DS.Name = 'Double Sync'
DS.Author = 'Double Sync Team'

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Debug print
function DS.Debug(...)
    if Config.Debug then
        local args = {...}
        local msg = '[DS-DEBUG] '
        for i, v in ipairs(args) do
            msg = msg .. tostring(v) .. ' '
        end
        print(msg)
    end
end

-- Print colorido
function DS.Print(type, msg)
    local prefix = {
        ['info'] = '^5[DS-INFO]^7',
        ['success'] = '^2[DS-SUCCESS]^7',
        ['warning'] = '^3[DS-WARNING]^7',
        ['error'] = '^1[DS-ERROR]^7'
    }
    print((prefix[type] or '^7[DS]^7') .. ' ' .. tostring(msg))
end

-- Generate unique ID
function DS.GenerateId(length)
    length = length or 8
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local id = ''
    for i = 1, length do
        local randIndex = math.random(1, #chars)
        id = id .. string.sub(chars, randIndex, randIndex)
    end
    return id
end

-- Generate unique CitizenId
function DS.GenerateCitizenId()
    return 'DS' .. DS.GenerateId(6)
end

-- Format money
function DS.FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return '$' .. formatted
end

-- Check if server
function DS.IsServer()
    return IsDuplicityVersion()
end

-- Check if client
function DS.IsClient()
    return not IsDuplicityVersion()
end

-- Table contains
function DS.TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Deep copy table
function DS.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DS.DeepCopy(orig_key)] = DS.DeepCopy(orig_value)
        end
        setmetatable(copy, DS.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- ============================================
-- OBJECT EXPORT
-- ============================================

-- Export to get core object
exports('GetCoreObject', function()
    return DS
end)

DS.Print('success', 'Double Sync Framework v' .. DS.Version .. ' carregado!')

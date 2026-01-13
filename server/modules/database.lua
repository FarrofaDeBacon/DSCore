--[[
    Double Sync Framework - Server Database Module
    Database handler with oxmysql
]]

DS.Database = {}

-- ============================================
-- INITIALIZATION
-- ============================================

function DS.Database.Init()
    -- Create tables if they don't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS ds_players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL UNIQUE,
            license VARCHAR(100) NOT NULL,
            name VARCHAR(100),
            charinfo JSON DEFAULT '{}',
            money JSON DEFAULT '{"cash":100,"bank":500,"gold":0}',
            job JSON DEFAULT '{"name":"unemployed","label":"Unemployed","grade":0}',
            gang JSON DEFAULT '{"name":"none","label":"None","grade":0}',
            position JSON DEFAULT NULL,
            metadata JSON DEFAULT '{"hunger":100,"thirst":100,"stamina":100,"isdead":false}',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_license (license),
            INDEX idx_citizenid (citizenid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {}, function()
        DS.Print('success', 'Table ds_players verified/created')
    end)
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS ds_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            type VARCHAR(50) NOT NULL,
            source INT,
            citizenid VARCHAR(50),
            message TEXT,
            data JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_type (type),
            INDEX idx_citizenid (citizenid),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {}, function()
        DS.Print('success', 'Table ds_logs verified/created')
    end)
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS ds_bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            license VARCHAR(100) NOT NULL,
            discord VARCHAR(50),
            reason TEXT,
            banned_by VARCHAR(100),
            expire_at TIMESTAMP NULL,
            permanent BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_license (license)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {}, function()
        DS.Print('success', 'Table ds_bans verified/created')
    end)
end

-- ============================================
-- PLAYER OPERATIONS
-- ============================================

-- Save player data
function DS.Database.SavePlayer(playerData)
    MySQL.update([[
        INSERT INTO ds_players (citizenid, license, name, charinfo, money, job, gang, position, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            charinfo = VALUES(charinfo),
            money = VALUES(money),
            job = VALUES(job),
            gang = VALUES(gang),
            position = VALUES(position),
            metadata = VALUES(metadata),
            updated_at = CURRENT_TIMESTAMP
    ]], {
        playerData.citizenid,
        playerData.license,
        playerData.name,
        json.encode(playerData.charinfo),
        json.encode(playerData.money),
        json.encode(playerData.job),
        json.encode(playerData.gang),
        json.encode(playerData.position),
        json.encode(playerData.metadata)
    })
end

-- Load player by citizenid
function DS.Database.LoadPlayer(citizenid)
    local result = MySQL.single.await('SELECT * FROM ds_players WHERE citizenid = ?', { citizenid })
    if result then
        return {
            citizenid = result.citizenid,
            license = result.license,
            name = result.name,
            charinfo = json.decode(result.charinfo) or {},
            money = json.decode(result.money) or {},
            job = json.decode(result.job) or {},
            gang = json.decode(result.gang) or {},
            position = json.decode(result.position),
            metadata = json.decode(result.metadata) or {}
        }
    end
    return nil
end

-- Load all characters by license
function DS.Database.GetCharactersByLicense(license)
    local results = MySQL.query.await('SELECT citizenid, charinfo FROM ds_players WHERE license = ?', { license })
    local characters = {}
    if results then
        for _, row in ipairs(results) do
            table.insert(characters, {
                citizenid = row.citizenid,
                charinfo = json.decode(row.charinfo) or {}
            })
        end
    end
    return characters
end

-- Delete character
function DS.Database.DeleteCharacter(citizenid)
    MySQL.query('DELETE FROM ds_players WHERE citizenid = ?', { citizenid })
end

-- Check if citizenid exists
function DS.Database.CitizenIdExists(citizenid)
    local result = MySQL.scalar.await('SELECT 1 FROM ds_players WHERE citizenid = ?', { citizenid })
    return result ~= nil
end

-- ============================================
-- LOGGING
-- ============================================

function DS.Log(type, source, citizenid, message, data)
    if not Config.Logging.Enabled then return end
    
    if Config.Logging.LogToConsole then
        DS.Print('info', '[LOG:' .. type .. '] ' .. message)
    end
    
    if Config.Logging.LogToDatabase then
        MySQL.insert('INSERT INTO ds_logs (type, source, citizenid, message, data) VALUES (?, ?, ?, ?, ?)', {
            type,
            source,
            citizenid,
            message,
            json.encode(data or {})
        })
    end
end

-- ============================================
-- BAN SYSTEM
-- ============================================

function DS.Database.AddBan(license, reason, bannedBy, expireAt, permanent)
    MySQL.insert('INSERT INTO ds_bans (license, reason, banned_by, expire_at, permanent) VALUES (?, ?, ?, ?, ?)', {
        license,
        reason,
        bannedBy,
        expireAt,
        permanent or false
    })
end

function DS.Database.RemoveBan(license)
    MySQL.query('DELETE FROM ds_bans WHERE license = ?', { license })
end

function DS.Database.IsBanned(license)
    local result = MySQL.single.await([[
        SELECT * FROM ds_bans 
        WHERE license = ? 
        AND (permanent = TRUE OR expire_at > NOW())
    ]], { license })
    return result
end

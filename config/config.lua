--[[
    Double Sync Framework - Configuration
    Global framework settings
]]

Config = {}

-- ============================================
-- GENERAL SETTINGS
-- ============================================
Config.Debug = true                          -- Debug mode (shows logs in console)
Config.Locale = 'pt-br'                       -- Default language
Config.CommandPrefix = ''                     -- Command prefix (e.g. 'ds' = /ds:command)

-- ============================================
-- SERVER SETTINGS
-- ============================================
Config.ServerName = 'Double Sync RP'          -- Server name
Config.MaxCharacters = 3                      -- Max characters per player
Config.DefaultSpawn = vector4(-279.46, 805.88, 119.38, 90.0) -- Default spawn

-- ============================================
-- ECONOMY
-- ============================================
Config.Money = {
    Types = {
        cash = { label = 'Cash', default = 100 },
        bank = { label = 'Bank', default = 500 },
        gold = { label = 'Gold', default = 0 }
    }
}

-- ============================================
-- NEEDS (STATUS)
-- ============================================
Config.Needs = {
    Enabled = true,
    UpdateInterval = 60000,                   -- Update interval in ms
    
    Hunger = {
        Enabled = true,
        DecayRate = 1.0,                      -- Decay per interval
        DamageThreshold = 10,                 -- Below this takes damage
        DamageAmount = 1                      -- Damage per interval when hungry
    },
    
    Thirst = {
        Enabled = true,
        DecayRate = 1.5,                      -- Decay per interval
        DamageThreshold = 10,                 -- Below this takes damage
        DamageAmount = 1                      -- Damage per interval when thirsty
    },
    
    Stamina = {
        Enabled = true,
        RegenRate = 2.0                       -- Regen per interval (when idle)
    }
}

-- ============================================
-- ANIMATIONS
-- ============================================
Config.Animations = {
    CancelKey = 0x760A9C6F,                   -- Key to cancel animation (X by default)
    DefaultBlendIn = 4.0,                     -- Default blend in speed
    DefaultBlendOut = -4.0,                   -- Default blend out speed
    DefaultDuration = -1,                     -- Default duration (-1 = until finished)
    LoadTimeout = 5000                        -- Timeout to load dictionary (ms)
}

-- ============================================
-- ADMIN
-- ============================================
Config.Admin = {
    Groups = {
        'admin',
        'mod',
        'dev'
    },
    DefaultGroup = 'user'                     -- Default group for new players
}

-- ============================================
-- DISCORD WEBHOOK
-- ============================================
Config.Webhooks = {
    Enabled = false,
    PlayerConnect = '',                       -- Webhook URL for connections
    PlayerDisconnect = '',                    -- Webhook URL for disconnections
    AdminActions = '',                        -- Webhook URL for admin actions
    Economy = ''                              -- Webhook URL for transactions
}

-- ============================================
-- RESPAWN
-- ============================================
Config.Respawn = {
    Timer = 30,                               -- Respawn timer in seconds
    RespawnLocations = {
        { coords = vector4(-279.46, 805.88, 119.38, 90.0), label = 'Valentine' },
        { coords = vector4(2934.08, 1283.92, 44.67, 180.0), label = 'Saint Denis' },
        { coords = vector4(-1800.0, -375.0, 161.0, 0.0), label = 'Blackwater' }
    }
}

-- ============================================
-- LOGGING
-- ============================================
Config.Logging = {
    Enabled = true,
    LogToDatabase = true,                     -- Save logs to database
    LogToConsole = true,                      -- Show logs in console
    LogToWebhook = false                      -- Send logs to webhook
}

return Config

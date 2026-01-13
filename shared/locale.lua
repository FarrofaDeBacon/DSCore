--[[
    Double Sync Framework - Locale System
    Translation loader
]]

local Locales = {}
local currentLocale = nil

-- Load locale file
local function LoadLocale(lang)
    local path = ('locales/%s.lua'):format(lang)
    local content = LoadResourceFile(GetCurrentResourceName(), path)
    
    if content then
        local fn = load(content)
        if fn then
            Locales[lang] = fn()
            DS.Debug('Locale loaded: ' .. lang)
            return true
        end
    end
    
    DS.Debug('Failed to load locale: ' .. lang)
    return false
end

-- Initialize locales
CreateThread(function()
    -- Load default locale (English as fallback)
    LoadLocale('en')
    
    -- Load configured locale
    local configLocale = Config.Locale or 'en'
    if configLocale ~= 'en' then
        LoadLocale(configLocale)
    end
    
    currentLocale = configLocale
    DS.Print('success', 'Locale system initialized: ' .. currentLocale)
end)

-- Get translated string
function DS.Locale(key, ...)
    -- Try current locale first
    local translation = Locales[currentLocale] and Locales[currentLocale][key]
    
    -- Fallback to English
    if not translation then
        translation = Locales['en'] and Locales['en'][key]
    end
    
    -- Return key if no translation found
    if not translation then
        DS.Debug('Translation not found: ' .. key)
        return key
    end
    
    -- Format with arguments if provided
    if ... then
        return string.format(translation, ...)
    end
    
    return translation
end

-- Alias for convenience
function _L(key, ...)
    return DS.Locale(key, ...)
end

-- Set locale at runtime
function DS.SetLocale(lang)
    if not Locales[lang] then
        if not LoadLocale(lang) then
            return false
        end
    end
    currentLocale = lang
    return true
end

-- Get current locale
function DS.GetLocale()
    return currentLocale
end

-- Add custom translations
function DS.AddLocale(lang, translations)
    if not Locales[lang] then
        Locales[lang] = {}
    end
    
    for key, value in pairs(translations) do
        Locales[lang][key] = value
    end
end

-- Get all available locales
function DS.GetAvailableLocales()
    local available = {}
    for lang, _ in pairs(Locales) do
        table.insert(available, lang)
    end
    return available
end

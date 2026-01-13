fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'ds-core'
author 'Double Sync Team'
description 'Double Sync Framework - Core for RedM'
version '1.0.0'

lua54 'yes'

-- Dependencies
dependencies {
    'oxmysql'
}

-- Shared files (loaded first)
shared_scripts {
    'config/config.lua',
    'config/animations.lua',
    'shared/main.lua',
    'shared/locale.lua',
    'shared/items.lua',
    'shared/jobs.lua'
}

-- Locale files
files {
    'locales/en.lua',
    'locales/pt-br.lua',
    'locales/es.lua'
}

-- Client scripts
client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/modules/utils.lua',
    'client/modules/animations.lua',
    'client/modules/player.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/callbacks.lua',
    'server/commands.lua',
    'server/modules/database.lua',
    'server/modules/player.lua',
    'server/modules/economy.lua',
    'server/modules/spawner.lua'
}

-- Exports
exports {
    'GetPlayerData',
    'GetCoreObject',
    'IsLoggedIn',
    'Notify',
    'TriggerCallback'
}

server_exports {
    'GetCoreObject',
    'GetPlayer',
    'GetPlayers',
    'CreatePlayer',
    'GetPlayerByCitizenId',
    'CreateCallback',
    'AddMoney',
    'RemoveMoney'
}

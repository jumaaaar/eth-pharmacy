fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Jumar'
description 'Eth Pharmacy for ESX'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
}

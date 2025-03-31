fx_version 'cerulean'
game 'gta5'
lua54 'yes' -- Thêm dòng này để bật Lua 5.4

author 'Pin Cobra'
description 'Script điều chế vật phẩm cho ESX Legacy với ox_inventory và ox_lib'
version '1.1.1'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_lib'
}

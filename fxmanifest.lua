fx_version 'cerulean'
game 'gta5'

author 'smq scripts'
description 'Advanced vehicle key management system'
version '1.0.0'

-- [!] ATTENTION: Please read the README.md file before installation and use!
-- [!] Support / Discord: https://discord.gg/z7x6dD3yXm


dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Opravuje chybu 'MySQL'
    'server/main.lua'
}

-- Metadata
repository 'https://github.com/smqscripts/smq_vehiclekey' 

discord 'https://discord.gg/z7x6dD3yXm' 

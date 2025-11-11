fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Business System'
version '1.0.0'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua'
}

ui_page 'html/business.html'

files {
    'html/business.html'
}

dependencies {
    'qb-core',
    'qb-target'
}
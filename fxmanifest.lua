fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'lxr-contraband'
version '1.0.0'

client_scripts {
    'config.lua',
    '/client/client.lua'
}

server_script '/server/server.lua'

lua54 'yes'
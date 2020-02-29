fx_version 'adamant'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts {
	"@_core/libs/utils.lua",
	'client.lua'
}

server_scripts {
	"@_core/libs/utils.lua",
	'server.lua'
}

ui_page './html/html/select-character.html'

files {
    './html/assets/char-select/*',
    './html/fonts/*',
    './html/scripts/*',
    './html/html/*',
    './html/styles/*'
}

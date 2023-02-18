fx_version 'adamant'

game 'gta5'

description 'ESX Status'

version '2.0'
legacyversion '1.9.1'

lua54 'yes'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
    'locales/*.lua',
	'config.lua',
	'server/*.lua'
}

client_scripts {
	'@es_extended/locale.lua',
    'locales/*.lua',
	'client/classes/status.lua',
	'config.lua',
	'client/*.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/css/app.css',
	'html/scripts/app.js'
}

dependency 'es_extended'

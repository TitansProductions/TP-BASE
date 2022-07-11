fx_version 'adamant'
game 'gta5'

author 'Nosmakos'
description 'Titans Productions Base UI (ESX)'
version '1.2.0'

ui_page 'html/index.html'

client_scripts {
    'config.lua',
    'achievements.lua',
    'locales.lua',
    'client/*.lua',
    'client/trunk/*.lua',
}

server_scripts {
	--'@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'achievements.lua',
    'locales.lua',
    'server/*.lua',
    'server/trunk/*.lua',
    'server/trunk/classes/*.lua',
}

files {
	'html/index.html',

    'html/js/config.js',
    'html/js/locales/*.js',

    'html/js/script.js',

	'html/css/*.css',
	'html/font/Prototype.ttf',
    'html/img/logo.png',
    'html/img/transaction.png',
    'html/img/items/*.png',
    'html/img/achievements/*.png',

    'html/sounds/button_click.wav',
}

dependency 'es_extended'

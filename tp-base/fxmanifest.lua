fx_version 'adamant'
game 'gta5'

author 'Nosmakos'
description 'Titans Productions Base UI (ESX)'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'config.lua',
    'locales.lua',
    'client/*.lua',
    'client/trunk/*.lua',
}

server_scripts {
	--'@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'locales.lua',
    'server/*.lua',
    'server/trunk/*.lua',
    'server/trunk/classes/*.lua',
}

files {
	'html/index.html',

    'html/js/config.js',

    'html/js/locales/locales-en.js',
    'html/js/locales/locales-gr.js',
    'html/js/locales/locales-de.js',
    'html/js/locales/locales-ru.js',
    'html/js/locales/locales-zh.js',
	
    'html/js/script.js',

	'html/css/*.css',
	'html/font/Prototype.ttf',
    'html/img/logo.png',
    'html/img/transaction.png',
    'html/img/items/*.png',

    'html/sounds/button_click.wav',
}

dependency 'es_extended'

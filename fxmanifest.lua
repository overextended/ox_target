-- FX Information
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

-- Resource Information
name 'ox_target'
author 'Overextended'
version '1.2.1'
repository 'https://github.com/overextended/ox_target'
description ''

-- Manifest
ui_page 'web/index.html'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'@ox_lib/init.lua',
	'client/utils.lua',
	'client/api.lua',
	'client/debug.lua',
	'client/defaults.lua',
	'client/framework/*.lua',
	'client/compat/*.lua',
	'client/main.lua',
}

server_scripts {
	'server/main.lua'
}

files {
	'web/**',
}

provide 'qtarget'
provide 'qb-target'
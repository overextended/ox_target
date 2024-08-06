-- FX Information
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

-- Resource Information
name 'ox_target'
author 'Overextended'
version '1.16.0'
repository 'https://github.com/overextended/ox_target'
description ''

-- Manifest
ui_page 'web/index.html'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua'
}

files {
	'web/**',
	'locales/*.json',
	'client/api.lua',
	'client/utils.lua',
	'client/state.lua',
	'client/debug.lua',
	'client/defaults.lua',
	'client/framework/nd.lua',
	'client/framework/ox.lua',
	'client/framework/esx.lua',
	'client/framework/qbx.lua',
	'client/compat/qtarget.lua',
}

provide 'qtarget'

dependency 'ox_lib'

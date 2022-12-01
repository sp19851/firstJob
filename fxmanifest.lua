fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Cruso#5040'

shared_scripts {
  'config.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
  'client.lua',
  
}

server_scripts {
  'server.lua',
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/scripts/*.js',
	'html/img/*.png',
	'html/css/*.css',
	'html/fonts/*.ttf',
	
}





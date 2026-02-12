fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iamlation'
description 'A unique take on oxy runs for FiveM'
version '1.0.0'

dependencies {
  'qbx_core',
  'ox_lib',
  'ox_inventory',
  'ox_target'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  'server/*.lua'
}

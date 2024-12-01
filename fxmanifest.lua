fx_version 'cerulean'
game 'gta5'

author 'DonHulieo'
description 'Don\'s Interactive Blips Framework for FiveM'
version '1.0.2'
url 'https://github.com/DonHulieo/iblips'

shared_script '@duff/shared/import.lua'

server_script 'server/main.lua'

client_script 'client/main.lua'

files {'client/blips.lua', 'shared/config.lua', 'images/*.png', 'locales/*.lua'}

dependencies {'duff'}

lua54 'yes'
fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts {
	'libs/utils.lua',
	---------------------
	'config/Clothes.lua',
	'config/Items.lua',
	'config/CraftableItems.lua',
	'config/DefaultClothes.lua',
	---------------------
	'client/_Main.lua',
	'client/Horse.lua',
	'client/Basic_Needs.lua',
	'client/LoadIPL.lua',
	-- 'client/DebuggingControls.lua'
}

server_scripts {
	'libs/utils.lua',
	---------------------
	'config/Items.lua',
	'config/XPSystem.lua',
	---------------------
	'server/Database.lua',
	'server/_Main.lua',
	'server/Auth.lua',
	'server/Gui.lua',
	'server/Basic_Needs.lua',
	-----------------------
	'server/class/Inventory.lua',
	'server/class/ItemData.lua',
	'server/class/Character.lua',
	'server/class/User.lua',
	'server/class/Chest.lua',
	'server/class/ShopItem.lua',
	'server/class/Horse.lua',
	'server/class/Posse.lua',
	-----------------------
	-- 'server/manager/ChestManager.lua',
	'server/manager/ItemDataManager.lua',
	'server/manager/CharacterManager.lua',
	'server/manager/HorseManager.lua',
	'server/manager/PosseManager.lua'
}

files {
	'libs/utils.lua',
	'libs/Tunnel.lua',
	'libs/Proxy.lua',
	'libs/Tools.lua',
	'html/*',
	'html/img/*',
	'html/fonts/*',
}

ui_page 'html/index.html'

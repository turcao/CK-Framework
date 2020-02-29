local Tunnel = module('_core', 'libs/Tunnel')
local Proxy = module('_core', 'libs/Proxy')

API = Tunnel.getInterface('API')
cAPI = Proxy.getInterface('API')

RegisterNetEvent('ck_selector:createSelectorClient')
AddEventHandler('ck_selector:createSelectorClient', function(listcharacters)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "listchar",
        characters = listcharacters
    })
end)

RegisterNUICallback('CreateCharacter', function()
    TriggerServerEvent('ck_selector:createCharacterTest', "Joseph Test")
    closeNUI()
end)

RegisterNUICallback('DeleteCharacter', function(data)
    TriggerServerEvent('ck_selector:deleteCharacter', data.charid)
    closeNUI()
end)

RegisterNUICallback('SelectCharacter', function(data)
    TriggerServerEvent('ck_selector:setCharacter', data.charid)
    closeNUI()
end)


function closeNUI() 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeCharacters"
    })
end
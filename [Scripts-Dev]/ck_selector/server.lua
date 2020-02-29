local Tunnel = module('_core', 'libs/Tunnel')
local Proxy = module('_core', 'libs/Proxy')

API = Tunnel.getInterface('API')
cAPI = Proxy.getInterface('API')

RegisterServerEvent('ck_selector:createSelectorServer')
AddEventHandler('ck_selector:createSelectorServer',function(source)
    local User = API.getUserFromSource(source)
    if User:getId() then
        TriggerClientEvent('ck_selector:createSelectorClient', source, User:getCharacters())
    end
end)

RegisterServerEvent('ck_selector:createCharacterTest')
AddEventHandler('ck_selector:createCharacterTest', function(charName)
    local _source = source
    local User = API.getUserFromSource(_source)
    User:createCharacter(charName)
    TriggerEvent('ck_selector:createSelectorServer', _source)
end)

RegisterServerEvent('ck_selector:deleteCharacter')
AddEventHandler('ck_selector:deleteCharacter', function(charid)
    local _source = source
    local User = API.getUserFromSource(_source)
    User:deleteCharacter(charid)
    TriggerEvent('ck_selector:createSelectorServer', _source)
end)

RegisterServerEvent('ck_selector:setCharacter')
AddEventHandler('ck_selector:setCharacter', function(charid)
    local _source = source
    local User = API.getUserFromSource(_source)
    User:setCharacter(charid)
end)
RegisterNetEvent('FCRP:HORSE:openChest')
AddEventHandler('FCRP:HORSE:openChest', function()
    local _source = source
    local User = API.getUserFromSource(_source)
    local Character = User:getCharacter()
    local Horse = Character:getHorse()

    if Horse ~= nil then
        User:viewInventoryAsPrimary(Character:getInventory())
        User:viewInventoryAsSecondary(Horse:getInventory())
    end
end)
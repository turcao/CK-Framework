local chests = {}
local chestsSyncData = {}

-- TABELA fcrp_CHESTS

-- id    position       type    capacity   charid
-- 1  {150, 20, 10, 10}   1      20         1

Citizen.CreateThread(
    function()
        local rows = ... -- Query get every chest from database on script start up
        if #rows > 0 then
            for index = 0, #rows do
                local id = rows[index].id
                local type = rows[index].type
                local position = json.decode(rows[index].position)
                local capacity = rows[index].capacity
                local owner_char_id = rows[index].owner_char_id
                local inventories = {}
                local inventoriesRows = ... -- Query to get every inventory that is from that chest id
                if #inventoriesRows > 0 then
                    for index2 = 0, #inventoriesRows do
                        local Inventory = API.Inventory(inventoriesRows[index2].id, capacity, table.decode(inventoriesRows[index2].items))
                        local charId = string.gsub(inventoriesRows[index2].id, string.find(inventoriesRows[index2].id, '_char') + 5)
                        inventories[tonumber(charId)] = Inventory
                    end
                end
                chests[id] = API.Chest(id, position, type, capacity, owner_char_id, inventories)
                chestsSyncData[id] = {capacity, table.unpack(position)} -- OUTPUT: [1] = {20, x, y, z ,h}
            end
        else -- Caso não exista nenhum CHEST na table, consequentemente não haverá nenhum CHEST da CONFIG, então cria eles na tablea
            for _, data in pairs(Chests) do
                local x, y, z, h, type, capacity = table.unpack(data)
                local rowsWithId = API_Database.execute('FCRP/InsertChest', {position = json.encode({x, y, z, h}), type = type, capacity = capacity, charid = nil})
                if #rowsWithId > 0 then
                    local id = rowsWithId[1].id
                    chests[id] = API.Chest(id, position, type, capacity, nil, {})
                end
            end
        end
    end
)

function API.getChestFromChestId(chestId)
    return chests[chestId]
end

function API.syncChestsWithPlayer(source)
    TriggerClientEvent('FCRP:CHESTS:SyncMultipleChests', source, chestsSyncData) -- Vai mandar informaçoes de todos os CHESTS registrados da seguinte forma
    -- {
    --     [chestId1] = {capacity, x, y, z, h},
    --     [chestId2] = {capacity, x, y, z, h},
    --     [chestId3] = {capacity, x, y, z, h},
    --     [chestId4] = {capacity, x, y, z, h},
    -- }
    -- A capacity do CHEST determina o modelo de prop que será usado in-game
end

function API.cacheChest(Chest)
    chests[Chest:getId()] = Chest
    chestsSyncData[Chest:getId()] = {Chest:getCapacity(), table.unpack(Chest:getPosition())} -- OUTPUT: -- {capacity, x, y, z}
    TriggerClientEvent('FCRP:CHESTS:SyncChest', -1, chest:getId(), chest:Capacity(), table.unpack(Chest:getPosition())
end

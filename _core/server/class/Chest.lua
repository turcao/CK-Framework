function API.Chest(id, position, type, capacity, owner_char_id, inventories)
    local self = {}

    self.id = id
    self.position = position -- Table {x, y, z, h}
    self.type = 0 -- GLOBAL[0] | PUBLIC[1] | PRIVATE[2]
    self.capacity = capacity
    self.owner_char_id = owner_char_id

    self.inventories = inventories or {}

    for charId, Inventory in pairs(inventories) do
        self.inventories[charId] = Inventory
    end

    self.cache = function()
        API.cacheChest(self)
    end

    self.getId = function()
        return self.id
    end

    self.getPosition = function()
        return self.position
    end

    self.getOwnerCharId = function()
        return self.owner_id
    end

    -- O items do baú são globais, são sempre os mesmos independente de quem abra
    self.isGlobal = function()
        return type == 0
    end

    -- O baú pode ser aberto por qualquer um, mas os items sao diferentes para cada player
    self.isPublic = function()
        return type == 1
    end

    -- O baú é aberto só pelo dono do baú, os items são sempre os mesmos
    self.isPrivate = function()
        return type == 2
    end

    self.getInventory = function(this, charId)
        if self:isGlobal() then
            -- !!!!!!!!!!!! OPTIMIZATION ?KINDA OF
            -- Update Query on INVENTORY CLASS > ADDITEM to create a new row on UPDATE type of query
            local Inventory = self.inventories[charId]

            if Inventory == nil then
                Inventory = API.Inventory('chest:' .. self.id .. '_char:' .. charId, self.capacity, {})
                self.inventories[charId] = Inventory
            end

            return Inventory
        end

        if self:isPublic() then
            if self.inventories[self:getOwnerCharId()] == nil then
                if Inventory == nil then
                    Inventory = API.Inventory('chest:' .. self.id .. '_char:' .. self:getOwnerCharId(), self.capacity, {})
                    self.inventories[charId] = Inventory
                end
            end
            return self.inventories[self:getOwnerCharId()]
        end

        if self:isPrivate() then
            if charId == self:getOwnerCharId() then
                if self.inventories[self:getOwnerCharId()] == nil then
                    if Inventory == nil then
                        Inventory = API.Inventory('chest:' .. self.id .. '_char:' .. self:getOwnerCharId(), self.capacity, {})
                        self.inventories[charId] = Inventory
                    end
                end
                return self.inventories[self:getOwnerCharId()]
            end
        end
    end

    return self
end

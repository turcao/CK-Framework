function API.User(source, id, ipAddress)
    local self = {}

    self.source = source
    self.id = id
    self.ipAddress = ipAddress or '0.0.0.0'
    self.posseId = nil

    self.save = function()
    end

    self.getSource = function()
        return self.source
    end

    self.getId = function()
        return self.id
    end

    self.getIpAddress = function()
        return ipAddress
    end

    self.getIdentifiers = function()
        local num = GetNumPlayerIdentifiers(self.source)

        local identifiers = {}
        for i = 1, num do
            table.insert(identifiers, GetPlayerIdentifier(self.source, i))
        end

        return identifiers
    end

    self.getCharacters = function()
        local rows = API_Database.query('FCRP/GetCharacters', {user_id = self.id})
        if #rows > 0 then
            return rows
        end
    end

    self.createCharacter = function(this, characterName)
        local Character = nil
        local rows = API_Database.query('FCRP/CreateCharacter', {user_id = self:getId(), charName = characterName})
        if #rows > 0 then
            local charId = rows[1].id

            Character = API.Character(charId, characterName, 1, 0, {}, API.Inventory('char:' .. charId, nil, nil))
            local Inventory = Character:getInventory()
            local Horse = Character:createHorse('A_C_Donkey_01', 'Burrinho')

            Character:setData(charId, 'charTable', 'hunger', 0)
            Character:setData(charId, 'charTable', 'thirst', 0)

            API_Database.execute('FCRP/Inventory', {id = 'char:' .. Character:getId(), charid = Character:getId(), itemName = 0, itemCount = 0, typeInv = 'insert'})
        end

        return Character
    end

    self.deleteCharacter = function(this, id)
        API_Database.execute('FCRP/DeleteCharacter', {charid = id})
    end

    self.setCharacter = function(this, id)
        local charRow = API_Database.query('FCRP/GetCharacter', {charid = id})
        if #charRow > 0 then
            API.chars[id] = self:getId()
            local rows2 = API_Database.query('FCRP/Inventory', {id = 'char:' .. id, charid = id, itemName = 0, itemCount = 0, typeInv = 'select'})
            local Inventory = nil
            if #rows2 > 0 then
                Inventory = API.Inventory('char:' .. id, parseInt(rows2[1].capacity), json.decode(rows2[1].items))
            end
            self.Character = API.Character(id, charRow[1].characterName, charRow[1].level, charRow[1].xp, json.decode(charRow[1].groups), Inventory)

            local weapons = json.decode(charRow[1].weapons) or {}
            cAPI.replaceWeapons(self:getSource(), weapons)

            -- Vai retornar o cavalo atual do Character, caso não tenha, vai buscar pelo bancao de dados e carregar ele
            local Horse = self:getCharacter():getHorse()
            if Horse then
                cAPI.setHorse(self:getSource(), Horse:getModel(), Horse:getName())
            end

            local posse = API.getPosse(tonumber(json.decode(charRow[1].charTable).posse))
            if posse ~= nil then
                self.posseId = posse:getId()
            end

            ---------------- AUTO ADMING GROUP TO USER WITH ID 1
            if self:getId() == 1 then
                if not self.Character:hasGroup('admin') then
                    self.Character:addGroup('admin')
                end
            end
            ---------------- AUTO ADMING GROUP TO USER WITH ID 1
            self.drawCharacter()
        end
    end

    self.getCharacter = function()
        return self.Character
    end

    self.saveCharacter = function()
        return self.Character:savePosition(self.source)
    end

    self.drawCharacter = function()
        if cAPI.setModel(self.source, self.Character:getModel()) then
            Wait(200)
            if cAPI.startNeeds(self.source) then
                Wait(100)
                if cAPI.setDados(self.source, self.Character:getCharTable()) then
                    Wait(100)
                    cAPI.setClothes(self.source, self.Character:getClothes())
                    Wait(100)
                    cAPI.teleportSpawn(self.source, self.Character:getLastPos(self.source))
                end
            end
        end
    end

    self.disconnect = function(this, reason)
        DropPlayer(self.source, reason)
    end

    self.viewInventory = function()
        if self.Character ~= nil then
            self:viewInventoryAsPrimary(self.Character:getInventory())
        end
    end

    self.viewInventoryAsPrimary = function(this, Inventory)
        self.primaryViewingInventory = Inventory
        Inventory:viewAsPrimary(self:getSource())
    end

    self.viewInventoryAsSecondary = function(this, Inventory)
        self.secondaryViewingInventory = Inventory
        Inventory:viewAsSecondary(self:getSource())
    end

    self.closeInventory = function()
        if self.primaryViewingInventory ~= nil then
            self.primaryViewingInventory:removeViewer(self:getSource())
            self.primaryViewingInventory = nil
        end

        if self.secondaryViewingInventory ~= nil then
            self.secondaryViewingInventory:removeViewer(self:getSource())
            self.secondaryViewingInventory = nil
        end
    end

    self.getPrimaryInventoryViewing = function()
        return self.primaryViewingInventory
    end

    self.getSecondaryInventoryViewing = function()
        return self.secondaryViewingInventory
    end

    self.setHorse = function(this, id)
        local Horse = self:getCharacter():setHorse(id)
        cAPI.setHorse(self:getSource(), Horse:getModel(), horse:getName())
    end

    self.notify = function(this, v)
        cAPI.notify(self:getSource(), v)
    end

    self.getWeapons = function()
        return cAPI.getWeapons(self:getSource())
    end

    self.giveWeapon = function(this, weapon, ammo)
        self:giveWeapons({[weapon] = ammo})
    end

    self.giveWeapons = function(this, array)
        cAPI.giveWeapons(self:getSource(), array, false)
        self.Character:setWeapons(cAPI.getWeapons(self:getSource()))
    end

    self.removeWeapon = function(this, weapon)
        self:removeWeapons({weapon})
    end

    self.removeWeapons = function(this, array)
        local weapons = cAPI.getWeapons(self:getSource())
        for _, weapon in pairs(array) do
            weapons[weapon] = nil
        end
        cAPI.replaceWeapons(self:getSource(), weapons)
        self.Character:setWeapons(cAPI.getWeapons(self:getSource()))
    end

    self.replaceWeapons = function(this, array)
        cAPI.replaceWeapons(self:getSource(), array)
        self.Character:setWeapons(cAPI.getWeapons(self:getSource()))
    end

    self.setPosse = function(this, id)
        self.posseId = id

        TriggerClientEvent('FCRP:POSSE:SetPosse', self:getSource(), id)

        if id ~= nil then
            self:getCharacter():setData(self:getCharacter():getId(), 'charTable', 'posse', id)
        else
            self:getCharacter():remData(self:getCharacter():getId(), 'charTable', 'posse')
        end
    end

    self.getPosseId = function()
        return self.posseId
    end

    self.isInAPosse = function()
        return self.posseId ~= nil
    end

    return self
end

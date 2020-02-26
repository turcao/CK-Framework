local horseModel
local horseEntity
local horseName
local horsePrompt

function cAPI.setHorse(model, name)
    horseModel = model
    horseName = name
end

function cAPI.clearHorse()
    if horseEntity ~= nil then
        SetVehicleHasBeenOwnedByPlayer(horseEntity, false)
    end
    horseModel = nil
    horseEntity = nil
    horseName = nil
    horsePrompt = nil
end

function cAPI.spawnHorse()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local modelHash = GetHashKey(horseModel)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    local x, y, z = table.unpack(pCoords)
    local bool, nodePosition = GetClosestVehicleNode(x, y, z, 1, 3.0, 0.0)

    local index = 0
    while index <= 25 do
        local _bool, _nodePosition = GetNthClosestVehicleNode(x, y, z, index, 1, 3.0, 2.5)
        if _bool == true or _bool == 1 then
            bool = _bool
            nodePosition = _nodePosition
            index = index + 3
        else
            break
        end
    end

    horseEntity = CreatePed(modelHash, nodePosition, GetEntityHeading(ped), 1, 0)
    -- SetRandomOutfitVariation(horseEntity, true)
    Citizen.InvokeNative(0x283978A15512B2FE, horseEntity, true)
    Citizen.InvokeNative(0x283978A15512B2FE, horseEntity, true)
    Citizen.InvokeNative(0x58A850EAEE20FAA3, horseEntity)
    Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, horseEntity)
    SetVehicleHasBeenOwnedByPlayer(horseEntity, true)
    SetPedNameDebug(horseEntity, horseModel)
    SetPedPromptName(horseEntity, horseName)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0xFD4E14C5, true, true, true) --saddle
    Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0x508B80B9, true, true, true) --blanket
    -- Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0x16923E26, true, true, true) --mane
    -- Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0xF867D611, true, true, true) --tail
    Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0xF0C30271, true, true, true) --bag
    Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0x12F0DF9F, true, true, true) --bedroll
    Citizen.InvokeNative(0xD3A7B003ED343FD9, horseEntity, 0x67AF7302, true, true, true) --stirups
    SetModelAsNoLongerNeeded(horseEntity)
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            if horseEntity ~= nil then
                if DoesEntityExist(horseEntity) then
                    local ped = PlayerPedId()
                    local pCoords = GetEntityCoords(ped)

                    local dist = #(pCoords - GetEntityCoords(horseEntity))
                    if dist <= 100 then
                        if IsControlJustPressed(0, 0xFF8109D8) then
                            if dist <= 1.5 then
                                TriggerServerEvent('FCRP:HORSE:openChest')
                            end
                        end
                        if IsControlJustPressed(2, 0x24978A28) then
                            TaskGoToEntity(horseEntity, ped, -1, 7.2, 2.0, 0, 0)
                        end
                    else
                        horseEntity = nil
                    end
                else
                    horseEntity = nil
                end
            else
                if IsControlJustPressed(2, 0x24978A28) then -- Segurar H
                    if horseModel and horseName then
                        if horseEntity == nil then
                            cAPI.spawnHorse()
                            TaskGoToEntity(horseEntity, PlayerPedId(), -1, 7.2, 2.0, 0, 0)
                        else
                            TaskGoToEntity(horseEntity, PlayerPedId(), -1, 7.2, 2.0, 0, 0)
                        end
                    else
                        -- print('Cavalo invalido! Relogue')
                    end
                end
            end
        end
    end
)

AddEventHandler(
    'onResourceStop',
    function(resourceName)
        if GetCurrentResourceName() ~= resourceName then
            return
        end

        if horsePrompt ~= nil then
        end
    end
)


local trunkWeight            = 0
local maxTrunkWeight         = 0

RegisterNetEvent("tp-base:openTrunkInventory")
AddEventHandler("tp-base:openTrunkInventory", function (plate, classWeight)
    maxTrunkWeight = classWeight

	ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(data)

        loadPlayerInventory(nil, "secondInventory")
        loadOtherInventory(data, plate)

        isInInventory = true

        uiType = "enable_second_inventory"
        EnableGui(true, uiType)

    end, plate)

end)

function loadOtherInventory(_data, plate)
    local data      = _data

    trunkWeight       = 0

    items           = {}
    money           = data.money
    black_money     = data.black_money
    inventory       = data.inventory
    weapons         = data.weapons

    DisableControlAction(0, 57)

    if money ~= nil and money > 0 then

        local moneyWeight =  (Config.TrunkMoneyWeight * money) / 1000
        trunkWeight         = trunkWeight + moneyWeight

        moneyData = {
            label = "Cash",
            name = "cash",
            type = "item_money",
            count = money,
            usable = false,
            rare = false,
            limit = -1,
            canRemove = true
        }

        table.insert(items, moneyData)
    end

    if black_money > 0 then

        local blackMoneyWeight =  (Config.TrunkBlackMoneyWeight * black_money) / 1000
        trunkWeight              = trunkWeight + blackMoneyWeight

        blackMoneyData = {
            label = "Black Money",
            name = "black_money",
            type = "item_black_money",
            count = black_money,
            usable = false,
            rare = false,
            limit = -1,
            canRemove = true
        }

        table.insert(items, blackMoneyData)
    end

    if inventory ~= nil then
        for key, value in pairs(inventory) do

            if value.count > 0 then

                trunkWeight = trunkWeight + (value.weight * value.count)
                inventory[key].type = "item_standard"
                table.insert(items, inventory[key])

            end
        end
    end


    if weapons ~= nil then
        for key, value in pairs(weapons) do

            if weapons[key].count > 0 then

                if weapons[key].label ~= "NOT_AVAILABLE" then

                    local playerPed    = PlayerPedId()
                    local weaponHash   = GetHashKey(weapons[key].name)

                    local weaponsCount = weapons[key].count
                    local weaponLabel  = weapons[key].label

                    trunkWeight = trunkWeight + (value.weight * weapons[key].count)
    
                    if Config.WeaponLabelNames[weapons[key].name] then
                        weaponLabel = Config.WeaponLabelNames[weapons[key].name]
                    end
    
                    table.insert(
                        items,
                        {
                            label = weaponLabel,
                            count = weaponsCount,
                            limit = -1,
                            type = "item_weapon",
                            name = weapons[key].name,
                            usable = false,
                            rare = false,
                            canRemove = true
                        }
                    )
                end
            end
        end
    end

    if round(trunkWeight, 4) == 99.9999 then trunkWeight = 100 end

    SendNUIMessage({action = "setSecondInventoryInformation", plate = plate, weight = round(trunkWeight, 2), maxWeight = maxTrunkWeight})

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = items
        }
    )

end

RegisterNUICallback("TakeFromTrunk", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        local count = tonumber(data.number)

        if data.item and data.item.type == "item_weapon" then
            count = 1
        end

        if data.item then
            -- Put Into Player Inventory From Trunk.

            TriggerServerEvent("tp-base:TakeFromTrunk", data.plate, trunkWeight, data.item.type, data.item.name, count, data.item.count)

            Wait(250)
            ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(trunkInventoryData)

                loadPlayerInventory(nil, "secondInventory")
                loadOtherInventory(trunkInventoryData, data.plate)

                TriggerServerEvent("tp-base:requestTrunkInventoryUpdate", data.plate)
        
            end, data.plate)
        end
    end
    
end)


RegisterNUICallback("PutIntoTrunk", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        local count = tonumber(data.number)

        if data.item and data.item.type == "item_weapon" then
            count = 1
        end

        if data.item then

            -- Put Into Trunk From Player Inventory.
            TriggerServerEvent("tp-base:PutIntoTrunk", data.plate, trunkWeight, data.item.type, data.item.name, count, data.item.count)

            Wait(250)
            ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(trunkInventoryData)

                loadPlayerInventory(nil, "secondInventory")
                loadOtherInventory(trunkInventoryData, data.plate)

                TriggerServerEvent("tp-base:requestTrunkInventoryUpdate", data.plate)
   
            end, data.plate)

        end
    end
    
end)


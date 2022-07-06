
local trunkWeight            = 0
local maxTrunkWeight         = 0
local currentPlate           = nil

function openTrunkInventory(plate, classWeight)
    maxTrunkWeight = classWeight

    currentPlate   = nil
    currentPlate   = plate

	ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(data)

        loadPlayerInventory(nil, "secondInventory")
        loadTrunkInventory(data)

        isInInventory = true

        uiType = "enable_second_inventory"
        EnableGui(true, uiType)

    end, plate)
end

function loadTrunkInventory(_data)
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

    SendNUIMessage({action = "setSecondInventoryInformation", inventoryType = "trunk", plate = currentPlate, hasWeight = true, weight = round(trunkWeight, 2), maxWeight = maxTrunkWeight})

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = items
        }
    )

end


function takeFromTrunkInventory(data, count)

    if data.plate ~= nil then

        TriggerServerEvent("tp-base:TakeFromSecondInventory", "trunk", data.plate, trunkWeight, data.item.type, data.item.name, count, data.item.count)

        Wait(250)
        ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(trunkInventoryData)
    
            loadPlayerInventory(nil, "secondInventory")
            loadTrunkInventory(trunkInventoryData, data.plate)
    
            TriggerServerEvent("tp-base:requestTrunkInventoryUpdate", data.plate)
    
        end, data.plate)

    end

end

function putIntoTrunkInventory(data, count)

    if data.plate ~= nil then

        TriggerServerEvent("tp-base:PutIntoSecondInventory", "trunk", data.plate, trunkWeight, data.item.type, data.item.name, count, data.item.count)

        Wait(250)
        ESX.TriggerServerCallback("tp-base:getTrunkInventory", function(trunkInventoryData)
    
            loadPlayerInventory(nil, "secondInventory")
            loadTrunkInventory(trunkInventoryData, data.plate)
    
            TriggerServerEvent("tp-base:requestTrunkInventoryUpdate", data.plate)
    
        end, data.plate)
    end

end


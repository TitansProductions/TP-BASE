
RegisterNetEvent('tp-base:openSecondInventory')
AddEventHandler('tp-base:openSecondInventory', function(secondInventoryType, secondInventoryData, secondInventoryHeader, secondInventoryHasTargetSource, secondInventoryTargetSource)

    loadPlayerInventory(nil, "secondInventory")
    loadSecondInventory(secondInventoryType, secondInventoryData, secondInventoryHeader, secondInventoryHasTargetSource, secondInventoryTargetSource)

    uiType = "enable_second_inventory"
    EnableGui(true, uiType)

end)


RegisterNetEvent('tp-base:refreshSecondInventory')
AddEventHandler('tp-base:refreshSecondInventory', function(secondInventoryType, secondInventoryData, secondInventoryHeader, secondInventoryHasTargetSource, secondInventoryTargetSource)

    loadPlayerInventory(nil, "secondInventory")
    loadSecondInventory(secondInventoryType, secondInventoryData, secondInventoryHeader, secondInventoryHasTargetSource, secondInventoryTargetSource)

end)

function loadSecondInventory(secondInventoryType, secondInventoryData, secondInventoryHeader, secondInventoryHasTargetSource, secondInventoryTargetSource)

    SendNUIMessage(
        {
            action = "setSecondInventoryInformation", 
            
            inventoryType = secondInventoryType, 
            header = secondInventoryHeader,
            hasTargetSource = secondInventoryHasTargetSource,
            targetSource = secondInventoryTargetSource,
        }
    )

    SendNUIMessage(
        {
            action = "setSecondInventoryItems",
            itemList = secondInventoryData
        }
    )

end


RegisterNUICallback("TakeFromSecondInventory", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        local count = tonumber(data.number)

        if data.item and data.item.type == "item_weapon" then
            count = 1
        end

        if data.item then

            -- if second inventory type is trunk, take from trunk inventory.
            if data.inventoryType == "trunk" then
                takeFromTrunkInventory(data, count)
            else

                TriggerServerEvent("tp-base:TakeFromSecondInventory", data.inventoryType, data.hasTargetSource, data.targetSource, data.item.type, data.item.name, count, data.item.count)
                -- event to call when an inventory type is not trunk in order to refresh.
            end


        end
    end
    
end)


RegisterNUICallback("PutIntoSecondInventory", function(data, cb)
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        local count = tonumber(data.number)

        if data.item and data.item.type == "item_weapon" then
            count = 1
        end

        if data.item then

            -- if second inventory type is trunk, put into trunk inventory.
            if data.inventoryType == "trunk" then
                putIntoTrunkInventory(data, count)
            else
                -- event to call when an inventory type is not trunk in order to refresh.
                TriggerServerEvent("tp-base:PutIntoSecondInventory", data.inventoryType, data.hasTargetSource, data.targetSource, data.item.type, data.item.name, count, data.item.count)
            end

        end
    end
    
end)
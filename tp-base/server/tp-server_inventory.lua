ESX = nil

ServerItems, itemShopList = {}, {}

local arrayWeight = Config.localWeight

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


-- Return the sum of all item in pPlayer inventory
function getInventoryWeight(pPlayer)
    local weight = 0
	local itemWeight = 0
  
	if #pPlayer.inventory > 0 then
		for i=1, #pPlayer.inventory, 1 do
		  if pPlayer.inventory[i] ~= nil then
			itemWeight = Config.DefaultWeight
			if arrayWeight[pPlayer.inventory[i].name] ~= nil then
			  itemWeight = arrayWeight[pPlayer.inventory[i].name]
			end
			weight = weight + (itemWeight * pPlayer.inventory[i].count)
		  end
		end
	end
  
	return weight
end

RegisterServerEvent('tp-base:FUpdate')
AddEventHandler('tp-base:FUpdate', function(xPlayer)
    local source_ = source
    local weight = getInventoryWeight(xPlayer)
    TriggerClientEvent('tp-base:change',source_,weight)
end)
  
  
RegisterServerEvent('tp-base:Update')
AddEventHandler('tp-base:Update', function(source)
    local source_ = source
    local xPlayer = ESX.GetPlayerFromId(source_)
    local weight = getInventoryWeight(xPlayer)
    TriggerClientEvent('tp-base:change',source_,weight)
end)

RegisterServerEvent('esx:onAddInventoryItem')
AddEventHandler('esx:onAddInventoryItem', function(source, item, count)
    local source_ = source
    local xPlayer = ESX.GetPlayerFromId(source_)
    local currentInventoryWeight = getInventoryWeight(xPlayer)
    TriggerEvent('tp-base:Update',source_)
    if currentInventoryWeight > Config.Limit then
        local xPlayer = ESX.GetPlayerFromId(source_)
        local itemWeight = Config.DefaultWeight
  
        if arrayWeight[item.name] then
            itemWeight = arrayWeight[item.name]
        end

        local qty = 0
        local weightTooMuch = 0

        weightTooMuch = currentInventoryWeight - Config.Limit
        qty = math.floor(weightTooMuch / itemWeight) + 1

    
        if qty > count then
          qty = count
        end

        ESX.CreatePickup('item_standard', item.name, qty, item.label..'['..qty..']', source_)

        xPlayer.removeInventoryItem(item.name, qty)
        TriggerEvent('tp-base:Update',source_)
    end
end)


ESX.RegisterServerCallback("tp-base:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
    cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), black_money = targetXPlayer.getAccount('black_money').money, weapons = targetXPlayer.loadout})
	else
		cb(nil)
	end
end)

ESX = nil

local trunkData      = {}

TriggerEvent("esx:getSharedObject",function(obj) ESX = obj end)

-- Clearing trunk inventories data on resource stop.
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

	for k, v in pairs(trunkData) do
		if v then
			trunkData[k] = nil
		end
    end

end)


-- Generating trunk inventories on resource start.
AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

    Wait(1000)
	local spawnedTrunkInventories        = 0

	local trunkResults                   = MySQL.Sync.fetchAll('SELECT * FROM base_trunk_inventories')
	local itemResult, weaponResult       = MySQL.Sync.fetchAll('SELECT * FROM items'), ESX.GetWeaponList()

	for i=1, #trunkResults, 1 do

		local itemElements, weaponElements   = {}, {}
		local trunk                          = trunkResults[i]

		for i=1, #itemResult, 1 do
			local _weight = Config.TrunkLocalWeight[itemResult[i].name]
	
			if _weight == nil then
				_weight = Config.DefaultWeight
			end
	
			table.insert(itemElements, {
				name = itemResult[i].name, 
				label = itemResult[i].label, 
				weight = _weight, 
				count = 0
			})
		end
	
		for i=1, #weaponResult, 1 do
			local _weight = Config.TrunkLocalWeight[weaponResult[i].name]
	
			if _weight == nil then
				_weight = Config.DefaultWeaponWeight
			end
	
			table.insert(weaponElements, {
				name = weaponResult[i].name, 
				label = "NOT_AVAILABLE", 
				realLabel = weaponResult[i].label, 
				weight = _weight, 
				count = 1
			})
		end
		
		-- Loading all items & weapons from trunk inventory after loading all items & weapons by the system.
		local inventory, weapons = json.decode(trunk.inventory), json.decode(trunk.weapons)

		for i=1, #itemElements, 1 do
			for key, value in pairs(inventory) do

				if itemElements[i].name == value.name then
					itemElements[i].count = value.count
				end
			end
		end

		for i=1, #weaponElements, 1 do
			for key, value in pairs(weapons) do
				if weaponElements[i].name == value.name then
					weaponElements[i].count = value.count
					weaponElements[i].label = weaponElements[i].realLabel
				end
			end
		end

		trunkData[trunk.plate] = {plate = trunk.plate, inventory = itemElements, weapons = weaponElements, money = trunk.money, black_money = trunk.black_money, owned = trunk.owned}

		spawnedTrunkInventories = spawnedTrunkInventories + 1

    end

	Citizen.Wait(5000)
	print("Successfully loaded (" .. spawnedTrunkInventories .. ") trunk inventories.")

end)

-- ## Trunk Inventory Events

RegisterServerEvent("tp-base:requestTrunkInventoryUpdate")
AddEventHandler("tp-base:requestTrunkInventoryUpdate", function(plate)
    local data = trunkData[plate]

	local itemResult, weaponResult = {}, {}

	for i=1, #data.inventory, 1 do

		if data.inventory[i].count >= 1 then
			table.insert(itemResult, {
				name = data.inventory[i].name, 
				label = data.inventory[i].label, 
				count = data.inventory[i].count
			})
		end
    end
	
	for i=1, #data.weapons, 1 do

		if data.weapons[i].label ~= "NOT_AVAILABLE" then
			table.insert(weaponResult, {
				name = data.weapons[i].name, 
				label = data.weapons[i].label, 
				realLabel = data.weapons[i].realLabel, 
				count = data.weapons[i].count
			})
		end
    end

	MySQL.Sync.execute('UPDATE base_trunk_inventories SET inventory = @inventory, weapons = @weapons, money = @money, black_money = @black_money WHERE plate = @plate', {
		["plate"]         = plate,
		["inventory"]     = json.encode(itemResult),
		["weapons"]       = json.encode(weaponResult),
		["money"]         = data.money,
		["black_money"]   = data.black_money,
	}) 
end)

RegisterServerEvent("tp-base:PutIntoTrunk")
AddEventHandler("tp-base:PutIntoTrunk", function(plate, trunkWeight, type, itemName, itemCount, clickedItemCount)
	local _source = source

	if trunkWeight >= Config.TrunkLimit then
		TriggerClientEvent('tp-base:sendNotification', _source, Locales['weight_warning'], "error")
		return
	end

	local targetXPlayer = ESX.GetPlayerFromId(_source)

	if type == "item_standard" then

		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and clickedItemCount >= itemCount then

			local _weight = Config.TrunkLocalWeight[itemName]

			if _weight == nil then
				_weight = Config.TrunkDefaultWeight
			end

			if trunkWeight + (_weight * itemCount) > Config.TrunkLimit then
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['weight_warning'], "error")
				return
			end

			targetXPlayer.removeInventoryItem(itemName, itemCount)

			local inventory = trunkData[plate].inventory

			for key, value in pairs(inventory) do
				if value.name == itemName then
					value.count = value.count + itemCount
				end
			end

		else

			TriggerClientEvent('tp-base:sendNotification', _source, Locales['amount_warning'], "error")
		end

	elseif type == "item_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			local moneyWeight =  (Config.TrunkMoneyWeight * itemCount) / 1000

			if (trunkWeight + moneyWeight) > Config.TrunkLimit then
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['weight_warning'], "error")
				return
			end

			targetXPlayer.removeMoney(itemCount)

			trunkData[plate].money = trunkData[plate].money + itemCount

		else
			TriggerClientEvent('tp-base:sendNotification', _source, Locales['amount_warning'], "error")
		end
	elseif type == "item_black_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			local blackMoneyWeight =  (Config.TrunkBlackMoneyWeight * itemCount) / 1000

			if (trunkWeight + blackMoneyWeight) > Config.TrunkLimit then
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['weight_warning'], "error")
				return
			end

			targetXPlayer.removeAccountMoney("black_money", itemCount)

			trunkData[plate].black_money = trunkData[plate].black_money + itemCount
		else
			TriggerClientEvent('tp-base:sendNotification', _source, Locales['amount_warning'], "error")
		end

	elseif type == "item_weapon" then

		local inventory = trunkData[plate].weapons

		for key, value in pairs(inventory) do

			if value.name == itemName then

				local _weight = Config.TrunkLocalWeight[itemName]

				if _weight == nil then
					_weight = Config.TrunkDefaultWeaponWeight
				end
	
				if trunkWeight + (_weight * 1) > Config.TrunkLimit then
					TriggerClientEvent('tp-base:sendNotification', _source, Locales['weight_warning'], "error")
					return
				end

				targetXPlayer.removeWeapon(itemName)

				if value.label == "NOT_AVAILABLE" then
					value.label = value.realLabel
				else
					value.count = value.count + 1
				end
				
			end
		end

	end
end)

RegisterServerEvent("tp-base:TakeFromTrunk")
AddEventHandler("tp-base:TakeFromTrunk", function(plate, trunkWeight, type, itemName, itemCount, clickedItemCount)
	local _source = source

	local targetXPlayer = ESX.GetPlayerFromId(_source)

	if type == "item_standard" then

		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addInventoryItem(itemName, itemCount)

			local inventory = trunkData[plate].inventory

			for key, value in pairs(inventory) do
				if value.name == itemName then
					value.count = value.count - itemCount
				end
			end

		else

			TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
		end

	elseif type == "item_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addMoney(itemCount)

			trunkData[plate].money = trunkData[plate].money - itemCount
		else
			TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")

		end
	elseif type == "item_black_money" then
		if itemCount > 0 and clickedItemCount >= itemCount then

			targetXPlayer.addAccountMoney("black_money", itemCount)

			trunkData[plate].black_money = trunkData[plate].black_money - itemCount
		else
			TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
		end
	elseif type == "item_weapon" then
		if not targetXPlayer.hasWeapon(itemName) then

			targetXPlayer.addWeapon(itemName, itemCount)

			local inventory = trunkData[plate].weapons

			for key, value in pairs(inventory) do

				if value.name == itemName then

					if (value.count - 1) <= 0 then
						value.count = 1
						value.label = "NOT_AVAILABLE"
					else
						value.count = value.count - 1
					end
					
				end
			end

		else
			TriggerClientEvent('tp-base:sendNotification', _source, Locales['already_carrying'], "error")
		end
	end
end)

-- ## Callbacks
ESX.RegisterServerCallback("tp-base:getTrunkInventory", function(source, cb, plate)

    local _plate   = plate
	local _source  = source
    local xPlayer  = ESX.GetPlayerFromId(source)

    if xPlayer then

        -- Inserting to SQL the new trunk if doesnt exist.

        local itemResult, weaponResult       = MySQL.Sync.fetchAll('SELECT * FROM items'), ESX.GetWeaponList()
        local trunkResults                   = MySQL.Sync.fetchAll("SELECT * FROM base_trunk_inventories WHERE plate = @plate", {["@plate"] = _plate})

        if #trunkResults == 0 then

            print("does not exist, creating..")
    
            MySQL.Async.execute('INSERT INTO base_trunk_inventories (plate, owned) VALUES (@plate, @owned)',
            {
                ['@plate']            = _plate,
                ['@owned']            = 1,
            })

            local itemResult, weaponResult       = MySQL.Sync.fetchAll('SELECT * FROM items'), ESX.GetWeaponList()
            local itemElements, weaponElements   = {}, {}
        
            for i=1, #itemResult, 1 do
                local _weight = Config.TrunkLocalWeight[itemResult[i].name]
        
                if _weight == nil then
                    _weight = Config.DefaultWeight
                end
        
                table.insert(itemElements, {
                    name = itemResult[i].name, 
                    label = itemResult[i].label, 
                    weight = _weight, 
                    count = 0
                })
            end
        
            for i=1, #weaponResult, 1 do
                local _weight = Config.TrunkLocalWeight[weaponResult[i].name]
        
                if _weight == nil then
                    _weight = Config.DefaultWeaponWeight
                end
        
                table.insert(weaponElements, {
                    name = weaponResult[i].name, 
                    label = "NOT_AVAILABLE", 
                    realLabel = weaponResult[i].label, 
                    weight = _weight, 
                    count = 1
                })
            end
        
            local data = {plate = _plate, inventory = itemElements, weapons = weaponElements, money = 0, black_money = 0, owned = 1}
            trunkData[_plate] = data
        
            cb(data)
        else
            cb(trunkData[_plate])
        end
    end

end)

ESX.RegisterServerCallback("tp-base:fetchAvailableTrunksData", function(source, cb, plate)
	cb(trunkData)
end)
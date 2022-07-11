local Keys = {
	["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["["] = 39, ["]"] = 40,
	["CAPS"] = 137, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["Z"] = 20, ["X"] = 73, ["B"] = 29, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local durability = {}
local dumpsters = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951}

local inventory, money, weapons
local canUseShortcuts, canGive, isInInventory = true, true, false
local poid		 = 0

AddEventHandler('esx:onPlayerDeath', function(data)
    SendNUIMessage({
        action = "clearSlots"
    })
end)

RegisterNetEvent('tp-base:clearSlots')
AddEventHandler('tp-base:clearSlots', function()

    SendNUIMessage({
        action = "clearSlots"
    })
end)

RegisterNetEvent('tp-base:canGiveItem')
AddEventHandler('tp-base:canGiveItem',function(result)
    if result then
        canGive = true
    else
        canGive = false
    end
end)

RegisterNetEvent("tp-base:useShortcuts")
AddEventHandler("tp-base:useShortcuts",function(cb)
    canUseShortcuts = cb
end)


RegisterNetEvent("tp-base:change")
AddEventHandler("tp-base:change", function(tpoid)
    poid = tpoid
end)


RegisterNetEvent('tp-base:openBaseUI')
AddEventHandler('tp-base:openBaseUI', function()

	if not isDead then

        uiType = "enable_loading"

        EnableGui(true, uiType)

        loadPlayerInventory()
    
        DisableControlAction(0, 57)
    
        isInInventory = true
    
        Wait(200)
        uiType = "enable_personal_inventory"
        
        EnableGui(true, uiType)
			 
	end
end)

RegisterNUICallback('openPersonalInventory', function()

    uiType = "enable_loading"

    EnableGui(true, uiType)

    loadPlayerInventory()

    DisableControlAction(0, 57)

    isInInventory = true

    Wait(200)
    uiType = "enable_personal_inventory"
    
    EnableGui(true, uiType)
end)

RegisterNUICallback("removeHoldingWeaponOnShortcutClear", function()

    if IsPedArmed(PlayerPedId(), 4) then
        SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
    end
end)


RegisterNUICallback('UseItem', function(data, cb)
	if data.item.type ~= 'item_weapon' then

        if not string.find(data.item.name, "N_REMOVABLE") then
            TriggerServerEvent('esx:useItem', data.item.name)
		
            if shouldCloseInventory(data.item.name) then
                closeBaseUI()
            else
                Citizen.Wait(250)
                loadPlayerInventory()
            end
        else
            TriggerServerEvent('esx:useItem', data.item.name)

            if shouldCloseInventory(data.item.name) then
                closeBaseUI()
            end
        end
	else

		if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey(data.item.name) then

			if IsPedArmed(PlayerPedId(), 4) then
				SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
				Citizen.Wait(1000)
			end

			SetCurrentPedWeapon(PlayerPedId(), GetHashKey(data.item.name), true)
		else
			SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
		end
	end
	
	cb('ok')
end)

RegisterNUICallback("DropItem", function(data, cb)
    local playerPed = PlayerPedId()
    if IsPedSittingInAnyVehicle(playerPed) then
        return
    end

    if type(data.number) == "number" and math.floor(data.number) == data.number then
        TriggerServerEvent("esx:removeInventoryItem", data.item.type, data.item.name, data.number)
    end

    Wait(250)
    loadPlayerInventory()
    PlaySound(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", 0, 0, 1)
    cb("ok")
    RemoveAllPedWeapons(PlayerPedId(), true)
end)

RegisterNUICallback("GiveItem",function(data, cb)

    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayer = false
    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            if GetPlayerServerId(players[i]) == data.player then
                foundPlayer = true 
            end
        end
    end
   if foundPlayer then

        local count = tonumber(data.number)
        local dict = "mp_common"		
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end

        if data.item.type == "item_weapon" then
            count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
        end

       TriggerServerEvent("esx:giveInventoryItem", data.player, data.item.type, data.item.name, count)
        Wait(250)
        loadPlayerInventory()
        local playerPed = GetPlayerPed(-1)
        local coords    = GetEntityCoords(playerPed)
    
        local vehicle = nil
    
        if IsPedInAnyVehicle(playerPed,  false) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
        else
            TaskPlayAnim(GetPlayerPed(-1), dict, "givetake1_a", 8.0, 8.0, -1, 48, 1, false, false, false)
        end
    else
        ESX.ShowNotification('~r~No players nearby.')
    end
    cb("ok")
end)

RegisterNUICallback("GetNearPlayers",function(data, cb)
    
    local playerPed = PlayerPedId()
    local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
    local foundPlayers = false
    local elements = {}

    for i = 1, #players, 1 do
        if players[i] ~= PlayerId() then
            foundPlayers = true

            table.insert(
                elements,
                {
                    label = 'Anonymous',
                    player = GetPlayerServerId(players[i])
                }
            )
        end
    end

    if not foundPlayers then
        ESX.ShowNotification('~r~No players nearby to perform this action.')
    else
        SendNUIMessage(
            {
                action = "nearPlayers",
                foundAny = foundPlayers,
                players = elements,
                item = data.item
            }
        )
    
    end
    
    cb("ok")
end)

RegisterNUICallback("nodrag",function(data, cb)  
    SendNUIMessage({action = "nodrag"})
end)

function loadPlayerInventory(targetSource, inventoryType)

    local isOtherSource = false

    if targetSource == nil then
        targetSource = GetPlayerServerId(PlayerId())
    else
        isOtherSource = true
    end

    ESX.TriggerServerCallback("tp-base:getPlayerInventory",function(data)

            items = {}
            inventory = data.inventory
            money = data.money
            black_money     = data.black_money

            weapons = data.weapons
            DisableControlAction(0, 57)
            
            if money ~= nil and money > 0 then
                moneyData = {
                    label = "Cash",
                    name = "cash",
                    type = "item_money",
		    description = "none",
                    count = money,
                    usable = false,
                    rare = false,
                    limit = -1,
                    canRemove = true
                }

                table.insert(items, moneyData)
            end

            if black_money > 0 then

                blackMoneyData = {
                    label = "Black Money",
                    name = "black_money",
                    type = "item_black_money",
		    description = "none",
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
                    if inventory[key].count <= 0 then
                        inventory[key] = nil
                    else
                        inventory[key].type = "item_standard"
						
                        if Config.ItemDescriptions[inventory[key].name] then
                            local description = Config.ItemDescriptions[inventory[key].name]
                            inventory[key].description = description
                        else
                            inventory[key].description = "none"
                        end
						
                        table.insert(items, inventory[key])
                    end
                end
            end

            if weapons ~= nil then
                for key, value in pairs(weapons) do
                    local weaponHash = GetHashKey(weapons[key].name)
                    local playerPed = PlayerPedId()
                    -- if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
                    if weapons[key].name ~= "WEAPON_UNARMED" then
                        local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

                        local weaponLabel = weapons[key].label

                        if Config.WeaponLabelNames[weapons[key].name] then
                            weaponLabel = Config.WeaponLabelNames[weapons[key].name]
                        end
						
                        local weaponDescription = "none"

                        if Config.ItemDescriptions[weapons[key].name] then
                            weaponDescription = Config.ItemDescriptions[weapons[key].name]
                        end

                        table.insert(
                            items,
                            {
                                label = weaponLabel,
                                count = ammo,
                                limit = -1,
                                type = "item_weapon",
                                name = weapons[key].name,
                                description = weaponDescription,
                                usable = false,
                                rare = false,
                                canRemove = true
                            }
                        )
                    end
                end
            end


           if inventoryType == "secondInventory" then
                SendNUIMessage(
                    {
                        action = "setSecondPlayerInventoryItems",
                        itemList = items
                    }
                )
            else

                SendNUIMessage(
                    {
                        action = "setItems",
                        itemList = items,
                        isTarget = isOtherSource
                    }
                )
            end

        end,
        targetSource
    )
end


Citizen.CreateThread(function()
    while true do
		Wait(0)
		
		DisableControlAction(0, 157, true)	--[1]
		DisableControlAction(0, 158, true)	--[2]
		DisableControlAction(0, 160, true)	--[3]
		DisableControlAction(0, 164, true)	--[4]
		DisableControlAction(0, 165, true)	--[5]
	end
end)


Citizen.CreateThread(function()
    while true do

        if canUseShortcuts then
            if IsDisabledControlJustReleased(0, 157) then
                SendNUIMessage({action = 'shortcut', slot = 0})
            elseif IsDisabledControlJustReleased(0, 158) then
                SendNUIMessage({action = 'shortcut', slot = 1})
            elseif IsDisabledControlJustReleased(0, 160) then
                SendNUIMessage({action = 'shortcut', slot = 2})
            elseif IsDisabledControlJustReleased(0, 164) then
                SendNUIMessage({action = 'shortcut', slot = 3})
            elseif IsDisabledControlJustReleased(0, 165) then
                SendNUIMessage({action = 'shortcut', slot = 4})
            end
        end
		
        Wait(0)
	end
end)

CreateThread(function()
    while isInInventory do
        local playerPed = PlayerPedId()
        
        if IsEntityDead(playerPed) then
            closeBaseUI()
        end
        DisableControlAction(0, 1, true) -- Disable pan
        DisableControlAction(0, 2, true) -- Disable tilt
        DisableControlAction(0, 24, true) -- Attack
        DisableControlAction(0, 257, true) -- Attack 2
        DisableControlAction(0, 25, true) -- Aim
        DisableControlAction(0, 263, true) -- Melee Attack 1
        DisableControlAction(0, Keys["W"], true) -- W
        DisableControlAction(0, Keys["A"], true) -- A
        DisableControlAction(0, 31, true) -- S (fault in Keys table!)
        DisableControlAction(0, 30, true) -- D (fault in Keys table!)

        DisableControlAction(0, Keys["R"], true) -- Reload
        DisableControlAction(0, Keys["SPACE"], true) -- Jump
        DisableControlAction(0, Keys["Q"], true) -- Cover
        DisableControlAction(0, Keys["TAB"], true) -- Select Weapon
        DisableControlAction(0, Keys["F"], true) -- Also 'enter'?

        DisableControlAction(0, Keys["F1"], true) -- Disable phone
        DisableControlAction(0, Keys["F2"], true) -- Inventory
        DisableControlAction(0, Keys["F3"], true) -- Animations
        DisableControlAction(0, Keys["F6"], true) -- Job

        DisableControlAction(0, Keys["V"], true) -- Disable changing view
        DisableControlAction(0, Keys["C"], true) -- Disable looking behind
        DisableControlAction(0, Keys["X"], true) -- Disable clearing animation
        DisableControlAction(2, Keys["P"], true) -- Disable pause screen
       
        DisableControlAction(0, 59, true) -- Disable steering in vehicle
        DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
        DisableControlAction(0, 72, true) -- Disable reversing in vehicle

        DisableControlAction(2, Keys["LEFTCTRL"], true) -- Disable going stealth

        DisableControlAction(0, 47, true) -- Disable weapon
        DisableControlAction(0, 264, true) -- Disable melee
        DisableControlAction(0, 257, true) -- Disable melee
        DisableControlAction(0, 140, true) -- Disable melee
        DisableControlAction(0, 141, true) -- Disable melee
        DisableControlAction(0, 142, true) -- Disable melee
        DisableControlAction(0, 143, true) -- Disable melee
        DisableControlAction(0, 75, true) -- Disable exit vehicle
        DisableControlAction(27, 75, true) -- Disable exit vehicle
        Wait(0)
    end
end)  

function shouldCloseInventory(itemName)
    for index, value in ipairs(Config.CloseUiItems) do
        if value == itemName then
            return true
        end
    end

    return false
end


-- Play animation
function animsAction(ped, animObj) 
    Citizen.CreateThread(function() -- animObj
        if not playAnim then
            local playerPed = ped
            if DoesEntityExist(playerPed) then -- Check if ped exist
                dataAnim = animObj

                -- Play Animation
                RequestAnimDict(dataAnim.lib)
                while not HasAnimDictLoaded(dataAnim.lib) do
                    Citizen.Wait(0)
                end
                if HasAnimDictLoaded(dataAnim.lib) then
                    local flag = 0
                    if dataAnim.loop ~= nil and dataAnim.loop then
                        flag = 1
                    elseif dataAnim.move ~= nil and dataAnim.move then
                        flag = 49
                    end

                    TaskPlayAnim(playerPed, dataAnim.lib, dataAnim.anim, 8.0, -8.0, -1, flag, 0, 0, 0, 0)
                    playAnimation = true
                end

                -- Wait end animation
                while true do
                    Citizen.Wait(0)
                    if not IsEntityPlayingAnim(playerPed, dataAnim.lib, dataAnim.anim, 3) then
                        playAnim = false
                        TriggerEvent('ft_animation:ClFinish')
                        break
                    end
                end
            end -- end ped exist
        end
    end)
end

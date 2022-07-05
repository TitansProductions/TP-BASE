ESX = nil

local idVisable = true
local isScoreboardEnabled = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(2000)

	ESX.TriggerServerCallback('tp-base:getConnectedPlayers', function(connectedPlayers)
		UpdatePlayerTable(connectedPlayers)
	end)

end)

-- #################################################
-- General Events
-- #################################################


RegisterNetEvent('tp-base:updateConnectedPlayers')
AddEventHandler('tp-base:updateConnectedPlayers', function(connectedPlayers)
	UpdatePlayerTable(connectedPlayers)
end)

-- #################################################
-- General NUI Callbacks
-- #################################################

RegisterNUICallback('openOnlinePlayersList', function()

    uiType = "enable_online_users"
    
    EnableGui(true, uiType)

	Wait(2000)
	isScoreboardEnabled = true
end)


RegisterNUICallback('openSelectedPlayerProfile', function(table)

	ESX.TriggerServerCallback("tp-base:fetchUserGroup", function(playerGroup)
		if Config.WhitelistedGroups[playerGroup] then

			isScoreboardEnabled = false

			uiType = "enable_loading"
		
			EnableGui(true, uiType)
		
			ESX.TriggerServerCallback("tp-base:fetchSelectedUserData", function(data)
		
				SendNUIMessage({
					action       = 'addSelectedPlayerInformation',
					avatar_url   = data['avatar_url'],
					steamName    = table.steamName,
					name         = data['firstname'] .. " " .. data['lastname'],
					money        = table.money,
					bank         = table.bank,
					black_money  = table.black_money,
					dc           = table.dc,
					source       = table.source,
				})
		
				loadPlayerInventory(table.source)
		
				Wait(2000)
				uiType = "enable_selected_user_personal_iformation"
				EnableGui(true, uiType)
		
			end, table.identifier)
		else
			ESX.ShowNotification('~r~You do not have sufficient permissions to perform this action.')
		end
	end)

end)

RegisterNUICallback('refreshSelectedCharacterData', function(table)

    ESX.TriggerServerCallback("tp-base:fetchSelectedUserCurrentData", function(data)

        SendNUIMessage({
            action       = 'addSelectedPlayerInformationOnRefresh',
			money        = data.money,
			bank         = data.bank,
			black_money  = data.black_money,
			dc           = data.dc,
			source       = table.source,
        })

    end, table.source)

end)


-- #################################################
-- General Functions
-- #################################################

function setScoreboardEnabledStatus(status)
	isScoreboardEnabled = status
end

function UpdatePlayerTable(connectedPlayers)

	if not isScoreboardEnabled then
		
		SendNUIMessage({
			action = 'clearOnlinePlayers',
		})
	
		local players = 0
	
		local formattedPlayerList, num = {}, 1
		local police, ambulance, taxi, bennys, lscustom = 0, 0, 0, 0, 0
	
		for k,v in pairs(connectedPlayers) do
			players = players + 1
	
			if v.job == 'police' then
				police = police + 1
	
			elseif v.job == 'ambulance' then
				ambulance = ambulance + 1
	
			elseif v.job == 'taxi' then
				taxi = taxi + 1
	
			elseif v.job == 'bennys' then
				bennys = bennys + 1
	
			elseif v.job == 'lscustom' then
				lscustom = lscustom + 1
			end
	
			SendNUIMessage({
				action = 'addOnlinePlayer',
				player_det = v
			})
	
		end
	
		SendNUIMessage({
			action = 'updatePlayerJobs',
			jobs   = {police = police, ambulance = ambulance, taxi = taxi, bennys = bennys, lscustom = lscustom}
		})
	
		SendNUIMessage({
			action = 'addOnlinePlayersInGame',
			onlinePlayers = players
		})	

	end
	
end
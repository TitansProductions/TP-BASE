ESX                          = nil

local isAllowedToClose = false

local guiEnabled, isDead = false, false
local myIdentity = {}

local uiType = 'enableui'

cachedData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	TriggerServerEvent("tp-base:setUserStatistics")
end)


-- #################################################
-- General Events
-- #################################################

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		SetNuiFocus(false,false)
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true

	if guiEnabled then
		EnableGui(false, uiType)
	end
end)

AddEventHandler('hospital:server:SetDeathStatus', function(data)
	isDead = true

	if guiEnabled then
		EnableGui(false, uiType)
	end
end)

-- Supporting Disc-Death Script for player revive.
AddEventHandler('disc-death:onPlayerRevive', function(data)
    isDead = false
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterNetEvent('tp-base:teleportUser')
AddEventHandler('tp-base:teleportUser', function(x, y, z)
	SetEntityCoords(PlayerPedId(), x, y, z)
end)

RegisterNetEvent('tp-base:sendNotification')
AddEventHandler('tp-base:sendNotification', function(text, type)
	sendNotification(text, type)
end)


-- #################################################
-- General Callbacks
-- #################################################

RegisterNUICallback('closeNUI', function()
	EnableGui(false, uiType)
end)

RegisterNUICallback('personalInformation', function()
	openPersonalInformation()
end)

RegisterNUICallback('changeAvatarUrl', function(table)

	TriggerServerEvent("tp-base:changeSelectedAvatarUrl", table.url)
	Wait(500)

	SendNUIMessage({
		action = 'changePlayerAvatar',
		avatar_url = table.url,
	})

end)

RegisterNUICallback('openTicketCreation', function()
	uiType = "enable_ticket"
	EnableGui(true, uiType)
end)

RegisterNUICallback('openTicketsManagement', function()

	ESX.TriggerServerCallback("tp-base:fetchUserGroup", function(playerGroup)
		if Config.WhitelistedGroups[playerGroup] then
			uiType = "enable_loading"

			EnableGui(true, uiType)
		
			SendNUIMessage({
				action = 'clearTickets',
			})
		
			ESX.TriggerServerCallback('tp-base:getReports', function(cb_reports)
		
				for k,v in pairs(cb_reports)do
					SendNUIMessage({
						action = 'addReport',
						reports_det = v,
						reports_id  = k,
					})		
		
				end
		
				Wait(1000)
		
				uiType = "enable_tickets_list"
		
				EnableGui(true, uiType)
			
			end)
		else
			EnableGui(false, uiType)
			Wait(500)

			sendNotification(Locales['no_permission'], "error")
		end
	end)
		
end)

RegisterNUICallback('teleportTo', function(table)
	local _source = table.source

	SendNUIMessage({
		action = 'clearTickets',
	})	
	EnableGui(false, uiType)
	Wait(500)
	
	TriggerServerEvent("tp-base:teleportTo", _source)

end)


RegisterNUICallback('changeStatus', function(table)
	TriggerServerEvent("tp-base:setElementAsSolved", table.reportId)

	refreshTickets()
end)

RegisterNUICallback('submitReport', function(data, cb)
	local reason = ""
	myIdentity = data

	for theData, value in pairs(myIdentity) do

		if theData == "description" then

			if value == "" or value == " " or value == nil or value == "invalid" then
				data.description = "N/A"
			end


		elseif theData == 'reason' then

			if value == " " or value == nil or value == "invalid" or value == "Select A Reason" then
				reason = "~r~Reason / Report type not selected."
				break
			end

		end

	end

	if data.descriptionLength > 298 then
		reason = "~r~Report description is too long."
	end
	
	if reason == "" then

		ESX.TriggerServerCallback("tp-base:fetchUserData", function(userData)

			TriggerServerEvent('tp-base:submitNewReportOrFeedBack', data.reason, data.description, "REPORT")

			for _,id in pairs(GetActivePlayers()) do
	
				local ped = GetPlayerPed(id)
				local ids = GetPlayerServerId(NetworkGetEntityOwner(ped))
		  
				TriggerServerEvent('tp-base:sendAvailableStaffReport', ids)
				EnableGui(false, uiType)
			end
		end)

	else
		sendNotification(reason, "error")
	end

end)

RegisterNUICallback('submitNewSuggestion', function(data, cb)
	if data.description == "" or data.description == " " or data.description_about == "" or data.description_about == " " then
		EnableGui(false, uiType)

		sendNotification(Locales['feedback_error'], "error")

		Wait(1000)

		uiType = "enable_loading"

		EnableGui(true, uiType)
	
		Wait(250)
		uiType = "enable_suggestions_section"
		EnableGui(true, uiType)
		return
	end

	TriggerServerEvent('tp-base:submitNewReportOrFeedBack', data.description_about, data.description, "FEEDBACK")

	EnableGui(false, uiType)
end)

RegisterNUICallback('openSuggestionSection', function()
	uiType = "enable_loading"

	EnableGui(true, uiType)

	Wait(250)
	uiType = "enable_suggestions_section"
	EnableGui(true, uiType)
end)

RegisterNUICallback('openInformationSection', function()
	uiType = "enable_loading"

	EnableGui(true, uiType)

	Wait(250)

	uiType = "enable_info_section"
	EnableGui(true, uiType)
end)

-- #################################################
-- Open Base UI
-- #################################################

RegisterCommand('openbase', function()

	if not isDead then
		TriggerEvent("tp-base:openBaseUI")
	end
end, false)

RegisterKeyMapping('openbase', 'Open Base UI', 'keyboard', Config.OpenKey)

-- #################################################
-- General Functions
-- #################################################

function closeBaseUI()
	EnableGui(false, uiType)
end

function EnableGui(state, ui)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = ui,
		enable = state
	})

	if state == false then
		setScoreboardEnabledStatus(false)
	end

	if ui ~= 'enable_online_users' then
		setScoreboardEnabledStatus(false)
	end

end

function openPersonalInformation()

	uiType = "enable_loading"

	EnableGui(true, uiType)

	ESX.TriggerServerCallback("tp-base:fetchUserData", function(data)
		ESX.TriggerServerCallback("tp-base:fetchSelectedUserCurrentData", function(cdata)

			SendNUIMessage({
				action       = 'addPlayerInformation',
				avatar_url   = data['avatar_url'],
				steamName    = data['name'],
				name         = data['firstname'] .. " " .. data['lastname'],
				money        = cdata.money,
				bank         = cdata.bank,
				black_money  = cdata.black_money,
	
			})
	
			local achievements = {}

			ESX.TriggerServerCallback("tp-base:fetchPlayerAchievements", function(achievement_data)

				for k, v in pairs(achievement_data) do

					achievementData = {
						name = v.achievement,
						title = v.title,
						type = v.type,
						description = v.description,
						image = v.image,
						color = v.color,
					}

					table.insert(achievements, achievementData)
				end

				SendNUIMessage(
                    {
                        action = "addPlayerAchievements",
                        achievementsList = achievements,
						otherSource = false,
                    }
                )
	
			end, nil)

			uiType = "enable_personal_iformation"
			EnableGui(true, uiType)

		end, GetPlayerServerId(PlayerId()) )
	end)
end

function refreshTickets()

	SendNUIMessage({
		action = 'clearTickets',
	})
	
	ESX.TriggerServerCallback('tp-base:getReports', function(cb_reports)

		for k,v in pairs(cb_reports)do
			SendNUIMessage({
				action = 'addReport',
				reports_det = v,
				reports_id  = k,
			})		
		end

		Wait(500)

		uiType = "enable_tickets_list"

		EnableGui(true, uiType)
	
	end)
end

function sendNotification(text, type)
    if Config.NotificationScript == "mythic_notify" then

        if type == nil then
            exports['mythic_notify']:DoHudText('error', text)
        else
            exports['mythic_notify']:DoHudText(type, text)
        end

    elseif Config.NotificationScript == "pnotify" then

        if type == nil then
            exports.pNotify:SendNotification({
                text = text,
                type = "error",
                timeout = 2500,
                layout = "centerLeft",
                queue = "left"
            })
        else
            exports.pNotify:SendNotification({
                text = text,
                type = type,
                timeout = 2500,
                layout = "centerLeft",
                queue = "left"
            })
        end

    elseif Config.NotificationScript == 'okoknotify' then

        if type == nil then
            exports['okokNotify']:Alert('', text, 2500, 'error')
        else
            exports['okokNotify']:Alert('', text, 2500, type)
        end
        
    elseif Config.NotificationScript == "default" then
        
        ESX.ShowNotification(text)

    end

end

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end
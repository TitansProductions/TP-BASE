ESX = nil

CurrentReportsTable, CurrentSolvedReportsTable = {}, {}

local solvedReports   = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('tp-base:setElementAsSolved')
AddEventHandler('tp-base:setElementAsSolved', function(_reportId)

	local selectedReport = CurrentReportsTable[tonumber(_reportId)]

	table.insert(CurrentSolvedReportsTable,{
		source          = selectedReport.source,
		name            = selectedReport.name,
		reason          = selectedReport.reason,
		description     = selectedReport.description,
		currentDateTime = selectedReport.currentDateTime,
		currentState    = "SOLVED",
	})

	CurrentReportsTable[tonumber(_reportId)] = nil
	
	TriggerClientEvent('tp-base:sendNotification', source, Locales['report_set_as_solved'], "success")

	solvedReports = solvedReports + 1
end)

RegisterServerEvent('tp-base:sendAvailableStaffReport') 
AddEventHandler('tp-base:sendAvailableStaffReport', function(online)

	if Config.WhitelistedGroups[getGroup(online)] then

		TriggerClientEvent('chat:addMessage', online, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255,69,0, 0.7); border-radius: 3px;">{0}</div>',
			args = { "[REPORT] - A new report has been submitted. "}
		})

	end

end)


RegisterServerEvent('tp-base:teleportTo')
AddEventHandler('tp-base:teleportTo', function(target_source)
    local _source = source

    if GetPlayerName(target_source) == nil then
		TriggerClientEvent('tp-base:sendNotification', _source, Locales['player_not_online'], "error")
		return
	end

	if Config.WhitelistedGroups[getGroup(_source)] then

		local destPed = GetPlayerPed(target_source)
		local coords = GetEntityCoords(destPed)
	
		TriggerClientEvent('tp-base:teleportUser', _source, coords.x,coords.y, coords.z)

	else
		print("Someone tried to use 'tp-base:teleportTo' event to teleport on a player using an injection cheating software.")
	end

end)


function insertReportsTable(data)
	table.insert(CurrentReportsTable, data)
end

-- load and set users group
function getGroup(source)
	local _source = source
	local player = ESX.GetPlayerFromId(_source)

	if player ~= nil then
        local playerGroup = player.getGroup()

		if playerGroup ~= nil then 
			return playerGroup
		else
			return "user"
		end
	else
		return "user"
	end
end

ESX.RegisterServerCallback('tp-base:getReports', function(source,cb)
	cb(CurrentReportsTable)
end)
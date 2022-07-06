ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local connectedPlayers = {}
local currentLevel = 1

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()

			while true do
				Citizen.Wait(5000)
				AddPlayersToScoreboard()
			end
		end)
	end
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	connectedPlayers[playerId].job = job.name

	TriggerClientEvent('tp-base:updateConnectedPlayers', -1, connectedPlayers)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	connectedPlayers[playerId] = nil

	TriggerClientEvent('tp-base:updateConnectedPlayers', -1, connectedPlayers)
end)

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.source

	connectedPlayers[playerId] = {}

	connectedPlayers[playerId].job = xPlayer.job.name
	connectedPlayers[playerId].ping = GetPlayerPing(playerId)
	connectedPlayers[playerId].steamName = GetPlayerName(xPlayer.source)
	connectedPlayers[playerId].name = Sanitize(xPlayer.getName())
	connectedPlayers[playerId].id = xPlayer.source
	connectedPlayers[playerId].identifier = xPlayer.identifier

	connectedPlayers[playerId].money = xPlayer.getMoney()
	connectedPlayers[playerId].bank = xPlayer.getAccount('bank').money
	connectedPlayers[playerId].black_money = xPlayer.getAccount('black_money').money

	if Config.IncludeDC then
		connectedPlayers[playerId].dc = xPlayer.getAccount('dc').money
	else
		connectedPlayers[playerId].dc = 0
	end

	if update then
		TriggerClientEvent('tp-base:updateConnectedPlayers', -1, connectedPlayers)
	end

end

function AddPlayersToScoreboard()
	local players = ESX.GetPlayers()

	for i=1, #players, 1 do
		local xPlayer = ESX.GetPlayerFromId(players[i])
		AddPlayerToScoreboard(xPlayer, true)
	end

end

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end


ESX.RegisterServerCallback('tp-base:getConnectedPlayers', function(source, cb)
	cb(connectedPlayers)
end)
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('tp-base:submitNewReportOrFeedBack')
AddEventHandler('tp-base:submitNewReportOrFeedBack', function(about, description, type)

    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	time = os.date("*t") 
	local currentDate, currentTime = table.concat({time.day, time.month, "2022"}, "/"), table.concat({time.hour, time.min}, ":")

	if Config.STORE_IN_SQL then
		MySQL.Async.execute('INSERT INTO user_reports_and_feedbacks (identifier, name, about, description, type, dnt) VALUES (@identifier, @name, @about, @description, @type, @dnt)',
		{
			["@identifier"] = xPlayer.identifier, 
			["@name"] = GetPlayerName(_source),
			["@about"] = about,
			["@description"] = description,
            ["@type"] = type,
			["@dnt"] = currentTime .. " " .. currentDate,
	
		},function()
		end)
	end

    if type == "FEEDBACK" then

        if Config.Webhooks['feedback'].useWebhook then
            sendToDiscord(Config.Webhooks['feedback'].url, GetPlayerName(source), "**The referred player submitted a new feedback:** \n\n**About:** ".. about .. "\n\n**Description:**\n\n".. description .. "\n\n**Source ID:**\n\n".. _source)
        end

        TriggerClientEvent('tp-base:sendNotification', _source, Locales['feedback_success'], "success")

    elseif type == "REPORT" then

        insertReportsTable(
            {
                source          = _source,
                name            = GetPlayerName(_source),
                reason          = about,
                description     = description,
                currentDateTime = currentTime .. ' '.. currentDate,
                currentState    = "INPROGRESS",
            }
        )

        if Config.Webhooks['reports'].useWebhook then
            sendToDiscord(Config.Webhooks['reports'].url, GetPlayerName(source), "**The referred player submitted a new report:** \n\n**Reason:** ".. about .. "\n\n**Description:**\n\n".. description .. "\n\n**Source ID:**\n\n".. _source)
        end

        TriggerClientEvent('tp-base:sendNotification', _source, Locales['report_success'], "success")
    end
	

end)


RegisterServerEvent('tp-base:changeSelectedAvatarUrl')
AddEventHandler('tp-base:changeSelectedAvatarUrl', function(url)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        MySQL.Async.execute("UPDATE `users` SET  `avatar_url` = @avatar_url WHERE identifier = @identifier",
        {
            ['@identifier']     = xPlayer.identifier,
            ['@avatar_url']     = url,
      
        },function()
    
        end)
    end
end)


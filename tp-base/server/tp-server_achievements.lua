ESX = nil

playerAchievementData = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('tp-base:addPlayerAchievement')
AddEventHandler('tp-base:addPlayerAchievement', function(targerSource, achievement)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if targerSource ~= nil and targerSource ~= 0 then
        _source = targerSource
        xPlayer = ESX.GetPlayerFromId(_source)
    end
    

    if xPlayer then
        local identifier = xPlayer.identifier

        MySQL.Async.execute('INSERT INTO base_achievements (identifier, name, achievement) VALUES (@identifier, @name, @achievement)',
        {
            ["@identifier"] = identifier, 
            ["@name"] = GetPlayerName(_source),
            ["@achievement"] = achievement,
    
        },function() end)

    end

end)

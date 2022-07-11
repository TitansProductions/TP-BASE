
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- load users achievements.
ESX.RegisterServerCallback("tp-base:fetchPlayerAchievements", function(source, cb, identifier)
    local _source           = source
    local targetIdentifier  = nil

    if identifier ~= nil then
        targetIdentifier    = identifier
    else
        local xPlayer       = ESX.GetPlayerFromId(_source)
        targetIdentifier    = xPlayer.identifier
    end
	
    local achievementResults                 = MySQL.Sync.fetchAll('SELECT * FROM base_achievements')
    local achievementElements                =  {}

    for i=1, #achievementResults, 1 do

        local achievementData                = achievementResults[i]

        if achievementData.identifier == targetIdentifier then

            if Achievements[achievementData.achievement] then
                table.insert(achievementElements, {
                    name        = achievementData.achievement, 
                    title       = Achievements[achievementData.achievement].title, 
                    description = Achievements[achievementData.achievement].description, 
                    type        = Achievements[achievementData.achievement].type,
                    image       = Achievements[achievementData.achievement].image,
                    color       = Achievements.TypeColors[Achievements[achievementData.achievement].type],
                })
            end

        end

    end

    cb(achievementElements)
end)

-- Loading users data
ESX.RegisterServerCallback("tp-base:fetchUserData", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	
    if xPlayer then
        local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier})
        if result[1] ~= nil then 
            local playerStats = result[1]
    
            return {
                cb(playerStats)
            }
        else
            return cb(nil)
        end
    else
        return cb(nil)
    end
end)

-- Loading users data
ESX.RegisterServerCallback("tp-base:fetchSelectedUserData", function(source, cb, identifier)

    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if result[1] ~= nil then 
        local playerStats = result[1]

        return {
            cb(playerStats)
        }
    else
        return cb(nil)
    end
end)


-- Loading users data
ESX.RegisterServerCallback("tp-base:fetchSelectedUserCurrentData", function(source, cb, target_source)

    local xPlayer = ESX.GetPlayerFromId(target_source)

    local data = {}

    if xPlayer then

        data = { 
            money       = xPlayer.getMoney(), 
            bank        = xPlayer.getAccount('bank').money, 
            black_money = xPlayer.getAccount('black_money').money,
        }

        cb(data)
    else
        return cb(nil)
    end
end)

ESX.RegisterServerCallback("tp-base:fetchUserGroup", function(source, cb)
	local player = ESX.GetPlayerFromId(source)
  
	if player then
		local playerGroup = player.getGroup()
  
		if playerGroup then 
			cb(playerGroup)
		else
			cb("user")
		end
	else
		cb("user")
	end
end)
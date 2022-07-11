Config = {}

Config.WhitelistedGroups      = { ['staff'] = true, ['mod'] = true, ['moderator'] = true, ['admin'] = true, ['administrator'] = true, ['superadmin'] = true, ['owner'] = true }

-- ## [SCRIPTS SUPPORTED]: mythic_notify, okoknotify, pnotify, default
Config.NotificationScript     = "default" 

-- Key for opening the Base UI.
Config.OpenKey                = 'F5'

-- Set it to false if you dont want any reports or feedbacks to be stored in sql (`user_reports_and_feedbacks` database table).
Config.STORE_IN_SQL           = true

-- ###########################################################################################
-- DISCORD WEBHOOKING
-- ###########################################################################################

-- Insert your discord server name, example: [MY SERVER]
Config.DISCORD_NAME           = "[MyServer]"

-- Insert your discord logo image, example: https://i.imgur.com/xxxxxx.png
Config.DISCORD_IMAGE          = "https://i.imgur.com/xxxxxxxxxx.png"

-- Insert your discord footer text.
Config.DISCORD_FOOTER         = "© MyServer Support Team"

Config.Webhooks = {
    ['reports']  = {
        useWebhook = true,
        url = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",

    },
    ['feedback'] = {
        useWebhook = true,
        url = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    },
}

-- ###########################################################################################
-- Inventory
-- ###########################################################################################

Config.IncludeCash = true -- Include cash in inventory?
Config.IncludeWeapons = true -- Include weapons in inventory?

Config.CloseUiItems = {
    "water",
    "N_REMOVABLE_RADIO"
}

Config.Limit = 30000
Config.DefaultWeight = 10
Config.userSpeed = false

Config.localWeight = {
    bread = 50,
    water = 50,
}


-- You can change your custom / replacement weapon names in inventory when displayed.
Config.WeaponLabelNames = {

    ['WEAPON_ADVANCEDRIFLE']  = "AUG",
    ['WEAPON_ASSAULTRIFLE']   = "AK47",
    ['WEAPON_COMPACTRIFLE']   = "AKS-74U",
    ['WEAPON_CARBINERIFLE']   = "M4A1",
    ['WEAPON_SPECIALCARBINE'] = "SCAR",
    ['WEAPON_COMBATPDW']      = "UMP .45",
    ['WEAPON_MICROSMG']       = "UZI",
    ['WEAPON_SMG']            = "MP5",

}

Config.ItemDescriptions = {
    ['medikit'] = "A first aid kit is a box, bag or pack that holds supplies used to treat minor injuries including cuts, scrapes, burns, bruises, and sprains. More elaborate first aid kits can also include survival supplies, life-saving emergency supplies or convenience items like bug sting wipes or cold & flu medicines.",
}

-- ###########################################################################################
-- Trunk Inventory
-- ###########################################################################################

Config.OpenTrunkKey = 56

Config.TrunkLimit = 200.0

-- Default weight for an item:
-- weight == 0 : The item do not affect character inventory weight
-- weight > 0 : The item cost place on inventory
-- weight < 0 : The item add place on inventory. Smart people will love it.
Config.TrunkDefaultWeight       = 10

Config.TrunkDefaultWeaponWeight = 3.5
Config.TrunkMoneyWeight         = 0.01
Config.TrunkBlackMoneyWeight    = 0.01

Config.TrunkLocalWeight = {
    bread = 0.5,
    water = 0.5,

    disc_ammo_rifle = 1.0,
    disc_ammo_pistol = 1.0,
    disc_ammo_smg    = 1.0,
    disc_ammo_shotgun = 1.0,

    WEAPON_SMG = 4.5,
}

Config.VehicleLimit = {
    [0] = 100.0, --Compact
    [1] = 100.0, --Sedan
    [2] = 200.0, --SUV
    [3] = 100.0, --Coupes
    [4] = 100.0, --Muscle
    [5] = 100.0, --Sports Classics
    [6] = 100.0, --Sports
    [7] = 100.0, --Super
    [8] = 25.0, --Motorcycles
    [9] = 200.0, --Off-road
    [10] = 100.0, --Industrial
    [11] = 100.0, --Utility
    [12] = 300.0, --Vans
    [13] = 0, --Cycles
    [14] = 1000.0, --Boats
    [15] = 1000.0, --Helicopters
    [16] = 10000.0, --Planes
    [17] = 100.0, --Service
    [18] = 100.0, --Emergency
    [19] = 0, --Military
    [20] = 100.0, --Commercial
    [21] = 0 --Trains
}

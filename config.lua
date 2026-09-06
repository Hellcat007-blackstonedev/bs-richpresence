Config = {}

-- Discord Developer Portal application ID.
Config.DiscordAppId = 'XXXXXXXXXXXXXXXXXXX'

-- Framework handling:
-- "auto"       = use QBCore if qb-core is running, otherwise standalone
-- "qb"         = use QBCore when it is running, otherwise fall back gracefully
-- "standalone" = never use QBCore
Config.Framework = "auto"

-- Server branding.
-- The Discord application name is configured in the Discord Developer Portal.
Config.ServerName = "Your Server Name"
Config.AssetName = "asset key" -- Discord Rich Presence large art asset key
Config.AssetText = ""     -- Leave blank to use Config.ServerName

-- Rich Presence buttons. These are re-published on each presence refresh.
Config.DiscordInvite = "https://discord.gg/INVITE"
Config.ConnectLink = "fivem://connect/SERVERIP:PORT"

-- Presence content.
Config.ShowCharacterName = true
Config.ShowPlayerCount = true
Config.ShowActivity = true
Config.ShowLocation = true

-- QBCore-only information. These are disabled by default because displaying them
-- publicly in Discord may expose information some roleplay servers consider metagaming.
Config.ShowCitizenId = false
Config.ShowJob = false
Config.ShowJobGrade = false

-- Location formatting.
Config.ShowArea = true           -- e.g. Sandy Shores
Config.ShowStreet = true         -- e.g. Panorama Dr
Config.ShowCrossStreet = false   -- e.g. Panorama Dr / Alhambra Dr
Config.LocationSeparator = " • "

-- Activity formatting.
Config.ShowVehicleName = true
Config.ShowPassengerStatus = true

-- Optional population warning. Set to 0 to disable.
-- Example: with 5, a 64-slot server shows "Nearly Full" from 59/64 onward.
Config.NearlyFullSlots = 5
Config.NearlyFullText = "Nearly Full"

-- Separates each major section of the presence line.
Config.Separator = " | "

-- How often the presence text is refreshed, in milliseconds.
-- 15000 keeps movement/activity changes reasonably current without pointlessly
-- hammering natives every frame.
Config.UpdateTime = 15000

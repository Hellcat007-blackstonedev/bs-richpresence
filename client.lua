local QBCore = nil
local serverPlayerCount = 0
local serverMaxPlayers = GetConvarInt('sv_maxclients', 64)

local function trim(value)
    value = tostring(value or '')
    return (value:gsub('^%s*(.-)%s*$', '%1'))
end

local function shouldUseQBCore()
    local framework = string.lower(Config.Framework or 'auto')

    if framework == 'standalone' then
        return false
    end

    return GetResourceState('qb-core') == 'started'
end

local function refreshQBCore()
    if not shouldUseQBCore() then
        QBCore = nil
        return
    end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    QBCore = ok and core or nil
end

local function safeLabel(label)
    if not label or label == '' or label == 'NULL' then
        return nil
    end

    local translated = GetLabelText(label)
    if translated and translated ~= 'NULL' and translated ~= '' then
        return translated
    end

    return label
end

local function getAreaName(coords)
    local zoneCode = GetNameOfZone(coords.x, coords.y, coords.z)
    if not zoneCode or zoneCode == '' then
        return nil
    end

    local area = safeLabel(zoneCode)
    if area and area ~= zoneCode then
        return area
    end

    return zoneCode
end

local function getStreetName(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = streetHash and GetStreetNameFromHashKey(streetHash) or nil
    local crossingName = crossingHash and GetStreetNameFromHashKey(crossingHash) or nil

    if not streetName or streetName == '' then
        return nil
    end

    if Config.ShowCrossStreet and crossingName and crossingName ~= '' and crossingName ~= streetName then
        return streetName .. ' / ' .. crossingName
    end

    return streetName
end

local function getLocation()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local parts = {}

    if Config.ShowArea then
        local area = getAreaName(coords)
        if area then
            parts[#parts + 1] = area
        end
    end

    if Config.ShowStreet then
        local street = getStreetName(coords)
        if street then
            parts[#parts + 1] = street
        end
    end

    if #parts == 0 then
        return 'Unknown Location'
    end

    return table.concat(parts, Config.LocationSeparator or ' • ')
end

local function getPlayerData()
    if not QBCore or not QBCore.Functions then
        return nil
    end

    local ok, playerData = pcall(QBCore.Functions.GetPlayerData)
    if ok then
        return playerData
    end

    return nil
end

local function getDisplayName(playerData)
    if playerData and playerData.charinfo then
        local firstName = playerData.charinfo.firstname or ''
        local lastName = playerData.charinfo.lastname or ''
        local fullName = trim(('%s %s'):format(firstName, lastName))

        if fullName ~= '' then
            return fullName
        end
    end

    return GetPlayerName(PlayerId()) or 'Unknown Player'
end

local function getJobText(playerData)
    if not Config.ShowJob or not playerData or not playerData.job then
        return nil
    end

    local job = playerData.job
    local jobName = trim(job.label or job.name or '')

    if jobName == '' then
        return nil
    end

    if Config.ShowJobGrade and job.grade then
        local gradeName

        if type(job.grade) == 'table' then
            gradeName = job.grade.name or job.grade.label
        end

        gradeName = trim(gradeName or '')
        if gradeName ~= '' then
            return ('💼 %s • %s'):format(jobName, gradeName)
        end
    end

    return ('💼 %s'):format(jobName)
end

local function getVehicleName(vehicle)
    if not vehicle or vehicle == 0 then
        return nil
    end

    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local friendlyName = safeLabel(displayName)

    if friendlyName and friendlyName ~= '' then
        return friendlyName
    end

    return nil
end

local function getActivity()
    local ped = PlayerPedId()

    if IsEntityDead(ped) then
        return '💀 Down'
    end

    if IsPedSwimmingUnderWater(ped) then
        return '🤿 Diving'
    end

    if IsPedSwimming(ped) then
        return '🏊 Swimming'
    end

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleClass = GetVehicleClass(vehicle)
        local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
        local vehicleName = Config.ShowVehicleName and getVehicleName(vehicle) or nil
        local action

        if vehicleClass == 15 then
            action = '🚁 Flying'
        elseif vehicleClass == 16 then
            action = '✈️ Flying'
        elseif vehicleClass == 14 then
            action = '🚤 Boating'
        elseif vehicleClass == 8 then
            action = '🏍️ Riding'
        elseif vehicleClass == 13 then
            action = '🚲 Riding'
        elseif not isDriver and Config.ShowPassengerStatus then
            action = '🚗 Passenger'
        else
            action = '🚗 Driving'
        end

        if vehicleName then
            return ('%s %s'):format(action, vehicleName)
        end

        return action
    end

    if IsPedRunning(ped) or IsPedSprinting(ped) then
        return '🏃 On Foot'
    end

    return '🚶 On Foot'
end

local function getPopulationText()
    local text = ('👥 %s/%s'):format(serverPlayerCount, serverMaxPlayers)
    local threshold = tonumber(Config.NearlyFullSlots) or 0

    if threshold > 0 and serverMaxPlayers > 0 and serverPlayerCount >= math.max(0, serverMaxPlayers - threshold) then
        local warning = trim(Config.NearlyFullText or '')
        if warning ~= '' then
            text = text .. ' • ' .. warning
        end
    end

    return text
end

local function buildPresence()
    local playerData = getPlayerData()
    local parts = {}

    if Config.ShowCharacterName then
        local name = getDisplayName(playerData)

        if Config.ShowCitizenId and playerData and playerData.citizenid then
            parts[#parts + 1] = ('👤 %s [%s]'):format(name, playerData.citizenid)
        else
            parts[#parts + 1] = ('👤 %s'):format(name)
        end
    end

    if Config.ShowPlayerCount then
        parts[#parts + 1] = getPopulationText()
    end

    if Config.ShowActivity then
        parts[#parts + 1] = getActivity()
    end

    if Config.ShowLocation then
        parts[#parts + 1] = ('📍 %s'):format(getLocation())
    end

    local jobText = getJobText(playerData)
    if jobText then
        parts[#parts + 1] = jobText
    end

    return table.concat(parts, Config.Separator or ' | ')
end

RegisterNetEvent('bs-richpresence:updatePlayerCount', function(playerCount, maxPlayers)
    serverPlayerCount = tonumber(playerCount) or serverPlayerCount
    serverMaxPlayers = tonumber(maxPlayers) or serverMaxPlayers
end)

local function updateDiscordButtons()
    local invite = trim(Config.DiscordInvite)
    local connect = trim(Config.ConnectLink)

    if invite ~= '' then
        SetDiscordRichPresenceAction(0, 'Join Discord', invite)
    end

    if connect ~= '' then
        SetDiscordRichPresenceAction(1, 'Connect to Server', connect)
    end
end

CreateThread(function()
    refreshQBCore()

    SetDiscordAppId(Config.DiscordAppId)
    SetDiscordRichPresenceAsset(Config.AssetName)

    local assetText = Config.AssetText
    if not assetText or trim(assetText) == '' then
        assetText = Config.ServerName
    end

    if assetText and trim(assetText) ~= '' then
        SetDiscordRichPresenceAssetText(assetText)
    end

    updateDiscordButtons()

    TriggerServerEvent('bs-richpresence:requestPlayerCount')

    while true do
        -- Auto mode also recovers if qb-core is restarted while the server is live.
        refreshQBCore()
        TriggerServerEvent('bs-richpresence:requestPlayerCount')
        SetRichPresence(buildPresence())
        updateDiscordButtons()
        Wait(math.max(5000, tonumber(Config.UpdateTime) or 15000))
    end
end)

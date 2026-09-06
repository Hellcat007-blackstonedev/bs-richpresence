local function getPlayerCount()
    return #GetPlayers()
end

local function getMaxPlayers()
    return GetConvarInt('sv_maxclients', 64)
end

local function sendPlayerCount(target)
    TriggerClientEvent('bs-richpresence:updatePlayerCount', target, getPlayerCount(), getMaxPlayers())
end

RegisterNetEvent('bs-richpresence:requestPlayerCount', function()
    sendPlayerCount(source)
end)

local function broadcastPlayerCount()
    sendPlayerCount(-1)
end

AddEventHandler('playerJoining', function()
    SetTimeout(1000, broadcastPlayerCount)
end)

AddEventHandler('playerDropped', function()
    SetTimeout(1000, broadcastPlayerCount)
end)

CreateThread(function()
    while true do
        Wait(60000)
        broadcastPlayerCount()
    end
end)

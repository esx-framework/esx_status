local function setPlayerStatus(xPlayer, data)
	data = data and json.decode(data) or {}

	xPlayer.set('status', data)
	ESX.Players[xPlayer.source] = data
	TriggerClientEvent('esx_status:load', xPlayer.source, data)
end

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  	return
	end

	for _, xPlayer in pairs(ESX.Players) do
		MySQL.scalar('SELECT status FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
			setPlayerStatus(xPlayer, result)
		end)
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	MySQL.scalar('SELECT status FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
		setPlayerStatus(xPlayer, result)
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local status = ESX.Players[xPlayer.source]

	MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', { json.encode(status), xPlayer.identifier })
	ESX.Players[xPlayer.source] = nil
end)

AddEventHandler('esx_status:getStatus', function(playerId, statusName, cb)
	local status = ESX.Players[playerId]
	for i = 1, #status do
		if status[i].name == statusName then
			return cb(status[i])
		end
	end
end)

RegisterNetEvent('esx_status:update', function(status)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		xPlayer.set('status', status)	-- save to xPlayer for compatibility
		ESX.Players[xPlayer.source] = status	-- save locally for performance
	end
end)

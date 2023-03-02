local PlayerStatus = {}

function setPlayerStatus(xPlayer, data)
	data = data and json.decode(data) or {}

	xPlayer.set('status', data)
	PlayerStatus[xPlayer.source] = data

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

AddEventHandler('esx:playerDropped', function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if Config.EnableHealth and Config.EnableArmor then
		local Status = PlayerStatus[xPlayer.source]
		local Ped = GetPlayerPed(playerId)

		for name, status in pairs(Status) do 
			if name == 'health' then 
				Status[name] = GetEntityHealth(Ped)
			elseif name == 'armor' then 
				Status[name] = GetPedArmour(Ped)
			end
		end
	end

	MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', { json.encode(Status), xPlayer.identifier })
	PlayerStatus[xPlayer.source] = nil
end)

RegisterServerEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		xPlayer.set('status', status)	-- save to xPlayer for compatibility
		PlayerStatus[xPlayer.source] = status	-- save locally for performance
	end
end)

CreateThread(function()
	while true do
		Wait(10 * 60 * 1000)

		local parameters = {}
		for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
			local status = PlayerStatus[xPlayer.source]
			if status and next(status) then
				parameters[#parameters+1] = {json.encode(status), xPlayer.identifier}
			end
		end

		if #parameters > 0 then
			MySQL.prepare('UPDATE users SET status = ? WHERE identifier = ?', parameters)
		end
	end
end)

function getStatus(playerId, statusName)
	local status = PlayerStatus[playerId]

	return status[statusName]
end

exports("getStatus", getStatus)

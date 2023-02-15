local Status, isPaused = {}, false

function convertStatus()
	local result = {}

	for name, status in pairs(Status) do
		result[name] = status.val
	end

	return result
end

function GetStatusData()
	local data = {}

	for name, status in pairs(Status) do
		data[#data + 1] = {
			name = name,
			val = status.val,
			percent = (status.val / Config.StatusMax) * 100,
			color = status.color,
			visible = status.visible(status)
		}
	end

	return data
end

AddEventHandler('esx_status:registerStatus', function(name, default, color, visible, tickCallback)
	local status = CreateStatus(name, default, color, visible, tickCallback)

	Status[name] = status
end)

AddEventHandler('esx_status:unregisterStatus', function(name)
	Status[name] = nil
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	Status = {}

	if Config.Display then
		SendNUIMessage({
			update = true,
			status = {}
		})
	end
end)

RegisterNetEvent('esx_status:load')
AddEventHandler('esx_status:load', function(newStatus)
	ESX.PlayerLoaded = true

	TriggerEvent('esx_status:loaded')

	for name,value in pairs(newStatus) do 
		Status[name].set(value)
	end

	SetEntityHealth(PlayerPedId(), Status['health'].get())
	SetPedArmour(PlayerPedId(), Status['armor'].get())

	TriggerServerEvent('esx_status:update', convertStatus())

	if Config.Display then TriggerEvent('esx_status:setDisplay', 0.5) end

	CreateThread(function()
		while ESX.PlayerLoaded do
			local data = {}

			for name, status in pairs(Status) do 
				status.onTick()

				data[#data + 1] = {
					name = name,
					val = status.val,
					percent = (status.val / 1000000) * 100,
					color = status.color,
					visible = status.visible(status)
				}
			end

			if Config.Display then 
				SendNUIMessage({
					update = true,
					status = data
				})
			end

			TriggerEvent('esx_status:onTick', data)
			Wait(Config.TickTime)
		end
	end)
end)

RegisterNetEvent('esx_status:loaded')
AddEventHandler('esx_status:loaded', function()
	TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#CFAD0F', function(status)
		return true
	end,
		function(status) status.remove(100)
	end)

	TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1', function(status)
		return true
	end,
		function(status) status.remove(75)
	end)

	TriggerEvent('esx_status:registerStatus', 'health', GetEntityMaxHealth(PlayerPedId()), '#19cf0f', function(status)
		return false
	end,
		function(status) status.remove(0)
	end)

	TriggerEvent('esx_status:registerStatus', 'armor', GetPedArmour(PlayerPedId()), '#0f3fcf', function(status)
		return false
	end,
		function(status) status.remove(0)
	end)

	TriggerEvent('esx_status:registerStatus', 'drunk', 0, '#8F15A5', function(status)
      	if status.val > 0 then
        	return true
      	else
        	return false
      	end
    end, function(status)
      	status.remove(1500)
    end)
end)

RegisterNetEvent('esx_status:set')
AddEventHandler('esx_status:set', function(name, val)
	Status[name].set(val)

	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
	Status[name].add(val)

	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
	Status[name].remove(val)

	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

AddEventHandler('esx_status:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)

-- Pause menu disable hud display
if Config.Display then
	CreateThread(function()
		while true do
			Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				TriggerEvent('esx_status:setDisplay', 0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false 
				TriggerEvent('esx_status:setDisplay', 0.5)
			end
		end
	end)
end

-- Loading screen off event
AddEventHandler('esx:loadingScreenOff', function()
	if not isPaused then
		TriggerEvent('esx_status:setDisplay', 0.3)
	end
end)

-- Update server
CreateThread(function()
	while true do
		Wait(Config.UpdateInterval)

		if ESX.PlayerLoaded then
			TriggerServerEvent('esx_status:update', convertStatus())
		end
	end
end)

function getStatus(statusName)
	return Status[statusName]
end

exports("getStatus", getStatus)

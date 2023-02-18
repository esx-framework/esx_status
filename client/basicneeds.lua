local isAnimated = false
local isDrunk 	 = false
local DrunkLevel = -1

AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
end)

RegisterNetEvent('esx_basicneeds:healPlayer')
AddEventHandler('esx_basicneeds:healPlayer', function()
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)

	SetEntityHealth(ESX.PlayerData.ped, GetEntityMaxHealth(ESX.PlayerData.ped))
end)

AddEventHandler('esx_basicneeds:setDrunk', function()
	isDrunk = true

	CreateThread(function()
		while isDrunk do
			Wait(1000)

			local status = exports["esx_status"]:getStatus('drunk')

			if status.val > 0 then
				local start = true

				if isDrunk then
					start = false
				end

				local level = 0

				if status.val <= 250000 then
					level = 0
				elseif status.val <= 500000 then
					level = 1
				else
					level = 2
				end

				if level ~= DrunkLevel then
					Drunk(level, start)
				end

				isDrunk = true
				DrunkLevel = level
			end

			if status.val == 0 then
				if isDrunk then
					Reality()
				end

				isDrunk = false
				DrunkLevel = -1
			end
		end
	end)
end)

AddEventHandler('esx_status:onTick', function(data)
	local prevHealth = GetEntityHealth(ESX.PlayerData.ped)
	local health     = prevHealth
	
	for k, v in pairs(data) do
		if v.name == 'hunger' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		elseif v.name == 'thirst' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		end
	end
	
	if health ~= prevHealth then SetEntityHealth(ESX.PlayerData.ped, health) end
end)

AddEventHandler('esx_basicneeds:isEating', function(cb)
	cb(isAnimated)
end)

RegisterNetEvent('esx_basicneeds:onUse')
AddEventHandler('esx_basicneeds:onUse', function(type, prop_name)
	if not isAnimated then
		local anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
		isAnimated = true
		if type == 'food' then
			prop_name = prop_name or 'prop_cs_burger_01'
			anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
		elseif type == 'drink' then
			prop_name = prop_name or 'prop_ld_flow_bottle'
			anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
		elseif type == 'drunk' then
			prop_name = prop_name or 'prop_beer_logopen'
			anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
			TriggerEvent('esx_basicneeds:setDrunk')
		end

		CreateThread(function()
			local x,y,z = table.unpack(GetEntityCoords(ESX.PlayerData.ped))
			local prop = CreateObject(joaat(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(ESX.PlayerData.ped, 18905)
			AttachEntityToEntity(prop, ESX.PlayerData.ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict(anim.dict, function()
				TaskPlayAnim(ESX.PlayerData.ped, anim.dict, anim.name, anim.settings[1], anim.settings[2], anim.settings[3], anim.settings[4], anim.settings[5], anim.settings[6], anim.settings[7], anim.settings[8])
				RemoveAnimDict(anim.dict)

				Wait(3000)
				isAnimated = false
				ClearPedSecondaryTask(ESX.PlayerData.ped)
				DeleteObject(prop)
			end)
		end)
	end
end)

function Drunk(level, start)
	CreateThread(function()
	  	if start then
			DoScreenFadeOut(800)
			Wait(1000)
	  	end
  
	  	if level == 0 then
			RequestAnimSet("move_m@drunk@slightlydrunk")
			
			while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
				Wait(0)
			end
	
			SetPedMovementClipset(ESX.PlayerData.ped, "move_m@drunk@slightlydrunk", true)
	  	elseif level == 1 then
  
			RequestAnimSet("move_m@drunk@moderatedrunk")
			
			while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
				Wait(0)
			end

			SetPedMovementClipset(ESX.PlayerData.ped, "move_m@drunk@moderatedrunk", true)
	  	elseif level == 2 then
  
			RequestAnimSet("move_m@drunk@verydrunk")
			
			while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
				Wait(0)
			end
  
			SetPedMovementClipset(ESX.PlayerData.ped, "move_m@drunk@verydrunk", true)
	  	end
  
		SetTimecycleModifier("spectator5")
		SetPedMotionBlur(ESX.PlayerData.ped, true)
		SetPedIsDrunk(ESX.PlayerData.ped, true)
  
	  	if start then
			DoScreenFadeIn(800)
	  	end
	end)
end

function Reality()
	CreateThread(function()
	  	DoScreenFadeOut(800)
	  	Wait(1000)
  
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
		ResetPedMovementClipset(ESX.PlayerData.ped, 0)
		SetPedIsDrunk(ESX.PlayerData.ped, false)
		SetPedMotionBlur(ESX.PlayerData.ped, false)

	  	DoScreenFadeIn(800)
	end)
end
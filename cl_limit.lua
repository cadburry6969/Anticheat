-- ================================================
--         CHEAT ENGINE SPEED HACK
-- ================================================
CreateThread(function()
	while true do
		Wait(30000)
		TriggerServerEvent("AntiCheat:timer")
	end
end)
-- ================================================
--             SPEED HACK
-- ================================================
CreateThread(function()
	while true do
        Wait(500)
        local ped = PlayerPedId()
        local speed = GetEntitySpeed(ped) 
        local inveh = IsPedInAnyVehicle(ped, false)
        local ragdoll = IsPedRagdoll(ped)
        local jumping = IsPedJumping(ped)
        local falling = IsPedFalling(ped)
		if not inveh then
			if not ragdoll then 
				if not falling then 
					if not jumping then 
						if speed > Config.MaxSpeed then 
							TriggerServerEvent('AntiCheat:CustomFlag', "Speed Hack", "Player Speed is More than Limit")						
						end
					end
				end
			end
		end
    end
end)
-- ================================================
--             INVINCIBLE HACK
-- ================================================
CreateThread(function()
	while true do
		Wait(30000)
		local curPed = PlayerPedId()
		local curHealth = GetEntityHealth(curPed)
		local curWait = math.random(10,150)		
		Wait(curWait)
		if GetPlayerInvincible( PlayerId() ) then 
			TriggerServerEvent("AntiCheese:InvincibleFlag", curHealth-2, GetEntityHealth(curPed),curWait )
			SetPlayerInvincible( PlayerId(), false)
		end
	end
end)
-- ================================================
--               PROP SPAWN
-- ================================================
function ReqAndDelete(object, detach)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		while not NetworkHasControlOfEntity(object) do
			Wait(1)
		end
		if detach then
			DetachEntity(object, 0, false)
		end
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
		DeleteEntity(object)
	end
end

CreateThread(function()
	while true do
		Wait(500)
		local ped = PlayerPedId()
		local handle, object = FindFirstObject()
		local finished = false
		repeat
			Wait(1)
			if IsEntityAttached(object) and DoesEntityExist(object) then
				if GetEntityModel(object) == GetHashKey("prop_acc_guitar_01") then
					ReqAndDelete(object, true)
				end
			end
			for i=1,#Config.CageObjs do
				if GetEntityModel(object) == GetHashKey(Config.CageObjs[i]) then
					ReqAndDelete(object, false)
				end
			end
			finished, object = FindNextObject(handle)
		until not finished
		EndFindObject(handle)
	end
end)
-- ================================================
--                JUMP HACK
-- ================================================
CreateThread(function()
	while true do
        Wait(500)
        local ped = PlayerPedId()
        local pedId = PlayerPedId()        
		if IsPedJumping(pedId) then
			local firstCoord = GetEntityCoords(ped)
			while IsPedJumping(pedId) do
				Wait(0)
			end
			local secondCoord = GetEntityCoords(ped)
			local lengthBetweenCoords = GetDistanceBetweenCoords(firstCoord, secondCoord, false)
			if (lengthBetweenCoords > Config.SuperJumpLength) then          
				TriggerServerEvent("AntiCheat:JumpFlag", lengthBetweenCoords)
			end
		end
    end
end)
-- ================================================
--               NIGHT VISION
-- ================================================
CreateThread(function()
    while true do
        Wait(2000)
        local ped = PlayerPedId()        
		if GetUsingnightvision(true) then 
			if not IsPedInAnyHeli(ped) then                    
				TriggerServerEvent('AntiCheat:CustomFlag', "Night Vision", "Using Night Vision without Helicopter")
			end
		end        
    end
end)
-- ================================================
--             THERMAL VISION
-- ================================================
CreateThread(function()
    while true do
        Wait(2000)
        local ped = PlayerPedId()             
		if GetUsingseethrough(true) then 
			if not IsPedInAnyHeli(ped) then                    
				TriggerServerEvent('AntiCheat:CustomFlag', "Thermal Vision", "Using Thermal Vision without Helicopter")
			end
		end        
    end
end)
-- ================================================
--               BLACKLISTING
-- ================================================
--[[ BLACKLISTED WEAPON CHECK ]]--
CreateThread(function()
	while true do
		local sleep = 2000
    for _,theWeapon in ipairs(Config.WeaponBL) do
        if HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1 then
          sleep = 500          
          RemoveWeaponFromPed(PlayerPedId(), GetHashKey(theWeapon))
		  -- You may need to add your inventory remove item trigger here		
      end
    end
      Wait(sleep)
	end
end)

-- [ANTI BLACKLISTED OBJECT HASH]
local objx = {
a1328154590 = true,
a2042668880 = true,
a803874239 = true,
a1708919037 = true,
a206865238 = true,
a2126974554 = true,
a1072941776 = true,
a1234788901 = true,
a1241740398 = true,
a1803116220 = true,
a788747387 = true,
a782665360 = true,
}

-- [ANTI BLACKLISTED OBJECT]
CreateThread(function()
  while true do
    local sleep = 3000
    for obj in EnumerateObjects() do
      local xobj = math.abs(tonumber(GetEntityModel(obj)))   
      if objx["a"..tostring(xobj)] then
        if IsEntityAttachedToEntity(obj, PlayerPedId()) then
          DetachEntity(PlayerPedId(), false, false)
          ClearPedSecondaryTask(PlayerPedId())
          DeleteEntity(obj)
        end
        DeleteEntity(obj)
      end
    end
    Wait(sleep)
  end
end)

-- [OPTIMIZED BLACK LISTED PED HASH]
local pedx = {
 a1581098148 = true,
 a1096929346 = true ,
 a1320879687 = true,
 a1939545845 = true,
 a451459928  = true,
 a1920001264 = true,
 a1286380898 = true,
 a1430544400 = true,
 a356333586  = true,
 a1612950799 = true,
}

-- [OPTIMIZED BLACK LISTED PED]
CreateThread(function()
  while true do
		local sleep = 500
    for ped in EnumeratePeds() do
        local xped = math.abs(tonumber(GetEntityModel(ped)))   
        if pedx["a"..tostring(xped)] then
            if IsPedSittingInAnyVehicle(ped) then
              DeleteEntity(GetVehiclePedIsUsing(ped))
            end
            DeleteEntity(ped)
            ClearPedSecondaryTask(PlayerPedId())
        end
    end
  Wait(sleep)
  end
end)

-- [OPTIMIZED CAR BLACKLIST]
function isCarBlacklisted(model)
	for _, blacklistedCar in pairs(Config.CarsBL) do
		if model == GetHashKey(blacklistedCar) then
			return true
		end
	end

	return false
end
-- [OPTIMIZED CAR BLACKLIST]
CreateThread(function()
	while true do
		Wait(500)
		if IsPedInAnyVehicle(PlayerPedId()) then
			v = GetVehiclePedIsIn(playerPed, false)
		end
		playerPed = PlayerPedId()
		
		if playerPed and v then
			if GetPedInVehicleSeat(v, -1) == playerPed then
				local car = GetVehiclePedIsIn(playerPed, false)
				carModel = GetEntityModel(car)
				carName = GetDisplayNameFromVehicleModel(carModel)
				if isCarBlacklisted(carModel) then
					DeleteVehicle(car)
					TriggerServerEvent('AntiCheat:CarFlag', carModel)
				end
			end
		end
	end
end)

-- [OPTIMIZED CAR PLATE BLACKLIST]
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()     
        local veh = GetVehiclePedIsIn(ped)
        local DriverSeat = GetPedInVehicleSeat(veh, -1)
        local plate = GetVehicleNumberPlateText(veh)
        
		if IsPedInAnyVehicle(ped, true) then
			for _, BlockedPlate in pairs(Config.BlacklistedPlates) do
				if plate == BlockedPlate then
					if DriverSeat == ped then 
						DeleteVehicle(veh)               
						TriggerServerEvent('AntiCheat:CarFlag', veh..'| Plate:'..plate)
					end   
				end
			end
		end
    end
end)

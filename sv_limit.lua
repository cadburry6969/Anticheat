Components = {	
	GodMode = true,
	Speedhack = false,	
	CustomFlag = true,
	Explosions = true,
	CarBlacklist = true,
}

Users = {}
recentExplosions = {}
-- ================================================
--                EVENTS
-- ================================================
RegisterServerEvent("AntiCheat:timer")
AddEventHandler("AntiCheat:timer", function()
	if Users[source] then
		if (os.time() - Users[source]) < 15 and Components.Speedhack then -- prevent the player from doing a good old cheat engine speedhack
			DropPlayer(source, "Speedhacking")
		else
			Users[source] = os.time()
		end
	else
		Users[source] = os.time()
	end
end)

AddEventHandler('playerDropped', function()
	if(Users[source])then
		Users[source] = nil
	end
end)

AddEventHandler("AntiCheat:SetComponentStatus", function(component, state)
	if type(component) == "string" and type(state) == "boolean" then
		Components[component] = state 
	end
end)

AddEventHandler("AntiCheat:ToggleComponent", function(component)
	if type(component) == "string" then
		Components[component] = not Components[component]
	end
end)

AddEventHandler("AntiCheat:SetAllComponents", function(state)
	if type(state) == "boolean" then
		for i,theComponent in pairs(Components) do
			Components[i] = state
		end
	end
end)

RegisterServerEvent('AntiCheat:SendWebhook')
AddEventHandler('AntiCheat:SendWebhook',function(source, title, message, color)
	local src = source	
	local steam = PlayerIdentifier('steam', src)
	local license = PlayerIdentifier('license', src)
	local name = GetPlayerName(src)	
	SendWebhookMessage(""..title.."\n```\n"..name.."\n"..steam.."\n"..license.."\n"..message.."```", color)
end)
-- ================================================
--             EXPLOSION THREAD
-- ================================================
CreateThread(function()
	while true do 
		Wait(2000)
		clientExplosionCount = {}
		for i, expl in ipairs(recentExplosions) do 
			if not clientExplosionCount[expl.sender] then clientExplosionCount[expl.sender] = 0 end
			clientExplosionCount[expl.sender] = clientExplosionCount[expl.sender]+1
			table.remove(recentExplosions,i)
		end 
		recentExplosions = {}
		for c, count in pairs(clientExplosionCount) do 
			if count > 20 then
				TriggerEvent('AntiCheat:SendWebhook', source, "**Explosion Spawner**", "Spawned "..count.." Explosions in <2s. \n", 16007897)									
				TriggerEvent("EasyAdmin:banPlayer", source, "Explosion Spawner.", false, GetPlayerName(source))
			end
		end
	end
end)
-- ================================================
--                FUNCTIONS
-- ================================================
function PlayerIdentifier(type, id)
    local identifiers = {}
    local numIdentifiers = GetNumPlayerIdentifiers(id)
    for a = 0, numIdentifiers do
        table.insert(identifiers, GetPlayerIdentifier(id, a))
    end
    for b = 1, #identifiers do
        if string.find(identifiers[b], type, 1) then
            return identifiers[b]
        end
    end
    return false
end

function SendWebhookMessage(message, color)
	local DCWHB = {
		  {
			  ["color"] = color,
			  ["title"] = "**AntiCheat**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = "Cadburry#7547",
			  },
		  }
	  }
	PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "CAD AntiCheat", embeds = DCWHB, avatar_url = ""}), { ['Content-Type'] = 'application/json' })
end
-- ================================================
--          EVENTS WITH BAN TRIGGER
-- ================================================
CreateThread(function()

	RegisterServerEvent('AntiCheat:CustomFlag')
	AddEventHandler('AntiCheat:CustomFlag', function(reason,extrainfo)
		if Components.CustomFlag and not IsPlayerAceAllowed(source,"command") then			
			if extrainfo == nil then extrainfo = "no extra informations provided" end			
			TriggerEvent('AntiCheat:SendWebhook', source, ""..reason.."", ""..extrainfo.."\n", 16007897)															
			TriggerEvent("EasyAdmin:banPlayer", source, reason, false, GetPlayerName(source))
		end
	end)

	RegisterServerEvent('AntiCheat:JumpFlag')
	AddEventHandler('AntiCheat:JumpFlag', function(jumplength)
		if Components.SuperJump and not IsPlayerAceAllowed(source,"command") then									
			TriggerEvent('AntiCheat:SendWebhook', source, "**SuperJump Hack**", "Jumped "..jumplength.."ms long\n", 16007897)						
			TriggerEvent("EasyAdmin:banPlayer", source, "Super Jump.", false, GetPlayerName(source))
		end
	end)

	RegisterServerEvent('AntiCheese:InvincibleFlag')
	AddEventHandler('AntiCheese:InvincibleFlag', function(oldHealth, newHealth, curWait)
		if Components.GodMode and not IsPlayerAceAllowed(source,"command") then			
			SendWebhookMessage(webhook,"**Health Hack!** \n```\nUser:"..name.."\n"..license.."\n"..steam.."\nRegenerated "..newHealth-oldHealth.."hp ( to reach "..newHealth.."hp ) in "..curWait.."ms! ( PlayerPed was invincible )\n ```")						
			TriggerEvent("EasyAdmin:banPlayer", source, "Invincible Hack.", false, GetPlayerName(source))
		end
	end)

	RegisterServerEvent('AntiCheat:CarFlag')
	AddEventHandler('AntiCheat:CarFlag', function(car)
		if Components.CarBlacklist and not IsPlayerAceAllowed(source,"command") then			
			TriggerEvent('AntiCheat:SendWebhook', source, "**Car Spawning**", "Got Vehicle: "..car.."( Blacklisted )\n", 16007897)			
			TriggerEvent("EasyAdmin:banPlayer", source, "Spawning Blacklisted Cars.", false, GetPlayerName(source))
		end
	end)
		
	AddEventHandler('explosionEvent', function(sender, ev)
		if Components.Explosions and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then -- make sure component is enabled, damage isnt 0 and owner is the sender
			ev.time = os.time()
			table.insert(recentExplosions, {sender = sender, data=ev})
		end
	end)
end)
-- ================================================
--              TEST WEBHOOK
-- ================================================
-- RegisterCommand('testwebhook2',function(source)
-- 	TriggerEvent('AntiCheat:SendWebhook', source, "Test Webhook", "Reason: Testing", 15761536)		
-- end)
ITEM.name = "Adrenaline"
ITEM.uniqueID = "adrenaline"
ITEM.model = Model("models/w_models/weapons/w_eq_adrenaline.mdl")
ITEM.desc = "Used to heal yourself and to restore your stamina."
ITEM.price = 100
ITEM.weight = 1

ITEM.functions = {}
ITEM.functions.Use = {
	menuOnly = true,
	alias = "Use",
	tip = "Heal yourself.",
	icon = "icon16/eye.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			print(client:Health())
			print(client.character:GetVar("stamina"))
			if client:Health() < 100 or client.character:GetVar("stamina") < 100 then
				client:Freeze(true)
				nut.util.Notify("Using Adrenaline...", client)
				timer.Simple(5, function()
					client:SetHealth(math.Clamp(client:Health() + 25, 1, 100))
					client.character:SetVar("stamina", 100)
					nut.util.Notify("You are now healed and can run again.", client)
					client:Freeze(false)
				end)
			else
				nut.util.Notify("You are already fully healed and have full stamina!", client)
				return false
			end
		end
	end,
	shouldDisplay = function( itemTable, data, entity)
		return true
	end
}

ITEM.functions.Apply = {
	menuOnly = true,
	alias = "Heal Target",
	icon = "icon16/heart.png",
	run = function(itemTable, client, data)
		if (SERVER) then
			if client.character:GetVar("faction") != FACTION_EMT then return false end

			local data = {
				start = client:GetShootPos(),
				endpos = client:GetShootPos() + client:GetAimVector() * 72,
				filter = client
			}
			local target = util.TraceLine(data).Entity

			if target:IsValid() and target:IsPlayer() then
				if target:Health() < 100 or target.character:GetVar("stamina") < 100  then
					client:Freeze(true)
					target:Freeze(true)
					nut.util.Notify("Healing target...", client)
					nut.util.Notify("You are being healed...", target)
					timer.Simple(5, function()
						target:SetHealth(math.Clamp(target:Health() + 60, 1, 100))
						target.character:SetVar("stamina", 100)
						nut.util.Notify("The target has been healed.", client)
						nut.util.Notify("You are now healed and can run again.", target)
						if IsValid(client) then
							client:Freeze(false)
						end
						if IsValid(target) then
							target:Freeze(false)
						end
					end)
				else
					nut.util.Notify("The target is already fully healed and have full stamina!", client)
					return false
				end
			else
				return false
			end
		end
	end,
	shouldDisplay = function( itemTable, data, entity)
		local data = {
			start = LocalPlayer():GetShootPos(),
			endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 72,
			filter = LocalPlayer()
		}
		local target = util.TraceLine(data).Entity

		if LocalPlayer().character:GetVar("faction") == FACTION_EMT and target:IsValid() and target:IsPlayer() then
			return true
		else
			return false
		end
	end
}
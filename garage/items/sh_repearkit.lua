ITEM.name = "Repair Kit"
ITEM.model = Model("models/props_c17/tools_wrench01a.mdl")
ITEM.desc = "A repair kit for vehicles. It will restore 20% of the vehicle's health when used."
ITEM.weight = 10
ITEM.functions = {}
ITEM.functions.Use = {
	menuOnly = true,
	alias = "Fix Vehicle",
	icon = "icon16/asterisk_yellow.png",
	run = function(itemTable, client, data)
		if (SERVER) then
			local dat = {
				start = client:GetShootPos(),
				endpos = client:GetShootPos() + client:GetAimVector() * 72,
				filter = client
			}
			local trace = util.TraceLine(dat)
			if trace.Entity:IsValid() then
				if trace.Entity:IsVehicle() then
					if trace.Entity.disabled then
						nut.util.Notify("You cannot repair a disabled vehicle!", client)
						return false
					end

					if client.character:GetData("repairing", false) then
						nut.util.Notify("You are already repairing a vehicle!", client)
						return false
					end

					client.character:SetData("repairing", true, true, true)
					client:Freeze(true)
					nut.util.Notify("Repairing vehicle...", client)

					timer.Simple(15, function()
						if not IsValid(client) or not IsValid(trace.Entity) then return end

						client:Freeze(false)
						client.character:SetData("repairing", false, true, true)
						trace.Entity:SetHealth(math.Clamp(trace.Entity:Health() + 200, 0, 1000))

						if trace.Entity.smoking and trace.Entity:Health() > 250 then
							trace.Entity:StopParticles()
							trace.Entity.smoking = false
						end

						nut.util.Notify("Vehicle repaired!", client)
					end)
				else
					return false
				end
			else
				return false
			end
		end
	end
}
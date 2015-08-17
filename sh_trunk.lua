PLUGIN.name = "Vehicle Trunk"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Your vehicle is now a storage!"

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 84
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		if IsValid(entity) then
			if entity:GetClass() == "prop_vehicle_jeep" then
				if !entity.locked then
					if IsValid(entity.storage) then
						netstream.Start(ply, "nut_Storage", entity.storage)
					end
				else
					nut.util.Notify("Vehicle locked!", ply)
				end
			else
				nut.util.Notify("You must be looking at a vehicle!", ply)
			end
		else
			nut.util.Notify("You must be looking at a vehicle!", ply)
		end
	end
}, "trunk")

if (CLIENT) then
	properties.Add("trunk",{
		MenuLabel	=	"Open Trunk",
		Order		=	3011,
		MenuIcon	=	"icon16/box.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or ent:GetClass() != "prop_vehicle_jeep" then return false end
							if !ent.locked or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/trunk")
						end
	})
end
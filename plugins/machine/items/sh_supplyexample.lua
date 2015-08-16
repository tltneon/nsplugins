ITEM.name = "Canned Food Machine Supply"
ITEM.uniqueID = "ms_example"
ITEM.category = "Machine Supply"
ITEM.model = Model("models/props_junk/cardboard_box003a.mdl")
ITEM.desc = "A supply for a specific machine.\nCan supply a machine by:\nMoving dropped supply to the machine.\nUsing supply in your inventory."
ITEM.functions = {}
ITEM.supplyAmount = 30
ITEM.functions.Supply = {
	tip = "Supply the machine",
	icon = "icon16/weather_sun.png",
	menuOnly = true,
	run = function(itemTable, client, data)
		if (SERVER) then
			local data2 = {
				start = client:GetShootPos(),
				endpos = client:GetShootPos() + client:GetAimVector() * 90,
				filter = client
			}
			local trace = util.TraceLine(data2)
			if trace.Entity:IsValid() then
				if trace.Entity.Supply then
					if trace.Entity.Supply == itemTable.uniqueID then
						if trace.Entity:CanSupply(itemTable.supplyAmount) then
							trace.Entity:AddSupply(itemTable.supplyAmount, true)
							return true
						else
							client:notify("You can't overload the machine.")
							return false
						end
					else
						client:notify("This supply is not for that machine.")
						return false
					end
				end
			end
			client:notify("You have to face the machine.")
			return false
		end
		return false
	end
}
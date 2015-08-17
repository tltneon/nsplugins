ITEM.name = "Pot"
ITEM.uniqueID = "pot"
ITEM.model = Model("models/props_italian/flowerpot_empty01.mdl")
ITEM.desc = "Plants can be grown in it."
ITEM.price = 10
ITEM.weight = 1
ITEM.data = {
	inUse = false
}

ITEM.functions = {}

ITEM.functions.Inspect = {
	entityOnly = true,
	alias = "Inspect",
	tip = "Inspect the plant.",
	icon = "icon16/eye.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local plant = nut.item.Get(data.plant)
			if CurTime() >= data.endTime then
				nut.util.Notify("This pot contains "..plant.name..", it's content is ready for harvest.", client)
			else
				nut.util.Notify("This pot contains "..plant.name..", it's content will be ready for harvest in "..math.Round(data.endTime - CurTime()).." seconds.", client)
			end

			return false
		end
	end,
	shouldDisplay = function( itemTable, data, entity )
		return data.inUse == true
	end
}

ITEM.functions.Destroy = {
	entityOnly = true,
	alias = "Destroy Plant",
	tip = "Destroy the plant and pickup the pot.",
	icon = "icon16/delete.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			client:UpdateInv(itemTable.uniqueID, 1, itemTable.data, true)
			client:EmitSound("player/footsteps/dirt1.wav")
		end
	end,
	shouldDisplay = function( itemTable, data, entity )
		return data.inUse == true
	end
}

ITEM.functions.Harvest = {
	entityOnly = true,
	alias = "Harvest",
	tip = "Harvest the plant.",
	icon = "icon16/arrow_up.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local plant = nut.item.Get(data.plant)
			if CurTime() >= data.endTime then
				local result = client:UpdateInv(data.plant, 1)

				if result then
					local pos, ang = entity:GetPos(), entity:GetAngles()
					local newData = {
						inUse = false
					}

					nut.item.Spawn(pos, ang, itemTable.uniqueID, newData)
					client:EmitSound("player/footsteps/dirt1.wav")
				else
					nut.util.Notify("You do not have enough room in your inventory.", client)
				end

				return result
			end
		end
	end,
	shouldDisplay = function( itemTable, data, entity )
		return data.inUse == true and CurTime() >= data.endTime
	end
}
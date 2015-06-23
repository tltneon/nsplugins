ITEM.name = "Faceplate"
ITEM.partdata = { -- You can use PAC3 to setup the part.
	model = "models/barneyhelmet_faceplate.mdl",
	bone = "ValveBiped.Bip01_Head1",
	position = Vector( 2.22, -2.5, -0 ),
	angle = Angle( 0.518, -90.168, -90.983 ),
	scale = Vector( 1, 1, 1 ),
	size = 1,
}
ITEM.model = Model("models/props_junk/cardboard_box004a.mdl")
ITEM.weight = 1
ITEM.desc = "A Mask that protects you from the bad air area."

ITEM:hook("Equip", function(itemTable, client, data, entity, index)
	if (SERVER) then
		client:ConCommand("say /me grabs mask from the inventory and puts mask on the face.")
		client:EmitSound("items/ammopickup.wav")
	end
end)

ITEM.functions = ITEM.functions or {}

ITEM.functions._CheckFilter = { -- don't ask why I put _ before 'filter'.
	text = "Check Filter",
	menuOnly = true,
	tip = "Toggle this device.",
	icon = "icon16/weather_sun.png",
	onRun = function(item)
		if (SERVER) then
			local filter = item.Filter or 0--data.Filter or 0 -- mod this to change filter time.

			if filter == 0 then
				item.player:notify("The filter is expired.")
			else
				item.player:notify("The filter's health is " .. filter .. "." )
			end
			return false
		end
	end
}

ITEM.functions._Filter = { -- don't ask why I put _ before 'filter'.
	text = "Change Filter",
	menuOnly = true,
	tip = "Toggle this device.",
	icon = "icon16/weather_sun.png",
	onRun = function(item)
		if (SERVER) then
			if item.player:getChar():getInv():hasItem("air_filter") then
				item.Filter = 300
				--local newData = table.Copy(data)

				-- Default Think time : 1 seconds
				-- It survives 300 thinks
				-- 300 * 1 seconds = 300 seconds.
				--newData.Filter = 300 -- mod this to change filter time.

				--item.player:UpdateInv(itemTable.uniqueID, 1, newData, true)
				--item.player:getChar():getInv():remove("air_filter")--UpdateInv("air_filter", -1, {}, true)
				item.player:getChar():getInv():hasItem("air_filter"):remove()

				item.player:EmitSound("HL1/fvox/hiss.wav")
				item.player:notify("You changed the mask's filter.")
				--return true
			else
				item.player:notify("You don't have any filter to change.")
			end
			return false
		end
	end
}
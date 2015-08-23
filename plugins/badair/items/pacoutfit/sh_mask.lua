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
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A Mask that protects you from the bad air area."

ITEM:hook("equip", function(item)
	if (SERVER) then
		local client = item.player
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
			local filter = item:getData("filter") or 0 -- mod this to change filter time.

			if filter == 0 then
				nut.util.Notify("The filter is expired.", client)
			else
				nut.util.Notify("The filter's health is " .. filter .. "." , client)
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
			local client = item.player
			if client:HasItem("filter") then
				local id = client:HasItem("filter"):getID()
				--local newData = table.Copy(data)
				-- Default Think time : 1 seconds
				-- It survives 300 thinks
				-- 300 * 1 seconds = 300 seconds.
				--newData.Filter = 300 -- mod this to change filter time.
				client:UpdateInv(item.uniqueID, 1, {filter = 300}, true)
				client:UpdateInv(id, -1)

				client:EmitSound("HL1/fvox/hiss.wav")
				nut.util.Notify("You changed the mask's filter.", client)
				return true
			else
				nut.util.Notify("You don't have any filter to change.", client)
			end
			return false
		end
	end
}
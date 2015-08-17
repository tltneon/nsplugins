BASE.name = "Base PAC3 Outfit"
BASE.uniqueID = "base_pac3"
BASE.category = "Outfit"
BASE.model = Model( "models/props_c17/BriefCase001a.mdl" )
BASE.desc = "Allows you to get unique identity."
BASE.weight = 0

BASE.outfit = "null"
BASE.part = "e_head"

BASE.functions = {}
BASE.functions.Equip = {
	alias = "Wear",
	tip = "Wear the outfit.",
	icon = "icon16/wand.png",
	run = function(itemTable, client, data, entity)
		if ( SERVER ) then	
		
			
			print( itemTable.part .. " : " .. client:GetNetVar( itemTable.part ) )
			
			if client:GetNetVar( itemTable.part ) != "null" then
				nut.util.Notify("You're already wearing something.", client)
				return false
			end
			
			nut.util.Notify("equipped the outfit.", client)
			client:SetNetVar( itemTable.part, itemTable.outfit )

			local newData = table.Copy(data)
			newData.Equipped = true
			client:UpdateInv(itemTable.uniqueID, 1, newData)
			
			return true
		end
		return false
	end,
	
	shouldDisplay = function(itemTable, data, entity)
		return !data.Equipped or data.Equipped == nil
	end
}
BASE.functions.Unequip = {
	run = function(itemTable, client, data)
		if (SERVER) then
		
			if ( client:GetNetVar( itemTable.part ) != itemTable.outfit ) then
				nut.util.Notify("You're not wearing this.", client)
				return false
			end
			
			nut.util.Notify("unequipped the outfit.", client)
			client:SetNetVar( itemTable.part, "null" )

			local newData = table.Copy(data)
			newData.Equipped = false
			client:UpdateInv(itemTable.uniqueID, 1, newData)

			return true
		end
	end,
	shouldDisplay = function(itemTable, data, entity)
		return data.Equipped == true
	end
}

local size = 16
local border = 4
local distance = size + border
local tick = Material("icon16/tick.png")

function BASE:PaintIcon(w, h)
	if (self.data.Equipped) then
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(w - distance - 1, w - distance - 1, size + 2, size + 2)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(tick)
		surface.DrawTexturedRect(w - distance, w - distance, size, size)
	end
end

function BASE:CanTransfer(client, data)
	if (data.Equipped) then
		nut.util.Notify("You must unequip the item before doing that.", client)
	end

	return !data.Equipped
end

if (SERVER) then
	hook.Add("PlayerSpawn", "nut_Outfits", function(client)
		timer.Simple(0.05, function()
			if (!IsValid(client) or !client.character) then
				return
			end

			for class, items in pairs(client:GetInventory()) do
				local itemTable = nut.item.Get(class)
				if !itemTable then continue end
				if (itemTable.outfit) then
					for k, v in pairs(items) do
						if (v.data.Equipped) then
							client:SetNetVar( itemTable.part, itemTable.outfit )
						end
					end
				end
			end
		end)
	end)
end
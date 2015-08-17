PLUGIN.name = "Plants"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Grow drugs you punk!"

if SERVER then
	function PLUGIN:OnItemTaken( item )
		if item.uniqueID == "pot" then
			if item.itemData.inUse then
				return false
			end
		end
	end

	PLUGIN.maxPots = 10
	function PLUGIN:OnItemDropped( client, itemTable, entity )
		if itemTable.uniqueID == "pot" then
			local pots = client.character:GetData("pots", 0)
			if pots >= self.maxPots then
				nut.util.Notify("You have reached the maximum pot limit!", client)
				entity:Remove()
				client:UpdateInv("pot")
			else
				client.character:SetData("pots", pots + 1, true, true)
			end
		end
	end

	timer.Create("PotsDecrementation", 500, 0, function()
		for _, client in pairs(player.GetAll()) do
			if client.character then
				client.character:SetData("pots", math.Clamp(client.character:GetData("pots", 0) - 1, 0, 1000), true, true)
			end
		end
	end)
end
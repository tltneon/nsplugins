PLUGIN.name = "More Logging"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "If you want to be american NSA, so be it."

if SERVER then
	function PLUGIN:OnItemTransfered( player, entity, itemTable )
		if (player:IsValid() and entity:IsValid() and itemTable) then
			nut.util.AddLog(Format("%s transfered to container by %s", itemTable.uniqueID, player:Name()), LOG_FILTER_ITEM)
		end
	end
	function PLUGIN:OnItemDropped( player, itemTable, entity )
		if (player:IsValid() and itemTable) then
			nut.util.AddLog(Format("%s dropped %s.", player:Name(), itemTable.uniqueID), LOG_FILTER_ITEM)
		end
	end
	function PLUGIN:OnItemTaken( itemTable )
		if (itemTable.player:IsValid() and itemTable) then
			nut.util.AddLog(Format("%s taken %s.", itemTable.player:Name(), itemTable.uniqueID), LOG_FILTER_ITEM)
		end
	end
	function PLUGIN:OnWeaponEquipped( player, itemTable, equip )
		local string = "unequipped"
		if (equip) then 
			string = "equipped"
		end
		nut.util.AddLog(Format("%s %s %s.", itemTable.player:Name(),string,itemTable.uniqueID), LOG_FILTER_ITEM)
	end
	function PLUGIN:OnClothEquipped( player, itemTable, equip )
		local string = "unequipped"
		if (equip) then 
			string = "equipped"
		end
		nut.util.AddLog(Format("%s %s %s.", itemTable.player:Name(),string,itemTable.uniqueID), LOG_FILTER_ITEM)
	end
	function PLUGIN:OnPartEquipped( player, itemTable, equip )
		local string = "unequipped"
		if (equip) then 
			string = "equipped"
		end
		nut.util.AddLog(Format("%s %s %s.", itemTable.player:Name(),string,itemTable.uniqueID), LOG_FILTER_ITEM)
	end
end


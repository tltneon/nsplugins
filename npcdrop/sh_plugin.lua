PLUGIN.name = "NPC Item Drop"
PLUGIN.author = "Halokiller38"
PLUGIN.desc = "This plugin makes it when you kill a zombie it drops a random item from the junk category."

-- If you would like to make it so it drops a different category of items, then change the word junk in (v.category == "junk") then
-- to whatever name of the category you want to have NPCs to drop. If you want it to drop multiple different categories add me and I can help you.
-- Thank you for using my plugin!

function PLUGIN:OnNPCKilled(entity)
	local class = entity:GetClass()
	local items = {}
	
	for k, v in pairs( nut.item.GetAll() ) do
		if (v.category == "Junk") then
			items[k] = v
		end;
	end;
	
	local RandomItem = table.Random(items)
	if (class == "npc_zombie" or class == "npc_zombie_torso" or class == "npc_poisonzombie" or class == "npc_fastzombie" or class == "npc_fastzombie_torso") then
		nut.item.Spawn(entity:GetPos() + Vector(0, 0, 8), nil, RandomItem)
	end
end

local PLUGIN = PLUGIN
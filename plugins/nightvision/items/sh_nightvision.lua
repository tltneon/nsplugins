ITEM.name = "Thermal Vision and Target Finder"
ITEM.partdata = { -- You can use PAC3 to setup the part.
	model = "models/props_combine/combinebutton.mdl",
	bone = "ValveBiped.Bip01_Spine1",
	position = Vector( 0, 0, 0 ),
	angle = Angle( 0, 0, 0 ),
	scale = Vector( 1, 1, 1 ),
	size = 1,
	--material = "",
	--skin = "",
	--bodygroup = ""
}
ITEM.model = Model("models/props_combine/combinebutton.mdl")
ITEM.desc = "Heavy vision augmentation."
ITEM.price = 1000
ITEM.factions = {}

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local client = item.player
		local items = client:getChar():getInv():getItems()
		client.armor = client.armor or {}

		for k, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]
				if (client.armor["head"] and itemTable:getData("equip")) then
				--if (client.armor[item.armorclass] and itemTable:getData("equip")) then
					client:notify("Вы не можете одеть эту экипировку!")
					return false
				end
			end
		end
		client.armor["head"] = item
		item:setData("equip", true)
		client:setNetVar("nvision", true)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item.player.armor = item.player.armor or {}
		item.player.armor["head"] = nil
		item:setData("equip", false)
		item.player:setNetVar("nvision", false)
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}
ITEM:hook("drop", function(item)
	item.player:setNetVar("nvision", false)
	item:setData("equip", false)
end)
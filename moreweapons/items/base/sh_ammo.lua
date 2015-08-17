BASE.name = "Base Ammo"
BASE.uniqueID = "base_ammo"
BASE.category = nut.lang.Get("ammo_cat")
BASE.ammo = "pistol"
BASE.amount = 10
BASE.desc = "A bullet that can be used for the gun."
BASE.weight = 1
BASE.functions = {}
BASE.functions.Load = {
	menuOnly = true,
	alias = "Load",
	tip = "Load the ammo to the magazine.",
	icon = "icon16/wand.png",
	run = function(itemTable, client, data, entity)
		if SERVER then
			nut.util.Notify("Loaded ".. itemTable.amount .. " bullets.", client)
			client:GiveAmmo( itemTable.amount, itemTable.ammo )
		end
		return true
	end
}

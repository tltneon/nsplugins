ITEM.name = "NORAD Anti-Rad Kit"
ITEM.uniqueID = "buff_antirad"
ITEM.model = Model("models/Items/battery.mdl")
--ITEM.desc = "Overwatch Issue De-toxin purpose medical injector."
ITEM.desc = "The NORAD Anti-Rad Kit. It removes 100 radioactive irradiations."
ITEM.usesound = "HL1/fvox/hiss.wav"

ITEM.addbuff = {
	{ "addrad", 1, { amount = -200 } }, -- Removes radioactive irradiation by -200. ( 20% of max radiation. )
}
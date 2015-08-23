PLUGIN.name = "Gas Station"
PLUGIN.author = "_FR_Starfox64 (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "A new way to put gas in your vehicle!"

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Gas Station Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

PLUGIN.price = 2

nut.util.Include("sv_plugin.lua")
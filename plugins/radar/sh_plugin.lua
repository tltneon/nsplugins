PLUGIN.name = "Radar"
PLUGIN.author = "_FR_Starfox64 (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Speed radars, speed radars everywhere!"

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Radar Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

nut.util.Include("sv_plugin.lua")

if CLIENT then
	function PLUGIN:HUDPaint()
		if IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():GetVehicle():GetNWString("Radar", "N/A") != "N/A" then
			draw.SimpleTextOutlined( "Target's Speed: "..LocalPlayer():GetVehicle():GetNWString("Radar", "ERROR"), "7SEG", (ScrW()/2), ScrH() - 25, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
		end
	end
end
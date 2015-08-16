PLUGIN.name = "PlayX"
PLUGIN.author = "_FR_Starfox64 & sk89q (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Integrates PlayX into NutScript"

PLUGIN.screenPos = Vector(-7028, -13586, 348)
PLUGIN.screenAng = Angle(0, -90, 0)

PLUGIN.controllers = {2375, 2376}

nut.util.include("sv_plugin.lua")

nut.flag.add("m", {
	desc = "Allows one to play music at Issies Palace."
})

netstream.Hook("nut_RequestPlayxURL", function()
	Derma_StringRequest("Izzies Palace", "Input a URL that is compatible with PlayX...", "Media URL...", function( url )
		netstream.Start("nut_MediaRequest", url)
	end)
end)
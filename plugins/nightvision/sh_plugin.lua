PLUGIN.name = "NightVision"
PLUGIN.author = "CaptJack92a, Neon (Porting and Rewriting)"
PLUGIN.desc = "Adds a simple wearable item that toggles on a night vision mode."

if CLIENT then
	function PLUGIN:HUDPaint()
		if LocalPlayer():getNetVar("nvision", false) then
			local col = {}
			col["$pp_colour_addr"] = 0.1
			col["$pp_colour_addg"] = 0.15
			col["$pp_colour_addb"] = 0.2
			col["$pp_colour_brightness"] = 0.05
			col["$pp_colour_contrast"] = 0.85
			col["$pp_colour_colour"] = 0.75
			col["$pp_colour_mulr"] = 0
			col["$pp_colour_mulg"] = 0
			col["$pp_colour_mulb"] = 0
			DrawColorModify(col)
			DrawSharpen(1,1)
			surface.SetDrawColor(160,160,160,255)
			local client = LocalPlayer()
			for k, v in pairs(player.GetAll()) do
				if (v != client and v.character and v:GetPos():Distance(client:GetPos()) <= 2000) then
					local position = v:LocalToWorld(v:OBBCenter()):ToScreen()
					local x, y = position.x, position.y
					local mat = Material("models/wireframe")
					surface.SetDrawColor(255, 255, 255, 220)
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(x - 10, y - 10, 20, 20)
					
				end
			end
		end
	end
end
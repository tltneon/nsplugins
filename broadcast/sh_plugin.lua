PLUGIN.name = "Broadcast System"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Adds usable radios for in-game communication."

if (CLIENT) then
	surface.CreateFont("nut_ChatFontRadio", {
		font = "Courier New",
		size = 18,
		weight = 800
	})

	function PLUGIN:ShouldDrawTargetEntity(entity)
		if (entity:GetClass() == "nut_bdcast") then
			return true
		end
	end

	function PLUGIN:DrawTargetID(entity, x, y, alpha)
		if (entity:GetClass() == "nut_bdcast") then
			local mainColor = nut.config.mainColor
			local color = Color(mainColor.r, mainColor.g, mainColor.b, alpha)

				nut.util.DrawText(x, y, "Broadcast System", color)
				y = y + nut.config.targetTall
				local text = "Can broadcast with /b <text>."
				nut.util.DrawText(x, y, text, Color(255, 255, 255, alpha))
		end
	end
	
else
	function PLUGIN:LoadData()
		local restored = nut.util.ReadTable("bdcast")

		if (restored) then
			for k, v in pairs(restored) do
				local position = v.position
				local angles = v.angles
				local frequency  = v.freq
				local active = v.active

				local entity = ents.Create("nut_bdcast")
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity:Spawn()
				entity:Activate()
				entity:SetNetVar("active", active)
			end
		end
	end

	function PLUGIN:SaveData()
		local data = {}

		for k, v in pairs(ents.FindByClass("nut_bdcast")) do
			data[#data + 1] = {
				position = v:GetPos(),
				angles = v:GetAngles(),
				active = v:GetNetVar("active")
			}
		end

		nut.util.WriteTable("bdcast", data)
	end
end

nut.chat.Register("broadcast", {
	onChat = function(speaker, text)
		surface.PlaySound( "ambient/levels/prison/radio_random" .. math.random( 1, 9 ) ..".wav" )
		if (LocalPlayer() != speaker and speaker:GetPos():Distance(LocalPlayer():GetPos()) <= nut.config.chatRange) then
			chat.AddText(Color(255, 100, 100), speaker:Name()..": "..text)
		else
			chat.AddText(Color(180, 0, 0), speaker:Name()..": "..text)
		end
	end,
	prefix = {"/broadcast", "/b"},
	canHear = function(speaker, listener)
		return true
	end,
	canSay = function(speaker)
	
		for k, v in pairs( ents.FindInSphere( speaker:GetPos(), 128 ) ) do
			if v:GetClass() == "nut_bdcast" and v:GetNetVar( "active" ) then
				return true
			end
		end
		nut.util.Notify("You need to be near at broadcast system that is on.", speaker)
		
	end,
	font = "nut_ChatFontRadio"
})
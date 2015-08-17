PLUGIN.name = "Half Life 2 Stuffs"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gives you more Half-Life 2 Stuffs."
PLUGIN.comlock = {}

if SERVER then
	function PLUGIN:LoadData()
		local restored = nut.util.ReadTable("comlocks")

		if (restored) then
			for k, v in pairs(restored) do
				local position = v.position
				local angles = v.angles
				local door = v.door
				if !door then continue end

				local entity = ents.Create("nut_reader")
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity.door = door
				entity:Spawn()
			end
		end
	end	
	
	function PLUGIN:SaveData()
		local data = {}
		for k, v in pairs( ents.FindByClass("nut_reader") ) do
			data[#data + 1] = {
				position = v:GetPos(),
				angles = v:GetAngles(),
				door = v.door
			}
		end
		nut.util.WriteTable("comlocks", data)		
	end
	
end

local function IsDoor(entity)
	return string.find(entity:GetClass(), "door")
end


nut.command.Register({
	adminOnly = true,
	syntax = "[bool showTime]",
	onRun = function(client, arguments)
		local name = arguments[1]
		tr = {}
		tr.start = client:GetShootPos()
		tr.endpos = tr.start + client:GetAimVector() * 200
		tr.filter = client
		trace = util.TraceHull(tr)
	
		if (!client:GetNutVar("comlock")) then
			if trace.Entity:IsValid() and trace.Entity:GetClass() == "nut_reader" then
				client:SetNutVar("comlock", trace.Entity)
				nut.util.Notify("Now face the door. and with name.", client)
			end
		else
			if trace.Entity:IsValid() and IsDoor( trace.Entity ) then
				
				local comlock = client:GetNutVar("comlock")
				comlock.door = trace.Entity:GetPos()

				client:SetNutVar("comlock", nil)
				nut.util.Notify("You've added a new combine lock.", client)
			else
				client:SetNutVar("comlock", nil)
				nut.util.Notify("Resetted selection.", client)
			end
		end
		
	end
}, "addcomlock")

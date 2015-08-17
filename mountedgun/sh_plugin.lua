PLUGIN.name = "Mounted Guns"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Area Control is on the way."

function PLUGIN:LoadData()
	local restored = nut.util.ReadTable("m_guns")
	if (restored) then
		for k, v in pairs(restored) do
			local position = v.position
			local angles = v.angles
			local eclass  = v.class
			local entity = ents.Create(eclass)
			entity:SetPos(position)
			entity:SetAngles(angles)
			entity:Spawn()
			entity:Activate()

			local physicsObject = entity:GetPhysicsObject();
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
				physicsObject:Sleep();
			end
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	for k, v in pairs(ents.FindByClass("nut_mmg_*")) do
		data[#data + 1] = {
			position = v:GetPos(),
			angles = v:GetAngles(),
			class = v:GetClass()
		}
	end
	nut.util.WriteTable("m_guns", data)
end


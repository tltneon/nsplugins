PLUGIN.name = "Productive Machines"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "If your server does not have proper economy? install this!"
PLUGIN.generateJunks = true

function PLUGIN:LoadData()
	local restored = self:getData()
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
			local phys = entity:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	for k, v in pairs(ents.FindByClass("nut_m_*")) do
		print(v:GetClass())
		data[#data + 1] = {
			position = v:GetPos(),
			angles = v:GetAngles(),
			class = v:GetClass()
		}
	end
	self:setData(data)
end

if PLUGIN.generateJunks then
	local junks = {
		["junk_ws"] = { name = "Shelf Part", mdl = "models/gibs/furniture_gibs/furniturewooddrawer003a_chunk02.mdl", desc = "A broken part from the shelf.", weight = .3},
		["junk_wj"] = { name = "Wooden Junk", mdl = "models/gibs/furniture_gibs/furnituredrawer002a_gib06.mdl", desc = "A Wooden piece.", weight = .2},
		["junk_be"] = { name = "Broken Engine", mdl = "models/gibs/airboat_broken_engine.mdl", desc = "A Broken Engine.", weight = 3},
		["junk_bt"] = { name = "Broken TV", mdl = "models/props_c17/tv_monitor01.mdl", desc = "A Broken TV.", weight = 1},
		["junk_p"] = { name = "Pulley", mdl = "models/props_c17/pulleywheels_small01.mdl", desc = "A Metal Pulley.", weight = .6},
		["junk_ss"] = { name = "Streen Sign", mdl = "models/props_c17/streetsign004e.mdl", desc = "A Metal Street Sign.", weight = .5},
		["junk_bl"] = { name = "Broken Lamp", mdl = "models/props_c17/lamp_standard_off01.mdl", desc = "A Broken Lamp.", weight = 1},
		["junk_k"] = { name = "Keyboard", mdl = "models/props_c17/computer01_keyboard.mdl", desc = "A Keyboard.", weight = .2},
		["junk_p"] = { name = "Pot", mdl = "models/props_interiors/pot01a.mdl", desc = "A Pot.", weight = .4},
		["junk_hp"] = { name = "Handled Pot", mdl = "models/props_interiors/pot02a.mdl", desc = "A Handled Pot.", weight = .7},
		["junk_ec"] = { name = "Empty Can", mdl = "models/props_junk/garbage_metalcan002a.mdl", desc = "An Empty Can.", weight = .2},
		["junk_ej"] = { name = "Empty Jurry", mdl = "models/props_junk/metalgascan.mdl", desc = "An Empty Jurry", weight = .2},
	}
	local ITEM = {}
	for k, v in pairs(junks) do
		ITEM.name = v.name
		ITEM.uniqueID = k
		ITEM.category = "Junks"
		ITEM.model = v.mdl or wepdat.WM
		ITEM.weight = v.weight or 1
		ITEM.desc = v.desc .. "\nThis junk weighs " .. v.weight .. " kg."
		nut.item.PrepareItemTable(ITEM)
		nut.item.Register(ITEM, false)
		ITEM = {}
	end
end
PLUGIN.name = "Talking NPCs"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Adding talking NPCs."
PLUGIN.chatDelay = { min = .5, max = 1 }
PLUGIN.defaultDialogue = {
	npc = {
		["_start"] = "Hello, This is default Text.",
		["test1"] = "He is also known as 'Black Tea'. He is really famous for incredible sucky coding skill and not working buggy code. Long time ago, I suggested him to kill himself but he refused.",
	},
	player = {
		["_quit"] = "I gotta go.",
		["test1"] = "Can you tell me who is rebel1324?",
	},
}

if (SERVER) then
	local PLUGIN = PLUGIN
	
	function PLUGIN:SaveData()
		local data = {}
			for k, v in ipairs(ents.FindByClass("nut_talker")) do
				data[#data + 1] = {
					name = v:getNetVar("name"),
					desc = v:getNetVar("desc"),
					pos = v:GetPos(),
					angles = v:GetAngles(),
					model = v:GetModel(),
					factions = v:getNetVar("factiondata", {}),
					dialogue = v:getNetVar( "dialogue", self.defaultDialogue ),
					classes = v:getNetVar("classdata", {})
				}
			end
		self:setData(data)
	end

	function PLUGIN:LoadData()
		for k, v in ipairs(self:getData() or {}) do
			local entity = ents.Create("nut_talker")
			entity:SetPos(v.pos)
			entity:SetAngles(v.angles)
			entity:Spawn()
			entity:SetModel(v.model)
			entity:setNetVar("dialogue", v.dialogue)
			entity:setNetVar("factiondata", v.factions)
			entity:setNetVar("classdata", v.classes)
			entity:setNetVar("name", v.name)
			entity:setNetVar("desc", v.desc)
		end
	end
end
local PLUGIN = PLUGIN
PLUGIN.name = "Talking NPC"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Adds NPCs that sell things."
nut.lang.Add( "talker_refuse", "%s: I don't have anything to talk." )
nut.util.Include("cl_dialogue.lua")
nut.util.Include("cl_dermafix.lua")
nut.util.Include("sh_advhandler.lua")

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
	function PLUGIN:LoadData()
		for k, v in pairs(nut.util.ReadTable("talkers")) do
			local position = v.pos
			local angles = v.angles
			local dialogue = v.dialogue
			local factionData = v.factionData
			local classData = v.classData
			local name = v.name
			local desc = v.desc
			local model = v.model

			local entity = ents.Create("nut_talker")
			entity:SetPos(position)
			entity:SetAngles(angles)
			entity:Spawn()
			entity:Activate()
			entity:SetNetVar("dialogue", dialogue)
			entity:SetNetVar("factiondata", factionData)
			entity:SetNetVar("classdata", classData)
			entity:SetNetVar("name", name)
			entity:SetNetVar("desc", desc)
			entity:SetModel(model)
			entity:SetAnim()
		end
	end

	function PLUGIN:SaveData()
		local data = {}

		for k, v in pairs(ents.FindByClass("nut_talker")) do
			data[#data + 1] = {
				pos = v:GetPos(),
				angles = v:GetAngles(),
				dialogue = v:GetNetVar( "dialogue", self.defaultDialogue ),
				factionData = v:GetNetVar("factiondata", {}),
				classData = v:GetNetVar("classdata", {}),
				name = v:GetNetVar("name", "John Doe"),
				desc = v:GetNetVar("desc", nut.lang.Get("no_desc")),
				model = v:GetModel()
			}
		end

		nut.util.WriteTable("talkers", data)
	end
end


nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local entity = trace.Entity

		if (IsValid(entity) and entity:GetClass() == "nut_talker") then
			netstream.Start(client, "nut_DialogueEditor", entity)
		else
			nut.util.Notify("You are not looking at a valid nut_talker!", client)
		end
	end
}, "talkersetting")

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		local position = client:GetEyeTraceNoCursor().HitPos
		local angles = client:EyeAngles()
		angles.p = 0
		angles.y = angles.y - 180

		local entity = ents.Create("nut_talker")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()

		PLUGIN:SaveData()

		nut.util.Notify("You have added a talker.", client)
	end
}, "talkeradd")

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local entity = trace.Entity

		if (IsValid(entity) and entity:GetClass() == "nut_talker") then
			entity:Remove()

			PLUGIN:SaveData()

			nut.util.Notify("You have removed this talker.", client)
		else
			nut.util.Notify("You are not looking at a valid talker!", client)
		end
	end
}, "talkerremove")
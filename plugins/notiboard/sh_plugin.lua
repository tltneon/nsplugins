PLUGIN.name = "Noti-Board"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "This is a noti-board for notifications!"

if SERVER then
	function PLUGIN:LoadData()
		local restored = self:getData()

		if (restored) then
			for k, v in pairs(restored) do
				local position = v.position
				local angles = v.angles
				local title  = v.title
				local text = v.text
				local group = v.group

				local entity = ents.Create("nut_notiboard")
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity:Spawn()
				entity:Activate()
				entity:setNetVar("title", title)
				entity:setNetVar("text", text)
				entity.group = group

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

		for k, v in pairs(ents.FindByClass("nut_notiboard")) do
			data[#data + 1] = {
				position = v:GetPos(),
				angles = v:GetAngles(),
				title = v:getNetVar("title"),
				text = v:getNetVar("text"),
				group = v.group
			}
		end

		self:setData(data)
	end
end

nut.command.add("notisetgroup", {
	syntax = "<number group>",
	adminOnly = true,
	onRun = function(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 450
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity
		local gp = arguments[1] or ""

		if (IsValid(entity) and entity:GetClass() == "nut_notiboard") then
			entity.group = gp
			client:notify("You have set this noti-board's group to "..gp..".")
		else
			client:notify("You must be looking at a noti-board.")
		end
	end
})

nut.command.add("notisetgrouptext", {
	syntax = "<number group> <number text>",
	adminOnly = true,
	onRun = function(client, arguments)
		if #arguments < 2 then 
			client:notify("You have to provide a text to change.")
			return
		end
		local gp = arguments[1] or ""
		table.remove(arguments, 1)
		local text = table.concat(arguments, " ")
		local count = 0
		for k, v in pairs(ents.FindByClass("nut_notiboard")) do
			if v.group == gp then
				v:setNetVar("text", text)
				count = count + 1
			end
		end
		client:notify("You changed " .. count .. " Noti-Board's text.")
	end
})
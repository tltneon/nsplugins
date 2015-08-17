local PLUGIN = PLUGIN


--Credits to whoever wrote the original string replacement code
nut.command.Register({
	syntax = "[string newnick]",
	onRun = function(client, arguments)
		if SERVER and IsValid(client) then
			local newNick = arguments[1]
			if newNick then
				local oldName=client:Name()
				local newName
				if not string.find(client:Name(), "'") then
					newName = string.gsub(oldName, " ", " '"..newNick.."' ")
				else
					newName = string.gsub(oldName, "'.*'", "'"..newNick.."'")
				end
				client.character:SetVar("charname", newName)
				nut.util.Notify("Your darker and edgier name is "..newName..".", client)
			else
				nut.util.Notify("You must specify a nickname.", client)
			end
		end
	end
}, "setnick")

nut.command.Register({
	syntax = "[none]",
	onRun = function(client, arguments)
		if SERVER and IsValid(client) then
			local newName = string.gsub(client:Name(), "'.*' ", "")
			client.character:SetVar("charname", newName)
			nut.util.Notify("Your lighter and tamer name is "..newName..".", client)
		end
	end
}, "removenick")


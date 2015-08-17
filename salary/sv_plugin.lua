local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedChar( client )
	local salary = client.character:GetData("salary", {0, 900})

	if timer.Exists("Salary-"..client:SteamID()) then
		timer.Adjust("Salary-"..client:SteamID(), salary[2], 0, function()
			if IsValid(client) and client.character and salary[1] > 0 then
				client.character:SetData("bank", client.character:GetData("bank", 1000) + salary[1])
				nut.util.Notify("It's payday, your employer sent "..(salary[1]).."€ to your bank account.", client)
			end
		end)
	else
		timer.Create("Salary-"..client:SteamID(), salary[2], 0, function()
			if IsValid(client) and client.character and salary[1] > 0 then
				client.character:SetData("bank", client.character:GetData("bank", 1000) + salary[1])
				nut.util.Notify("It's payday, your employer sent "..(salary[1]).."€ to your bank account.", client)
			end
		end)
	end
end
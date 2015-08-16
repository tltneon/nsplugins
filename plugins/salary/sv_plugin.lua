local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedChar( client )
	local salary = client:getChar():getData("salary", {0, 900})

	if timer.Exists("Salary-"..client:SteamID()) then
		timer.Adjust("Salary-"..client:SteamID(), salary[2], 0, function()
			if IsValid(client) and client:getChar() and salary[1] > 0 then
				client:getChar():setData("bank", client:getChar():getData("bank", 1000) + salary[1])
				client:notify("It's payday, your employer sent "..(salary[1]).."€ to your bank account.")
			end
		end)
	else
		timer.Create("Salary-"..client:SteamID(), salary[2], 0, function()
			if IsValid(client) and client:getChar() and salary[1] > 0 then
				client:getChar():setData("bank", client:getChar():getData("bank", 1000) + salary[1])
				client:notify("It's payday, your employer sent "..(salary[1]).."€ to your bank account.")
			end
		end)
	end
end
PLUGIN.name = "Salary"
PLUGIN.author = "_FR_Starfox64 (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Plugin to manage character salaries."

nut.util.include("sv_plugin.lua")

local PLUGIN = PLUGIN

nut.flag.add("s", {
	desc = "Allows one to manage salaries."
})

nut.command.add("setsalary", {
	syntax = "<string name> <string salary> [int interval=900]",
	onRun = function(ply, arguments)
		if not ply:hasFlag("s") then
			ply:notify("You are not authorized to use this command!")
			return
		end

		if not arguments[1] then
			ply:notifyLocalized("missing_arg", 1)
			return
		elseif not arguments[2] then
			ply:notifyLocalized("missing_arg", 2)
			return
		end

		local target = nut.command.findPlayer(ply, arguments[1])

		if IsValid(target) and target.character then
			local salary = tonumber(arguments[2])
			local interval = tonumber(arguments[3]) or 900

			if salary then
				target:getChar():setData("salary", {salary, interval})

				timer.Adjust("Salary-"..target:SteamID(), interval, 0, function()
					if IsValid(target) and target:getChar() and salary > 0 then
						target:getChar():setData("bank", target:getChar():GetData("bank", 1000) + target:getChar():getData("salary", {0, 900})[1])
						target:notify("It's payday, your employer sent "..(target:getChar():getData("salary", {0, 900})[1]).."€ to your bank account.")
					end
				end)

				target:notify("Your salary has been set to "..salary.."€ every "..interval.." seconds.")
				ply:notify(target:Name().."'s salary has been set to "..salary.."€ every "..interval.." seconds.")
				nut.log.add(ply:getChar():getVar("charname").." ( "..ply:RealName().." ) has set "..target:getChar():getVar("charname").." ( "..target:RealName().." )'s salary to "..salary.."€/"..interval.." seconds.", LOG_FILTER_CONCOMMAND)
			end
		end
	end
})

nut.command.Register("getsalary", {
	syntax = "<string name>",
	onRun = function(ply, arguments)
		if not arguments[1] then
			local salary = ply:getChar():getData("salary", {0, 900})
			ply:notify("Your salary is set to "..(salary[1]).."€ every "..(salary[2]).." seconds.")
			return
		end

		if not ply:hasFlag("s") then
			ply:notify("You are not authorized to use this command!")
			return
		end

		local target = nut.command.findPlayer(ply, arguments[1])

		if IsValid(target) and target:getChar() then
			local salary = target:getChar():getData("salary", {0, 900})
			ply:notify(target:Name().."'s salary is set to "..(salary[1]).."€ every "..(salary[2]).." seconds.")
		end
	end
})
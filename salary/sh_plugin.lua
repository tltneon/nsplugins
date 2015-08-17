PLUGIN.name = "Salary"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Plugin to manage character salaries."

nut.util.Include("sv_plugin.lua")

local PLUGIN = PLUGIN

nut.flag.Create("s", {
	desc = "Allows one to manage salaries."
})

nut.command.Register({
	syntax = "<string name> <string salary> [int interval=900]",
	onRun = function(ply, arguments)
		if not ply:HasFlag("s") then
			nut.util.Notify("You are not authorized to use this command!", ply)
			return
		end

		if not arguments[1] then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		elseif not arguments[2] then
			nut.util.Notify(nut.lang.Get("missing_arg", 2), ply)
			return
		end

		local target = nut.command.FindPlayer(ply, arguments[1])

		if IsValid(target) and target.character then
			local salary = tonumber(arguments[2])
			local interval = tonumber(arguments[3]) or 900

			if salary then
				target.character:SetData("salary", {salary, interval})

				timer.Adjust("Salary-"..target:SteamID(), interval, 0, function()
					if IsValid(target) and target.character and salary > 0 then
						target.character:SetData("bank", target.character:GetData("bank", 1000) + target.character:GetData("salary", {0, 900})[1])
						nut.util.Notify("It's payday, your employer sent "..(target.character:GetData("salary", {0, 900})[1]).."€ to your bank account.", target)
					end
				end)

				nut.util.Notify("Your salary has been set to "..salary.."€ every "..interval.." seconds.", target)
				nut.util.Notify(target:Name().."'s salary has been set to "..salary.."€ every "..interval.." seconds.", ply)
				nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) has set "..target.character:GetVar("charname").." ( "..target:RealName().." )'s salary to "..salary.."€/"..interval.." seconds.", LOG_FILTER_CONCOMMAND)
			end
		end
	end
}, "setsalary")

nut.command.Register({
	syntax = "<string name>",
	onRun = function(ply, arguments)
		if not arguments[1] then
			local salary = ply.character:GetData("salary", {0, 900})
			nut.util.Notify("Your salary is set to "..(salary[1]).."€ every "..(salary[2]).." seconds.", ply)
			return
		end

		if not ply:HasFlag("s") then
			nut.util.Notify("You are not authorized to use this command!", ply)
			return
		end

		local target = nut.command.FindPlayer(ply, arguments[1])

		if IsValid(target) and target.character then
			local salary = target.character:GetData("salary", {0, 900})
			nut.util.Notify(target:Name().."'s salary is set to "..(salary[1]).."€ every "..(salary[2]).." seconds.", ply)
		end
	end
}, "getsalary")
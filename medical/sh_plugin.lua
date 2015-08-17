PLUGIN.name = "Medical Supplies"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Just in case you get hurt."

nut.util.Include("sv_plugin.lua")

local PLUGIN = PLUGIN

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 100
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:DeployGurney( ply, entity )
	end
}, "deploygurney")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 100
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:RetractGurney( ply, entity )
	end
}, "retractgurney")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 84
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:PutInAmbulance( ply, entity )
	end
}, "putinambulance")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 100
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:Hospitalize( ply, entity )
	end
}, "hospitalize")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 100
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:Operate( ply, entity )
	end
}, "operate")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 100
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:WakeUp( ply, entity )
	end
}, "wakeup")

if CLIENT then
	properties.Add("deploy_gurney",{
		MenuLabel	=	"Deploy Gurney",
		Order		=	3200,
		MenuIcon	=	"icon16/arrow_inout.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or ent:GetClass() != "prop_vehicle_jeep" then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/deploygurney")
						end
	})

	properties.Add("retract_gurney",{
		MenuLabel	=	"Retract Gurney",
		Order		=	3201,
		MenuIcon	=	"icon16/arrow_in.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or ent:GetClass() != "prop_vehicle_jeep" then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/retractgurney")
						end
	})

	properties.Add("putin_ambulance",{
		MenuLabel	=	"Put in Ambulance",
		Order		=	3202,
		MenuIcon	=	"icon16/heart.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or !ent:GetNWBool("Body") then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/putinambulance")
						end
	})

	properties.Add("hospitalize",{
		MenuLabel	=	"Hospitalize",
		Order		=	3203,
		MenuIcon	=	"icon16/heart.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or ent:GetClass() != "prop_vehicle_jeep" then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/hospitalize")
						end
	})

	properties.Add("operate",{
		MenuLabel	=	"Operate",
		Order		=	3204,
		MenuIcon	=	"icon16/heart.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or !ent:GetNWBool("OpTable") then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/operate")
						end
	})

	properties.Add("wakeup",{
		MenuLabel	=	"Wake Up",
		Order		=	3205,
		MenuIcon	=	"icon16/heart.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or !ent:GetNWBool("WakeTbl") then return false end
							if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then return true end
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/wakeup")
						end
	})
end
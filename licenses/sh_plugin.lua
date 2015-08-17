local PLUGIN = PLUGIN
nut.util.Include("sv_plugin.lua")
nut.util.Include("cl_nut_licenses.lua")
nut.util.Include("sv_weapons.lua")
nut.util.Include("sv_driving.lua")

PLUGIN.name = "Licenses"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Adds a bunch of licenses."

PLUGIN.licenses = {
	pistol = "Allows one to purchase and own pistols.",
	rifle = "Allows one to purchase and own rifles.",
	attachments = "Allows one to purchase and equip attachments.",
	driving = "Allows one to purchase and drive a vehicle.",
	business = "Allows one to sell goods directly to EvoCity citizens.",
	bar = "Allows one to practice and protect law in court."
}

PLUGIN.weapons = {
	npc = {Vector(3888, 6072, 68), Angle(0, -45, 0)},
	range = {Vector(3772, 6134, 259), Vector(4267, 5763, 60)},
	tests = {
		pistol = {
			weapon = "fas2_p226",
			ammo = 10,
			ammoType = ".357 SIG",
			time = 60,
			reqPoints = 15,
			price = 2000,
		},
		/*rifle = {
			weapon = "fas2_m4a1",
			ammo = 10,
			ammoType = "5.56x45MM",
			time = 60,
			reqPoints = 15,
			price = 5000,
		},*/
		attachments = {
			weapon = "fas2_m4a1",
			att = "c79",
			attGroup = 1,
			ammo = 10,
			ammoType = "5.56x45MM",
			time = 60,
			reqPoints = 15,
			price = 500,
		}
	},
	targetDelay = 2,
	targetPopup = 1.5,
	whitelist = {
		"gmod_tool",
		"nut_fists",
		"nut_keys",
		"weapon_physgun",
		"weapon_eurp_defib",
		"weapon_pickaxe",
		"weapon_flashlight"
	},
	targets = {
		{
			pos = Vector(4186.388184, 6278.424805, 98.562210),
			ang = Angle(4186.388184, 6278.424805, 98.562210),
			mdl = "models/props_c17/streetsign005b.mdl"
		},
		{
			pos = Vector(4033.458008, 6388.332520, 68.146217),
			ang = Angle(0.249, -89.876, -0.045),
			mdl = "models/props/cs_militia/haybale_target_02.mdl"
		},
		{
			pos = Vector(4196.779297, 6459.798828, 68.090584),
			ang = Angle(-0.137, -89.999, 0.000),
			mdl = "models/props/cs_militia/haybale_target_03.mdl"
		},
		{
			pos = Vector(3993.164307, 6490.937500, 163.887375),
			ang = Angle(0.000, -179.903, 0.000),
			mdl = "models/props_c17/streetsign001c.mdl"
		},
		{
			pos = Vector(4177.269043, 6555.537109, 118.472900),
			ang = Angle(-0.000, -180.000, 0.000),
			mdl = "models/props_c17/streetsign002b.mdl"
		},
		{
			pos = Vector(4169.653320, 6599.396973, 68.504387),
			ang = Angle(0.000, -90.021, 0.000),
			mdl = "models/props/cs_militia/crate_extrasmallmill.mdl"
		},
		{
			pos = Vector(3990.898682, 6671.299805, 68.420700),
			ang = Angle(-0.184, -50.157, 0.066),
			mdl = "models/props/cs_militia/boxes_garage_lower.mdl"
		},
		{
			pos = Vector(4002.528320, 6762.655273, 121.875473),
			ang = Angle(0.000, -179.997, 0.000),
			mdl = "models/props_c17/streetsign004e.mdl"
		},
		{
			pos = Vector(4095.860352, 6888.875488, 139.147507),
			ang = Angle(-0.000, -90.001, 0.001),
			mdl = "models/props/cs_militia/haybale_target.mdl"
		},
		{
			pos = Vector(4154.833984, 6899.519043, 147.264679),
			ang = Angle(-0.000, 180.000, 0.000),
			mdl = "models/props_c17/streetsign005d.mdl"
		},
		{
			pos = Vector(4156.363770, 6890.063965, 191.683746),
			ang = Angle(0.000, -90.000, 0.000),
			mdl = "models/props/cs_militia/haybale_target_02.mdl"
		},
		{
			pos = Vector(4053.149902, 6804.701660, 112.700058),
			ang = Angle(1.311, -135.014, -1.296),
			mdl = "models/props/cs_militia/bottle01.mdl"
		},
		{
			pos = Vector(4075.587646, 6805.447266, 112.712982),
			ang = Angle(1.311, -135.014, -1.296),
			mdl = "models/props/cs_militia/bottle01.mdl"
		},
		{
			pos = Vector(4098.764648, 6805.380859, 112.697929),
			ang = Angle(1.311, -135.014, -1.296),
			mdl = "models/props/cs_militia/bottle01.mdl"
		},
		{
			pos = Vector(4121.913086, 6804.967285, 112.703384),
			ang = Angle(1.311, -135.014, -1.296),
			mdl = "models/props/cs_militia/bottle01.mdl"
		},
		{
			pos = Vector(4145.612793, 6804.390137, 112.673409),
			ang = Angle(1.311, -135.014, -1.296),
			mdl = "models/props/cs_militia/bottle01.mdl"
		}
	}
}

OrderVectors(PLUGIN.weapons.range[1], PLUGIN.weapons.range[2])

PLUGIN.driving = {
	script = "scripts/vehicles/tdmcars/focussvt.txt",
	model = "models/tdmcars/for_focussvt.mdl",
	price = 500,
	time = 120,
	npc = {Vector(3840, 7164, 64), Angle(0, 0, 0)},
	start = {Vector(-413.098969, -5844.740723, 84.380432), Angle(0, 145, 0)},
	tele = {Vector(3883, 7214, 132), Angle(0, -35, 0)},
	checkpoints = {
		{Vector(392.786469, -6236.108887, 84.405273), Vector(382.280640, -6797.928223, 76.765633)},
		{Vector(7436.288086, -5718.670898, 84.319366), Vector(8043.276855, -5704.112305, 84.253830)},
		{Vector(7868.876465, 642.344543, 83.484573), Vector(8338.619141, 261.087769, 84.152672)},
		{Vector(10904.140625, 1010.127625, 84.445396), Vector(10818.380859, 1565.313843, 84.398460)},
		{Vector(11764.484375, 5254.900391, 85.251984), Vector(12345.183594, 5245.508789, 84.313629)},
		{Vector(11782.705078, 11839.162109, 77.964668), Vector(12350.505859, 11802.129883, 77.788513)},
		{Vector(9088.829102, 12239.901367, 78.025002), Vector(9077.229492, 12811.501953, 77.773643)},
		{Vector(6502.224121, 9712.268555, 78.517769), Vector(6399.998047, 10291.091797, 77.644203)},
		{Vector(878.760132, 9629.874023, 78.190659), Vector(974.880249, 10171.219727, 77.313354)},
		{Vector(-167.736679, 12153.500977, 77.924019), Vector(198.825623, 12554.409180, 77.934425)},
		{Vector(-1378.130005, 12978.706055, 78.340088), Vector(-1751.715820, 12615.772461, 78.143394)},
		{Vector(-2360.121338, 14539.883789, 79.493118), Vector(-2095.308838, 15051.626953, 77.359039)},
		{Vector(-4917.144043, 14412.059570, 205.294098), Vector(-4968.448730, 15053.685547, 205.286011)},
		{Vector(-5315.975098, 11719.802734, 205.351379), Vector(-5900.514648, 11972.595703, 205.373093)},
		{Vector(-7227.645996, 11213.514648, 203.932129), Vector(-7647.859863, 11655.200195, 203.383804)},
		{Vector(-7974.691895, 8788.038086, 84.305679), Vector(-7386.554199, 8789.678711, 84.358650)},
		{Vector(-9273.634766, 8313.154297, 92.392197), Vector(-9321.370117, 8763.036133, 92.374260)}
	}
}

if SERVER then
	function PLUGIN:InitPostEntity()
		local range_npc = ents.Create("npc_range")
		range_npc:SetPos(PLUGIN.weapons.npc[1])
		range_npc:SetAngles(PLUGIN.weapons.npc[2])
		range_npc:Spawn()
		range_npc:Activate()

		local driving_npc = ents.Create("npc_driving")
		driving_npc:SetPos(PLUGIN.driving.npc[1])
		driving_npc:SetAngles(PLUGIN.driving.npc[2])
		driving_npc:Spawn()
		driving_npc:Activate()
	end
end

function PLUGIN:CreateCharVars(character)
	local data = {
		status = false,
		endTime = 0,
		test = "N/A",
		points = 0
	}
	character:NewVar("testData", data, CHAR_PRIVATE, true)
end

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 60
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:RequestLicences(ply, entity)
	end
}, "reqlicenses")

nut.command.Register({
	onRun = function(ply, arguments)
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 60
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		PLUGIN:ShowLicenses(ply, entity)
	end
}, "showlicenses")

nut.command.Register({
	syntax = "<string name> <string license>",
	onRun = function(ply, arguments)
		if not ply:HasFlag("l") then
			nut.util.Notify("You are not authorized to use this command!", ply)
			return
		end

		local target = nut.command.FindPlayer(ply, arguments[1])

		if IsValid(target) then
			if (!arguments[2]) then
				nut.util.Notify(nut.lang.Get("missing_arg", 2), ply)
				return
			end

			if not PLUGIN.licenses[arguments[2]] then
				nut.util.Notify(arguments[2].." isn't a valid license!", ply)
				return
			end

			PLUGIN:GiveLicense(target, arguments[2])
			nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) gave "..target:Name().. " ( "..target:RealName().." ) a "..arguments[2].." license.", LOG_FILTER_CONCOMMAND)
		end
	end
}, "givelicense")

nut.command.Register({
	syntax = "<string name> <string license>",
	onRun = function(ply, arguments)
		if not ply:HasFlag("l") then
			nut.util.Notify("You are not authorized to use this command!", ply)
			return
		end

		local target = nut.command.FindPlayer(ply, arguments[1])

		if IsValid(target) then
			if (!arguments[2]) then
				nut.util.Notify(nut.lang.Get("missing_arg", 2), ply)
				return
			end

			if not PLUGIN.licenses[arguments[2]] then
				nut.util.Notify(arguments[2].." isn't a valid license!", ply)
				return
			end

			PLUGIN:TakeLicense(target, arguments[2])
			nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) revoked "..target:Name().. "'s' ( "..target:RealName().." ) "..arguments[2].." license.", LOG_FILTER_CONCOMMAND)
		end
	end
}, "takelicense")

nut.flag.Create("l", {
	desc = "Allows one to give and revoke licenses."
})

if CLIENT then
	netstream.Hook("reqLicenses", function( cop )
		local ConfFrame = vgui.Create("DFrame")
		ConfFrame:SetSize(200, 70)
		ConfFrame:Center()
		ConfFrame:SetBackgroundBlur(true)
		ConfFrame:ShowCloseButton(false)
		ConfFrame:SetTitle("Evocity Registry")
		ConfFrame:MakePopup()

		local ConfText = vgui.Create("DLabel", ConfFrame)
		ConfText:Dock(TOP)
		ConfText:DockMargin(5, 0, 5, 5)
		ConfText:SetText("Show your licenses to "..cop:Name().."?")

		local Yes = vgui.Create("DButton", ConfFrame)
		Yes:SetPos(50, 50)
		Yes:SetSize(40, 15)
		Yes:SetText("Yes")
		Yes.DoClick = function()
			ConfFrame:Close()
			netstream.Start("showLicenses", {true, cop})
		end

		local No = vgui.Create("DButton", ConfFrame)
		No:SetPos(100, 50)
		No:SetSize(40, 15)
		No:SetText("No")
		No.DoClick = function()
			ConfFrame:Close()
			netstream.Start("showLicenses", {false, cop})
		end
	end)

	netstream.Hook("drivingMenu", function()
		local ConfFrame = vgui.Create("DFrame")
		ConfFrame:SetSize(200, 110)
		ConfFrame:Center()
		ConfFrame:SetTitle("Confirmation...")
		ConfFrame:MakePopup()

		local panel = vgui.Create("DPanel", ConfFrame)
		panel:Dock(FILL)

		local ConfText = vgui.Create("DLabel", panel)
		ConfText:Dock(TOP)
		ConfText:DockMargin(4, 0, 4, 2)
		ConfText:SetText("Take a driving test for "..PLUGIN.driving.price.."€?")
		ConfText:SetContentAlignment(5)

		local Yes = vgui.Create("DButton", panel)
		Yes:Dock(TOP)
		Yes:DockMargin(4, 2, 4, 2)
		Yes:SetText("Yes")
		Yes.DoClick = function()
			ConfFrame:Close()
			netstream.Start("ReqDriveTest")
		end

		local No = vgui.Create("DButton", panel)
		No:Dock(TOP)
		No:DockMargin(4, 2, 4, 2)
		No:SetText("No")
		No.DoClick = function()
			ConfFrame:Close()
		end
	end)

	netstream.Hook("rangeMenu", function()
		local Frame = vgui.Create("DFrame")
		Frame:SetSize(280, 140)
		Frame:Center()
		Frame:SetTitle("Firing Range")
		Frame:MakePopup()

		local Panel = vgui.Create("DPanel", Frame)
		Panel:Dock(FILL)

		local Text = vgui.Create("DLabel", Panel)
		Text:Dock(TOP)
		Text:DockPadding(4, 2, 4, 2)
		Text:DockMargin(4,2,4,2)
		Text:SetContentAlignment(5)
		Text:SetText("Which test do you wish to take?")
		
		local Pistol = vgui.Create("DButton", Panel)
		Pistol:Dock(TOP)
		Pistol:DockPadding(4, 2, 4, 2)
		Pistol:DockMargin(4,2,4,2)
		Pistol:SetText("Pistol "..PLUGIN.weapons.tests.pistol.price.."€")
		Pistol.DoClick = function()
			Frame:Close()
			netstream.Start("ReqWepTest", "pistol")
		end

		/*local Rifle = vgui.Create("DButton", Panel)
		Rifle:Dock(TOP)
		Rifle:DockPadding(4, 2, 4, 2)
		Rifle:DockMargin(4,2,4,2)
		Rifle:SetText("Rifle "..PLUGIN.weapons.tests.rifle.price.."€")
		Rifle.DoClick = function()
			Frame:Close()
			netstream.Start("ReqWepTest", "rifle")
		end*/

		local Att = vgui.Create("DButton", Panel)
		Att:Dock(TOP)
		Att:DockPadding(4, 2, 4, 2)
		Att:DockMargin(4,2,4,2)
		Att:SetText("Attachments "..PLUGIN.weapons.tests.attachments.price.."€")
		Att.DoClick = function()
			Frame:Close()
			netstream.Start("ReqWepTest", "attachments")
		end

	end)

	surface.CreateFont( "LicenseFont", {font="lcd", size=25, weight=60,shadow=false} )

	function PLUGIN:HUDPaint()
		if not LocalPlayer().character then return end
		local data = LocalPlayer().character:GetVar("testData")

		if data.status == true then
			local text
			if data.test == "driving" then
				text = "Checkpoint: "..data.points.."/"..#self.driving.checkpoints.." - Time Left: "..math.Round(data.endTime - CurTime())
				local checkpoint = self.driving.checkpoints[data.points]
				local center = checkpoint[1] + 0.5 * (checkpoint[2] - checkpoint[1]) -- Pro math level!
				center.z = center.z + 50
				local drawPos = center:ToScreen()
				draw.SimpleTextOutlined( "Checkpoint "..data.points, "LicenseFont", drawPos.x, drawPos.y, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
			else
				text = "Hits: "..data.points.."/"..self.weapons.tests[data.test].reqPoints.." - Time Left: "..math.Round(data.endTime - CurTime())
			end

			draw.SimpleTextOutlined( text, "LicenseFont", (ScrW()/2), ScrH() - 25, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
		end
	end
end
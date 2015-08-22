PLUGIN.name = "CCTV"
PLUGIN.author = "_FR_Starfox64 (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "The NSA is watching!"
PLUGIN.cctvDistance = 300

if !nut.plugin.list["_oldplugins-fix"] then
	print("[CCTV Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

nut.util.Include("sv_plugin.lua")

local PLUGIN = PLUGIN

nut.command.Register({
	onRun = function(ply, arguments)
		PLUGIN:StartCCTV( ply )
	end
}, "cctv")

nut.command.Register({
	adminOnly = true,
	syntax = "<string camName>",
	onRun = function(ply, arguments)
		if not arguments[1] then return ply:notifyLocalized("missing_arg", 1) end
		local ent = ents.Create("nut_cctv_camera")
		ent:SetPos(ply:GetPos())
		ent:SetNWString("name", arguments[1])
		ent:Spawn()
		ent:Activate()
	end
}, "cctvcreate")

if (CLIENT) then
	netstream.Hook("cctvStart", function()
		local Frame = vgui.Create("DFrame")
		Frame:SetPos(0, 300)
		Frame:SetSize(300, 500)
		Frame:SetTitle("CCTV Prompt")
		Frame:MakePopup()

		local Notice = vgui.Create("nut_NoticePanel", Frame)
		Notice:Dock( TOP )
		Notice:DockMargin( 0, 0, 0, 5 )
		Notice:SetType( 4 )
		Notice:SetText( "EvoCity CCTV Network" )
		
		local List = vgui.Create("DListView", Frame)
		List:Dock( FILL )
		List:DockMargin( 0, 0, 0, 5 )
		List:SetMultiSelect(false)
		List:AddColumn("Cameras")

		for k,v in pairs(ents.FindByClass("nut_cctv_camera")) do
			if v:GetNWString("name", "Unknown") != "Unknown" then
		        List:AddLine(v:GetNWString("name"))
		    end
		end

		function List:OnRowSelected( id, line )
			netstream.Start("cctvUpdate", line:GetColumnText(1))
		end
	end)

	properties.Add("cctv_open",{
		MenuLabel	=	"CCTV",
		Order		=	3015,
		MenuIcon	=	"icon16/camera.png",

		Filter		=	function(self, ent, ply)
							if !IsValid(ent) or ent:GetClass() != "nut_cctv" then return false end
							return true
						end,

		Action		=	function(self, ent)
							if not IsValid(ent) then return end
							RunConsoleCommand("say", "/cctv")
						end
	})
end
PLUGIN.name = "Access Cards"
PLUGIN.author = "_FR_Starfox64 / Riekelt"
PLUGIN.desc = "Plugin to manage access to buildings."

nut.util.Include("sv_plugin.lua")

local PLUGIN = PLUGIN

nut.flag.Create("d", {
	desc = "Allows one to manage access cards."
})

nut.command.Register({
	syntax = "<string name> <string access> [string \"Description\"]",
	onRun = function(ply, arguments)
		if not ply:HasFlag("d") then
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

		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 60
		data.filter = ply
		local trace = util.TraceLine(data)
		local target = nut.command.FindPlayer(ply, arguments[1])

		if IsValid(target) then
			PLUGIN:CreateCard(target, arguments[2], arguments[3], trace.HitPos)
			nut.util.Notify("Creating access card...", ply)
		end
	end
}, "createcard")

nut.command.Register({
	superAdminOnly = true,
	syntax = "[bool resetDoors]",
	onRun = function(ply, arguments)
		if arguments[1] and arguments[1] == "true" then
			ply.doors = {}
		end

		local trace = ply:GetEyeTrace()
		local door = trace.Entity

		if IsValid(door) then
			ply.doors = ply.doors or {}
			table.insert(ply.doors, door:MapCreationID())
			nut.util.Notify("Door added ("..tostring(door).. ")", ply)
		end
	end
}, "adddoor")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string access>",
	onRun = function(ply, arguments)
		if not arguments[1] then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 128
		data.filter = ply
		local trace = util.TraceLine(data)

		if ply.doors and ply.doors != {} then
			PLUGIN:AddReader(arguments[1], ply.doors, trace.HitPos)
			nut.util.Notify("Keycard Reader added, accepted flags '"..arguments[1].."'.", ply)
		else
			nut.util.Notify("You need to set doors with '/adddoor'!", ply)
		end
	end
}, "addreader")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string access>",
	onRun = function(ply, arguments)
		if not arguments[1] then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		local trace = ply:GetEyeTrace()
		local reader = trace.Entity

		if IsValid(reader) then
			reader.flags = arguments[1]
			nut.util.Notify("Reader Updated ("..arguments[1]..")", ply)
		end
	end
}, "setaccess")

if (CLIENT) then
	-- Access Cards Manager --
	local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW() * 0.375, ScrH() * 0.125)
		self:SetSize(ScrW() * nut.config.menuWidth, ScrH() * nut.config.menuHeight)
		self:MakePopup()
		self:SetTitle("Access Cards Manager")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(4)
		noticePanel:SetText("Welcome to the access cards management menu.")

		self.panel = self:Add("DPanel")
		self.panel:Dock(FILL)

		self.close = self.panel:Add("DButton")
		self.close:Dock(BOTTOM)
		self.close:DockMargin(5, 0, 5, 5)
		self.close:SetText("Close")
		self.close.DoClick = function()
			self:Close()
		end

		self.edit = self.panel:Add("DButton")
		self.edit:Dock(BOTTOM)
		self.edit:DockMargin(5, 0, 5, 5)
		self.edit:SetText("Edit Card")
		self.edit:SetDisabled(true)
		self.edit.DoClick = function()
			if self.id then
				local List = DermaMenu(self.edit)
				List:AddOption("Update Access", function() self.UpdateAccess() end)
				if self.active == "Yes" then
					List:AddOption("Disable", function()
						netstream.Start("accessQuery", {req = 2, uid = self.id, owner = self.name, active = false})
						self:Reload()
					end)
				else
					List:AddOption("Enable", function()
						netstream.Start("accessQuery", {req = 2, uid = self.id, owner = self.name, active = true})
						self:Reload()
					end)
				end
				List:AddOption("Delete", function()
					netstream.Start("accessQuery", {req = 4, uid = self.id, owner = self.name})
					self:Reload()
				end)
				List:Open()
			end
		end

		function self.UpdateAccess()
			local Frame = vgui.Create("DFrame")
			Frame:SetSize(300, 120)
			Frame:Center()
			Frame:SetTitle("Edit Access Flags")
			Frame:MakePopup()

			local Notice = vgui.Create("nut_NoticePanel", Frame)
			Notice:Dock(TOP)
			Notice:DockMargin(0, 0, 0, 5)
			Notice:SetType(4)
			Notice:SetText("Edit access flags for card #"..self.id..".")

			local Panel = vgui.Create("DPanel", Frame)
			Panel:Dock(FILL)

			local Text
			local Actions = vgui.Create("DButton", Panel)
			Actions:Dock(BOTTOM)
			Actions:DockMargin(5, 0, 5, 5)
			Actions:SetText("Update")
			Actions.DoClick = function()
				netstream.Start("accessQuery", {req = 3, uid = self.id, owner = self.name, access = Text:GetValue()})
				Frame:Close()
				self:Reload()
			end
			
			Text = vgui.Create("DTextEntry", Panel)
			Text:Dock(FILL)
			Text:DockMargin(5, 5, 5, 5)
			Text:SetText(self.access)
		end

		self.list = vgui.Create("DListView", self.panel)
		self.list:Dock(FILL)
		self.list:DockMargin(5, 5, 5, 5)
		self.list:SetMultiSelect(false)
		self.list.OnRowSelected = function( line, id )
			self.id = self.list:GetLines()[id].Columns[1].Value -- I have to do everyone's job here...
			self.name = self.list:GetLines()[id].Columns[2].Value
			self.access = self.list:GetLines()[id].Columns[3].Value
			self.active = self.list:GetLines()[id].Columns[4].Value
			self.edit:SetDisabled(false)
		end

		local id = self.list:AddColumn("Card ID")
		local name = self.list:AddColumn("Owner")
		local flags = self.list:AddColumn("Access Flags")
		local status = self.list:AddColumn("Active")
		local desc = self.list:AddColumn("Description")
		/*id:SetMaxWidth(ScrW() * nut.config.menuWidth / 6)
		id:SetMinWidth(ScrW() * nut.config.menuWidth / 6)
		name:SetMaxWidth(ScrW() * nut.config.menuWidth / 3)
		name:SetMinWidth(ScrW() * nut.config.menuWidth / 3)*/

		netstream.Start("accessQuery", {req = 1})

		netstream.Hook("accessSend", function( data )
			for k,v in pairs(data) do
				local active
				if v.active == 1 then
					active = "Yes"
				else
					active = "No"
				end
				self.list:AddLine(v.uid, v.owner, v.access, active, v.description)
			end
		end)
	end

	function PANEL:Reload()
		local parent = self:GetParent()
		self:Remove()
		nut.gui.cards = vgui.Create("nut_Cards", parent)
		nut.gui.menu:SetCurrentMenu(nut.gui.cards, true)
	end

	vgui.Register("nut_Cards", PANEL, "DFrame")

	function PLUGIN:CreateMenuButtons(menu, addButton)
		if LocalPlayer():HasFlag("d") then
			addButton("cards", "Access Cards", function()
				nut.gui.cards = vgui.Create("nut_Cards", menu)
				menu:SetCurrentMenu(nut.gui.cards)
			end)
		end
	end
end
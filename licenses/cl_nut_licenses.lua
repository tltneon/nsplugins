local PLUGIN = PLUGIN
local PANEL = {}
function PANEL:Init()
	self:SetPos(ScrW() * 0.375, ScrH() * 0.125)
	self:SetSize(ScrW() * nut.config.menuWidth, ScrH() * nut.config.menuHeight)
	self:MakePopup()
	self:SetTitle("Licenses")

	self.noticePanel = self:Add("nut_NoticePanel")
	self.noticePanel:Dock(TOP)
	self.noticePanel:DockMargin(0, 0, 0, 5)
	self.noticePanel:SetType(4)
	self.noticePanel:SetText("In this menu you can see whether or not you own a license.")

	self.body = self:Add("DHTML")
	self.body:Dock(FILL)
	self.body:DockMargin(4, 1, 1, 1)

	local prefix = [[
		<head>
			<style>
				body {
					background-color: #fbfcfc;
					color: #2c3e50;
					font-family: Verdana, Geneva, sans-serif;
				}
			</style>
		</head>
	]]

	function self.body:SetContents(html)
		self:SetHTML(prefix..html)
	end

	local html = ""

	for k, v in pairs(PLUGIN.licenses) do
		local color = "<font color=\"red\">&#10008;"
		local licenses = LocalPlayer().character:GetData("licenses", {})

		if (licenses[k]) then
			color = "<font color=\"green\">&#10004;"
		end

		html = html.."<p><b>"..color.."&nbsp;</font>"..string.upper(string.sub(k, 1, 1)) .. string.sub(k, 2).." license</b><br /><hi><i>Description:</i> "..v or nut.lang.Get("no_desc").."</p>"
	end

	self.body:SetContents(html)
end

function PANEL:Think()
	if (!self:IsActive()) then
		self:MakePopup()
	end
end
vgui.Register("nut_Licenses", PANEL, "DFrame")

function PLUGIN:CreateMenuButtons(menu, addButton)
	addButton("lic", "Licenses", function()
		nut.gui.lic = vgui.Create("nut_Licenses", menu)
		menu:SetCurrentMenu(nut.gui.lic)
	end)
end
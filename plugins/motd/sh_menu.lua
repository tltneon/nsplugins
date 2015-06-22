if SERVER then return end
local PLUGIN = PLUGIN

local PANEL = {}

	function PANEL:Init()
		local W, H = self:GetParent():GetSize()
		self:SetPos((ScrW()-W)/2, (ScrH()-H)/2)
		--self:SetSize(ScrW() * menuWidth, ScrH() * menuHeight)
		--self:Center()
		self:SetSize(self:GetParent():GetSize())
		self:ShowCloseButton(false)
		--self:MakePopup()
		self:SetTitle(L"motd")
		
		self.motd = self:Add("HTML")
		self.motd:Dock(FILL)
		self.motd:OpenURL( PLUGIN.url )

	end

	function PANEL:Think()
		if (!self:IsActive()) then
			self:MakePopup()
		end
	end
	
vgui.Register("nut_MOTD", PANEL, "DFrame")

function PLUGIN:CreateMenuButtons(tabs)--menu, addButton)
		tabs["motd"] = function(panel)
			--if removeGuiMenu then nut.gui.menu:Remove() end
			panel:Add("nut_MOTD")--vgui.Create("nut_MOTD")
		end
end
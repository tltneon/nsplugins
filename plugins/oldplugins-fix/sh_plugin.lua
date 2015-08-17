PLUGIN.name = "FIX for NutScript 1.1"
PLUGIN.desc = "Allow to use simple plugins from NS 1.0" --Смягчает переход от NS 1.0 к NS 1.1
PLUGIN.author = "Neon"

// Github NS Plugins: https://github.com/tltneon/nsplugins

nut.config.menuWidth = 0.5
nut.config.menuHeight = 0.5
nut.config.mainColor = Color(255, 255, 255, 255)

function nut.util.Notify(message, recipient)
	nut.util.notify(message, recipient)
end

function nut.util.AddLog(text, filter)
	nut.log.add(text, filter)
end

function nut.command.Register(data, cmd)
	nut.command.add(cmd, data)
end

function nut.bar.Add(identifier, data)
	nut.bar.add(data.getValue, data.color, priority or 1, identifier)
end

function nut.util.Include(file)
	nut.util.include(file)
end

function nut.flag.Create(flag, data)
	nut.flag.add(flag, data)
end

function nut.command.FindPlayer(client, name)
	nut.command.findPlayer(client, name)
end

function nut.lang.Get(text)
	L(text)
end

local playerMeta = FindMetaTable("Player")
function playerMeta:HasFlag(flag)
	self:getChar():hasFlags(flag)
end
if CLIENT then
	surface.CreateFont("nut_NotiFont", {
		font = "Myriad Pro",
		size = 16,
		weight = 500,
		antialias = true
	})

	local PANEL = {}
	PANEL.pnlTypes = {
		[1] = { -- NOT ALLOWED
			col = Color( 200, 60, 60 ),
			icon = "icon16/exclamation.png"
		},
		[2] = { -- COULD BE CANCELED
			col = Color( 255, 100, 100 ),
			icon = "icon16/cross.png"
		},
		[3] = { -- WILL BE CANCELED
			col = Color( 255, 100, 100 ),
			icon = "icon16/cancel.png"
		},
		[4] = { -- TUTORIAL/GUIDE
			col = Color( 100, 185, 255 ),
			icon = "icon16/book.png"
		},
		[5] = { -- ERROR
			col = Color( 255, 255, 100 ),
			icon = "icon16/error.png"
		},
		[6] = { -- YES
			col = Color( 140, 255, 165 ),
			icon = "icon16/accept.png"
		},
		[7] = { -- TUTORIAL/GUIDE
			col = Color( 100, 185, 255 ),
			icon = "icon16/information.png"
		},
	}
	function PANEL:Init()
		self.type = 1
		self.text = self:Add( "DLabel" )
		self.text:SetFont( "nut_NotiFont" )
		self.text:SetContentAlignment(5)
		self.text:SetTextColor( color_white )
		self.text:SizeToContents()
		self.text:Dock( FILL )
		self.text:DockMargin(2, 2, 2, 2)
		self.text:SetExpensiveShadow(1, Color(25, 25, 25, 120))
		self:SetTall(28)
	end
	function PANEL:SetType( num )
		self.type = num
		return 
	end
	function PANEL:SetText( str )
		self.text:SetText( str )
	end
	function PANEL:SetFont( str )
		self.text:SetFont( str )
	end
	function PANEL:Paint()
		self.material = self.material or Material( self.pnlTypes[ self.type ].icon )
		local col = self.pnlTypes[ self.type ].col
		local mat = self.material
		local size = self:GetTall()*.6
		local marg = 3
		draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), col )	
		if mat then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( mat )
			surface.DrawTexturedRect( size/2, self:GetTall()/2-size/2 + 1, size, size )
		end
	end
	vgui.Register("nut_NoticePanel", PANEL, "DPanel")
	
	function addButton(uniqueID, name, callback) --## innactive function. just for removing errors
		--tabs[name] = callback(panel)
			--addTab(name, callback, uniqueID)
		--end
	end
end
PLUGIN.name = "FIX for NutScript 1.1 | ver.2"
PLUGIN.desc = "Allow to use simple plugins from NS 1.0" --Смягчает переход от NS 1.0 к NS 1.1
PLUGIN.author = "Neon"

// Github NS Plugins: https://github.com/tltneon/nsplugins

nut.util.include("sh_vars.lua")
BASE = ITEM or nut.item.base
phrases = {}
/*database = {}

function PLUGIN:LoadData()
	database = self:getData() or {}
end
function PLUGIN:SaveData()
	self:setData(database)
end

function nut.util.ReadTable(name, _)
	return database[name] or {}
end
function nut.util.WriteTable(name, tbl, _, _)
	database[name] = tbl
end*/

function nut.util.Include(fileName, state)
	nut.util.include(fileName, state)
end

function nut.util.Notify(message, recipient)
	nut.util.notify(message, recipient)
end

function nut.util.AddLog(text, filter)
	nut.log.add(text, filter)
end

function nut.command.Register(data, cmd)
	nut.command.add(cmd, data)
end

function nut.flag.Create(flag, data)
	nut.flag.add(flag, data)
end

function nut.command.FindPlayer(client, name)
	nut.command.findPlayer(client, name)
end

function nut.lang.Add(key, value, language)
	phrases[key] = value
end
function nut.lang.Get(key, ...)
	if (phrases[key]) then
		return string.format(phrases[key], ...)
	else
		return "<missing "..key..">"
	end
end

function nut.attribs.SetUp(_,_,_)
end

function nut.plugin.Get(plugin)
	return nut.plugin[plugin]
end

function nut.currency.GetName(value)
	return nut.currency.get(value)
end

local entityMeta = FindMetaTable("Entity")
function entityMeta:GetNetVar(key, default)
	self:getNetVar(key, default)
end
function entityMeta:SetNetVar(key, default)
	self:setNetVar(key, default)
end

local playerMeta = FindMetaTable("Player")
--playerMeta.character = playerMeta:getChar()

function playerMeta:HasFlag(flag)
	self:getChar():hasFlags(flag)
end
function playerMeta:GetNutVar(var, def)
	self:getNutData(var, def)
end
function playerMeta:SetNutVar(var, value)
	self:setNutData(var, value)
end
function playerMeta:UpdateInv(uniqueID, quantity, data)
	if quantity > 0 then
		self:getChar():add(uniqueID, quantity, data)
	else
		self:getChar():remove(uniqueID)
	end
end
function playerMeta:GetInventory()
	return playerMeta:getChar():getInv()
end
function playerMeta:Kick()
	self:kick()
end

local ITEM = nut.meta.item or {}
function ITEM:Hook(name, func)
	self:hook(name, func)
end
if CLIENT then
	surface.CreateFont("nut_NotiFont", {
		font = "Myriad Pro",
		size = 16,
		weight = 500,
		antialias = true
	})
	surface.CreateFont("nut_TokensFont", {
		font = "ChatFont",
		size = 32,
		weight = 1600,
		italic = false
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

	function nut.bar.Add(identifier, data)
		--print(data,data.getValue, data.color,data["getValue"], data["color"])
		nut.bar.add(data.getValue, data.color, priority or 1, identifier)
	end
	function nut.util.DrawText(x, y, str, color, font)
		nut.util.drawText(str, x, y, color, 1, 1, font, 255)
	end
else
	--function nut.schema.Call(name, gm, ...)
	--	hook.Call(name, gm, ...)
	--end
	function nut.db.Query(query, callback, filter)
		nut.db.query(query, callback, filter)
	end
	function nut.db.Escape(str)
		nut.db.escape(str)
	end
	function nut.char.Save(chr)
	end
	function PLUGIN:PlayerLoadedChar(client)
		client.character = client:getChar()
	end
	function nut.item.Get(item)
		return nut.item.list[item]
	end
	
	function playerMeta:HasInvSpace(item)
		local w, h = nut.item.list[item].width, nut.item.list[item].height
		if self:getChar():getInv():findEmptySlot(w, h, false) then return true end
		return false
	end
	function playerMeta:CanAfford(price)
		return self:getChar():hasMoney(price)
	end
	function playerMeta:TakeMoney(amount)
		return self:getChar():giveMoney(-amount)
	end
	function playerMeta:RealName(player)
		return self:steamName()
	end

	local charMeta = nut.meta.character
	function charMeta:UpdateAttrib(key, value)
		self:updateAttrib(key, value)
	end
	function charMeta:GetAttrib(key, value)
		self:getAttrib(key, value)
	end
	function charMeta:GetData(key, value)
		self:getData(key, value)
	end
	function charMeta:SetData(key, value)
		self:setData(key, value)
	end
	function charMeta:GetVar(var)
		if var == "charname" then return self:Name() end
		if var == "faction" then return self:getFaction() end
		if var == "id" then return self:getChar():getID() end
		return self:getVar(var)
	end
	function charMeta:SetVar(var, value)
		self:setVar(var, value)
	end
end
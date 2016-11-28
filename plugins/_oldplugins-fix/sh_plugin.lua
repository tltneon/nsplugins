PLUGIN.name = "FIX for NutScript 1.1 | ver.3"
PLUGIN.desc = "Allow to use simple plugins from NS 1.0" --Смягчает переход от NS 1.0 к NS 1.1
PLUGIN.author = "Neon"

// Github NS Plugins: https://github.com/tltneon/nsplugins

nut.util.include("sh_vars.lua")
BASE = ITEM or nut.item.base
phrases = {}


if (SERVER) then
	local PLUGIN = PLUGIN
	database = {}

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
		database[name] = table.Copy(tbl)
		PLUGIN:SaveData()
	end
end

function nut.util.Include(fileName, state)
	nut.util.include(fileName, state)
end

function nut.util.Notify(message, recipient)
	nut.util.notify(message, recipient)
end

function nut.util.AddLog(text, filter)
	nut.log.add(text, filter)
end

function nut.item.GetAll()
	return nut.item.list
end

function nut.faction.GetAll()
	return nut.faction.indices
end

function nut.class.GetAll()
	return nut.class.list
end

function nut.command.Register(data, cmd)
	nut.command.add(cmd, data)
end

function nut.flag.Create(flag, data)
	nut.flag.add(flag, data)
end

function nut.command.FindPlayer(client, name)
	return nut.command.findPlayer(client, name)
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
function nut.anim.SetModelClass(class, model)
	nut.anim.setModelClass(model, class)
end
function nut.anim.GetClass(model)
	if !model then model = "citizen_male" end
	return nut.anim.getModelClass(model)
end

function nut.plugin.Get(plugin)
	return nut.plugin[plugin]
end
function nut.item.Get(item)
	return nut.item.list[item]
end

function nut.currency.GetName(value)
	return nut.currency.get(value)
end

local entityMeta = FindMetaTable("Entity")
function entityMeta:GetNetVar(key, default)
	return self:getNetVar(key, default)
end
function entityMeta:SetNetVar(key, default)
	self:setNetVar(key, default)
end

local playerMeta = FindMetaTable("Player")
--playerMeta.character = playerMeta:getChar()

function playerMeta:HasMoney(money)
	return self:getChar():hasMoney(money)
end
function playerMeta:HasFlag(flag)
	return self:getChar():hasFlags(flag)
end
function playerMeta:GetNutVar(var, def)
	--self:getNutData(var, def)
	return self:getNetVar(var, def)
end
function playerMeta:SetNutVar(var, value)
	--self:setNutData(var, value)
	self:setNetVar(var, value)
end
function playerMeta:UpdateInv(uniqueID, quantity, data, _)
	quantity = quantity or 1
	if quantity >= 0 then
		self:getChar():getInv():add(uniqueID, quantity, data or {})
	else
		self:getChar():getInv():remove(uniqueID)
	end
end
function playerMeta:GetInventory()
	return playerMeta:getChar():getInv()
end
function playerMeta:Kick()
	self:kick()
end
function playerMeta:WepRaised()
	return self:isWepRaised()
end

local charMeta = nut.meta.character
function charMeta:GetVar(var)
	if var == "charname" then return self:getName() end
	if var == "faction" then return self:getFaction() end
	if var == "id" then return self:getChar():getID() end
	return self:getVar(var)
end
function charMeta:SetVar(var, value)
	self:setVar(var, value)
end
	
local ITEM = nut.meta.item or {}
function ITEM:Hook(name, func)
	self:hook(name, func)
end
function ITEM:GetDesc()
	return self.desc
end
if CLIENT then
	--Fonts
	surface.CreateFont("nut_TargetFont", {
		font = "Myriad Pro",
		size = 16,
		weight = 500,
		antialias = true
	})
	surface.CreateFont("nut_ScoreTeamFont", {
		font = "Myriad Pro",
		size = 16,
		weight = 500,
		antialias = true
	})
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
	
	--Hooks
	netstream.Hook("nut_FadeIn", function(data)
		local color = data[1]
		local r, g, b, a = color.r, color.g, color.b, color.a or 255
		local time = data[2]
		local start = CurTime()
		local finish = start + time

		nut.fadeColor = color

		hook.Add("HUDPaint", "nut_FadeIn", function()
			local fraction = math.TimeFraction(start, finish, CurTime())

			surface.SetDrawColor(r, g, b, fraction * a)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end)
	end)

	netstream.Hook("nut_FadeOut", function(data)
		local color = data[2] or nut.fadeColor

		if (color) then
			local r, g, b, a = color.r, color.g, color.b, color.a or 255
			local time = data[1]
			local start = CurTime()
			local finish = start + time

			hook.Add("HUDPaint", "nut_FadeIn", function()
				local fraction = 1 - math.TimeFraction(start, finish, CurTime())

				if (fraction < 0) then
					return hook.Remove("HUDPaint", "nut_FadeIn")
				end

				surface.SetDrawColor(r, g, b, fraction * a)
				surface.DrawRect(0, 0, ScrW(), ScrH())		
			end)
		end
	end)
	
	--Panels
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
	
	--Functions
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
	function nut.currency.Spawn(amount, pos, angle)
		nut.currency.Spawn(pos, amount, angle)
	end
	function nut.db.Escape(str)
		return nut.db.escape(str)
	end
	function nut.char.Save(chr)
	end
	function PLUGIN:PlayerLoadedChar(client)
		client.character = client:getChar()
	end
	
	function playerMeta:HasInvSpace(item, test, _, _)
		local w, h = nut.item.list[item.uniqueID].width, nut.item.list[item.uniqueID].height
		if self:getChar():getInv():findEmptySlot(w, h, false) then return true end
		return false
	end
	function playerMeta:CanAfford(price)
		return self:getChar():hasMoney(price)
	end
	function playerMeta:TakeMoney(amount)
		self:getChar():giveMoney(-amount)
	end
	function playerMeta:GiveMoney(amount)
		self:getChar():giveMoney(amount)
	end
	function playerMeta:RealName(player)
		return self:steamName()
	end
	function playerMeta:HasItem(item)
		return self:getChar():getInv():hasItem(item)
	end
	function playerMeta:ScreenFadeIn(time, color)
		time = time or 5
		color = color or Color(25, 25, 25)
		netstream.Start(self, "nut_FadeIn", {color, time})
	end

	function playerMeta:ScreenFadeOut(time, color)
		netstream.Start(self, "nut_FadeOut", {time or 5, color})
	end

	function charMeta:UpdateAttrib(key, value)
		self:updateAttrib(key, value)
	end
	function charMeta:GetAttrib(key, value)
		return self:getAttrib(key, value)
	end
	function charMeta:GetData(key, value)
		return self:getData(key, value)
	end
	function charMeta:SetData(key, value)
		self:setData(key, value)
	end
end

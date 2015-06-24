PLUGIN.name = "Writing Notes"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Go write something"

local playerMeta = FindMetaTable("Player")

if SERVER then


	netstream.Hook( "Nut_SubmitNote", function( client, data )
		local text = data[1]
		local ent = data[2]
		local note = ents.GetByIndex( ent )
		if note:IsValid() then
			note:setNetVar( "text", text )
		end
		print( tostring( client ) .. ": Pushed new note." )
	end)

	function playerMeta:OpenNote( text, entity, private )
		netstream.Start( self, "Nut_PushNote", {text, entity:EntIndex(), private})
	end
	
	function PLUGIN:LoadData()
		local restored = self:getData()

		if (restored) then
			for k, v in pairs(restored) do
				local position = v.position
				local angles = v.angles
				local private = v.private
				local text = v.text
				local owner = v.owner

				local entity = ents.Create("nut_note")
				entity:SetPos(position)
				entity:SetAngles(angles)
				entity:Spawn()
				entity:Activate()
				entity:setNetVar("private", private)
				entity:setNetVar("text", text)
				entity:setNetVar("owner", owner)
			end
		end
	end

	function PLUGIN:SaveData()
		local data = {}

		for k, v in pairs(ents.FindByClass("nut_note")) do
			data[#data + 1] = {
				position = v:GetPos(),
				angles = v:GetAngles(),
				private = v:getNetVar("private"),
				text = v:getNetVar("text"),
				owner = v:getNetVar("owner"),
			}
		end

		self:setData(data)
	end
	
end

if CLIENT then
	
	
	function PLUGIN:ShouldDrawTargetEntity(entity)
		if (entity:GetClass() == "nut_note") then
			return true
		end
	end

	function PLUGIN:DrawTargetID(entity, x, y, alpha)
		if (entity:GetClass() == "nut_note") then
			local color = Color(255,255,255,255)

			nut.util.drawText(x, y, L"note_name", color)
				y = y + nut.config.targetTall
				local text = L"note_desc"
			nut.util.drawText(x, y, text, Color(255, 255, 255, alpha))
		end
	end
	
	function nut_OpenNote( text, entity, private )
		if note then note:Remove(); note=nil end
		note = vgui.Create( "DFrame" )
		note:SetSize( 300, 400 )
		note:Center()
		note:SetTitle( "" )
		note:ShowCloseButton( false )
		note:MakePopup()
		note.text = text
		note.Paint = function()
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawRect( 0, 22, note:GetWide(), note:GetTall() -22-30  ) 
		end
		
		function note:viewmode()
			if note.editor then
			note.text = note.editor:GetValue()
			note.editor:Remove() note.editor = nil end
			note.viewer = vgui.Create( "RichText", note )
			note.viewer:SetPos( 2, 26 )
			note.viewer:SetSize( note:GetWide()-4, note:GetTall()-28-30)
			timer.Simple( 0.05, function()
				note.viewer:SetFontInternal( "ChatFont" )
				note.viewer:SetText( note.text )
			end)
		end
		
		function note:editmode()
			if note.viewer then note.viewer:Remove() note.viewer = nil end
			if note.close then note.edited = true; note.close:SetText( L"Submit" ) end
			note.editor = vgui.Create( "DTextEntry", note )
			note.editor:SetPos( 2, 26 )
			note.editor:SetSize( note:GetWide()-4, note:GetTall()-28-30)
			note.editor:SetFont( "ChatFont" )
			note.editor:SetMultiline( true )
			note.editor:SetText( note.text )
			note.editor:SetAllowNonAsciiCharacters( true )
		end
		note:viewmode()
		
		local noteent = ents.GetByIndex( entity )
		print(noteent:getNetVar( "owner" ),  LocalPlayer():SteamID())
		if( !private or ( private and noteent:getNetVar( "owner" ) == LocalPlayer():SteamID() ) ) then
			note.edit = vgui.Create( "DButton", note )
			note.edit:SetSize( 148, 20 )
			note.edit:SetPos( 0, note:GetTall()-28 )
			note.edit:SetText( L"Edit" )
			note.edit.view = true
			note.edit:SetTextColor(color_white)
			note.edit.DoClick = function()
				if note.edit.view then
					note.edit:SetText( L"View" )
					note.edit.view = false
					note:editmode()
				else
					note.edit:SetText( L"Edit" )
					note.edit.view = true
					note:viewmode()
				end
			end
		end
		
		note.close = vgui.Create( "DButton", note )
		note.close:SetSize( 148, 20 )
		note.close:SetPos( 151, note:GetTall()-28 )
		note.close:SetText( L"Close" )
		note.close:SetTextColor(color_white)
		note.close.DoClick = function()
			if note.edited then --submit edited texts.
				local go
				if note.editor then
					go = note.editor:GetValue()
				else
					go = note.text
				end
				nut_SubmitNote( go, entity )
			end
			note:Remove()
			note = nil 
		end
	end
	
	function nut_SubmitNote( text, entity )
		netstream.Start("Nut_SubmitNote", {text, entity})
	end
	
	netstream.Hook( "Nut_PushNote", function( data )
		local text = data[1]
		local ent = data[2]
		local private = data[3]
		nut_OpenNote( text, ent, private )
	end)

end

/*
	Why this is not working shit!
	if shit then shit:Remove() shit = nil end

	local PANEL = {}

	function PANEL:EditMode()
		if self.viewer then self.viewer:Remove() self.viewer = nil end
		if self.close then self.edited = true; self.close:SetText( "Submit" ) end

		self.editor = vgui.Create( "DTextEntry", self )
		self.editor:SetPos( 2, 2 )
		self.editor:SetSize( self:GetWide()-4, self:GetTall()-35)
		self.editor:SetFont( "ChatFont" )
		self.editor:SetMultiline( true )
		self.editor:SetText( self.text )
	end

	function PANEL:ViewMode()
		if self.editor then
		self.text = self.editor:GetValue()
		self.editor:Remove() self.editor = nil end
		self.viewer = vgui.Create( "RichText", self )
		self.viewer:SetPos( 2, 2 )
		self.viewer:SetSize( self:GetWide()-4, self:GetTall()-35)
		timer.Simple( 0, function()
			self.viewer:SetFontInternal( "ChatFont" )
			self.viewer:SetText( self.text )
		end)
	end

	function PANEL:Init()
		self:SetSize( 300, 400 )
		self:MakePopup()
		self.text = "asd"
		self.edited = false
		self:ViewMode()
		
		self.edit = vgui.Create( "DButton", self )
		self.edit:SetSize( 148, 25 )
		self.edit:SetPos( 1, self:GetTall()-28 )
		self.edit:SetText( "Edit" )
		self.edit.view = true
		self.edit.DoClick = function()
			if self.edit.view then
				self.edit:SetText( "View" )
				self.edit.view = false
				self:EditMode()
			else
				self.edit:SetText( "Edit" )
				self.edit.view = true
				self:ViewMode()
			end
		end
		
		self.close = vgui.Create( "DButton", self )
		self.close:SetSize( 148, 25 )
		self.close:SetPos( 151, self:GetTall()-28 )
		self.close:SetText( "Close" )
		self.close.DoClick = function()
			if self.edited then --submit edited texts.
			end
			self:Remove()
			self = nil 
		end

	end

	function PANEL:Paint()
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawRect( 0, 0, shit:GetWide(), shit:GetTall() -30  ) 
	end

	vgui.Register( "Nut_Note", PANEL, "Panel" )

	shit = vgui.Create( "Nut_Note" )
	shit:Center()
*/
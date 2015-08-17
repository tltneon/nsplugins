local PLUGIN = PLUGIN
PLUGIN.name = "CID Visual"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Visual CID Plugin."

PLUGIN.defaultcid = "cid2"

/*---------------------------------------------------------
				THIS PLUGIN NEEDS FEW CUSTOMIZATION BY YOU.
				THIS PLUGIN WILL NOT WORK PROPERLY IN CERTAIN
				CIRCUMSTANCE AND IF YOU DIDN'T DO ANTYTING WITH
				THIS PLUGIN.
				
				THINGS NEED TO BE CHANGED
				LINE 260: PLUGIN:GetDefaultInv()
				CONDITION: IF YOU MADE ANY CUSTOM CITIZEN FACTION
				YOU HAVE TO MOD THIS LINE!
				
----------------------------------------------------------*/


nut.lang.Add("vcid_shown", "You have shown %s's CID to someone in front of you.")
nut.lang.Add("vcid_retrive", "You have retrived %s's CID from someone in front of you.")
nut.lang.Add("vcid_invalidtarget", "You must face someone to show your CID")
nut.lang.Add("vcid_examine", "You examine CID Card.")
nut.lang.Add("vcid_nocid", "No citizen ID found.")
nut.lang.Add("vcid_def", "Failed to load")

nut.lang.Add("vcid_det_me", "say /me switches something.")
nut.lang.Add("vcid_det_beep", "say /it something is beeping frequently.")

nut.lang.Add("vcid_forge_afford", "You don't have a CID forging kit.")
nut.lang.Add("vcid_forge_success", "You have created Fake CID with the fake name '%s'.")

if CLIENT then
	
	surface.CreateFont( "Nut_CIDFont",
	{
		font = "Constantia",
		size = 25,
		weight = 1500,
		strikeout = true,
	})
	surface.CreateFont( "Nut_CIDFontB",
	{
		font = "Constantia",
		size = 25,
		weight = 1500,
		blursize = 3,
	})
	surface.CreateFont( "Nut_CIDPPFont",
	{
		font = "Consolas",
		size = 15,
		weight = 1000,
	})
	surface.CreateFont( "Nut_CIDAPFont",
	{
		font = "Tahoma",
		size = 18,
		weight = 500,
	})

	/*--------------------------------------------------------------
		
		BLACK TEA STUDIO VGUI PANEL
		o-----
						
		This panel allows you to draw more than one more client-
		side models on the panel.
		
	---------------------------------------------------------------*/


	local PANEL = {}

	function PANEL:Init()
		self.camvec = Vector( 0, 0, 0 )
		self.camang = Angle( 0, 0, 0 )
		self.camfov = 30
		
		self.light = {}
		self.light.Ambient = Color( 50, 50, 50 )
		self.light.Modulation = Color( 250, 250, 250 )
		self.light[BOX_TOP] = Color( 255, 255, 255 )
		self.light[BOX_FRONT] = Color( 255, 255, 255 )
		self.models = {}
		self.ments = {}; -- Can't be changed. This table must not touched.
		
	end

	function PANEL:SetModelData( tbl )
		self.models = tbl	
		self:MakeStudio()
	end

	function PANEL:MakeStudio()
		for uid, dat in pairs( self.models ) do
			if self.ments[ uid ] and self.ments[ uid ]:IsValid() then
				self.ments[ uid ]:Remove()
				self.ments[ uid ] = nil
			end
			self.ments[ uid ] = ClientsideModel( dat.mdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
			self.ments[ uid ]:SetPos( dat.pos )
			self.ments[ uid ]:SetAngles( dat.ang )
			self.ments[ uid ]:SetNoDraw( true )
			self.ments[ uid ].col = dat.col
		end
	end

	function PANEL:PreModelPaint()
		surface.SetDrawColor( 0, 0, 0, 80 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	function PANEL:PostModelPaint()
	end
	function PANEL:Paint()
		self:PreModelPaint()
		
		local x, y = self:LocalToScreen( 0, 0 )
		local w, h = self:GetSize()
		cam.Start3D( self.camvec, self.camang, self.camfov, x, y, w, h, 5, 4096 )
			render.SuppressEngineLighting( true )
			render.SetColorModulation( 1, 1, 1 )
			for k,v in pairs(self.ments) do
				v:DrawModel()
			end
			render.SuppressEngineLighting( false )
		cam.End3D()
		
		self:PostModelPaint()
	end
	vgui.Register("BT_Studio", PANEL, "DPanel")



	/*--------------------------------------------------------------
		
		BLACK TEA CITIZEN ID LAYOUTS		
		This panel is just an eyecandy.
		
	---------------------------------------------------------------*/

	local PANEL = {}
	function PANEL:Init()
		self.face = vgui.Create( "BT_Studio", self )
		self.face:SetSize( 65, 85 )
		self.face:SetPos( 18, 60 )

		self.name = "Faild To Load"
		self.cid = "Failed To Load"
	end
	function PANEL:Paint()
		
		-- OH FUCKING GOD I HATE FUCKING VGUI
		-- CITIZEN ID LAYOUT
		local w, h = self:GetWide(), self:GetTall()
		draw.RoundedBox( 16, 0, 0, w, h, Color( 255,255,255 ) )
		surface.SetDrawColor( 0, 0, 0 )
		surface.DrawRect( 0, h/5, w, 5 )
		surface.DrawRect( 0, h/5+8	, w, 5 )
		
		-- TOP CID
		surface.SetTextPos( 13, 6 )
		surface.SetTextColor( 100, 0, 0 )
		surface.SetFont( "Nut_CIDFontB" )
		surface.DrawText( "CITIZEN ID" )
		
		surface.SetFont( "Nut_CIDFont" )
		surface.SetTextPos( 13, 6 )
		surface.SetTextColor( 0, 0, 0 )
		surface.DrawText( "CITIZEN ID" )
		
		-- INFORMATIONS
		surface.SetFont( "Nut_CIDPPFont" )
		surface.SetTextColor( 0, 0, 0 )
		surface.SetTextPos( 100, h/5+30 )
		surface.DrawText( "NAME" )
		surface.SetTextPos( 99, h/5+70 )
		surface.DrawText( "CITIZEN ID" )
		
		surface.SetFont( "Nut_CIDAPFont" )
		surface.SetTextColor( 0, 0, 0 )
		surface.SetTextPos( 100, h/5+45 )
		surface.DrawText( self.name )
		surface.SetTextPos( 99, h/5+85)
		surface.DrawText( self.cid )
		
	end
	vgui.Register( "Nut_CIDp", PANEL, "DPanel" )

	local PANEL = {}
	function PANEL:Init()
		local sh = 200
		self:SetTitle( "" )
		self:SetSize( sh*1.5, sh )
		self.vis = vgui.Create( "Nut_CIDp", self )
		self.vis:Dock( FILL )	
	end

	function PANEL:Paint()
		-- CID Paint	
	end

	function PANEL:SetInformation( name, id, model )
		self.vis.name = name
		self.vis.cid = id
		self.vis.face:SetModelData( {
			["char"] = { mdl = model, pos = Vector( 25, 0, -66 ), ang = Angle( 0, 180, 0 ), col = Color( 255, 255, 255 ) },
		} )
	end
	vgui.Register( "Nut_CID", PANEL, "DFrame" )

	netstream.Hook( "Nut_ShowCID", function( data )
		if cid then cid:Remove() cid = nil end

		cid = vgui.Create( "Nut_CID" )
		cid:MakePopup()
		cid:Center()
		cid:SetInformation( data[1], data[2], data[3] )
	end)
	
else

	local playerMeta = FindMetaTable("Player")
	function playerMeta:ShowCID( player, cidnum, cidname, cidmodel, forged, examine )
	
		-- If CID data is not valid
		if !( player || cidnum || cidname || cidmodel ) then
			nut.util.Notify( nut.lang.Get( "vcid_shown", cidname ) , player ) 
			print( "Error: Wrong ShowCID request has been made. Please check your code." )
			return
		end
		
		-- If this action is not done by you.
		if !examine then
			print( player:Name() .. " shown " .. cidname .. "'s CID to " .. self:Name() )
			nut.util.Notify( nut.lang.Get( "vcid_shown", cidname ) , player ) 
			nut.util.Notify( nut.lang.Get( "vcid_retrive", cidname ) , self ) 
		else
			nut.util.Notify( nut.lang.Get( "vcid_examine", cidname ) , self ) 
		end
		
		-- If you have Fake CID detector On..
		for invkey, dat in pairs( self:GetItemsByClass( "cid_fdet" ) ) do
			if dat.data.On == "on" then
				if forged then
					self:UpdateInv( "cid_fdet", -1, dat )
					self:ConCommand( nut.lang.Get( "vcid_det_beep") )
					self:EmitSound( "npc/attack_helicopter/aheli_damaged_alarm1.wav" )
				end
				break
			end
		end
		
				
		netstream.Start( self, "Nut_ShowCID", { cidname, cidnum, cidmodel })
	end	
	
	nut.command.Register({
		syntax = "",
		onRun = function(client, arguments)
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector()*84
				data.filter = client
			local trace = util.TraceLine(data)

			local cid = arguments[1]
			local entity = trace.Entity
			
			if (IsValid(entity) and entity:IsPlayer() and entity.character) then

				local default = false
				if cid then
					local itemdata = nut.item.Get(cid)
					if itemdata then
						if !itemdata.cid then
							default = true
							cid = PLUGIN.defaultcid
						end
					else
						local found = false
						for class, stack in pairs(client:GetInventory()) do
							local itemdata = nut.item.Get(class)
							if itemdata.cid then
								if string.find(string.lower(itemdata.name), string.lower(cid)) then
									cid = class
									found = true

									break
								end
							end
						end

						if !found then
							default = true
							cid = PLUGIN.defaultcid
						end
					end
				else
					cid = PLUGIN.defaultcid
				end

				local items = client:GetItemsByClass(cid)

				for k, v in pairs(items) do
					local data = v.data

					if data then
						if data.Digits and data.Owner then
							if default then
								nut.util.Notify( "No ID Itemdata, Showing default id.", client )
							end

							entity:ShowCID( client, data.Digits, data.Owner, data.Model, data.Forged )

							return
						end
					end
				end

			else
				nut.util.Notify( nut.lang.Get( "vcid_invalidtarget" ), client )
			end
		end
	}, "showid")

	nut.command.Register({
		syntax = "",
		onRun = function(client, arguments)
			for i = 1, 3 do
				if !arguments[i] then
					nut.util.Notify( "Missing argument #".. i, client )

					return
				end
			end

			local target = nut.util.FindPlayer(arguments[1])
			local cid = arguments[2]
			local digits = arguments[3]

			if (IsValid(target) and target:IsPlayer() and target.character) then

				if cid then
					local itemdata = nut.item.Get(cid)
					if itemdata then
						if !itemdata.cid then
							nut.util.Notify( "ID Itemdata not found.", client )	

							return
						end
					else
						local found = false
						for class, stack in pairs(client:GetInventory()) do
							local itemdata = nut.item.Get(class)
							if itemdata.cid then
								if string.find(string.lower(itemdata.name), string.lower(cid)) then
									cid = class
									found = true

									break
								end
							end
						end

						if !found then
							nut.util.Notify( "ID Itemdata not found.", client )	

							return
						end
					end
				end

				local items = client:GetItemsByClass(cid)
				for k, v in pairs(items) do
					local olddata = v.data
					local newdata = table.Copy(olddata)
					newdata.Owner = target:Name()
					newdata.Model = target:GetModel()
					newdata.Digits = digits

					target:UpdateInv(cid, -1, olddata)
					target:UpdateInv(cid, 1, newdata)

					nut.util.Notify( "ID has been modified.", client )	

					break
				end
			else
				nut.util.Notify( nut.lang.Get( "vcid_invalidtarget" ), client )
			end
		end
	}, "modid")
	
	function PLUGIN:GetDefaultInv(inventory, client, data)
		if (data.faction == FACTION_CITIZEN) then -- THIS LINE SHOULD BE CHANGED IF YOU HAVE CUSTOM CITIZEN FACTION!
			inventory:Add("cid2", 1, {
				Digits = math.random(11111, 99999), 
				Owner = data.charname,
				Model = data.model
			})
		end
	end

end


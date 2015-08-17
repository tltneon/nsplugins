local PLUGIN = PLUGIN
PLUGIN.name = "ViewBob"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "1337 S0 DR4M4T1C"
PLUGIN.config = PLUGIN.config or {}
PLUGIN.config.scale = PLUGIN.config.scale or 1
PLUGIN.config.distance = PLUGIN.config.distance or 0
local buffPLUGIN = nut.plugin.Get( "buffs" )
if not buffPLUGIN then
	print( 'Leg Break Buff will not work properly without "buffs" plugin!' )
end

if CLIENT then
	
	function PLUGIN:SchemaInitialized()
		local contents 
		local decoded
		if (file.Exists("nutscript/client/viewbob.txt", "DATA")) then
			contents = file.Read("nutscript/client/viewbob.txt", "DATA")
		end
		if contents then
			decoded = von.deserialize(contents)
		end
		if decoded then
			PLUGIN.config = decoded
		end
	end

	function PLUGIN:ShutDown()
		local encoded = von.serialize(PLUGIN.config)
		file.CreateDir("nutscript/")
		file.CreateDir("nutscript/client/")
		file.Write("nutscript/client/viewbob.txt", encoded)
	end

	local mc = math.Clamp
	local curang = Angle( 0, 0, 0 )
	local curvec = Vector( 0, 0, 0 )

	local tarang = Angle( 0, 0, 0 )
	local tarvec = Vector( 0, 0, 0 )

	local transang = Angle( 0, 0, 0 )
	
	local GetVelocity = FindMetaTable("Entity").GetVelocity
	local Length2D = FindMetaTable("Vector").Length2D

	local nobob = {
		"weapon_physgun",
		"gmod_tool",
	}

	function PLUGIN:CreateQuickMenu(panel)
		local label = panel:Add("DLabel")
		label:Dock(TOP)
		label:SetText(" Viewbob Settings")
		label:SetFont("nut_TargetFont")
		label:SetTextColor(Color(233, 233, 233))
		label:SizeToContents()
		label:SetExpensiveShadow(2, Color(0, 0, 0))

		local category = panel:Add("DPanel")
		category:Dock(TOP)
		category:DockPadding(10, 5, 0, 5)
		category:DockMargin(0, 5, 0, 5)
		category:SetTall(62)

		local vb_scale = category:Add("DNumSlider")
		vb_scale:Dock(TOP)
		vb_scale:SetText( "Viewbob Scale" )   // Set the text above the slider
		vb_scale.Label:SetTextColor(Color(22, 22, 22))
		vb_scale:SetMin( 0 )                  // Set the minimum number you can slide to
		vb_scale:SetMax( 2 )                // Set the maximum number you can slide to
		vb_scale:SetDecimals( 1 )             // Decimal places - zero for whole number
		vb_scale:SetTall( 25 )             // Decimal places - zero for whole number
		vb_scale:SetValue( self.config.scale )

		function vb_scale:OnValueChanged( val )
			local val = self:GetValue()
			PLUGIN.config.scale = val
		end

		local vb_distance = category:Add("DNumSlider")
		vb_distance:Dock(TOP)
		vb_distance:SetText( "View Distance" )   // Set the text above the slider
		vb_distance.Label:SetTextColor(Color(22, 22, 22))
		vb_distance:SetMin( 0 )                  // Set the minimum number you can slide to
		vb_distance:SetMax( 200 )                // Set the maximum number you can slide to
		vb_distance:SetDecimals( 0 )             // Decimal places - zero for whole number
		vb_distance:SetTall( 25 )             // Decimal places - zero for whole number
		vb_distance:SetValue( self.config.distance )

		function vb_distance:OnValueChanged( val )
			local val = self:GetValue()
			PLUGIN.config.distance = val
		end
	end

	function PLUGIN:ShouldDrawLocalPlayer()
		if ( LocalPlayer():Alive() && LocalPlayer().character ) then
			if ( LocalPlayer():GetOverrideSeq() or LocalPlayer():IsRagdolled() ) then
				return true
			end
			if self.config.distance > 0 then
				return true
			end
		end
		return false
	end
	
	local class
	function PLUGIN:CalcView( ply, pos, ang, fov )
		local rt = RealTime()
		local ft = FrameTime()
		local vel = math.floor( Length2D(GetVelocity(ply)) )
		local runspeed = ply:GetRunSpeed()
		local walkspeed = ply:GetWalkSpeed()
		local wep = ply:GetActiveWeapon()
		if wep and wep:IsValid() then
			class = ply:GetActiveWeapon():GetClass()
		else
			class = ""
		end
		local v = {}
		if 
			( ply:IsValid() &&
			ply:Alive() &&
			ply.character &&
			!ply:GetOverrideSeq()  &&
			!ply:IsRagdolled()
			)
		then
			if !ply:ShouldDrawLocalPlayer() and (!table.HasValue(nobob, class)) then
				if ply:OnGround() then
					if vel > walkspeed+5 then
						local perc = vel/runspeed*100
						perc = math.Clamp( perc, .5, 6 )
						perc = perc * self.config.scale
						tarang = Angle( math.abs( math.cos( rt*(runspeed/33) )*.4*perc ), math.sin( rt*(runspeed/29) ) * .5 * perc, 0 )
						tarvec = Vector( 0, 0, math.sin( rt*(runspeed/30) )*.4*perc )
					else
						local perc = vel/walkspeed*100
						perc = math.Clamp( perc/30, 0, 4 )
						perc = perc * self.config.scale
						tarang = Angle( math.cos( rt*(walkspeed/8) ) * .2 * perc, 0, 0 )
						tarvec = Vector( 0, 0, (math.sin( rt*(walkspeed/8) ) * .5)*perc )
						
						if buffPLUGIN then
							if ply:HasBuff( "leghurt" ) then
								if vel > 40 then
									tarang = tarang + Angle( 0 ,0, math.abs( math.cos( rt * 2 )  ) * -perc - 2 )
								end
							end
						end
						
					end
				else
					if ply:WaterLevel() >= 2 then
						tarvec = Vector( 0, 0, 0 )
						tarang = Angle( 0, 0, 0 )
					else	
						local vel = math.abs( ply:GetVelocity().z )
						local af = 0
						perc = math.Clamp( vel/200, .1, 8 )
						perc = perc * self.config.scale
						if perc > 1 then
							af = perc
						end
						tarang = Angle( math.cos( rt*15 ) * 2 * perc + math.Rand( -af*2, af*2 ), math.sin( rt*15 ) * 2 * perc + math.Rand( -af*2, af*2 ) ,math.Rand( -af*5, af*5 )  )
						tarvec = Vector( math.cos( rt*15 ) * .5 * perc , math.sin( rt*15 ) * .5 * perc, 0 )
					end
				end
				
				if self.config.scale > .1 then
					transang = LerpAngle( mc(mc(FrameTime(), 1/120, 1)*10,0,5), transang, ang)
				else
					transang = ang
				end
				curang = LerpAngle( ft * 10, curang, tarang )
				curvec = LerpVector( ft * 10, curvec, tarvec )
				
				v.angles = transang + curang
				v.origin = pos + curvec
				v.fov = fov
			else
				local data = {}
					data.start = pos
					data.endpos = data.start + ang:Up() * self.config.distance/3 + ang:Forward()*-self.config.distance
					data.filter = ply
				local trace = util.TraceLine(data)

				v.angles = ang + curang
				v.origin = trace.HitPos + curvec
				v.fov = fov
			end
			
			return GAMEMODE:CalcView(ply, v.origin, v.angles, v.fov)
			
		end
		
	end
	
end
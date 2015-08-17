ENT.Type = "anim"
ENT.PrintName = "Cock Reader"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.BurnArea = 100
ENT.BurnTime = 15
ENT.BurnDam = 20


if (SERVER) then

	util.AddNetworkString("nut_CardVerification")
	
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_smallmonitor001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		local p = self:GetPhysicsObject()
		p:EnableCollisions( false )
	end

	function ENT:Use(activator)
		if !activator.nextUse or activator.nextUse < CurTime() then
			net.Start( "nut_CardVerification" )
				net.WriteEntity( self )
			if activator:HasItem( "comkey" ) then
				net.WriteFloat( 2 )
				if self.door then
					for _, door in pairs( ents.FindInSphere( self.door, 5 ) ) do
						door:Fire( "open", .1 )
					end
				end
			else
				net.WriteFloat( 1 )
			end
			net.Broadcast()
			activator.nextUse = CurTime() + 1
		end
	end
	
else

	local curstat = {
		[0] = { "인증 필요", { 90, 150, 170 } },
		[1] = { "인증 실패", { 150, 20, 20 }, "buttons/combine_button2.wav" },
		[2] = { "인증 성공", { 90, 150, 100 }, "buttons/combine_button1.wav" },
	}
	
	net.Receive( "nut_CardVerification", function( len )
		local ent = net.ReadEntity()
		local stat = net.ReadFloat()
		if !ent:IsValid() then return end
		ent.ResetTime = CurTime() + 2
		ent.status = stat
		ent:EmitSound( curstat[ stat ][3] )
	end)

	function ENT:Initialize()
		self.width = 170
		self.height = 180
		self.scale = .1
	end

	
	function ENT:Think()
		if !self.ResetTime or self.ResetTime < CurTime() then
			self.status = 0
		end
		self:NextThink( CurTime() + 1 )
	end
	
	local grd = surface.GetTextureID("vgui/gradient_down")
	function ENT:Draw()
	
		self:DrawModel()		
		if LocalPlayer():GetPos():Distance( self:GetPos() ) > 200 then return end
		
		local pos, ang = self:GetPos(), self:GetAngles()
		local wide, tall = 165, 180
		pos=pos+self:GetRight()*7
		pos=pos+self:GetForward()*13
		pos=pos+self:GetUp()*20
		
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)
	
		cam.Start3D2D(pos, ang, .1)
			
			local alpha = 120 + math.sin( RealTime() * 80 ) * 10
			surface.SetDrawColor(80,80,80,alpha)
			surface.DrawRect(0,0,wide,tall)
			
			surface.SetTexture(grd)
			surface.SetDrawColor(10,10,10,alpha)
			surface.DrawTexturedRect(0,0,wide,tall)
			
			
			local alpha2 = math.abs( math.cos( RealTime() * 80 ) * 100 )
			local text = "출입 제어 시스템"
			surface.SetFont("DermaDefaultBold")
			local tx, ty = surface.GetTextSize( text )
			surface.SetTextColor(255,255,255,255 - alpha2 ) 
			surface.SetTextPos( wide / 2 - tx / 2 ,60)
			surface.DrawText( text )
			
			local text = curstat[ self.status ][1]
			surface.SetFont("DermaLarge")
			local tx, ty = surface.GetTextSize( text )
			local col = curstat[ self.status ][2]
			surface.SetTextColor( col[1]/2 , col[2]/2 , col[3]/3 ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 + math.random( -2, 2 ), tall/2 - ty/2 + math.random( -2, 2 ))
			surface.DrawText( text )
			
			surface.SetTextColor( col[1] , col[2] , col[3] ,255 - alpha2 )
			surface.SetTextPos( wide / 2 - tx / 2 , tall/2 - ty/2 )
			surface.DrawText( text )
			
			
		cam.End3D2D()
		
	end
	
end


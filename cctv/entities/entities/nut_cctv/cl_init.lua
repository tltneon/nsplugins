include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

ENT.DisplayVector = Vector( 0, -2, 120 )
ENT.DisplayAngle = Angle( -90, 0, 90 )
ENT.DisplayScale = .5
function ENT:DrawTranslucent()
	local pos = self:GetPos() + self:GetUp() * self.DisplayVector.z + self:GetRight() * self.DisplayVector.x + self:GetForward() * self.DisplayVector.y
	local ang = self:GetAngles() 
	ang:RotateAroundAxis( self:GetRight(), self.DisplayAngle.pitch ) -- pitch
	ang:RotateAroundAxis( self:GetUp(),  self.DisplayAngle.yaw )-- yaw
	ang:RotateAroundAxis( self:GetForward(), self.DisplayAngle.roll )-- roll
	cam.Start3D2D( pos, ang, self.DisplayScale )
		surface.SetTexture( surface.GetTextureID( "pp/rt" ) )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect(-95, 60, 190, 125)
		surface.SetDrawColor( 0, 0, 0, 220 )
		surface.DrawOutlinedRect( -96 , 59, 192, 127 )
		draw.DrawText( self:GetNWString("camera", "Unknown"), "DermaDefaultBold", -90, 60, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT )
	cam.End3D2D()
end
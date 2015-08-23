ENT.Type = "anim"
ENT.PrintName = "Crafting Table"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/FurnitureTable002a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local physicsObject = self:GetPhysicsObject()
		if ( IsValid(physicsObject) ) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		netstream.Start( activator, "nut_CraftWindow", activator) 
	end
else
	netstream.Hook("nut_CraftWindow", function(client, data)
		if (IsValid(nut.gui.crafting)) then
			nut.gui.crafting:Remove()
			return
		end
		surface.PlaySound( "items/ammocrate_close.wav" )
		nut.gui.crafting = vgui.Create("nut_Crafting")
		nut.gui.crafting:Center()
	end)

	function ENT:Initialize()
	end
	
	function ENT:Draw()
		self:DrawModel()
	end

	ENT.DisplayVector = Vector( 0, 0, 18.5 )
	ENT.DisplayAngle = Angle( 0, 90, 0 )
	ENT.DisplayScale = .5
	function ENT:DrawTranslucent()
	local pos = self:GetPos() + self:GetUp() * self.DisplayVector.z + self:GetRight() * self.DisplayVector.x + self:GetForward() * self.DisplayVector.y
	local ang = self:GetAngles() 
	ang:RotateAroundAxis( self:GetRight(), self.DisplayAngle.pitch ) -- pitch
	ang:RotateAroundAxis( self:GetUp(),  self.DisplayAngle.yaw )-- yaw
	ang:RotateAroundAxis( self:GetForward(), self.DisplayAngle	.roll )-- roll
	cam.Start3D2D( pos, ang, self.DisplayScale )	
		surface.SetDrawColor( 0, 0, 0 )
		surface.SetTextColor( 255, 255, 255 )
		surface.SetFont( "ChatFont" )
		local size = { x = 10, y = 10 }
		size.x, size.y = surface.GetTextSize( nut.lang.Get( "craftingtable" ) )
		surface.SetTextPos( -size.x/2, -size.y/2 )
		size.x = size.x + 20; size.y = size.y + 15
		surface.DrawText( nut.lang.Get( "craftingtable" ) )
	cam.End3D2D()
	end

	function ENT:OnRemove()
	end
end

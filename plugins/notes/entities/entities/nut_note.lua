ENT.Type = "anim"
ENT.PrintName = "Note"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then

	function ENT:Initialize()
		self:SetModel("models/props_lab/clipboard.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:setNetVar("text", "")
		self:SetUseType(SIMPLE_USE)
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		activator:OpenNote( self:getNetVar( "text" ), self, self:getNetVar( "private" ) )
	end
	
else

	function ENT:Draw()
		self:DrawModel()
	end
	
end

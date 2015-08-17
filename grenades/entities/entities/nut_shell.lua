ENT.Type = "anim"
ENT.PrintName = "Shell"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/grenadeAmmo.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.lifetime = CurTime() + 10
		self:SetGravity( 0.1 ) 	
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Sleep()
		end
	end
	function ENT:OnRemove()
	end
	function ENT:Think()
		if self.lifetime < CurTime() then
			self:Remove()
		end
		if self:WaterLevel() > 0 then
			self:Remove()
		end
		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + self:GetUp()*-self.movespeed
		trace.filter = self 
		local tr = util.TraceLine( trace )
		if tr.HitSky then
			self:Remove()
		end
		if tr.Hit then
			local ef = EffectData()
			ef:SetOrigin(tr.HitPos)
			ef:SetMagnitude(2)
			
			util.Effect("Explosion", ef)
			self:Remove()
		else
			self:SetPos(tr.HitPos)
		end
		-- move the shit
		self:NextThink( CurTime() )
		return true
	end
	function ENT:Use(activator)
	end
else
	function ENT:Initialize()
		self.emitter = ParticleEmitter( self:GetPos() )
		self.emittime = CurTime()
	end
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:Think()
	end
end
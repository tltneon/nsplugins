ENT.Type = "anim"
ENT.PrintName = "Ammo Crate"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

local ammotable = {
	[ "smg1" ] = 300,
	[ "ar2" ] = 200, 
	[ "357" ] = 50, 
	[ "pistol" ] = 300,
}

if (SERVER) then
	
	function ENT:Initialize()
		self:SetModel("models/Items/ammocrate_ar2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetPlaybackRate(1)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
	
	function ENT:PackAmmo( activator )
		for n, a in pairs( ammotable ) do
			activator:GiveAmmo( a, n )
		end
	end
	
	function ENT:Use(activator)
		if !self.nextUse or self.nextUse < CurTime() then
			self:ResetSequence("close")
			self:EmitSound("items/ammocrate_open.wav")
			
			timer.Simple( .5, function()
				self:PackAmmo( activator )
			end)
			
			timer.Simple( 1, function()
				self:ResetSequence("open")
				self:EmitSound("items/ammocrate_close.wav")
			end)
			
			self.nextUse = CurTime() + 1
		end
	end
	
	function ENT:SpawnFunction( ply, tr )
		if ( !tr.Hit ) then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create( "nut_ammocrate" )
			ent:SetPos( SpawnPos )
			ent:Spawn()
		ent:Activate()
		return ent
	end

else

	function ENT:Draw()
		self:DrawModel()
	end
	
end


ENT.Type = "anim"
ENT.Base = "nut_m_base"
ENT.PrintName = "Can Machine"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript Machines"

ENT.MaxEnergy = 100
ENT.Supply = "ms_example"
ENT.EntThinkTime = 1

if (SERVER) then
	function ENT:GenerateItem()
		self:EmitSound("plats/elevator_stop.wav", 60, 140)
		local pos, ang = self:GetPos(), self:GetAngles()
		pos = pos + self:GetForward()*4
		pos = pos + self:GetUp()*-12
		pos = pos + self:GetRight()*-5
		
		self:AddSupply(-20)
		local item = nut.currency.spawn(pos, 333)
		local phys = item:GetPhysicsObject()
		phys:SetVelocity(self:GetForward()*phys:GetMass()*5)
	end
end
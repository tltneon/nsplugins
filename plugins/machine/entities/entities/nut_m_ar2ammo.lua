ENT.Type = "anim"
ENT.Base = "nut_m_base"
ENT.PrintName = "AR2 Ammo Machine"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript Machines"

ENT.MaxEnergy = 100
ENT.Supply = "ms_example"
ENT.EntThinkTime = 1
ENT.NextItemGenerate = 3

if (SERVER) then
	function ENT:GenerateItem()
		self:EmitSound("plats/elevator_stop.wav", 60, 140)
		local pos, ang = self:GetPos(), self:GetAngles()
		pos = pos + self:GetForward()*4
		pos = pos + self:GetUp()*-12
		pos = pos + self:GetRight()*-5

		self:AddSupply(-10)
		local item = nut.item.spawn("ammo_ar2", pos, Angle(0,0,0))
		local phys = item:GetPhysicsObject()
		phys:SetVelocity(self:GetForward()*phys:GetMass()*3)
	end
end
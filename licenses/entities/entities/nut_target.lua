AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Target"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetHealth(10)
	end

	function ENT:OnTakeDamage(damageInfo)
		if (damageInfo:GetDamage() > 0) then
			if damageInfo:GetAttacker() == self.tester and damageInfo:IsBulletDamage() then
				local newData = damageInfo:GetAttacker().character:GetVar("testData")
				newData.points = newData.points + 1
				damageInfo:GetAttacker().character:SetVar("testData", newData)
				-- Play some sound...
				self:Remove()
			end
		end
	end
end

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
end
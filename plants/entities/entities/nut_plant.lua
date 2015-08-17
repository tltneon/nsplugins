AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Plant"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		--self:SetModel("models/props/cs_office/plant01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:SetHealth(100)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		if (activator:IsPlayer()) then
			if self:GetNWString("time") - CurTime() <= 0 then
				if activator:HasInvSpace(nut.item.Get(self:GetNWString("plant")), 1, false) then
					activator:UpdateInv(self:GetNWString("plant"))
					nut.util.Notify(nut.item.Get(self:GetNWString("plant")).name.." gathered.", activator)
					self:Remove()
				else
					nut.util.Notify("You do not have enouth space in your inventory!", activator)
				end
			end
		end
	end

	function ENT:OnTakeDamage(damageInfo)
		if (damageInfo:GetDamage() > 0) then
			self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))
			if (self:Health() <= 0) then
				self:Remove()
			end
		end
	end
end

if (CLIENT) then
	-- Called when the entity should draw.
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTargetID(x, y, alpha)
		local mainColor = nut.config.mainColor
		local color = Color(mainColor.r, mainColor.g, mainColor.b, alpha)

		if self:GetNWString("plant", "ERROR") == "ERROR" or self:GetNWString("time", "ERROR") == "ERROR" then return end

		nut.util.DrawText(x, y, nut.item.Get(self:GetNWString("plant", "ERROR")).name, color)

		y = y + nut.config.targetTall
		color = Color(255, 255, 255, alpha)
		
		if tonumber(self:GetNWString("time")) - CurTime() > 0 then
			nut.util.DrawText(x, y, string.gsub("Ready in "..math.Round(tonumber(self:GetNWString("time", "ERROR")) - CurTime()).." seconds", "\n", " "), color, "nut_TargetFontSmall")
		else
			nut.util.DrawText(x, y, string.gsub("Ready to gather", "\n", " "), color, "nut_TargetFontSmall")
		end
	end
end
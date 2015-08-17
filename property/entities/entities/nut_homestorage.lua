AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Home Storage"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		if (activator:IsPlayer()) then
			if IsValid(self.storage) then
				netstream.Start(activator, "nut_Storage", self.storage)
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
		nut.util.DrawText(x, y, "Home Storage", color)
	end
end
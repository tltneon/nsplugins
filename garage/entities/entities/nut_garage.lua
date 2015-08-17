AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Garage"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_downtown/atm.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		if (activator:IsPlayer()) then
			activator:SendLua("vgui.Create('nut_Garage')")
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
		nut.util.DrawText(x, y, "Garage", color)
	end
end
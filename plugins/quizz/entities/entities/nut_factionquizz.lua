AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Faction Quizz"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = false
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_downtown/atm.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:AcceptInput(name, activator, ply, data)
		if name == "Use" and IsValid(ply) and ply:IsPlayer() then
			if PLUGIN.Quizzes[self.quizz] and PLUGIN:CanTakeQuizz(ply, self.quizz) then
				local toSend = table.Copy(PLUGIN.Quizzes[self.quizz])
				for k, v in pairs(toSend) do
					v.t = nil
				end

				netstream.Start(ply, "nut_OpenQuizz", {self.quizz, toSend})
			end
		end
	end
end
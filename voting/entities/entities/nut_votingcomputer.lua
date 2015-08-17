AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Voting Computer"
ENT.Author = "_FR_Starfox64"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_downtown/atm.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType( SIMPLE_USE )
	end

	function ENT:AcceptInput(name, activator, ply, data)
		if name == "Use" and IsValid(ply) and ply:IsPlayer() then
			if PLUGIN:CanVote(ply) then
				netstream.Start(ply, "nut_OpenVotingComputer", PLUGIN.votingList)
			end
		end
	end
end
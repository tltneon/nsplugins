AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function ENT:Initialize() 
 	self:SetUseType( SIMPLE_USE )
 	self:SetHullType( HULL_HUMAN )
 	self:SetHullSizeNormal()

 	self:SetUseType( SIMPLE_USE )
 	self:SetModel("models/Humans/Group01/male_07.mdl")

 	self:SetSolid( SOLID_BBOX )  
 	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NPC )
 	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	
 	self:SetMaxYawSpeed( 90 )
	self:SetNotSolid( false )
end

function ENT:AcceptInput(name, activator, ply, data)
	if name == "Use" and IsValid(ply) and ply:IsPlayer() then
		netstream.Start(ply, "rangeMenu")
	end
end
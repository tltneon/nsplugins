AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function ENT:Initialize()
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	--self:SetModel("models/breen.mdl")
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD) )
	self:SetUseType( SIMPLE_USE )
	--self:DropToFloor()
 
	self:SetMaxYawSpeed( 90 )
end

function ENT:AcceptInput(name, activator, ply, data)
	if name == "Use" and IsValid(ply) and ply:IsPlayer() then
		if self.type == "CIV" then
			if ply:HasLicense("driving") then
				ply:SendLua("VehShopType = 'CIV'")
			end
		elseif self.type == "ECPD" then
			if ply.character:GetVar("faction") == FACTION_CP then
				ply:SendLua("VehShopType = 'ECPD'")
			else
				return
			end
		elseif self.type == "EMT" then
			if ply.character:GetVar("faction") == FACTION_EMT then
				ply:SendLua("VehShopType = 'EMT'")
			else
				return
			end
		end
		ply:SendLua("vgui.Create('nut_VehShop')")
	end
end
AddCSLuaFile()

SWEP.PrintName = "Defibrillator"
SWEP.Author = "Sinavestos edited by Jeezy; Ported to NS 1.1 by Neon"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to revive the wounded"

SWEP.Spawnable = false       -- Change to false to make Admin only.
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true
SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "none"

SWEP.DefibSound = "ambient/energy/zap1.wav"
SWEP.DefibCooldown = 20

if ( SERVER ) then
	function SWEP:Initialize()
		util.PrecacheSound( self.DefibSound )
		self:SetHoldType( "pistol" )
	end

	function SWEP:PrimaryAttack()
		self.Owner.nextDefib = self.Owner.nextDefib or 0
		if ( self.Owner.nextDefib > CurTime( ) ) then
			local timeRemaining = self.Owner.nextDefib - CurTime( )
			self.Owner:notify( "You must wait another " .. timeRemaining .. "." )
			return
		end
		local traceRes = self.Owner:GetEyeTrace()
		if ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_ragdoll" ) then
			local traceEnt = traceRes.Entity
			--if ( traceEnt.isDeadBody ) then
				if not ( IsValid( traceEnt.player ) ) then
					self.Owner:notify( "You cannot revive a disconnected player's body." )
					return
				end
				traceEnt.player:UnSpectate()
				traceEnt.player:Spawn()
				traceEnt.player:SetPos(traceEnt:GetPos())
				self.Owner:EmitSound( self.DefibSound )
				self.Owner:notify( "revived" )
				traceEnt.player:notify( "was_revived" )
				local defibCooldown = self.DefibCooldown--SVNOOB_VARS:Get( "DefibrillatorCoodlwon", true, "number", 120 )
				if ( self.Owner:Team( ) == FACTION_EMT ) then
					defibCooldown = defibCooldown / 2
				end
				self.Owner.nextDefib = CurTime( ) + defibCooldown
			--end
		end
	end
end

if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Medkit"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowViewModel		= true
	SWEP.ShowWorldModel		= true
	
end

SWEP.Base = "hl2_melee"
SWEP.Category			= "Black Tea"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.HoldType = "melee"
SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .2
SWEP.Primary.Reach			= 50
SWEP.Primary.Angle			= 1.5
SWEP.Primary.Delay		= 0.7
SWEP.Primary.MinCharge = .3

SWEP.ReOriginPos = Vector(-1, -2, -3)
SWEP.ReOriginAng = Vector(0, 0, 12.638)
SWEP.LowerAngles = Angle( -0, 12, -20 )-- nut

SWEP.SprintPos = Vector(1, -5, -5)
SWEP.SprintAng = Vector(0, 12, 0.638)
SWEP.SprintMulVec = Vector( 0, -0, 3 )
SWEP.SprintMulAng = Vector( -2, -4, 4 )

SWEP.SwingPos = Vector(-0,-12,-0)
SWEP.SwingAng = Vector(-20, 8, 12)

SWEP.DisoriginPos = Vector(-0,5,-0)
SWEP.DisoriginAng = Vector(-0, 8, 12)

function SWEP:OnSwing()
	--self.Owner:ViewPunch( Angle( math.random( 5, 7 ), math.random( -15, -10), 0 ) )
end

function SWEP:Swing()
	if SERVER then
		self.timeCooldown = CurTime() + self.Primary.Delay
		net.Start( "hl2_SendEffect" )
			net.WriteEntity( self )
		net.Send( self.Owner )
	end
	if CLIENT then
		self.Disorigin = CurTime() + .2
		self.Raised = false
	end

	self:DoDamage()
	self:SendWeaponAnim( ACT_VM_HITCENTER ) 	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
end

function SWEP:Impact( trcTrace )
	if trcTrace.Entity && trcTrace.Entity:IsEnemy( ) then
		self.Owner:EmitSound( Format( "ambient/machines/slicer%d.wav", math.random( 1,4 ) ), 80, math.random( 111, 122 ), 1  )
	end
	self.Owner:EmitSound( Format( "physics/metal/metal_solid_impact_bullet%d.wav", math.random(1,3 ) ), 80, math.random( 200, 210 ), .5  )
end
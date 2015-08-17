if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Knife"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= false
	
	SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(.1, .1, .1), pos = Vector(300, -300, 0), angle = Angle(0, 0, 0) }
	}

	SWEP.VElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/knife.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(0, 0, 4), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/knife.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 1, -2), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	
end

SWEP.Base = "hl2_melee"
SWEP.Category			= "Black Tea"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.HoldType = "melee"
SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .2
SWEP.Primary.Stamina			= 3
SWEP.Primary.Reach			= 55
SWEP.Primary.Multipiler = 1.4 -- dam + dam * multipiler
SWEP.Primary.Angle			= 1.5
SWEP.Primary.Delay		= 0.3
SWEP.Primary.MinCharge = .15

SWEP.ReOriginPos = Vector(5, -3, 4.267)
SWEP.ReOriginAng = Vector(5, 0, 40.638)
SWEP.LowerAngles = Angle( -10, 12, 0 )-- nut

SWEP.SwingPos = Vector(-1,-2,-4)
SWEP.SwingAng = Vector(15, 50, 0)
SWEP.DisoriginPos = Vector(12,-2,10)
SWEP.DisoriginAng = Vector(-30, -90, 15)

function SWEP:OnSwing()
	self.Owner:ViewPunch( Angle( math.random( 5, 7 ), math.random( -15, -10), 0 ) )
end

function SWEP:Impact( trcTrace )
	if trcTrace.Entity && trcTrace.Entity:IsEnemy( ) then
		self.Owner:EmitSound( Format( "ambient/machines/slicer%d.wav", math.random( 1,4 ) ), 80, math.random( 111, 122 ), 1  )
	end
	self.Owner:EmitSound( Format( "physics/metal/metal_solid_impact_bullet%d.wav", math.random(1,3 ) ), 80, math.random( 200, 210 ), .5  )
end
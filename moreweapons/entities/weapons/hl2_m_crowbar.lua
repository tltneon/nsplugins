if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Crowbar"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= false
	
	SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(.1, .1, .1), pos = Vector(300, -300, 0), angle = Angle(0, 0, 0) }
	}

	SWEP.VElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/crowbar.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(-0.1, -.456, 4.091), angle = Angle(-180, -170.387, 1.023), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/crowbar.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.273, 0.5, -4.092), angle = Angle(0, -90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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
SWEP.Primary.Damage			= 80
SWEP.Primary.Angle			= -.3
SWEP.Primary.Reach			= 60
SWEP.Primary.Spread			= .4

SWEP.ReOriginPos = Vector(3, -4, 12.267)
SWEP.ReOriginAng = Vector(-15.22, 12, 60.638)
SWEP.LowerAngles = Angle( -10, 12, 0 )-- nut

SWEP.SwingPos = Vector(3.7, -16, 10.314)
SWEP.SwingAng = Vector(20.85, 0, 70)
SWEP.DisoriginPos = Vector(-10.143, 40.26, 0.015)
SWEP.DisoriginAng = Vector(-120, 25.165, 60.354)

function SWEP:Impact( trcTrace )
	if trcTrace.Entity && trcTrace.Entity:IsEnemy( ) then
		self.Owner:EmitSound( Format( "ambient/machines/slicer%d.wav", math.random( 1,4 ) ), 80, math.random( 100, 105 ), 1  )
	end
	self.Owner:EmitSound( Format( "physics/metal/metal_solid_impact_bullet%d.wav", math.random(1,3 ) ), 60, math.random( 120, 180 ), .5  )
end
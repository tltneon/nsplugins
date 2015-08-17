if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Bat"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= false
	
	SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(.1, .1, .1), pos = Vector(300, -300, 0), angle = Angle(0, 0, 0) }
	}

SWEP.VElements = {
	["weapon"] = { type = "Model", model = "models/warz/melee/baseballbat.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(-0.5, 0, 5.908), angle = Angle(1, 93.068, -3), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["weapon"] = { type = "Model", model = "models/warz/melee/baseballbat.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 1, -5.909), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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
SWEP.Primary.Spread			= .4

SWEP.ReOriginPos = Vector(5, -5, 15)
SWEP.ReOriginAng = Vector(-30.22, 12, 50.638)
SWEP.LowerAngles = Angle( -10, 12, 0 )-- nut

SWEP.SwingPos = Vector(3.7, -16, 10.314)
SWEP.SwingAng = Vector(20.85, 0, 70)
SWEP.DisoriginPos = Vector(-10.143, 40.26, 0.015)
SWEP.DisoriginAng = Vector(-110, 25.165, 60.354)

function SWEP:Impact( trcTrace )
	self.Owner:EmitSound( Format( "physics/wood/wood_crate_impact_hard%d.wav", math.random(1,3 ) ), 80, math.random( 100, 120 )  )
end
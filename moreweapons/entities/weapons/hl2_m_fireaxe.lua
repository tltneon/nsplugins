if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Fire Axe"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= false
	
	SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(.1, .1, .1), pos = Vector(300, -300, 0), angle = Angle(0, 0, 0) }
	}

	SWEP.VElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/fireaxe.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(-0.456, -0.456, 5.908), angle = Angle(-1.024, 13.295, -8), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/fireaxe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 1.363, -2.274), angle = Angle(180, 117.613, -9.205), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
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
SWEP.Primary.Reach			= 65
SWEP.Primary.Angle			= -.4
SWEP.Primary.Spread			= .4
SWEP.Primary.MinCharge = .3

SWEP.ReOriginPos = Vector(4, -4, 8.267)
SWEP.ReOriginAng = Vector(-21.22, 0, 70.638)
SWEP.LowerAngles = Angle( -10, 12, 0 )-- nut

SWEP.SprintPos = Vector(8, -3, 6.267)
SWEP.SprintAng = Vector(-30.22, 6, 40.638)
SWEP.SprintMulVec = Vector( 0, -2, 3 )
SWEP.SprintMulAng = Vector( 10, 3, 10 )

SWEP.SwingPos = Vector(0.7, -16, 10.314)
SWEP.SwingAng = Vector(11.85, 0, 100)
SWEP.DisoriginPos = Vector(-16.143, 30.26, 4.015)
SWEP.DisoriginAng = Vector(-90, 42.165, 60.354)

function SWEP:Impact( trcTrace )
	if trcTrace.Entity && trcTrace.Entity:IsEnemy( ) then
		self.Owner:EmitSound( Format( "ambient/machines/slicer%d.wav", math.random( 1,4 ) ), 80, math.random( 100, 105 ), 1  )
	end
	self.Owner:EmitSound( Format( "physics/metal/metal_canister_impact_soft%d.wav", math.random(1,3 ) ), 75, math.random( 100, 110 ), .5  )
end
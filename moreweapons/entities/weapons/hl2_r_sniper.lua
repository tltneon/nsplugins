if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Standard Issue Sniper Rifle"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= true
end

SWEP.Category			= "Black Tea Firearms"
SWEP.Base = "hl2_base"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = false
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/v_combinesniper_e2.mdl"
SWEP.WorldModel = "models/weapons/w_combinesniper_e2.mdl"
SWEP.HoldType = "ar2"

SWEP.Primary.Sound = Sound( "Weapon_C_Sniper.Single" )
SWEP.Primary.ReloadSound			= Sound( "Weapon_C_Sniper.Reload" )

SWEP.Primary.Automatic		= false
SWEP.Primary.ClipSize		= 1			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SniperRound"

SWEP.Primary.Delay		= 0.1
SWEP.Primary.Damage			= 200
SWEP.Primary.Spread			= 0
SWEP.MuzScale = 1
SWEP.ReOriginPos = Vector(-1, -6, -2 )
SWEP.ReOriginAng = Vector(0, 0, 0 )
SWEP.SprintPos = Vector(-5, -6, -5)
SWEP.SprintAng = Vector(-15.7, 20.799, -40)
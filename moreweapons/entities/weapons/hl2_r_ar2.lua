if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "AR2 Rifle"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= true
end

SWEP.Category			= "Black Tea Firearms"
SWEP.Base = "hl2_base"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"
SWEP.Tracer = 1

SWEP.Primary.Sound = Sound( "Weapon_C_AR2.Single" )
SWEP.Primary.ReloadSound	= Sound( "Weapon_AR2.Reload" )
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= 30			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Delay		= 0.15
SWEP.Primary.Damage			= 45
SWEP.Primary.Spread			= .04
SWEP.CustomRecoil = Vector( 0, -5, -2 )
SWEP.ReOriginPos = Vector(-.5, -5, 0)
if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Sub-Machine Gun"
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
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.HoldType = "smg"

SWEP.Primary.Sound = Sound( "Weapon_C_SMG.Single" )
SWEP.Primary.ReloadSound	= Sound( "Weapon_SMG1.Reload" )
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= 45			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"
SWEP.Primary.Delay		= 0.07
SWEP.Primary.Damage			= 30
SWEP.Primary.Spread			= .06

SWEP.Shell = 1
SWEP.CustomRecoil = Vector( 0, -10, -.5 )

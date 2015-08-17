if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "9mm MP5 Kurz"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= true
end

SWEP.Category			= "Black Tea Firearms"
SWEP.Base = "hl2_base"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = false -- temp
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.HoldType = "smg"
SWEP.WorldModel = "models/weapons/w_mp5k.mdl"
SWEP.ViewModel = "models/weapons/v_mp5k.mdl"

SWEP.Primary.Sound = Sound( "Weapon_C_Pistol.Single" )
SWEP.Primary.ReloadSound			= Sound( "Weapon_MP5k.Reload" )
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= 25			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Delay		= .09
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .05
SWEP.MuzScale = .25	

SWEP.SprintPos = Vector(-5, -4, 0)
SWEP.SprintAng = Vector(-15.7, 20.799, -40)
--SWEP.ReOriginPos = Vector(1.1, -2, 1.5 )
SWEP.CustomRecoil = Vector( 0, -7, -1 )
SWEP.ReOriginPos = Vector( 0, 0, 1 )
SWEP.ReOriginAng = Vector(0, 0, 0 )
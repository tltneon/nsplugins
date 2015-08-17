if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "AR3 Carbine"
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
SWEP.WorldModel = "models/weapons/w_ar3c.mdl"
SWEP.ViewModel = "models/weapons/v_ar3c.mdl"

SWEP.Primary.Sound = Sound( "Weapon_C_AR3C.Single" )
SWEP.Primary.ReloadSound			= Sound( "Weapon_SMG1.Reload" )
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= 40			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Delay		= .075
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .03


SWEP.MuzScale = .26
SWEP.Shell = 2
SWEP.ShellSize = .8
SWEP.ShellAngle = Vector( -15, 20, 0 )
SWEP.ReOriginPos = Vector(1.1, -1, -1 )
SWEP.ReOriginAng = Vector(0, 0, 0 )

SWEP.CustomRecoil = Vector( 0, -5, -1 )

SWEP.SprintPos = Vector(-3, -7, -1)
SWEP.SprintAng = Vector(-15.7, 30.799, -20)
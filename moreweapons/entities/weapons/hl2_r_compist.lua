if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Overwatch Issue Combine Pistol"
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
SWEP.HoldType = "pistol"
SWEP.WorldModel = "models/weapons/w_cmbpis.mdl"
SWEP.ViewModel = "models/weapons/v_cmpist.mdl"

SWEP.Primary.Sound = Sound( "Weapon_C_CombinePistol.Single" )
SWEP.Primary.ReloadSound			= Sound( "Weapon_SMG1.Reload" )
SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= 10			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Delay		= .2
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .03


SWEP.MuzScale = .22
SWEP.Shell = 1
SWEP.ShellSize = .9
SWEP.CustomRecoil = Vector( 0, -10, -3 )
SWEP.ShellAngle = Vector( -15, 20, 0 )
SWEP.ReOriginPos = Vector(1.1, -2, -1 )
SWEP.ReOriginAng = Vector(0, 0, 0 )

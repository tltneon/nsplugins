if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "9mm USP Match"
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
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound = Sound( "Weapon_C_Pistol.Single" )
SWEP.Primary.Automatic		= false
SWEP.Primary.ClipSize		= 12			// Size of a clip
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Delay		= .1
SWEP.Primary.Damage			= 50
SWEP.Primary.Spread			= .03



AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = Model( "models/MaxOfS2D/camera.mdl" )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


SWEP.PrintName	= "Speed Gun"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.Spawnable		= true

SWEP.ShootSound = Sound( "buttons/blip2.wav" )

--
-- Network/Data Tables
--
function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "Zoom" )
	self:NetworkVar( "String", 0, "Speed" )

	if ( SERVER ) then
		self:SetZoom( 70 )
		self:SetSpeed( "READY" )
	end

end

--
-- Initialize Stuff
--
function SWEP:Initialize()

	self:SetHoldType( "camera" )

end

--
-- Reload resets the FOV
--
function SWEP:Reload()

	if ( !self.Owner:KeyDown( IN_ATTACK2 ) ) then self:SetZoom( self.Owner:IsBot() && 75 || self.Owner:GetInfoNum( "fov_desired", 75 ) ) end

end

--
-- PrimaryAttack - make a screenshot
--
function SWEP:PrimaryAttack()

	self:DoShootEffect()

	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if IsValid(trace.Entity) && trace.Entity:IsVehicle() then

		local vehicle = trace.Entity
		local vehAngles = vehicle:GetAngles()
		local plyAngles = self.Owner:GetAngles()

		vehAngles.yaw = vehAngles.yaw - 90

		if vehAngles.yaw < 0 then
			vehAngles.yaw = vehAngles.yaw + 180
		end

		if plyAngles.yaw < 0 then
			plyAngles.yaw = plyAngles.yaw + 180
		end

		if math.abs(plyAngles.yaw - vehAngles.yaw) > 25 then
			self:SetSpeed("ERROR")
		else
			local speed = math.Round(vehicle:GetVelocity():Length() / (3600 * 0.0035))
			self:SetSpeed(speed.." Km/h")
		end

	else

		self:SetSpeed("ERROR")

	end

end

--
-- SecondaryAttack - Nothing. See Tick for zooming.
--
function SWEP:SecondaryAttack()
end

--
-- Mouse 2 action
--
function SWEP:Tick()

	if ( CLIENT && self.Owner != LocalPlayer() ) then return end -- If someone is spectating a player holding this weapon, bail

	local cmd = self.Owner:GetCurrentCommand()

	if ( !cmd:KeyDown( IN_ATTACK2 ) ) then return end -- Not holding Mouse 2, bail

	self:SetZoom( math.Clamp( self:GetZoom() + cmd:GetMouseY() * 0.1, 10, 75 ) ) -- Handles zooming

end

--
-- Override players Field Of View
--
function SWEP:TranslateFOV( current_fov )

	return self:GetZoom()

end

--
-- Deploy - Allow lastinv
--
function SWEP:Deploy()

	return true

end

--
-- Set FOV to players desired FOV
--
function SWEP:Equip()

	if ( self:GetZoom() == 70 && self.Owner:IsPlayer() && !self.Owner:IsBot() ) then
		self:SetZoom( self.Owner:GetInfoNum( "fov_desired", 75 ) )
	end

end


--
-- The effect when a weapon is fired successfully
--
function SWEP:DoShootEffect()

	self:EmitSound( self.ShootSound )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

if ( SERVER ) then return end -- Only clientside lua after this line

surface.CreateFont( "7SEG", {font="lcd", size=25, weight=60,shadow=false} )

function SWEP:DrawHUD()
	draw.SimpleTextOutlined( "Speed: "..self:GetSpeed(), "7SEG", (ScrW()/2), ScrH() - 25, Color( 255, 255, 255, 200 ), false, false, 1, Color( 0, 0, 0, 200 ) )
end

function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:FreezeMovement()

	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyReleased( IN_ATTACK2 ) ) then
		return true
	end

	return false

end

/*function SWEP:CalcView( ply, origin, angles, fov )

	if ( self:GetRoll() != 0 ) then
		angles.Roll = self:GetRoll()
	end

	return origin, angles, fov

end*/

function SWEP:AdjustMouseSensitivity()

	if ( self.Owner:KeyDown( IN_ATTACK2 ) ) then return 1 end

	return self:GetZoom() / 80

end
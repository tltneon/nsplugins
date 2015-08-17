if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "HL2 Throwables"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left Click to Swing."
	SWEP.ShowWorldModel		= false
	SWEP.HoldType = "pistol"
	SWEP.ViewModelBoneMods = {
		["v_weapon.Flashbang_Parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	SWEP.VElements = {
		["weapon"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "v_weapon.Flashbang_Parent", rel = "", pos = Vector(0.455, 2.273, -0.456), angle = Angle(1.023, 13.295, -88.977), size = Vector(0.776, 0.776, 0.776), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	SWEP.WElements = {
		["weapon"] = { type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 1.363, -2.274), angle = Angle(0, 0, -180), size = Vector(0.8, 0.8, 0.8), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "hl2_melee"
SWEP.Category			= "Black Tea"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.HoldType = "melee"
SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 80
SWEP.Primary.Reach			= 60
SWEP.Primary.Spread			= .4
SWEP.Primary.Angle			= -.3

SWEP.ReOriginPos = Vector(-5, 0, 0)
SWEP.ReOriginAng = Vector(0, -10, 0)

SWEP.SprintPos = Vector(-8, -5, -2)
SWEP.SprintAng = Vector(-20, -20, -20 )

SWEP.SwingPos = Vector(2, -20, 0)
SWEP.SwingAng = Vector(30, 0, 0)
SWEP.DisoriginPos = Vector(-20, 20, 0)
SWEP.DisoriginAng = Vector(-50, 0, -50)

function SWEP:DoDamage()
	if SERVER then
		local ft = ents.Create( "nut_motolov" )
		ft:Spawn()
		local phy = ft:GetPhysicsObject()
		local curchar = ( CurTime() - self.timeCharge )
		local perc = math.Clamp( (curchar / ( self.Primary.MaxCharge - self.Primary.MinCharge)-1 ), 0, 1 )
		phy:SetVelocity( self.Owner:GetAimVector() * 600 * perc )
		phy:AddAngleVelocity( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )*1000 )
		ft:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20 )

	end
end

function SWEP:Think()	

	if self.Owner:KeyDown(IN_SPEED) and not (self.Owner:GetVelocity():Length() > self.Owner:GetWalkSpeed()) then
		self.intime = CurTime() + 0.35
	end
	
	if self.Owner:GetVelocity():Length() > self.Owner:GetWalkSpeed() and self.Owner:KeyDown(IN_SPEED) and self.Owner:OnGround() and self.Owner:WaterLevel() < 2 then
		if self.Owner:GetVelocity():Length() > 10 then
			if self:GetDTBool( 3 ) == false then
				self.intime = CurTime() + 0.35
			end
			self:SetDTBool( 3, true )
		end
	else
		if self:GetDTBool( 3 ) then
			self.intime = CurTime() + 0.35
		end
		self:SetDTBool( 3, false )
	end
	
	if SERVER then
		if self.Owner:KeyDown( IN_ATTACK ) and self.Owner:KeyDown( IN_USE ) then
			if self.timeToggle < CurTime() then
				self.Owner:SetWepRaised(!self.Owner:WepRaised())
				self.timeToggle = CurTime() + 1
				self.timeCooldown = CurTime() + .5
				return
			end
		end
	end
	
	if SERVER then
		if ( self.Owner:KeyDown( IN_ATTACK ) && self.Owner:WepRaised() && !self:GetDTBool(3) ) then
			if self.timeCooldown < CurTime() then
				local stam = self.Owner.character:GetVar( "stamina" )
				local redc = ( self.Owner:GetAttrib(ATTRIB_END) / 100 )
				if stam < ( self.Primary.Stamina - redc * self.Primary.Stamina ) then return end
				if !self.boolCharge then
					net.Start( "hl2_SendRaise" )
						net.WriteEntity( self )
					net.Send( self.Owner )
					self.boolCharge = true
					self.timeCharge = CurTime()
				end
			end
		else
				if !self:GetDTBool(3) then
					if self.boolCharge then
						if ( CurTime() - self.timeCharge ) > self.Primary.MinCharge then
							self.boolCharge = false
							self:Swing()
						end
					end
				end
		end
	else
		if self.Disorigin > CurTime() then
			if self.Disorigin-self.Primary.Disorigin+self.Primary.Disorigin*.45 > CurTime() then
				self.VElements["weapon"].color = Color( 255, 255, 255, 255 )
			else
				self.VElements["weapon"].color = Color( 255, 255, 255, 1 )
			end
		else
			self.VElements["weapon"].color = Color( 255, 255, 255, 255 )
		end
	end
	
end
ENT.Type = "anim"
ENT.PrintName = "Mounted Gun"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:CalcAimAngle()
	
	local ply = self:GetNWEntity( "User" )
	local normSelf = self:GetForward()
	local normAim = ply:GetAimVector()
			
	local tr = {}
	tr.start = self:GetPos()
	tr.endpos = tr.start + normAim
	tr.filter = { self, ply }
	trace = util.TraceHull(tr)
	local vecAim = ( self:GetPos() - trace.HitPos ) - normSelf
	local angLoc = ( self:WorldToLocalAngles( (vecAim):Angle() ) )
			
	-- doodly shit
	local intAngtemp = angLoc.y
	if angLoc.y < 0 then
		intAngtemp = 180 + angLoc.y  
	else
		intAngtemp = ( 180 - angLoc.y  ) * -1
	end
	
	print( intAngtemp )
	return { Pose = { angLoc.p * -1, intAngtemp }, Norm = vecAim }
			
end

if (SERVER) then
	
	function ENT:Initialize()
		self:SetModel("models/props_combine/bunker_gun01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		local p = self:GetPhysicsObject()
		p:EnableCollisions( false )
	end
	
	function ENT:Think()
		if self:GetNWEntity( "User" ):IsValid() then
			
			local atminfo = self:CalcAimAngle()
			self:SetPoseParameter( "aim_yaw", math.Clamp( atminfo.Pose[2] * 1.5, -60, 60 ) )
			self:SetPoseParameter( "aim_pitch", math.Clamp( atminfo.Pose[1], -35, 50 )  )
			 
			 if self:GetNWEntity( "User" ):KeyDown( IN_ATTACK ) then
				if !self.nextFire or self.nextFire < CurTime() then	
					self:FireBullet( self.User )
					local at = self:LookupAttachment( "muzzle" )
					local atpos = self:GetAttachment( at )
					local e = EffectData()
					e:SetOrigin( atpos.Pos )
					e:SetNormal( atpos.Ang:Forward() * 1 )
					e:SetScale( .3 )
					util.Effect( "muzzleflosh" , e)
					self:EmitSound( Sound( "Weapon_C_AR3C.Single" ) )
					self.nextFire = CurTime() + .07
				end
			 end
			 
			self:NextThink( CurTime()  )
			return true
 		end
		
	end
	
	function ENT:FireBullet( owner )
		
		local at = self:LookupAttachment( "muzzle" )
		local atd = self:GetAttachment( at )
		local atminfo = self:CalcAimAngle()
					
		local bullet = {}
			bullet.Num 		= 2
			bullet.Src 		= atd.Pos		// Source
			--bullet.Src 		= self:GetPos() + self:GetForward() * 10 + self:GetUp() * 10		// Source
			bullet.Dir 		= atd.Ang:Forward()			// Dir of bullet
			--bullet.Dir 		= atminfo.Norm * -1
			bullet.Spread 	= Vector( math.Rand( -.05, .05 ), math.Rand( -.05, .05 ), 0)			// Aim Cone
			bullet.Tracer	= 2							// Show a tracer on every x bullets
			bullet.TracerName = "AR2Tracer"
			bullet.Force	= 100					// Amount of force to give to phys objects
			bullet.Damage	= 30

		self:FireBullets(bullet)
	
	end
	
	function ENT:Use(activator)
		if !self.nextUse or self.nextUse < CurTime() then			
			if self:GetNWEntity( "User" ):IsValid() then
				self:SetNWBool( "Active", false )
				self:SetNWEntity( "User", nil )
				activator:SetNWEntity( "Mounted", nil )
			else
				self:SetNWBool( "Active", true )
				self:SetNWEntity( "User", activator )
				activator:SetNWEntity( "Mounted", self )
			end
			self:SetPoseParameter( "aim_pitch", math.Rand( -1, 1 ) )
			self:SetPoseParameter( "aim_yaw", math.Rand( -2, 2 ) )
			self.nextUse = CurTime() + 1
		end
	end
	
	function ENT:SpawnFunction( ply, tr )
		if ( !tr.Hit ) then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		local ent = ents.Create( "nut_mgun" )
			ent:SetPos( SpawnPos )
			ent:Spawn()
		ent:Activate()
		return ent
	end

else

	function ENT:Draw()
		self:DrawModel()
		
		if self:GetNWBool( "Active" ) then
			local atminfo = self:CalcAimAngle()
			PrintTable( atminfo )
			self:SetPoseParameter( "aim_yaw", math.Clamp( atminfo.Pose[2] * 1.5,  -60, 60 ) )
			self:SetPoseParameter( "aim_pitch", math.Clamp( atminfo.Pose[1] , -35, 50 )  )
		end
	end
	
end

hook.Add( "Move", "MountedHeck", function( ply, move )
		if ply:IsValid() and ply.character then
			if ply:GetNWEntity( "Mounted" ):IsValid() then
				move:SetForwardSpeed(0)
				move:SetSideSpeed(0)
			end
		end	
end)


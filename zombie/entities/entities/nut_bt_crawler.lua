ENT.Base            = "base_nextbot"
ENT.PrintName = "Crawler Zombie"
ENT.Author = "Black Tea"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Melee = {}

-------------------------------

ENT.Melee.Damage = 10
ENT.Melee.Reach = 80
ENT.Melee.Delay = 2
 
function ENT:Initialize()
  
    self:SetModel( NUT_MOB_CRAWLER_MODEL[ math.random( 1, #NUT_MOB_CRAWLER_MODEL ) ] );
	self:SetHealth( NUT_MOB_CRAWLER_HEALTH:GetInt() )
 
	self.loco:SetDeathDropHeight(200)	//default 200
	self.loco:SetAcceleration(400)		//default 400
	self.loco:SetDeceleration(900)		//default 400
	self.loco:SetStepHeight(50)			//default 18
	self.loco:SetJumpHeight(100)		//default 58
	self.Entity:SetCollisionBounds( Vector(-4,-4,0), Vector(4,4,64) )
	
	self.nextbot = true
	self.timeUseless = CurTime() + NUT_MOB_CRAWLER_REFRESH:GetInt() -- if this zombie haven't contacted any person in 5 min then it's useless.
	self.timeInterest = CurTime()
		
end

function ENT:BodyUpdate()

	local act = self:GetActivity()
	local seq = self:GetSequenceName( self:GetSequence() )
	if ( act == ACT_RUN || act == ACT_HL2MP_RUN_FIST || act == ACT_HL2MP_RUN_FAST || seq == "zombie_run" ) then
		self:BodyMoveXY()
	end
	self:FrameAdvance()

end

local _AllowedToMove = true
function ENT:StopMovingToPos( )

	_AllowedToMove = false
	
end	

function ENT:Stop()

end
	
function ENT:MoveToPos( pos, options )

	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end
	_AllowedToMove = true
	while ( path:IsValid() and _AllowedToMove ) do
		path:Update( self )
		if ( options.draw ) then
			path:Draw()
		end
		if ( self.loco:IsStuck() ) then
			self:HandleStuck();
			return "stuck"
		end
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		coroutine.yield()
	end
	return "ok"
	
end

local function center( ent )
	return ent:GetPos() + ent:OBBCenter()
end

function ENT:SetTarget( ent )
	self.Target = ent
end

function ENT:GetTarget()
	return self.Target
end

function ENT:Targetable()

end

function ENT:Trace( target )
		local vecPosition = center( self )
		local vecPosition2 = center( target )
		local tracedata = {}
		tracedata.start = vecPosition
		tracedata.endpos = vecPosition2
		tracedata.filter = { self }
		local trace = util.TraceLine(tracedata)
		return trace
end

function ENT:SearchTarget()

	local final
	local close = NUT_MOB_CRAWLER_DETECTRANGE:GetInt()
	if self:GetTarget() then close = close * 1.5 end
	
	local targets = {}
	for _, ply in pairs ( ents.GetAll() ) do
		if ply:IsPlayer() then
			if  ( center( self ):Distance( center( ply ) ) < close )  then
				if ply:Alive() then
					if ( ply:GetPos().z - self:GetPos().z ) < 150 then -- don't target the enemy 
						if self:Trace( ply ).Entity == ply then
							close = ply:GetPos():Distance( self:GetPos() ) 
							final = ply
						end
					end
				end
			end
		end
	end	
			
	return final
			
end

function ENT:GetDot( t )
	local vec 
	vec = ( self:GetPos() - t:GetPos() )
	vec:Normalize()
	return vec:Dot( self:GetAngles():Forward() )
end

function ENT:MeleeAttack( dmg, reach )

	local tracedata = {}
	tracedata.start = center( self )
	tracedata.endpos = center( self ) + self:GetForward() * reach
	tracedata.filter = self
	tracedata.mins = Vector( -10,-10,-10 )
	tracedata.maxs = Vector( 10,10,10 )
	local trace = util.TraceHull( tracedata )
	if trace.Hit then
		if trace.Entity:IsValid() then
			trace.Entity:EmitSound( "npc/fast_zombie/claw_strike" .. math.random( 1, 3 ) ..".wav" )
			local di = DamageInfo()
			di:SetDamage( dmg )
			di:SetAttacker( self )
			di:SetInflictor( self )
			di:SetDamageType( DMG_SLASH )
			if trace.Entity:IsPlayer() then
				trace.Entity:TakeDamageInfo( di )
			end
		end
	else
			self:EmitSound( "npc/fast_zombie/claw_miss" .. math.random( 1, 2 ) ..".wav" )
	end
	
end

function ENT:Alive()
	return ( self:Health() > 0 )
end

function ENT:Attack1()
	local targ = self:GetTarget()
	timer.Simple( .1, function()
		if not ( self:IsValid() && self:Alive() ) then return end
		self:MeleeAttack( NUT_MOB_CRAWLER_DAMAGE:GetInt()*2, 90 )
	end)
	self:RestartGesture( ACT_MELEE_ATTACK1 )  
	coroutine.wait( .2 )
end

function ENT:RunBehaviour()
 
 
    while ( true ) do
 
        -- walk somewhere random
		
		local t = self:SearchTarget()
		if t then
			self:SetTarget( t )
		end
		
		if !self:GetTarget() then
			                   -- walk anims
			self:StartActivity( ACT_WALK )       
			self.loco:SetDesiredSpeed( NUT_MOB_CRAWLER_SPEED:GetInt() * 0.5 )                        -- walk speeds
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200, { maxage = .7, tolerance = 10} ) -- walk to a random place within about 200 units (yielding)
			self:StartActivity( ACT_HL2MP_IDLE_ZOMBIE )   
			coroutine.wait( 1 )
			coroutine.yield()
			
		else
			
			local t = self:GetTarget()
			local nt = self:SearchTarget()
				
			if t && t:IsValid() && t:Alive() then
			
				if nt && nt:IsValid() then
					if ( nt != t ) then
						if nt:IsPlayer() then
							self:SetTarget( t )
						end
					else
						self.timeInterest = CurTime()
					end
				end
				
				if self:GetPos():Distance( self:GetTarget():GetPos() ) < 60 then
				
					self.loco:FaceTowards( self:GetTarget():GetPos() )
					local zdiff = self:GetPos().z - self:GetTarget():GetPos().z
					if self:GetDot( self:GetTarget() ) < -0.9 || ( (math.abs(zdiff) > 20) && (math.abs(zdiff) < 70) ) then
						self:Attack1()
					end
					
				else
				
					local opts = { maxage = .3, tolerance = 10}
					self:StartActivity( ACT_RUN )       
					self.loco:SetDesiredSpeed( NUT_MOB_CRAWLER_SPEED:GetInt() )                        -- walk speeds
					self:MoveToPos( t:GetPos(), opts )
					
				end
				
				self.timeUseless = CurTime() + NUT_MOB_CRAWLER_REFRESH:GetInt()
				if ( CurTime() - self.timeInterest ) >= NUT_MOB_CRAWLER_INTEREST:GetInt() then
					self:SetTarget( nil )
				end
				
			else
				self:SetTarget( nil )
			end
			
		end
		
		coroutine.yield()
 
    end
 
 
end

function ENT:OnInjured()

	self:EmitSound( "npc/zombie/zombie_pain" .. math.random( 1, 6 ) .. ".wav" )
				
end


list.Set( "NPC", "bt_zombie",   {   Name = "Black Tea NPC # 1",
                                        Class = "bt_zombie",
                                        Category = "Black Tea Stuffs"   
                                    })
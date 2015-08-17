ENT.Base            = "base_nextbot"
ENT.PrintName = "Emitter Zombie"
ENT.Author = "Black Tea"
ENT.Category = "NutScript"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Melee = {}

-------------------------------

ENT.Melee.Damage = 10
ENT.Melee.Reach = 80
ENT.Melee.Delay = 2
 
if CLIENT then

	local function ParticleSetup( em, tex, pos, dietime )
		local par = em:Add( tex, pos )
		return par
	end
	local function ParticleSize( p, s, e )
		p:SetStartSize( s )
		p:SetEndSize( e )
	end
	local function ParticleLength( p, s, e )
		p:SetStartLength( s )
		p:SetEndLength( e )
	end
	local function ParticleRollDelta( p, r, d )
		p:SetRoll( r )
		if d then
			p:SetRollDelta( d )
		end
	end
	local function ParticleAlpha( p, s, e)
		p:SetStartAlpha(s)
		p:SetEndAlpha(e)
	end
	local function GasLeak( n )
		local at = n:LookupAttachment( "chest" )
		local att = n:GetAttachment( at )
		n.Origin = att.Pos
		n.Emitter = n.Emitter or ParticleEmitter( n.Origin )
		n.timeNextEmit2 = n.timeNextEmit2 or CurTime()
		n.timeNextEmit = n.timeNextEmit or CurTime()
		
		n.dir = n.dir or {
			[1] = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ),
			[2] = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ),
			[3] = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ),
		}
		if n.timeNextEmit2 < CurTime() then 
			local particle = ParticleSetup( n.Emitter, "particle/smokesprites_000"..math.random(1,9), n.Origin )
			particle:SetVelocity( Vector( 0, 0, 0 ) )
			particle:SetDieTime(math.Rand(0.7,1))
			particle:SetColor( 100, 255, 100 )
			ParticleAlpha( particle, 50, 0)
			ParticleSize( particle, 0, math.random(150,200) )
			n.timeNextEmit2 = CurTime() + .7
		end
				
		if n.timeNextEmit < CurTime() then 
			local particle = ParticleSetup( n.Emitter, "particle/smokesprites_000"..math.random(1,9), n.Origin )
			particle:SetVelocity( Vector( 0, 0, 0 ) )
			particle:SetDieTime(math.Rand(0.3,0.4))
			particle:SetColor( 100, 255, 100 )
			ParticleAlpha( particle, 30, 0)
			ParticleSize( particle, 0, math.random(60,100) )
			for _, dir in pairs( n.dir ) do
				local particle = ParticleSetup( n.Emitter, "particle/smokesprites_000"..math.random(1,9), n.Origin )
				particle:SetVelocity( dir*100 )
				particle:SetDieTime(math.Rand(0.3,0.4))
				particle:SetColor( 100, 255, 100 )
				ParticleAlpha( particle, 50, 0)
				ParticleLength( particle, math.random( 30, 40), math.random( 50, 60 ) )
				ParticleSize( particle, 0, math.random(30,40) )
			end
			n.timeNextEmit = CurTime() + .1
		end
	end
	local function ToxicGas( n )
	
		local at = n:LookupAttachment( "chest" )
		local att = n:GetAttachment( at )
		n.Origin = att.Pos
		n.Emitter = n.Emitter or ParticleEmitter( n.Origin )
		n.timeNextEmit2 = n.timeNextEmit2 or CurTime()
		
		if n.timeNextEmit2 < CurTime() then 
			local particle = ParticleSetup( n.Emitter, "particle/smokesprites_000"..math.random(1,9), n.Origin )
			particle:SetVelocity( Vector( 0, 0, 0 ) )
			particle:SetDieTime(math.Rand(0.5,.6))
			particle:SetColor( 100, 255, 100 )
			ParticleAlpha( particle, 30, 0)
			ParticleSize( particle, 0, math.random(200,300) )
			n.timeNextEmit2 = CurTime() + .5
		end
		
	end
	
	hook.Add( "Think", "NPC_EMITS", function()
		for _, n in pairs( ents.FindByClass( "nut_bt_emitter" ) ) do
			if n:GetNWBool( "npc_dying" ) then
				 GasLeak( n )
			else
			 	ToxicGas( n )
			end
		end
	end) -- wow why i have to do this?
	
end	
 
function ENT:Initialize()
  
    self:SetModel( NUT_MOB_EMITTER_MODEL[ math.random( 1, #NUT_MOB_EMITTER_MODEL ) ] );
	self:SetHealth( NUT_MOB_EMITTER_HEALTH:GetInt() )
 
	self.loco:SetDeathDropHeight(200)	//default 200
	self.loco:SetAcceleration(400)		//default 400
	self.loco:SetDeceleration(900)		//default 400
	self.loco:SetStepHeight(35)			//default 18
	self.loco:SetJumpHeight(100)		//default 58
	self.Entity:SetCollisionBounds( Vector(-4,-4,0), Vector(4,4,64) )
	
	self.nextbot = true
	self.timeUseless = CurTime() + NUT_MOB_EMITTER_REFRESH:GetInt() -- if this zombie haven't contacted any person in 5 min then it's useless.
	self.timeInterest = CurTime()
		
end

function ENT:BodyUpdate()

	local act = self:GetActivity()
	local seq = self:GetSequenceName( self:GetSequence() )
	if ( act == ACT_HL2MP_WALK_ZOMBIE_01 ||  seq == "Walk" ||  seq == "Idle01" || seq == "Walk" ) then
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
	local close = NUT_MOB_EMITTER_DETECTRANGE:GetInt()
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
				trace.Entity:AddBuff( "posion", 100 )
				trace.Entity:TakeDamageInfo( di )
			end
		end
	else
			self:EmitSound( "npc/fast_zombie/claw_miss" .. math.random( 1, 2 ) ..".wav" )
	end
	
end

function ENT:Attack1()
	local targ = self:GetTarget()
	timer.Simple( .7, function()
		if not self:IsValid() then return end
		self:MeleeAttack( NUT_MOB_EMITTER_DAMAGE:GetInt()*2, 90 )
	end)
	self:StartActivity( ACT_MELEE_ATTACK1 )       
	coroutine.wait( 1.2)
end

function ENT:Die()

	self:SetNWBool( "npc_dying", true )
	self:PlaySequenceAndWait( "ThrowWarning" )       
	self:PlaySequenceAndWait( "releasecrab" )      
	local e = EffectData()
		e:SetOrigin( self:GetPos() )
		e:SetStart( self:GetPos() )
	util.Effect("Explosion", e)
	local e = EffectData()
		e:SetOrigin( self:GetPos() + Vector( 0, 0, 40 ) )
		e:SetStart( self:GetPos() + Vector( 0, 0, 40 ) )
	util.Effect("nut_emitter_explode", e)
	AddToxicZone( self:GetPos(), 90 )
	self:Remove()
end

function ENT:Poison()
end

function ENT:RunBehaviour()
 
 
    while ( true ) do
 
        -- walk somewhere random
		
		local t = self:SearchTarget()
		if t then
			self:SetTarget( t )
		end
		
		if self:Health() <= 1 then
			self:Die()
			coroutine.yield()
		end
		
		if !self:GetTarget() then
			                   -- walk anims
			self:StartActivity( ACT_WALK )       
			self.loco:SetDesiredSpeed( NUT_MOB_EMITTER_SPEED:GetInt() * 0.5 )                        -- walk speeds
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200, { maxage = 5 } ) -- walk to a random place within about 200 units (yielding)
			self:StartActivity( ACT_IDLE )       
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
				
					self:StartActivity( ACT_IDLE )       
					self.loco:FaceTowards( self:GetTarget():GetPos() )
					local zdiff = self:GetPos().z - self:GetTarget():GetPos().z
					if self:GetDot( self:GetTarget() ) < -0.9 || ( (math.abs(zdiff) > 20) && (math.abs(zdiff) < 70) ) then
						self:Attack1()
					end
					
				else
				
					local opts = { maxage = .7, tolerance = 10}
					self:ResetSequence( "Run" )
					self.loco:SetDesiredSpeed( NUT_MOB_EMITTER_SPEED:GetInt() )                        -- walk speeds
					self:MoveToPos( t:GetPos(), opts )
					
				end
				
				self.timeUseless = CurTime() + NUT_MOB_EMITTER_REFRESH:GetInt()
				if ( CurTime() - self.timeInterest ) >= NUT_MOB_EMITTER_INTEREST:GetInt() then
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

hook.Add( "EntityTakeDamage", "Nut_nodamwhiledie", function( ent, dam )
	if ent:GetClass() == "nut_bt_emitter" then
		if ent:Health() - dam:GetDamage() <= 0 then
			dam:SetDamage( 0 )
			ent:SetHealth(1)
		end
	end
end)
if SERVER then return end

local EFFECT = {}

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

local EFFECT = {}

function EFFECT:Init( data ) 
	
	self.Origin = data:GetOrigin()
	self.Emitter = ParticleEmitter( self.Origin )
	
	for i = 1, 3 do 
		local particle = ParticleSetup( self.Emitter, "particle/smokesprites_000"..math.random(1,9), self.Origin )
		particle:SetVelocity( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )* 30  )
		particle:SetDieTime(math.Rand(0.2,0.3))
		particle:SetColor( 100, 255, 100 )
		ParticleSize( particle, 0, math.random(100,200) )
	end
	
	for i = 1, 5 do 
		local particle = ParticleSetup( self.Emitter, "particle/smokesprites_000"..math.random(1,9), self.Origin )
		particle:SetVelocity( Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )* 100  )
		particle:SetDieTime(math.Rand(0.1,0.2))
		particle:SetColor( 100, 255, 100 )
		ParticleLength( particle, math.random( 70, 80), math.random( 90, 100 ) )
		ParticleSize( particle, math.random(20,30), 0 )
	end
	
 end 

effects.Register( EFFECT, "nut_emitter_explode" )
ENT.Type = "anim"
ENT.PrintName = "Motolov Cocktail"
ENT.Author = "Black Tea"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.BurnArea = 100
ENT.BurnTime = 15
ENT.BurnDam = 20


if (SERVER) then

	hook.Add( "EntityTakeDamage", "nut_MolotovThink", function( ent, dmg )
		if ent:IsZombie() then
			local atk = dmg:GetAttacker()
			if atk:GetClass() == "env_fire" then
				ent:Ignite( 10 )
			end
			if atk:GetClass() == "entityflame" then
				dmg:SetDamage( 5 )
			end
		end
	end)
	
	util.AddNetworkString("nut_MotolovEffect")
	util.AddNetworkString("nut_MotolovFire")
	
	function ENT:Initialize()
		self:SetModel("models/props_junk/GlassBottle01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.lifetime = CurTime() + 5
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		-- call something
	end
	
	function ENT:Think()
		if self.lifetime < CurTime() then
			self:Remove()
		end
	end
	
	function ENT:PhysicsCollide( dat, ent )
		self:EmitSound( "physics/glass/glass_sheet_break" .. math.random( 1,3 ) .. ".wav", 70, math.random( 120, 160 ) )
		net.Start( "nut_MotolovEffect" )
			net.WriteVector( self:GetPos() )
		net.Broadcast()
		
		for i = 1, 4 do
			local fire = ents.Create( "env_fire" )
			fire:SetPos( ent:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * math.random( 60, 100 ) )
			fire:SetKeyValue( "health", math.random( 10, 15 ) )
			fire:SetKeyValue( "firesize", math.random( 120, 130 ) )
			fire:SetKeyValue( "fireattack", "1" )
			fire:SetKeyValue( "fireignitionpoint", "1" )
			fire:SetKeyValue( "damagescale", self.BurnDam )
			fire:SetKeyValue( "StartDisabled", "0" )
			fire:SetKeyValue( "firetype", "0" )
			fire:SetKeyValue( "spawnflags", "132" )
			fire:Spawn()
			fire:Fire( "StartFire", "" )
		end
		
		return self:Remove()
	end
	
else

	local function motolov_effect( vec )
		local emit = ParticleEmitter( vec )
		for i = 1, 13 do
		
			local smoke = emit:Add( "modulus/particles/fire"..math.random( 1, 8 ), vec )
			smoke:SetVelocity( Vector( math.Rand( -1, 1 ),math.Rand( -1, 1 ),math.Rand( -0, .2 ) ) * 200 )
			smoke:SetDieTime(math.Rand(0.2,.4))
			smoke:SetStartAlpha(math.Rand(150,170))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(20,30))
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(255,255,255)
			smoke:SetGravity( Vector( 0, 0, 10 ) )
			smoke:SetAirResistance(200)
			
			local smoke = emit:Add( "modulus/particles/smoke"..math.random( 1, 6 ), vec )
			smoke:SetVelocity( Vector( math.Rand( -1, 1 ),math.Rand( -1, 1 ),math.Rand( -0, .4 ) ) * 400 )
			smoke:SetDieTime(math.Rand(0.3,.7))
			smoke:SetStartAlpha(math.Rand(100,120))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(20,30))
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(80,80,80)
			smoke:SetGravity( Vector( 0, 0, 10 ) )
			smoke:SetAirResistance(200)
			
		end
		for i = 1, 6 do
			local smoke = emit:Add( "modulus/particles/fire"..math.random( 1, 8 ), vec )
			smoke:SetVelocity( Vector( math.Rand( -1, 1 ),math.Rand( -1, 1 ),math.Rand( -0, 1 ) ) * 30 )
			smoke:SetDieTime(math.Rand(0.2,.3))
			smoke:SetStartAlpha(math.Rand(150,170))
			smoke:SetEndAlpha(0)
			smoke:SetStartLength( math.random( 11, 12 ) )
			smoke:SetEndLength( math.random( 55, 77 ) )
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(20,30))
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(255,255,255)
			smoke:SetGravity( Vector( 0, 0, 10 ) )
			smoke:SetAirResistance(200)
		end
	end

	net.Receive( "nut_MotolovEffect", function( len )
		local pos = net.ReadVector()
		motolov_effect( pos )
	end)

	function ENT:Initialize()
		self.emitter = ParticleEmitter( self:GetPos() )
		self.emittime = RealTime()
	end
	
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		self:DrawModel()		
		local position = 	self:GetPos() + ( self:GetUp() * 9 )
		local size = 20 + math.sin( RealTime()*15 ) * 5
		render.SetMaterial(GLOW_MATERIAL)
		render.DrawSprite(position, size, size, Color( 255, 162, 76, 255 ) )
		if self.emittime < RealTime() then
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), position	)
			smoke:SetVelocity(Vector( 0, 0, 120))
			smoke:SetDieTime(math.Rand(0.2,1.3))
			smoke:SetStartAlpha(math.Rand(150,200))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(20,30))
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(50,50,50)
			smoke:SetGravity( Vector( 0, 0, 10 ) )
			smoke:SetAirResistance(200)
			self.emittime = RealTime() + .05
		end
	end
	
end

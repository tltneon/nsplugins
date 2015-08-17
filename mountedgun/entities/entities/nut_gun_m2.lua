ENT.Type = "anim"
ENT.PrintName = "M2 Machine Gun"
ENT.Author = "Black Tea"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.MagazineSize = 100

local sndt = {
	channel = CHAN_USER_BASE + 50,
	volume = 1,
	soundlevel = 120,
	pitchstart = 100,
	pitchend = 100,
}

sndt.name = "Turret.Single"
sndt.sound = {
	"weapons/smg1/smg1_fire1.wav",
}
sndt.pitchstart = 66
sndt.pitchend = 77	
sound.Add( sndt )

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/cardboard_box004a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTInt(0, self.MagazineSize)
		self:SetCollisionGroup( 20 )
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:OnRemove()
	end

	function ENT:GetMagazine()
		return self:GetDTInt(0)
	end

	function ENT:SetMagazine(int)
		return self:SetDTInt(0, int)
	end

	function ENT:CanFire()
		return !(self:GetMagazine() <= 0 or self.reloading)
	end

	function ENT:ReloadGun()
		if (self.reloading or self:GetMagazine() == self.MagazineSize) then return end
		netstream.Start(player.GetAll(), "nut_EntReload", self)
		self.reloading = true
		timer.Simple( 3.1, function()
			self.reloading = false
			self:SetMagazine(self.MagazineSize)
		end)
	end

	function ENT:FireGun()
		if !self:CanFire() then
			self:EmitSound("weapons/pistol/pistol_empty.wav", 80, 80)
			return
		end
		self:SetMagazine( self:GetMagazine() - 1 )
		self:EmitSound("Turret.Single")
		util.ScreenShake( self:GetPos(), 5, 5, .1, 64 )

		local e = EffectData()
		e:SetEntity( self )
		util.Effect( "nut_MGFire" , e)

	    local origin = self:GetPos() + self:OBBCenter() + self:GetForward()*-30
    	local bullet = {
    		Attacker = self,
    		Damage = 15,
    		Num = 1,
    		Tracer = 0,
    		Force = 200,
    		Dir = -self:GetForward(),
    		Spread = VectorRand()*.05,
    		Src = origin
    	}
		self:FireBullets( bullet )
	end

	function ENT:Use(client)
		if self.parent then
			self.parent:Assign(client)
		end
	end
else

	local EFFECT = {}
	local EMITTER = ParticleEmitter(Vector(0, 0, 0))
	local SCALE = .8
	function EFFECT:Init( data ) 
		local ent = data:GetEntity()
		if ent and ent:IsValid() then

			local pos, ang = ent.models.barrel:GetPos(), ent.models.barrel:GetAngles()
			pos = pos + ang:Up()*-17
			ent.models.lever.offset = Vector( 7, 0, 0 )
			ent:ShellEject()
			local dlight = DynamicLight(ent:EntIndex())
				
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 170
			dlight.b = 0
			dlight.Brightness = 5
			dlight.Size = 128
			dlight.Decay = 512
			dlight.DieTime = CurTime() + 0.1

			for i=0,3 do
				local Smoke = EMITTER:Add("particle/smokesprites_000"..math.random(1,9), pos )
				Smoke:SetVelocity(120*i*1.5*-ang:Up()*(SCALE*1.5))
				Smoke:SetDieTime(math.Rand(0.5,1.9))
				Smoke:SetStartAlpha(math.Rand(11,33))
				Smoke:SetEndAlpha(0)
				Smoke:SetStartSize(math.random(20,30)*SCALE)
				Smoke:SetEndSize(math.random(40,55)*SCALE*i)
				Smoke:SetRoll(math.Rand(180,480))
				Smoke:SetRollDelta(math.Rand(-3,3))
				Smoke:SetColor(255,255,255)
				Smoke:SetLighting(true)
				Smoke:SetGravity( Vector( 0, 0, 100 )*math.Rand( .2, 1 ) )
				Smoke:SetAirResistance(501)
			end

			for i=2, 4 do
				local Gas = EMITTER:Add( "effects/muzzleflash"..math.random(1,4), pos )
				Gas:SetVelocity ( -ang:Up()*i*300*SCALE  )
				Gas:SetDieTime( math.Rand(0.06, 0.08)  )
				Gas:SetStartAlpha( 80 )
				Gas:SetEndAlpha( 0 )
				Gas:SetStartSize( (25 - i*1.4)*SCALE )
				Gas:SetEndSize( (35 - i*1.3)*SCALE/2 )
				Gas:SetRoll( math.Rand(0, 360) )
				Gas:SetRollDelta( math.Rand(-50, 50) )			
				Gas:SetAirResistance( 500 ) 			 		
				Gas:SetColor( 255,220,220 )
			end

		end
	end
	function EFFECT:Think( )
	end
	function EFFECT:Render()
	end
	effects.Register( EFFECT, "nut_MGFire" )

	netstream.Hook("nut_EntFire", function(ent)
		ent:FireGun()
	end)
	netstream.Hook("nut_EntReload", function(ent)
		ent:ReloadGun()
	end)

	ENT.modelData = {
		["base"] = {
			model = "models/props_lab/powerbox02b.mdl",
			size = 0.675,
			material = "models/gibs/metalgibs/metal_gibs",
			angle = Angle(90, 0, 0),
			position = Vector(0, 0, 0),
			scale = Vector(1, 0.69999998807907, 1.2000000476837),
		},
		["stand"] = {
			model = "models/props_lab/jar01a.mdl",
			size = 0.5,
			material = "models/gibs/metalgibs/metal_gibs",
			angle = Angle(90, 0, 0),
			position = Vector(-14.0263671875, -0.00634765625, -0.5439453125),
			scale = Vector(1, 1, 1.7000000476837),
		},
		["barrel"] = {
			model = "models/props_lab/pipesystem02c.mdl",
			size = 1.35,
			material = "models/gibs/metalgibs/metal_gibs",
			angle = Angle(-90, 0, -180),
			position = Vector(-31.897966384888, 0.012451171875, -0.5888671875),
			scale = Vector(1, 1, 0.60000002384186),
		},
		["ammo"] = {
			model = "models/Items/BoxSRounds.mdl",
			size = 0.85,
			angle = Angle(-0.22314141690731, 178.19999694824, -7.0627326965332),
			position = Vector(-5.346848487854, -8.9610595703125, -10.771484375),
			scale = Vector(1, 1, 1),
		},
		["sw1"] = {
			model = "models/props_wasteland/light_spotlight01_base.mdl",
			size = 0.225,
			angle = Angle(-90, 0, 90),
			position = Vector(11.685546875, -2.4024658203125, -0.7783203125),
			scale = Vector(1, 1, 1),
		},
		["sw2"] = {
			model = "models/props_wasteland/light_spotlight01_base.mdl",
			size = 0.225,
			angle = Angle(-100, 0, 90),
			position = Vector(11.685546875, 2.2980000972748, -0.7783203125),
			scale = Vector(1, 1, 1),
		},
		["lever"] = {
			model = "models/props_c17/TrapPropeller_Lever.mdl",
			size = 0.725,
			material = "models/gibs/metalgibs/metal_gibs",
			angle = Angle(90, -3.4373784728814e-005, 5.2030736696906e-006),
			position = Vector(0.64049649238586, 2.1524658203125, 0.8408203125),
			scale = Vector(1, 1, 1),
		},
	}

	function ENT:Initialize()
		self.models = {}
	end

	function ENT:ShellEject()
		local pos, ang = self:GetPos(), self:GetAngles()
		if pos then
			local entity = ClientsideModel( "models/weapons/rifleshell.mdl", RENDERGROUP_BOTH )
			entity:SetPos( pos + self:GetForward()*2 )
			entity:SetAngles( ang )
			entity:PhysicsInitBox( Vector(-1,-1,-1), Vector(1,1,1) )
			entity:SetModelScale( .8, 0 )
			entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )
			local phys = entity:GetPhysicsObject()
			if ( phys ):IsValid() then
				phys:Wake()
				phys:SetDamping( 0, 15 )
				phys:SetVelocity( -ang:Right() * math.random( 150, 200 ) + VectorRand() * 40 )
				phys:AddAngleVelocity(VectorRand() * 50000)
				phys:SetMass( .1 )
				phys:SetMaterial( "gmod_silent" )
			end
			
			timer.Simple( 1, function()
				entity:Remove()
			end)
		end
	end

	function ENT:ReloadGun()
		sound.Play( "buttons/lever7.wav", self:GetPos() )
		self.models.ammo:SetMaterial("models/effects/vol_light001")
		timer.Simple( 1, function()
			sound.Play( "buttons/lever8.wav", self:GetPos(), 80, 140 )
			sound.Play( "buttons/lever7.wav", self:GetPos() )
			self.models.ammo:SetMaterial()
			timer.Simple( 1, function()
				sound.Play( "weapons/shotgun/shotgun_cock.wav", self:GetPos(), 80, 200 )
				self.models.lever.offset = Vector( 7, 0, 0 )
			end)
		end)
	end

	function ENT:OnRemove()
		for k, v in pairs(self.models) do
			self.models[k]:Remove()
		end
	end

	function ENT:Draw()
		--self:DrawModel()
		for k, v in pairs(self.modelData) do
			local drawingmodel = self.models[k] -- localize
			if !drawingmodel or !drawingmodel:IsValid() then		
				self.models[k] =  ClientsideModel(v.model, RENDERGROUP_BOTH )
				self.models[k]:SetColor( v.color or color_white )
				if (v.scale) then
					local matrix = Matrix()
					matrix:Scale( (v.scale or Vector( 1, 1, 1 ))*(v.size or 1) )
					self.models[k]:EnableMatrix("RenderMultiply", matrix)
				end
				if (v.material) then
					self.models[k]:SetMaterial( v.material )
				end
			end
			if drawingmodel and drawingmodel:IsValid() then
				local pos, ang = self:GetPos() - self:GetForward()*-5, self:GetAngles()
				drawingmodel.offset = drawingmodel.offset or Vector(0, 0, 0)
				pos = pos + self:GetForward()*v.position.x + self:GetUp()*v.position.z + self:GetRight()*-v.position.y
				pos = pos + self:GetForward()*drawingmodel.offset.x + self:GetUp()*drawingmodel.offset.z + self:GetRight()*-drawingmodel.offset.y
				local ang2 = ang
				ang2:RotateAroundAxis( self:GetRight(), v.angle.pitch ) -- pitch
				ang2:RotateAroundAxis( self:GetUp(),  v.angle.yaw )-- yaw
				ang2:RotateAroundAxis( self:GetForward(), v.angle.roll )-- roll
				drawingmodel:SetRenderOrigin( pos )
				drawingmodel:SetRenderAngles( ang2 )
				drawingmodel:DrawModel()
			end
		end
		if self.models.lever then
			self.models.lever.offset = LerpVector(FrameTime()*8, self.models.lever.offset or Vector( 0, 0, 0 ), Vector(0, 0, 0))
		end
	end

end
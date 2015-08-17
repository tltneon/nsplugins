ENT.Type = "anim"
ENT.PrintName = "M2 Mounted Gun"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Delay = .11

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_lab/tpplug.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetAngles( Angle( -90, 0, 0))
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self.firedelay = CurTime()

		self.gun = ents.Create("nut_gun_m2")
		self.gun:SetPos( self:GetPos() + self:GetForward()*15 )
		self.gun:Spawn()
		self.gun:SetParent(self)
		self.gun.parent = self
		self.gunang = Angle( 0, 0, 0 )
	end

	function ENT:TurnOff()
	end

	function ENT:TurnOn()
	end

	function ENT:Think()
		if self.activated then
			if self.user:IsValid() and self.user:Alive() and self:GetPos():Distance(self.user:GetPos()) <= 64 then
				local data = {}
					data.start = self.user:GetShootPos()
					data.endpos = data.start + self.user:GetAimVector()*10000
					data.filter = self.user
				local trace = util.TraceLine(data)

				local fowa = self:GetUp()
				local norm = trace.Normal 
				local capped = (fowa - trace.Normal)
				capped.x = math.Clamp( capped.x, -.4, .4)
				capped.y = math.Clamp( capped.y, -.4, .4)
				capped.z = math.Clamp( capped.z, -.4, .4)

				local ang = (fowa-capped):Angle()
				ang:RotateAroundAxis( ang:Up(), 180 )

				self.gunang = LerpAngle( .1, self.gunang, ang )
				self.gun:SetAngles( self.gunang  )

				if self.user:GetActiveWeapon():IsValid() then
					self.user:GetActiveWeapon():SetNextPrimaryFire(CurTime()+1)
					self.user:GetActiveWeapon():SetNextSecondaryFire(CurTime()+1)
				end
			
				if self.user:KeyDown( IN_ATTACK ) then
					if self.firedelay < CurTime() then
						self.gun:FireGun()
						self.firedelay = CurTime() + self.Delay
					end
				end

				if self.user:KeyDown( IN_RELOAD ) then
					if self.firedelay < CurTime() then
						self.gun:ReloadGun()
						self.firedelay = CurTime() + 1
					end
				end
			else
				self.user = nil
				self.activated = false
				self:EmitSound("Func_Tank.BeginUse")
			end
		end
		self:NextThink(CurTime()+.01)
		return true
	end
	function ENT:Assign(client)
		if !self.activated then
			self.user = client
			self:EmitSound("Func_Tank.BeginUse")
			self.activated = true
		else
			if client == self.user then
				self.user = nil
				self.activated = false
				self:EmitSound("Func_Tank.BeginUse")
			end
		end
	end
	function ENT:Use(client)
		self:Assign(client)
	end
else

	function ENT:Draw()
		self:DrawModel()
	end

end
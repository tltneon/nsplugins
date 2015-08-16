ENT.Type = "anim"
ENT.PrintName = "Recycler"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript Machines"
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.CurrencyPerKG = 5

if (CLIENT) then
	ENT.CurrencyShort = "tok"
end
if (SERVER) then
	local RecycleTargets = {
		"junk_ws",
		"junk_wj",
		"junk_be",
		"junk_bt",
		"junk_p",
		"junk_ss",
		"junk_bl",
		"junk_k",
		"junk_p",
		"junk_hp",
		"junk_ec",
		"junk_ej",
	}
	ENT.RecycleTime = 30
	ENT.TokenHoldTime = 60

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/laundry_dryer002.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTInt(0, 0) -- recycle amount
		self:SetDTInt(0, 0) -- holding tokens
		self:SetDTBool(0, false) -- activated
		self:SetDTBool(0, false) -- holding
		self.timeGen = CurTime()
		self.timeHold = CurTime()
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
	end

	function ENT:TurnOff()
		self:SetDTBool(0, false)
		self:SetDTBool(1, true)
		self:SetDTInt(1, self:GetDTInt(0)*self.CurrencyPerKG)
		self.timeHold = CurTime() + self.TokenHoldTime
		self:EmitSound("plats/elevator_stop.wav")
		self.loopsound:Stop()
	end

	function ENT:TurnOn(client)
		local weight = 0
		local itemdat
		for _, class in pairs(RecycleTargets) do
			itemdat = nut.item.list[class]
			for k, v in pairs( client:GetItemsByClass(class) ) do
				if itemdat then
					weight = weight + (itemdat.weight * v.quantity)
				end
			end
			itemdat = nil
		end

		if weight < 1 then
			client:notify("You must have more than 1 kg of junks.")

			return
		end
		
		for _, class in pairs(RecycleTargets) do
			for k, v in pairs( client:GetItemsByClass(class) ) do
				if v.quantity > 0 then
					client:UpdateInv(class, -v.quantity, v.data or {})
				end
			end
		end

		client:notify("Decimal numbers has been cut out from the pay.")
		client:notify(Format("You Processed %s kg of junks.", weight))
		
		self.loopsound = CreateSound( self, "ambient/machines/machine3.wav" ) -- weird issue.
		self.loopsound:Play()
		self:SetDTBool(0, true)
		self:SetDTInt(0, math.floor(weight))
		self.timeGen = CurTime() + self.RecycleTime
	end

	function ENT:Think()
		if self:GetDTBool(0) then
			if self.timeGen < CurTime() then
				self:TurnOff()
			end
		else
			if self:GetDTBool(1) and self.timeHold < CurTime() then
				self:EmitSound("hl1/fvox/dadeda.wav", 60, 100)
				self:EmitSound("ambient/machines/combine_terminal_idle1.wav", 60, 100)
				self:SetDTBool(1, false)
				self.activator = nil
			end
		end
		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:CanTurnOn(client)
		return (!self:GetDTBool(0) and !self:GetDTBool(1)) -- machine is off
	end

	function ENT:Use(client)
		if (self:GetDTBool(1) and self.activator == client and !self.idle) then
			self.idle = true
			self:EmitSound("ambient/machines/combine_terminal_idle4.wav", 80, 130)
			timer.Simple(1, function()
				self.idle = false
				self:EmitSound("hl1/fvox/deeoo.wav", 60, 150)
				client:notify(Format("You've got %s from this machine.", nut.currency.GetName(self:GetDTInt(1), true)))
				client:GiveMoney( tonumber(self:GetDTInt(1)) )
				self:SetDTBool(1, false)
			end)
			self.activator = nil
			return
		end
		if self:CanTurnOn(client) then
			self.activator = client
			self:TurnOn(client)
			return
		else
			client:notify("This machine is busy")
			self:EmitSound("common/wpn_denyselect.wav", 80, 130)
			return
		end
	end
else

	ENT.modelData = {
		["cylinder"] = {
			model = "models/props_wasteland/laundry_washer001a.mdl",
			size = 0.6,
			angle = Angle(-90, 0, 0),
			position = Vector(5.7164611816406, 2.4400634765625, 5.051220703125),
			scale = Vector(1, 1, 1),
		},
		["card"] = {
			model = "models/props_lab/powerbox03a.mdl",
			size = 1,
			angle = Angle(0, 0, 0),
			position = Vector(17.266235351563, -27.982055664063, -8.01220703125),
			scale = Vector(1, 1, 1),
		},
		["comlock"] = {
			model = "models/props_combine/combine_lock01.mdl",
			size = 1,
			angle = Angle(0, -90, 0),
			position = Vector(18.120361328125, -30.808715820313, 7.033935546875),
			scale = Vector(1, 0.69999998807907, 1.2000000476837),
		},
		["display"] = {
			model = "models/props_lab/reciever01d.mdl",
			size = 1,
			angle = Angle(0, 0, 0),
			position = Vector(9.527954101563, -27.65576171875, -19.580200195313),
			scale = Vector(1, 1, 1),
		},
	}

	function ENT:OnRemove()
	end

	function ENT:Draw()
		self:DrawModel()
		self.models = self.models or {}

		for k, v in pairs(self.modelData) do
			local drawingmodel = self.models[k] -- localize

			if !drawingmodel or !drawingmodel:IsValid() then		
				self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
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
				local ang2 = ang

				drawingmodel.offset = drawingmodel.offset or Vector(0, 0, 0)
				pos = pos + self:GetForward()*v.position.x + self:GetUp()*v.position.z + self:GetRight()*-v.position.y
				pos = pos + self:GetForward()*drawingmodel.offset.x + self:GetUp()*drawingmodel.offset.z + self:GetRight()*-drawingmodel.offset.y

				ang2:RotateAroundAxis( self:GetRight(), v.angle.pitch ) -- pitch
				ang2:RotateAroundAxis( self:GetUp(),  v.angle.yaw )-- yaw
				ang2:RotateAroundAxis( self:GetForward(), v.angle.roll )-- roll

				drawingmodel:SetRenderOrigin( pos )
				drawingmodel:SetRenderAngles( ang2 )
				drawingmodel:DrawModel()
			end
		end
		if self.models then
			local mdl = self.models.cylinder
			if mdl:IsValid() then
				mdl.offset = mdl.offset or Vector( 0, 0, 0 )
				if self:GetDTBool(0) then
					mdl.offset = LerpVector(FrameTime(), mdl.offset, Vector(-3, 0, 0))
				else
					mdl.offset = LerpVector(FrameTime(), mdl.offset, Vector(0, 0, 0))
				end
			end
		end
	end

	local sx, sy = 100, 50
	local ms = math.sin
	local mc = math.cos
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:DrawTranslucent()
		if self.models then
			local rt = RealTime()
			local mdl = self.models.comlock
			if mdl:IsValid() then
				local pos, ang = mdl:GetPos(), mdl:GetAngles()
				pos = pos + self:GetForward()*5.4
				pos = pos + self:GetUp()*-10.6
				pos = pos + self:GetRight()*-3.8
				if self:GetDTBool(0) then
					local alpha = math.Clamp(math.abs( ms(6*rt)+ms(14*rt)+mc(22*rt) )*500, 0, 255 )
					render.SetMaterial(GLOW_MATERIAL)
					render.DrawSprite(pos, 12, 12, Color( 44, 255, 44, alpha ) )
				else
					local alpha = math.Clamp(math.abs( ms(2*rt) )*255, 0, 255 )
					render.SetMaterial(GLOW_MATERIAL)
					if self:GetDTBool(1) then
						render.DrawSprite(pos, 12, 12, Color( 255, 150, 10, alpha ) )
					else
						render.DrawSprite(pos, 12, 12, Color( 255, 44, 44, alpha ) )
					end
				end
			end

			local mdl = self.models.display
			if mdl:IsValid() then
				local pos, ang = mdl:GetPos(), mdl:GetAngles()
				pos = pos + self:GetForward()*5.76
				pos = pos + self:GetUp()*-.4
				pos = pos + self:GetRight()*2.80
				ang:RotateAroundAxis( self:GetRight(), -90 )
				ang:RotateAroundAxis( self:GetForward(), 90 )
				cam.Start3D2D(pos, ang, .05)
					surface.SetDrawColor(0, 200, 20, distalpha)
					surface.DrawRect(-sx/2, -sy/2, sx, sy)
					local text = self.CurrencyPerKG .. " " .. self.CurrencyShort .. "/kg"
					if self:GetDTBool(0) then
						text = self:GetDTInt(0) .. " kg"
					end
					if self:GetDTBool(1) then
						text = self:GetDTInt(1) .. " " .. self.CurrencyShort .. "s"
					end 
					nut.util.drawText( text, 0, 0,Color(255, 255, 255, distalpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "ChatFont")
				cam.End3D2D()
			end
		end
	end

end
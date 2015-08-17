if (SERVER) then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Half Life 2 - Ranged Base"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Base Weapon."
	SWEP.Contact    = ""
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 50
	SWEP.ViewModelFlip		= false
	SWEP.ShowViewModel		= true
	SWEP.ShowWorldModel		= true
	
end

SWEP.Category			= "Black Tea Firearms"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true

SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
 
SWEP.ViewModel = "models/weapons/v_ar3c.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.HoldType = "melee"

SWEP.Primary.Sound			= Sound( "Weapon_C_Pistol.Single" )
SWEP.Primary.ReloadSound			= Sound( "Weapon_Pistol.Reload" )

SWEP.Primary.ClipSize		= 15			// Size of a clip
SWEP.Primary.DefaultClip	= 1000
SWEP.Primary.Automatic		= true

SWEP.Primary.Delay		= .075
SWEP.Primary.Damage			= 40
SWEP.Primary.Spread			= .03

SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Secondary.ClipSize      = 0
SWEP.Secondary.DefaultClip    = 0

SWEP.MuzScale = .3
SWEP.Shell = 1

-- Weapon Position

SWEP.ReOriginPos = Vector(0, -2, 0 )
SWEP.ReOriginAng = Vector(0, 0, 0 )
SWEP.LowerAngles = Angle( 0, 0, -20 )-- nut

SWEP.SprintPos = Vector(0, 0, 0)
SWEP.SprintAng = Vector(-15.7, 20.799, 0)

SWEP.SprintMulVec = Vector( 0, 0, 2 )
SWEP.SprintMulAng = Vector( 2, 10, 0 )

SWEP.SteadyPos = Vector(-1.719, -10.738, -5.217)
SWEP.SteadyAng = Vector(37.013, -3.406, 0)

SWEP.CustomRecoil = Vector( 0, -5, -1 )


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	
	self:SetDTBool( 2, false )
	self:SetDTBool( 3, false )
	self:SetDTBool( 4, false )
	
	self.timeCooldown = CurTime()
	self.timeToggle = CurTime()
	self.intime = CurTime()
	self.Disorigin = CurTime()
	self.OldD = Angle( 0, 0, 0 )
	self.NewD = Angle( 0, 0, 0 )
	
	if CLIENT then

		self.customrecoil = Vector( 0, 0, 0 )
		self.VEmitter = ParticleEmitter( Vector( 0, 0, 0 ) )
		self.WEmitter = ParticleEmitter( Vector( 0, 0, 0 ) )
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements) 
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end

	end

end

function SWEP:Holster()

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()

		if self.OldD then
		
			FT = FrameTime()
			EA = self.Owner:EyeAngles()
			delta = Angle(EA.p, EA.y, 0) - self.OldD
				
			self.OldD = Angle(EA.p, EA.y, 0)
			self.NewD = LerpAngle(FT * 10, self.NewD, delta*5)
			self.NewD.y = math.Clamp(self.NewD.y, -15, 15)
			
		end
         
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

	local apptime = 0
	local footcyclex = 0
	local footcycley = 0
	local footcyclez = 0

	local swayvec = Vector( 0, 0, 0 )
	local swayang = Vector( 0, 0, 0 )
	local swaylerp = Vector( 0, 0, 0 )
	local swaylerpang = Vector( 0, 0, 0 )
	local targetvec = Vector( 0, 0, 0 )
	local targetang = Vector( 0, 0, 0 )
	local lerpvec = Vector( 0, 0, 0 )
	local lerpang = Vector( 0, 0, 0 )
	local invr = 1
	local add = 0
	local loreal = 0
	local mv = Vector( 0, 0, 0 )
	local ma = Vector( 0, 0, 0 )
	
	function util_ClampVector( vec, cmin, cmax )
		return Vector( math.Clamp( vec.x, cmin.x, cmax.x ), math.Clamp( vec.y, cmin.y, cmax.y ), math.Clamp( vec.z, cmin.z, cmax.z ) )
	end
	
	/*---------------------------------------------------------
	   Name: GetViewModelPosition
	   Desc: Allows you to re-position the view model
	---------------------------------------------------------*/
	function SWEP:GetViewModelPosition( pos, ang )

		local runspeed = self.Owner:GetRunSpeed() / 35
		local walkspeed = self.Owner:GetWalkSpeed() / 15
		
		self.SwayScale 	= 0
		self.BobScale 	= 0.1
			
		--- morecontrol

		if self.Owner:KeyDown(IN_MOVELEFT) then
			add = -5
		elseif self.Owner:KeyDown(IN_MOVERIGHT) then
			add = 5
		else
			add = 0
		end
		loreal = Lerp( FrameTime()*5, loreal, add )
				
		
		if self:GetDTBool(3) then
			
			if self.intime > CurTime() then
				apptime = FrameTime() * 2.5
			else
				apptime = FrameTime() * 10
			end
			
			targetvec = self.SprintPos
			targetang = self.SprintAng
			
			footcyclex = math.sin( RealTime() * runspeed )
			footcycley = math.sin( RealTime() * runspeed )
			footcyclez = math.abs(math.sin( RealTime() * runspeed ))
			
			targetvec = targetvec + Vector( footcyclex * self.SprintMulVec.x, footcycley * self.SprintMulVec.y, footcyclez * self.SprintMulVec.z - self.SprintMulVec.z)
			targetang = targetang + Vector( footcyclex * self.SprintMulAng.x, footcycley * self.SprintMulAng.y, footcyclez * self.SprintMulAng.z  )
	
		elseif self.Raised == true then
		
			apptime = FrameTime() * 10
			targetvec = self.SwingPos
			targetang = self.SwingAng
			
		else
				
			apptime = FrameTime() * 8
			targetvec = self.ReOriginPos
			targetang = self.ReOriginAng
			if self.Owner:GetVelocity():Length() > walkspeed * 7.5 and self.Owner:OnGround() then
			
				footcyclex = math.sin( RealTime()  * walkspeed * .4 )
				footcycley = math.sin( RealTime()  * walkspeed )
				footcyclez = math.abs(math.sin( RealTime()  * walkspeed * .8 ))
				
				targetvec = targetvec + Vector( footcyclex * -0.9 , footcycley * 0 - 1, footcyclez * 1.2 - 0.4)
				targetang = targetang + Vector( footcyclex * 1, footcyclex * -0.1, footcycley * 1.2 )

				targetvec = targetvec + Vector( loreal/3,0 ,  loreal / 9 - 1 )
				targetang = targetang + Vector( 0, 0, loreal - 1 )
				
			else
			
				footcyclex = math.sin( RealTime() * 2.5 )
				footcycley = math.sin( RealTime() * 2.5 )
				footcyclez = math.sin( RealTime() * 1 )
				targetvec = targetvec + Vector( footcyclex * 0 , footcycley * 0 , footcyclez * 0.05 )
				targetang = targetang + Vector( footcyclex * 0.2, footcycley * .2 - footcyclez * .15, 0 )
				
			end
			
		end
		

		
		if !self:GetDTBool(2) then
			if self.Owner:KeyDown(IN_DUCK) and self.Owner:OnGround() then
				targetvec = targetvec + Vector( 0, 0, 0.5 )
			end
			targetvec = targetvec + Vector( 0, 0, self.Owner:GetAimVector().z * -0.8 )
			if self.ViewModelFlip then
				invr = -1
			else
				invr = 1
			end
			mv = LerpVector( FrameTime()*30 , mv, Vector( self.NewD.y * .1 * invr, self.NewD.y * 0, self.NewD.y * 0 ) )
			ma = LerpVector( FrameTime()*30  , ma, Vector( self.NewD.y * 0, self.NewD.y * .3 * invr, 0) )
			targetvec = targetvec + mv
			targetang = targetang + ma
		end
		
		--self.customrecoil = ( LerpVector( FrameTime()*25, self.customrecoil, Vector( 0, 0, 0 ) ) ) or Vector( 0, 0, 0 )
		self.customrecoil = ( self.customrecoil / ( 2 + FrameTime() * 100 ) ) or Vector( 0, 0, 0 )
		self.customrecoil = util_ClampVector( self.customrecoil, Vector( -5, -10, -10 ), Vector( 5, 0, 0 ) )
		targetvec = targetvec + self.customrecoil
		
		lerpvec = LerpVector( apptime, lerpvec, targetvec )
		lerpang = LerpVector( apptime, lerpang, targetang )
		
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		lerpang.x )
		ang:RotateAroundAxis( ang:Up(), 		lerpang.y  )
		ang:RotateAroundAxis( ang:Forward(), 	lerpang.z  ) 
		
		local Right 	= ang:Right()
		local Up 		= ang:Up()
		local Forward 	= ang:Forward()
		
		pos = pos + ( lerpvec.x )* Right 
		pos = pos + ( lerpvec.y )* Forward 
		pos = pos + ( lerpvec.z )* Up 

		return pos, ang
		
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
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
	
end

local TracerName = "Tracer"
function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone)

	num_bullets 		= num_bullets or 1
	aimcone 			= aimcone or 0

	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	else
		TracerName = "Tracer"
	end
	
	local bullet = {}
		bullet.Num 		= num_bullets
		bullet.Src 		= self.Owner:GetShootPos()			// Source
		bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
		bullet.Spread 	= Vector(aimcone, aimcone, 0)			// Aim Cone
		bullet.Tracer	= 2							// Show a tracer on every x bullets
		bullet.TracerName = TracerName
		bullet.Force	= damage * 0.5					// Amount of force to give to phys objects
		bullet.Damage	= damage

	self.Owner:FireBullets(bullet)

end

function SWEP:CanPrimaryAttack()

	// Clip is empty or you're under water
	if (self.Weapon:Clip1() <= 0) or (self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	if self.Weapon:GetDTBool(3) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end

function SWEP:WorldFlash()
		if self.Owner:ShouldDrawLocalPlayer() or self.Owner != LocalPlayer() then
			local at = self:LookupAttachment( "muzzle" )
			local atpos = self:GetAttachment( at )
			local e = EffectData()
			e:SetOrigin( atpos.Pos )
			e:SetNormal( atpos.Ang:Forward() * 1 )
			e:SetScale( self.MuzScale * .9 )
			util.Effect( "muzzleflosh" , e)
		end
end

function SWEP:ViewFlash()

		if not self.Owner:ShouldDrawLocalPlayer() then
			local vm = self.Owner:GetViewModel()
			if !IsValid(vm) then return end
			local at = vm:LookupAttachment( "muzzle" )
			local atpos = vm:GetAttachment( at )
			local e = EffectData()
			e:SetOrigin( atpos.Pos )
			e:SetNormal( atpos.Ang:Forward() * 1 )
			e:SetScale( self.MuzScale )
			util.Effect( "muzzleflosh" , e)
			self.customrecoil = self.customrecoil + self.CustomRecoil * math.Clamp( ( 1 + FrameTime() * 100 ), 1, 10 )
		end
		
end

function SWEP:ShellEject()

			local e = EffectData()
			--e:SetOrigin( atpos.Pos )
			--e:SetNormal( atpos.Ang:Forward() * 1 )
			e:SetStart( self.ShellAngle or Vector( 0, 0, 0 ) )
			e:SetRadius( self.Shell or 1 )
			e:SetEntity( self )
			e:SetScale( self.ShellSize or 1 )
			e:SetAttachment("2")
			util.Effect( "cusshell" , e)
end

function SWEP:FireAnimationEvent(pos, ang, ev)
	
	if ev == 6001 then
		self:ShellEject()
		return ev == 6001
	end
	
	if ev == 5003 then
		self:WorldFlash()
		return ev == 5003
	end
	if ev == 22 then
		self:WorldFlash()
		return ev == 22
	end
	
	if ev == 21 then
		self:ViewFlash()
		return ev == 21
	end
end
	
function SWEP:DoAnimation()
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) 		// View model animation
	self.Owner:SetAnimation(PLAYER_ATTACK1)				// 3rd Person Animation
end

function SWEP:PrimaryAttack()
	
	if !self:CanPrimaryAttack() or !self.Owner:WepRaised() or self.Owner:KeyDown( IN_USE ) then return false end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:EmitSound(self.Primary.Sound)
	nut.schema.Call("OnGunShot", self.Owner, self)
	self:DoAnimation()

	self:ShootBullet( self.Primary.Damage , self.Primary.Recoil, self.Primary.NumShots, self.Primary.Spread)
	self:TakePrimaryAmmo(1)
	
end

function SWEP:Reload()

	if self.Primary.ClipSize == self:Clip1() or self.Owner:GetAmmoCount(self.Primary.Ammo)  == 0 then
	return end
	
	self:EmitSound( self.Primary.ReloadSound )
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
end


function SWEP:SecondaryAttack()
	return false	
end
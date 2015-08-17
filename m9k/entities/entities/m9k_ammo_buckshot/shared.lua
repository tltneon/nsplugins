ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Buckshot"
ENT.Category		= "M9K Ammunition"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(ply, tr)

	if (!tr.Hit) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create("m9k_ammo_buckshot")
	
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent.Planted = false
	
	return ent
end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	local model = ("models/Items/BoxBuckshot.mdl")
	
	self.Entity:SetModel(model)
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)
end


/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data, physobj)
	
	// Play sound on bounce
	if (data.Speed > 80 and data.DeltaTime > 0.2) then
		self.Entity:EmitSound("Default.ImpactSoft")
	end
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmginfo)

	if dmginfo:GetAttacker():GetClass() == "m9k_ammo_explosion" then return end
	blaster = dmginfo:GetAttacker()
	pos = self.Entity:GetPos()+Vector(0,0,10)
	
	dice = math.random(1,5)

	if dmginfo:GetDamage() >75 or dice == 1 then
		self.Entity:Remove()
	
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("ThumperDust", effectdata)
		util.Effect("Explosion", effectdata)
	
		timer.Simple(.01, function()
		
			for i=1, 300 do //if that turns out to be too many, i might have to call it 200 or something. goddamn, 1200 calculations in a heartbeat.
			
			ouchies = {}
			ouchies.start = pos
			ouchies.endpos = pos + Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(0,1)) * 64000
			ouchies = util.TraceLine(ouchies)
			
			if ouchies.Hit and not ouchies.HitSky then 
				util.Decal("Impact.Concrete", ouchies.HitPos + ouchies.HitNormal, ouchies.HitPos - ouchies.HitNormal )//and ouchies.Entity then
				ouchies.Entity:TakeDamage(30 * math.Rand(.85,1.15), blaster, self.Entity)
			end
			end
		end)
	end	
	
	self.Entity:TakePhysicsDamage(dmginfo)

end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use(activator, caller)

	
	if (activator:IsPlayer()) and not self.Planted then
		// Give the collecting player some free health
		activator:GiveAmmo(100, "buckshot")
		self.Entity:Remove()
	end
end

end

if CLIENT then

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	
	self.Entity:DrawModel()
	
	local ledcolor = Color(230, 45, 45, 255)

  	local TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 3) + (self.Entity:GetRight() * 2) + (self.Entity:GetForward() * 3.54)

	local FixAngles = self.Entity:GetAngles()
	local FixRotation = Vector(0, 90, 90)
	
	FixAngles:RotateAroundAxis(FixAngles:Right(), FixRotation.x)
	FixAngles:RotateAroundAxis(FixAngles:Up(), FixRotation.y)
	FixAngles:RotateAroundAxis(FixAngles:Forward(), FixRotation.z)

	self.Text = "Buckshot"
	
	cam.Start3D2D(TargetPos, FixAngles, .07)
		draw.SimpleText(self.Text, "DermaLarge", 31, -22, ledcolor, 1, 1)
	cam.End3D2D()
end

end
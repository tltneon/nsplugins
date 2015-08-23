AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Lootbag"
ENT.Author = "Johnny Guitar"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "cash" );
	self:DTVar( "Float", 1, "health" );

end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/SuitCase001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTFloat(0, math.random(1000,20000))
		self:SetHealth(200)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end


	end

	function ENT:Explode()

		local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
			effectData:SetScale(2)
		util.Effect("RPGShotDown", effectData, true, true)

		self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")

	end

	function ENT:OnTakeDamage(damageInfo)
		
		if (damageInfo:GetDamage() > 0) then
			self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))
		
			if (self:Health() <= 0) then
			
				local curAmmount = math.ceil((self:GetDTFloat(0)/5))

				for i = 1, 5 do
					
					nut.currency.Spawn(curAmmount, self:GetPos() + (self:GetUp()*i*5) + Vector(math.random(-10,25),math.random(-10,25),math.random(-10,25)))

				end


				self:Explode()
				self:Remove()

			end

		end

	end

elseif (CLIENT) then

local glowMaterial = Material("sprites/glow04_noz");

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local angles = self:GetAngles();
	local position = self:GetPos();

	local fix_angles = self.Entity:GetAngles()
	local fix_rotation = Vector(0, 0, 0)

	fix_angles:RotateAroundAxis(fix_angles:Right(), fix_rotation.x)
	fix_angles:RotateAroundAxis(fix_angles:Up(), fix_rotation.y)
	fix_angles:RotateAroundAxis(fix_angles:Forward(), fix_rotation.z)

	local cash    = self:GetDTFloat(0)

	cam.Start3D2D( position + (self:GetUp() * 8) + (self:GetForward() * -15) + (self:GetRight() * 0), fix_angles, 0.25 )
		draw.DrawText("$"..cash, "nut_TokensFont", 0, 0, Color(0, 180, 70, 255), TEXT_ALIGN_LEFT )
	cam.End3D2D();


end;
end
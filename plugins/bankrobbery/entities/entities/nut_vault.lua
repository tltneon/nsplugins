AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Bank Vault"
ENT.Author = "Johnny Guitar"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:SetupDataTables()
	self:DTVar( "Bool", 0, "BeingDrilled" );
	self:DTVar( "Float", 1, "DrillTime");
	self:DTVar( "Bool", 2, "BrokenInto")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_wasteland/controlroom_storagecloset001b.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self:SetDTBool(0, false)
		self:SetDTBool(2, false)
	end
	
	function ENT:SetAmount(arg1, arg2)
		if arg1 == "BeingDrilled" then
			self:SetDTBool(0, arg2)
		elseif arg1 == "DrillTime" then
			self:SetDTFloat(1, arg2)
		end
	end;

	function ENT:drillIntoVault()
		if self:GetDTBool(2) == true then return end;
		self:SetAmount("BeingDrilled", true)
		self:SetDTBool(2, true)

		local drill = ents.Create( "prop_dynamic" ) 
		local physicsObject = self:GetPhysicsObject()
		drill:SetParent( physicsObject:GetEntity() )
		drill:SetModel("models/props_lab/tpplug.mdl")
		drill:SetPos(self:GetPos() + (self:GetForward() * 17))
		drill:SetAngles(self:GetAngles())
		drill:Spawn()

		local sparks = ents.Create("env_spark")

		sparks:SetParent( drill )
		sparks:SetPos(self:GetPos() + (self:GetForward() * 17))
		sparks:Fire("StartSpark","",0)

		sparks:Spawn()

		for i = 1, self:GetDTFloat(1) do
			timer.Simple(i, function()
				local timeLeft = self:GetDTFloat(1)
				local newTimeLeft = timeLeft - 1
				self:SetDTFloat(1, newTimeLeft)
			end)
		end

		timer.Simple(self:GetDTFloat(1), function()
			drill:Remove()
			sparks:Remove()
			self:SetDTBool(0, false)

			local lootbag = ents.Create( "nut_lootbag" ) 
			lootbag:SetPos(self:GetPos() + (self:GetForward() * 50) + (self:GetRight() * 10))
			lootbag:SetAngles(self:GetAngles())
			lootbag:Spawn()

			local lootbagtwo = ents.Create( "nut_lootbag" ) 
			lootbagtwo:SetPos(self:GetPos() + (self:GetForward() * 50) + (self:GetRight() * -10))
			lootbagtwo:SetAngles(self:GetAngles())
			lootbagtwo:Spawn()
			for i = 1, 25 do	
				nut.currency.Spawn(math.random(10,200), self:GetPos() + self:GetForward() * 50 + (self:GetUp()*i*5) + Vector(math.random(-10,25),math.random(10,25),math.random(-10,25)))
			end
		end)
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
		local fix_rotation = Vector(0, 90, 90)

		fix_angles:RotateAroundAxis(fix_angles:Right(), fix_rotation.x)
		fix_angles:RotateAroundAxis(fix_angles:Up(), fix_rotation.y)
		fix_angles:RotateAroundAxis(fix_angles:Forward(), fix_rotation.z)

		local beingDrilled = self:GetDTBool(0)
		local drillTime    = self:GetDTFloat(1)

		if beingDrilled == true then
			cam.Start3D2D( position + (self:GetUp() * 10) + (self:GetForward() * 20) + (self:GetRight() * 0), fix_angles, 0.25 )
				draw.DrawText(drillTime, "nut_TokensFont", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			cam.End3D2D();
		end
	end;
end
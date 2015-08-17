AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Drill"
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
		self:SetModel("models/props_lab/tpplug.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self:SetDTBool(0, false)
		self:drillIntoVault()

	end
	
	function ENT:SetAmount(arg1, arg2)

		if arg1 == "BeingDrilled" then
			
			self:SetDTBool(0, arg2)

		elseif arg1 == "DrillTime" then
			
			self:SetDTFloat(1, arg2)

		end

	end;

	function ENT:Use(activator)
		if (activator:IsPlayer()) then
		
			self:drillIntoVault()

		end
	end

	function ENT:drillIntoVault()

		if self:GetDTBool(2) == true then return end;

		self:SetAmount("BeingDrilled", true)
		self:SetDTBool(2, true)

		local physicsObject = self:GetPhysicsObject()
		local sparks = ents.Create("env_spark")

		sparks:SetParent( physicsObject:GetEntity() )
		sparks:SetPos(self:GetPos())
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

			sparks:Remove()

			self:SetDTBool(0, false)
			self:Remove()

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

		cam.Start3D2D( position + (self:GetUp() * 10) + (self:GetForward() * 10), fix_angles, 0.25 )
			draw.DrawText(drillTime, "nut_TokensFont", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	end

end;
end
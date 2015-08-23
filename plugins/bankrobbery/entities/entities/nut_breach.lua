AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "C4"
ENT.Author = "Johnny Guitar"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "detTime" );

end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_wasteland/prison_padlock001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self:SetDTFloat(0, 10)
		self:blowDoor()

	end

	function ENT:Use(activator)
		if (activator:IsPlayer()) then
		
			self:drillIntoVault()

		end
	end

	function ENT:Explode()

		local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
			effectData:SetScale(6)
		util.Effect("HelicopterMegaBomb", effectData, true, true)

		self:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav")

	end

	function ENT:blowDoor()

		for i = 1, self:GetDTFloat(0) do

			
			timer.Simple(i, function()

				self:SetDTFloat(0, self:GetDTFloat(0) - 1)

				self:EmitSound( "buttons/button6.wav", 110, 70 + (i * 20) ) 

			end)

		end

		timer.Simple(self:GetDTFloat(0), function()

			self:Explode()
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

	local detTime    = self:GetDTFloat(0)

	if detTime == 10 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 255 - 65, 255, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 9 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 205 - 65, 200, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 8 then
		
		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 185 - 65, 100, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 7 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 165 - 65, 50, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 6 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 145 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 5 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 145 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 4 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 125 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 3 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 105 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	elseif detTime == 2 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 85 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();
	
	elseif detTime == 1 then

		cam.Start3D2D(position + (self:GetUp() * 1) + (self:GetForward() * 2), fix_angles, 0.25 )
			draw.DrawText(detTime, "nut_TokensFont", 0, 0, Color(255, 65 - 65, 0, 255), TEXT_ALIGN_CENTER )
		cam.End3D2D();

	end
	
end
end
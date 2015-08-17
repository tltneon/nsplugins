local PLUGIN = PLUGIN
PLUGIN.name = "Prone"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Prone."
PLUGIN.viewOffset = { 20, 64 }
local playerMeta = FindMetaTable("Player")

--[[
	Purpose: Registering animations for RPAM Model Packs.
--]]
local actPLUGIN = nut.plugin.Get( "act" )
if actPLUGIN then
	actPLUGIN.sequences["citizen_blacktea"] = table.Copy(actPLUGIN.sequences["citizen_male"])
	actPLUGIN.sequences["citizen_blacktea_f"] = table.Copy(actPLUGIN.sequences["citizen_blacktea"])
	local notsupported = {
		"injured3",
		"injured4",
		"injured1",
		"examineground",
		"standpockets",
		"arrestlow",
		"clap",
		"showid",
		"stand",
	}
	local supported = {

	}
	for _, str in pairs( notsupported ) do
		actPLUGIN.sequences["citizen_blacktea_f"][ str ] = nil
	end
else
	print('ACT IS NOT REGISTERED? WHAT?')
end

-- Custom Black Tea citizen animation tree.
nut.anim.citizen_blacktea = {
	normal = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_BOLT},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_DOD_PRIMARYATTACK_KNIFE,
	},
	pistol = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_PISTOL},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_PISTOL},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	smg = {
		idle = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		idle = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = {ACT_IDLE, ACT_DOD_WALK_AIM_SPADE},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_SPADE},
		walk = {ACT_WALK, ACT_DOD_WALK_AIM_SPADE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_DOD_PRIMARYATTACK_PRONE_SPADE
	},
	melee = {
		idle = {ACT_IDLE_SUITCASE, ACT_DOD_WALK_AIM_SPADE},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_SPADE},
		walk = {ACT_WALK, ACT_DOD_WALK_AIM_SPADE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_BOLT},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_DOD_PRIMARYATTACK_PRONE_SPADE
	},
	glide = ACT_JUMP
}
nut.anim.citizen_blacktea_f = {
	normal = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_BOLT},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_DOD_PRIMARYATTACK_KNIFE,
	},
	pistol = {
		idle = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_PISTOL},
		walk = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_PISTOL},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_PISTOL},
		run = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_DOD_RELOAD_PISTOL
	},
	smg = {
		idle = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_DOD_RELOAD_MP40
	},
	shotgun = {
		idle = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_MP40},
		walk = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_SPADE},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_MP40},
		run = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_DOD_PRIMARYATTACK_PRONE_SPADE
	},
	melee = {
		idle = {ACT_IDLE_SUITCASE, ACT_DOD_WALK_AIM_SPADE},
		idle_crouch = {ACT_COVER_LOW, ACT_COVER_LOW},
		idle_prone = {ACT_DOD_PRONE_AIM_SPADE, ACT_DOD_PRONE_AIM_SPADE},
		walk = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		walk_crouch = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		walk_prone = {ACT_DOD_PRONEWALK_IDLE_BOLT, ACT_DOD_PRONEWALK_IDLE_BOLT},
		run = {ACT_RUN, ACT_RUN},
		attack = ACT_DOD_PRIMARYATTACK_PRONE_SPADE
	},
	glide = ACT_JUMP
}

for i = 1, 9 do
	nut.anim.SetModelClass("citizen_blacktea", Format("models/custom/male_0%d.mdl", i))
end
for i = 1, 7 do
	if (i == 5) then continue end
	nut.anim.SetModelClass("citizen_blacktea_f", Format("models/custom/female_0%d.mdl", i))
end

--[[
	Purpose: Main functions. Do not touch anythng but IsBlackTeaModel
	if nessasary.
--]]

function playerMeta:Proning()
	return (self.character and self:GetNetVar("prone"))
end

function PLUGIN:IsBlackTeaModel(model)
	local class = nut.anim.GetClass(model)
	return (class == "citizen_blacktea" or class == "citizen_blacktea_f")
end

if SERVER then
	function playerMeta:Prone(boolProne)
		if (!nextProne or nextProne < CurTime()) then
			self:EmitSound("items/ammopickup.wav", 50, math.random(150, 160))
			if (boolProne) then
				local avz = self:GetAimVector().z
				self:ViewPunch( Angle(math.Clamp((1+avz)*90, 0, 180), 0, 0) )
				self:SetNetVar("prone", true)
				self:SetNetVar("t_prone", CurTime()+1)
				self:SetHull( Vector(-16, -16, 0), Vector(16, 16, 16) )
				self:SetViewOffset(Vector( 0, 0, PLUGIN.viewOffset[1]))
			else
				self:ViewPunch( Angle(30, 0, 0) )	
				self:SetNetVar("prone", false)
				self:SetNetVar("t_prone", CurTime()+1)
				self:SetHull( Vector(-16, -16, 0), Vector(16, 16, 64) )
				self:SetViewOffset(Vector( 0, 0, PLUGIN.viewOffset[2]))
			end
			nextProne = CurTime() + 1.5
		end
	end

	function PLUGIN:CanStartSeq(client)
		if  (client:Proning()) then
			nut.util.Notify("You must stand or crouch to perform any acts.", client)

			return false
		end
	end

	function PLUGIN:PlayerDeath(client)
		client:Prone(false)
	end

	function PLUGIN:PlayerSpawn(client)
		client:SetNetVar("prone", false)
		client:SetNetVar("t_prone", CurTime()+1)
		client:SetHull( Vector(-16, -16, 0), Vector(16, 16, 64) )
		client:SetViewOffset(Vector( 0, 0, self.viewOffset[2]))
	end

	local string_lower = string.lower
	concommand.Add( "prone", function(client, cmd, args)
		if (nut.schema.Call("IsBlackTeaModel", string_lower(client:GetModel()))) then
			if (nut.schema.Call("CanProne", client) != false) then
				client:Prone(!client:Proning())
			end
		else
			nut.util.Notify("This model doesn't supports prone.",client)
		end
	end)

	function PLUGIN:CanProne(client)
		local proning = client:Proning()
		if (!client:Alive()) then
			return false
		end
		if (client:GetOverrideSeq()) then
			nut.util.Notify("You must stop your act before go prone.", client)
			return false
		end
		if (client:IsRagdolled()) then
			nut.util.Notify("You must gain stablility to go prone.", client)
			return false
		end
		if (proning) then
			local data = {}
				data.start = client:GetPos()
				data.endpos = data.start + Vector(0, 0, 1)
				data.filter = client
				data.mins = Vector(-16, -16, 0)
				data.maxs = Vector(16, 16, 64)
			local trace = util.TraceHull(data)
			if (trace.Hit) then
				nut.util.Notify("Not enough space to stand.",client)
				return false
			end
		else
			local data = {}
				data.start = client:GetPos()
				data.endpos = data.start - Vector(0, 0, 1)
				data.filter = client
				data.mins = Vector(-16, -16, 0)
				data.maxs = Vector(16, 16, 16)
			local trace = util.TraceHull(data)
			if (!trace.Hit) then
				nut.util.Notify("You have to stand on the ground.",client)
				return false
			end
		end
	end
else
	local string_lower = string.lower
	local function resetbones(client)
		if (client.resetd) then return end
		local bone = client:LookupBone( "ValveBiped.Bip01_R_Clavicle" )
		if (!bone or bone == 0) then return end
		client:ManipulateBonePosition( bone, Vector())
		client:ManipulateBoneAngles(bone, Angle())
		local bone = client:LookupBone( "ValveBiped.Bip01_L_Clavicle" )
		client:ManipulateBonePosition( bone, Vector())
		client:ManipulateBoneAngles(bone, Angle())
		local bone = client:LookupBone( "ValveBiped.Bip01_Neck1" )
		client:ManipulateBonePosition( bone, Vector())
		client:ManipulateBoneAngles(bone, Angle())
		local bone = client:LookupBone( "ValveBiped.Bip01_Head1" )
		client:ManipulateBonePosition( bone, Vector())
		client.resetd = true
	end
	function PLUGIN:Think()
		local client = LocalPlayer()
		if client:Proning() then
			client:SetViewOffset(Vector( 0, 0, self.viewOffset[1]))
			client:SetHull( Vector(-16, -16, 0), Vector(16, 16, 16) )
		else
			client:SetViewOffset(Vector( 0, 0, self.viewOffset[2]))
			client:SetHull( Vector(-16, -16, 0), Vector(16, 16, 64) )
		end
		-- Manly Girl Fix
		for _, client in pairs(player.GetAll()) do
			if (!client.character) then continue end
			local model = string_lower(client:GetModel())
			local class = nut.anim.GetClass(model)
			if class == "citizen_blacktea_f" then
				if (client:Proning() or client:GetNetVar("t_prone", 0) > CurTime()) then
					local bone = client:LookupBone( "ValveBiped.Bip01_R_Clavicle" )
					client:ManipulateBonePosition( bone, Vector(0,-2,2) )
					client:ManipulateBoneAngles(bone, Angle(0, -5, -5))
					local bone = client:LookupBone( "ValveBiped.Bip01_L_Clavicle" )
					client:ManipulateBonePosition( bone, Vector(0,-2,-2) )
					client:ManipulateBoneAngles(bone, Angle(5, -5, 5))
					local bone = client:LookupBone( "ValveBiped.Bip01_Neck1" )
					client:ManipulateBonePosition( bone, Vector(-1,-2,0) )
					client:ManipulateBoneAngles(bone, Angle(0, 4, 0))
					local bone = client:LookupBone( "ValveBiped.Bip01_Head1" )
					client:ManipulateBonePosition( bone, Vector(-2,1,1) )
					client.resetd = false
				else
					resetbones(client)
				end
			else
				resetbones(client)
			end
		end
	end
end

--[[
	Purpose: Hooks.
--]]


local math_NormalizeAngle = math.NormalizeAngle
local string_find = string.find
local string_lower = string.lower
local getAnimClass = nut.anim.GetClass
local getHoldType = nut.util.GetHoldType
local config = nut.config

local Length2D = FindMetaTable("Vector").Length2D

function PLUGIN:Move(client, mv)
	if (client:GetMoveType() == 8) then return end
	if (!client.character) then return end
	if client:Proning() then
		local f = mv:GetForwardSpeed() 
		local s = mv:GetSideSpeed() 
		mv:SetForwardSpeed( f * .005 )
		mv:SetSideSpeed( s * .0025 )
	end
    if client:GetNetVar("t_prone", 0) > CurTime() then
		mv:SetForwardSpeed( 0 )
		mv:SetSideSpeed( 0 )
    end
end

function PLUGIN:PlayerBindPress(client, bind, pressed)
	if (client:Proning() or client:GetNetVar("t_prone", 0) > CurTime()) then
		return (bind == "+jump" or bind == "+duck")
	end
end

function GM:CalcMainActivity(client, velocity)
	local model = string_lower(client:GetModel())
	local class = getAnimClass(model)

	if (string_find(model, "/player/") or string_find(model, "/playermodel") or class == "player") then
		return self.BaseClass:CalcMainActivity(client, velocity)
	end

	if (client.character and client:Alive()) then
		client.CalcSeqOverride = -1

		local weapon = client:GetActiveWeapon()
		local holdType = "normal"
		local action = "idle"
		local length2D = Length2D(velocity)

		if (length2D >= config.runSpeed - 10) then
			if (!client:Proning()) then
				action = "run"
			end
		elseif (length2D >= 5) then
			action = "walk"
		end

		if (client:Crouching()) then
			action = action.."_crouch"
		elseif client:Proning() then
			action = action.."_prone"
		end

		local state = WEAPON_LOWERED

		if (IsValid(weapon)) then
			holdType = getHoldType(weapon)

			if (weapon.AlwaysRaised or config.alwaysRaised[weapon:GetClass()]) then
				state = WEAPON_RAISED
			end
		end

		if (client:WepRaised()) then
			state = WEAPON_RAISED
		end
		
		local animClass = nut.anim[class]

		if (!animClass) then
			class = "citizen_male"
		end

		if (!animClass[holdType]) then
			holdType = "normal"
		end

		if (!animClass[holdType][action]) then
			action = "idle"
		end

		local animation = animClass[holdType][action]
		local value = ACT_IDLE

		if (!client:OnGround()) then
			client.CalcIdeal = animClass.glide or ACT_GLIDE
		elseif (client:InVehicle()) then
			client.CalcIdeal = animClass.normal.idle_crouch[1]
		elseif (animation) then
			value = animation[state]

			if (type(value) == "string") then
				client.CalcSeqOverride = client:LookupSequence(value)
			else
				client.CalcIdeal = value
			end
		end

		if (nut.schema.Call("IsBlackTeaModel", model)) then
			local ang = client:GetAimVector()
			client:SetPoseParameter("body_pitch", math.Clamp(ang.z*90, -46, 90))
			local pp = (client:GetPoseParameter("head_yaw")-.5)*-160
        	client:SetPoseParameter("body_yaw", math.Clamp(pp, -45, 45 ) )
		end

		if (client:Proning()) then
        	if client:GetNetVar("t_prone", 0) > CurTime() then
        		client.CalcIdeal = ACT_GET_DOWN_STAND
        	end
        else
        	client:SetPoseParameter("body_yaw", 0 )
        	if client:GetNetVar("t_prone", 0) > CurTime() then
        		client.CalcIdeal = ACT_GET_UP_STAND
        	end
		end

		local override = client:GetNetVar("seq")

		if (override) then
			client.CalcSeqOverride = client:LookupSequence(override)
		end

		if (CLIENT) then
			client:SetIK(false)
		end

		local eyeAngles = client:EyeAngles()
		local yaw = velocity:Angle().yaw
		local normalized = math_NormalizeAngle(yaw - eyeAngles.y)

		client:SetPoseParameter("move_yaw", normalized)

		return client.CalcIdeal or ACT_IDLE, client.CalcSeqOverride or -1
	end
end

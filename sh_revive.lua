PLUGIN.name = "Revive"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "EMTs can revive dead players!"

local PLUGIN = PLUGIN

if CLIENT then
	surface.CreateFont( "ReviveText", {
	 font = "Trebuchet MS",
	 size = 25,
	 weight = 500,
	 blursize = 0,
	 scanlines = 0,
	 antialias = true
	} )

	hook.Add("HUDPaint", "DrawDeadPlayers", function()
		if (LocalPlayer().character) then
			if LocalPlayer().character:GetVar("faction") != FACTION_EMT then return end
			for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
				if IsValid(v) and v.isDeadBody then
					local Pos = v:GetPos():ToScreen()
					draw.RoundedBox(0, Pos.x, Pos.y, 10, 40, Color(175, 100, 100))
					draw.RoundedBox(0, Pos.x - 15, Pos.y + 15, 40, 10, Color(175, 100, 100))

					draw.SimpleText("Time Left: "..math.Round(v:GetNWFloat("Time") - CurTime()), "ReviveText", Pos.x, Pos.y - 20, Color(249, 255, 239), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end)

	netstream.Hook("nut_DeadBody", function( index )
		local ragdoll = Entity(index)
		print(index, ragdoll)

		if IsValid(ragdoll) then
			ragdoll.isDeadBody = true
		end
	end)
else
	function PLUGIN:PlayerSpawn( client )
		client:UnSpectate()
		if not client.character then 
			return 
		end

		if IsValid(SCHEMA.Corpses[client]) then
			SCHEMA.Corpses[client]:Remove()
		end

		if client.character:GetVar("faction") == FACTION_EMT then
			timer.Simple(0.1, function()
				client:Give("weapon_eurp_defib")
				client:SelectWeapon("weapon_eurp_defib")
			end)
		end
	end

	--[[
		Purpose: Called when the player has died with a valid character.
	--]]

	SCHEMA.Corpses = SCHEMA.Corpses or {}

	function SCHEMA:DoPlayerDeath( client, attacker, dmg )
		if not client.character then 
			return 
		end
		SCHEMA.Corpses[client] = ents.Create("prop_ragdoll")
		SCHEMA.Corpses[client]:SetPos(client:GetPos())
		SCHEMA.Corpses[client]:SetModel(client:GetModel())
		SCHEMA.Corpses[client]:Spawn()
		SCHEMA.Corpses[client]:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		local phys = SCHEMA.Corpses[client]:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:ApplyForceCenter(client:GetVelocity() * 15);
		end
		SCHEMA.Corpses[client].player = client
		SCHEMA.Corpses[client]:SetNWFloat("Time", CurTime() + nut.config.deathTime)
		SCHEMA.Corpses[client]:SetNWBool("Body", true)

		timer.Simple(0.5, function()
			netstream.Start(nil, "nut_DeadBody", SCHEMA.Corpses[client]:EntIndex())
		end)

		hook.Run("GenerateEvidences", client, SCHEMA.Corpses[client], attacker, dmg)
		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(SCHEMA.Corpses[client])
		timer.Simple(0.01, function()
			if(client:GetRagdollEntity() != nil and client:GetRagdollEntity():IsValid()) then
				client:GetRagdollEntity():Remove()
			end
		end)
		for k,ply in pairs(player.GetAll()) do
			if ply.character then
				if ply.character:GetVar("faction") == FACTION_EMT then
					nut.util.Notify("DISPATCH: A citizen has been severely wounded and need medical attention!", ply)
					ply:ChatPrint("DISPATCH: A citizen has been severely wounded and need medical attention!")
				end
			end
		end
	end
end
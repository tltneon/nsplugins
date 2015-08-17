local PLUGIN = PLUGIN

PLUGIN.hospital = {Vector(-11377, 9176, 225), Vector(-10914, 9785, 60)}
PLUGIN.wakeUp = {
	{Vector(-10183, 9132, 100), Angle(-95, 90, 180)},
	{Vector(-10063, 9132, 100), Angle(-95, 90, 180)},
	{Vector(-9947, 9132, 100), Angle(-95, 90, 180)},
	{Vector(-9947, 8956, 100), Angle(-95, -90, 180)},
	{Vector(-10063, 8956, 100), Angle(-95, -90, 180)},
	{Vector(-10183, 8956, 100), Angle(-95, -90, 180)}
}
PLUGIN.wakeUpENT = {}
PLUGIN.ER = {
	{Vector(-10772, 9077, 116), Angle(-85, 0, 0)},
	{Vector(-10772, 9692, 116), Angle(-85, 0, 0)},
	{Vector(-10173, 9686, 125), Angle(-85, 180, 180)},
	{Vector(-9961, 9686, 125), Angle(-85, 0, 180)}
}
PLUGIN.ERENT = {}
PLUGIN.wakePos = {Vector(-9972, 9044, 73), Angle(0, 180, 0)}
PLUGIN.podPos = {Vector(0, 34, 42), Angle(-80, 90, 0)}
PLUGIN.gurneyModel = "models/props_unique/hospital/gurney.mdl"

OrderVectors(PLUGIN.hospital[1], PLUGIN.hospital[2])

function PLUGIN:InitPostEntity()
	timer.Simple(1, function()
		for _, v in pairs(self.wakeUp) do
			local pod = ents.Create("prop_vehicle_prisoner_pod")
			pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
			pod:SetKeyValue("vehiclescript" , "scripts/vehicles/prisoner_pod.txt")
			pod:SetPos(v[1])
			pod:SetAngles(v[2])
			pod.VehicleTable = list.Get("Vehicles")["Pod"]
			pod:Spawn()
			pod:Activate()
			pod:SetColor(Color(255, 255, 255, 0))
			pod:SetRenderMode(RENDERMODE_TRANSALPHA)
			pod:SetMoveType(MOVETYPE_NONE)
			pod:SetNWBool("WakeTbl", true)

			local podData = list.Get("Vehicles")["Pod"]
			if podData.KeyValues then
				for k, v in pairs(podData.KeyValues) do
					pod:SetKeyValue( k, v )
				end
			end

			table.insert(self.wakeUpENT, pod)
		end

		for _, v in pairs(self.ER) do
			local pod = ents.Create("prop_vehicle_prisoner_pod")
			pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
			pod:SetKeyValue("vehiclescript" , "scripts/vehicles/prisoner_pod.txt")
			pod:SetPos(v[1])
			pod:SetAngles(v[2])
			pod.VehicleTable = list.Get("Vehicles")["Pod"]
			pod:Spawn()
			pod:Activate()
			pod:SetColor(Color(255, 255, 255, 0))
			pod:SetRenderMode(RENDERMODE_TRANSALPHA)
			pod:SetMoveType(MOVETYPE_NONE)
			pod:SetNWBool("OpTable", true)

			local podData = list.Get("Vehicles")["Pod"]
			if podData.KeyValues then
				for k, v in pairs(podData.KeyValues) do
					pod:SetKeyValue( k, v )
				end
			end

			table.insert(self.ERENT, pod)
		end
	end)
end

function PLUGIN:PlayerSpawnedVehicle( ply, vehicle )
	if not vehicle.VehicleTable then return end
	if vehicle.VehicleTable.Gurney then
		local Gurney = vehicle.VehicleTable.Gurney
		local pos, ang = LocalToWorld(Gurney["in"][1], Gurney["in"][2], vehicle:GetPos(), vehicle:GetAngles())
		local gurney = ents.Create("prop_physics")
		gurney:SetModel(self.gurneyModel)
		gurney:SetPos(pos)
		gurney:SetAngles(ang)
		gurney:Spawn()
		gurney:Activate()
		gurney:SetParent(vehicle)
		gurney:DeleteOnRemove(vehicle)
		vehicle.gurney = gurney

		local pos, ang = LocalToWorld(self.podPos[1], self.podPos[2], gurney:GetPos(), gurney:GetAngles())
		local pod = ents.Create("prop_vehicle_prisoner_pod")
		pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		pod:SetKeyValue("vehiclescript" , "scripts/vehicles/prisoner_pod.txt")
		pod:SetPos(pos)
		pod:SetAngles(ang)
		pod:Spawn()
		pod:Activate()
		pod:SetColor(Color(255, 255, 255, 0))
		pod:SetRenderMode(RENDERMODE_TRANSALPHA)
		pod:SetParent(gurney)
		pod:DeleteOnRemove(gurney)
		gurney.pod = pod

		local podData = list.Get("Vehicles")["Pod"]
		if podData.KeyValues then
			for k, v in pairs(podData.KeyValues) do
				pod:SetKeyValue( k, v )
			end
		end
	end
end

function GM:PlayerDeathThink( ply )
	if (ply.character and ply:GetNutVar("deathTime", 0) < CurTime()) then
		ply:Spawn()
		for _, v in pairs(ents.GetAll()) do
			if v.player == ply then
				v.player = nil
				break
			end
		end
		nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) wasn't revived.", LOG_FILTER_CONCOMMAND)
		return true
	end
	return false
end

function PLUGIN:Think()
	for _, ply in pairs(player.GetAll()) do
		if (ply.character and ply.character.revive and ply:GetNutVar("deathTime", 0) < CurTime()) then
			ply.character.revive = false
			ply.character.stabilized = false
			ply:Spawn()
			nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." )'s revive attempt was failed (Timer ran out).", LOG_FILTER_CONCOMMAND)
		end
	end
end

function PLUGIN:CanExitVehicle( vehicle, ply )
	if ply.character.revive then
		return false
	end
end

function PLUGIN:DeployGurney( ply, vehicle )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if IsValid(vehicle.gurney) then
			local gurney = vehicle.gurney
			local GurneyData = vehicle.VehicleTable.Gurney or {}
			local pos, ang = LocalToWorld(GurneyData["in"][1], GurneyData["in"][2], vehicle:GetPos(), vehicle:GetAngles())
			gurney:SetPos(GurneyData["out"][1])
			gurney:SetAngles(ang)
			vehicle.oldFuel = vehicle.fuel
			vehicle.fuel = 0
			nut.util.Notify("Gurney deployed", ply)
		else
			nut.util.Notify("Gurney not found!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end

function PLUGIN:RetractGurney( ply, vehicle )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if IsValid(vehicle.gurney) then
			local gurney = vehicle.gurney
			local GurneyData = vehicle.VehicleTable.Gurney or {}
			local pos, ang = LocalToWorld(GurneyData["in"][1], GurneyData["in"][2], vehicle:GetPos(), vehicle:GetAngles())
			gurney:SetPos(GurneyData["in"][1])
			gurney:SetAngles(ang)
			vehicle.fuel = vehicle.oldFuel or vehicle.fuel
			nut.util.Notify("Gurney retracted", ply)
		else
			nut.util.Notify("Gurney not found!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end

function PLUGIN:PutInAmbulance( ply, entity )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if IsValid(entity) and entity:GetNWBool("Body") then
			if IsValid(entity.player) then
				local dist = 32768
				local found
				for k,v in pairs(ents.FindByClass("prop_vehicle_jeep")) do
					if v.type == "EMT" and v.gurney then
						local carDist = v:GetPos():Distance(ply:GetPos())
						if carDist < dist then
							dist = carDist
							found = v
						end
					end
				end
				if dist > 300 then
					nut.util.Notify("No ambulances in range!", ply)
					return
				end
				if not IsValid(found.gurney.pod:GetDriver()) then
					local victim = entity.player
					victim:Spawn()
					timer.Simple(0.1, function()
						victim:EnterVehicle(found.gurney.pod)
						victim.character.revive = true
						nut.util.Notify("The victim is now in the gurney.", ply)
						nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) put "..entity.player.character:GetVar("charname").." ( "..entity.player:RealName().." ) in an ambulance.", LOG_FILTER_CONCOMMAND)
						if IsValid(entity) then
							entity:Remove()
						end
					end)
				else
					nut.util.Notify("The gurney is already in use!", ply)
				end
			else
				nut.util.Notify("Player not found...", ply)
			end
		else
			nut.util.Notify("You must be looking at an unconscious citizen!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end

function PLUGIN:Hospitalize( ply, vehicle )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if ply:GetPos():WithinAABox(self.hospital[1], self.hospital[2]) then
			if IsValid(vehicle.gurney) then
				local pod = vehicle.gurney.pod
				if IsValid(pod:GetDriver()) then
					local victim = pod:GetDriver()
					local er
					local id
					for k, v in pairs(self.ERENT) do
						if not IsValid(v:GetDriver()) then
							er = v
							id = k
							break
						end
					end
					if er then
						victim:ExitVehicle()
						victim:EnterVehicle(er)
						nut.util.Notify("The victim is now in ER-"..id, ply)
						nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) hospitalized "..victim.character:GetVar("charname").." ( "..victim:RealName().." ).", LOG_FILTER_CONCOMMAND)
					else
						nut.util.Notify("The hospital is full, at least une ER needs to be free.", ply)
					end
				else
					nut.util.Notify("There is no one to hospitalize!", ply)
				end
			else
				nut.util.Notify("Gurney not found!", ply)
			end
		else
			nut.util.Notify("You are not at the hospital!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end

function PLUGIN:Operate( ply, vehicle )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if IsValid(vehicle) then
			if vehicle:GetNWBool("OpTable") then
				if IsValid(vehicle:GetDriver()) then
					local victim = vehicle:GetDriver()
					if victim.character.revive then
						local bed
						for _, v in pairs(self.wakeUpENT) do
							if not IsValid(v:GetDriver()) then
								bed = v
								break
							end
						end
						if bed then
							victim:ExitVehicle()
							victim:EnterVehicle(bed)
							victim.character.stabilized = false
							nut.util.Notify("The patient is now safe and sound, go wake him/her up.", ply)
							nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) operated "..victim.character:GetVar("charname").." ( "..victim:RealName().." ).", LOG_FILTER_CONCOMMAND)
						else
							nut.util.Notify("The waking room is full, go wake up some patients first!", ply)
						end
					else
						nut.util.Notify("This person does not require medical attention.", ply)
					end
				else
					nut.util.Notify("There is no one to operate!", ply)
				end
			else
				nut.util.Notify("This is not an operating table!", ply)
			end
		else
			nut.util.Notify("You are not looking at anything!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end

function PLUGIN:WakeUp( ply, vehicle )
	if ply.character:GetVar("faction") == FACTION_EMT or ply:IsAdmin() then
		if IsValid(vehicle) then
			if vehicle:GetNWBool("WakeTbl") then
				if IsValid(vehicle:GetDriver()) then
					local victim = vehicle:GetDriver()
					victim:ExitVehicle()
					victim.character.revive = false
					timer.Simple(0.5, function()
						victim:SetPos(self.wakePos[1])
						victim:SetEyeAngles(self.wakePos[2])
					end)
					nut.util.Notify("The patient was woken up.", ply)
					nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) woke up "..victim.character:GetVar("charname").." ( "..victim:RealName().." ).", LOG_FILTER_CONCOMMAND)
				else
					nut.util.Notify("There is no one to wake up!", ply)
				end
			else
				nut.util.Notify("This is not a bed!", ply)
			end
		else
			nut.util.Notify("You are not looking at anything!", ply)
		end
	else
		nut.util.Notify("You must be a member of the EMT!", ply)
	end
end
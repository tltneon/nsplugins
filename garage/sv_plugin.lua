local PLUGIN = PLUGIN

netstream.Hook("GarageRequest", function( ply, netTbl )
	local carID = netTbl[1]
	local storage = netTbl[2]
	local storageData = PLUGIN.GetStorage(storage)
	local customVehData = ply.character:GetData("vehicles")
	local defaultVehData = PLUGIN.GetCar(customVehData[carID].class)
	if not customVehData then
		nut.util.Notify("ERROR: Couldn't retreive 'customVehData'! Go yell at Starfox64!", ply)
		return
	elseif not defaultVehData then
		nut.util.Notify("ERROR: Couldn't retreive 'defaultVehData'! Go yell at Starfox64!", ply)
		return
	elseif not storageData then
		nut.util.Notify("ERROR: Couldn't retreive 'storageData'! Go yell at Starfox64!", ply)
		return
	end
	if customVehData[carID].onWorld and customVehData[carID].ent then
		if IsValid(Entity(customVehData[carID].ent)) then
			local vehicle = Entity(customVehData[carID].ent)
			if vehicle.disabled then
				nut.util.Notify("Your vehicle is disabled!", ply)
				return
			end

			if storageData.spawnPos:Distance(vehicle:GetPos()) <= 300 then
				local newData = customVehData
				newData[carID].inv = vehicle.storage:GetNetVar("inv", {})
				newData[carID].money = vehicle.storage:GetNetVar("money", 0)
				newData[carID].fuel = math.Round(vehicle.fuel)
				newData[carID].color = vehicle:GetColor()
				newData[carID].storage = storage
				newData[carID].hp = vehicle:Health()
				newData[carID].onWorld = false
				newData[carID].ent = nil
				vehicle.storage:Remove()
				vehicle:Remove()
				table.RemoveByValue(ply.VehiclesOut, vehicle)
				ply.character:SetData("vehicles", newData, ply, false)
				nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) stored a "..customVehData[carID].class..".", LOG_FILTER_CONCOMMAND)
			else
				nut.util.Notify("Your vehicle is too far!", ply)
			end
		else
			nut.util.Notify("ERROR: This vehicle does not exist, reseting vehicle data. Please try again.")
			local newData = customVehData
			newData[carID].ent = nil
			newData[carID].onWorld = false
			ply.character:SetData("vehicles", newData, ply, false)
		end
	elseif !customVehData[carID].onWorld and customVehData[carID].storage == storage then
		if customVehData[carID].ent then
			if IsValid(Entity(customVehData[carID].ent)) then
				Entity(customVehData[carID].ent):Remove()
			end
		end
		if ply.VehiclesOut then
			if table.Count(ply.VehiclesOut) + 1 > PLUGIN.maxVehiclesOut then
				nut.util.Notify("You cannot have more than "..PLUGIN.maxVehiclesOut.." vehicles out!", ply)
				return
			end
		end
		local vehicle = ents.Create("prop_vehicle_jeep")
		vehicle:SetModel(defaultVehData.model)
		vehicle:SetKeyValue("vehiclescript", defaultVehData.script)
		vehicle:SetPos(storageData.spawnPos)
		vehicle:SetAngles(storageData.spawnAng)
		vehicle:SetHealth(customVehData[carID].hp or 1000)
		vehicle:Spawn()
		vehicle.owner = ply
		vehicle:SetNetVar("owner", ply) -- To lazy to find where I'm using each of these ;)
		vehicle.fuel = customVehData[carID].fuel
		vehicle:SetColor(customVehData[carID].color or Color(255, 255, 255))
		vehicle.type = defaultVehData.type
		vehicle:SetSkin(defaultVehData.skin)
		vehicle.locked = false
		if defaultVehData.photon then
			vehicle.VehicleTable = list.Get("Vehicles")[defaultVehData.photon]
		end

		hook.Run("PlayerSpawnedVehicle", ply, vehicle) -- Passanger Mod

		local storage = ents.Create("nut_container")
		storage:SetPos(vehicle:GetPos())
		storage:Spawn()
		storage:Activate()
		storage:SetModel("models/Gibs/HGIBS.mdl")
		storage:PhysicsInit(SOLID_NONE)
		storage:SetParent(vehicle)
		storage:SetColor(Color(0, 0, 0, 0))
		storage:SetRenderMode(RENDERMODE_TRANSALPHA)
		storage:SetNetVar("inv", customVehData[carID].inv)
		storage:SetNetVar("money", customVehData[carID].money)
		storage:SetNetVar("name", "Trunk")
		storage.itemID = "trunk"
		storage.Trunk = true
		storage:SetNetVar("max", defaultVehData.maxWeight)
		vehicle.storage = storage

		local newData = customVehData
		newData[carID].storage = "N/A"
		newData[carID].onWorld = true
		newData[carID].ent = vehicle:EntIndex()
		ply.character:SetData("vehicles", newData, ply, false)

		if not ply.VehiclesOut then
			ply.VehiclesOut = {vehicle}
		else
			table.insert(ply.VehiclesOut, vehicle)
		end
		nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) took out his "..customVehData[carID].class..".", LOG_FILTER_CONCOMMAND)
	end
end)

netstream.Hook("VehShopRequest", function( ply, netTbl )
	local type = netTbl[1]
	local vehID = netTbl[2]
	local color = netTbl[3]
	local ShopStorage = "DowntownMotors"
	local plyVehicles = ply.character:GetData("vehicles", {})
	if type == 1 then -- Buy
		if table.Count(plyVehicles) >= PLUGIN.maxVehicles then
			nut.util.Notify("You have reached the maximum vehicles amount per character. ("..PLUGIN.maxVehicles..")", ply)
			return
		else
			if !ply:HasLicense("driving") and ply.character:GetVar("faction") == FACTION_CITIZEN then
				nut.util.Notify("You do not have a drivers license!", ply)
				return
			end

			local data = PLUGIN.GetCar(vehID)
			if ply:CanAfford(data.price) then
				local dist = 32768
				for k,v in pairs(PLUGIN.Storages) do
					local shopDist = v.pos:Distance(ply:GetPos())
					if shopDist < dist then
						dist = shopDist
						ShopStorage = k
					end
				end
				local carData = {}
				carData.class = vehID
				carData.color = Color(color.r, color.g, color.b)
				carData.fuel = 100
				carData.inv = {}
				carData.money = 0
				carData.storage = ShopStorage
				carData.onWorld = false
				carData.ent = nil
				local newData = plyVehicles
				table.insert(newData, carData)
				ply.character:SetData("vehicles", newData, ply, false)
				ply:TakeMoney(data.price)
				nut.char.Save(ply)
				nut.util.Notify("You have successfully bought a "..data.name.." for "..nut.currency.GetName(data.price)..". It is now in the "..ShopStorage.." storage.", ply)
				nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) bought a "..vehID..".", LOG_FILTER_CONCOMMAND)
			else
				nut.util.Notify("You do not have enough money!", ply)
				return
			end
		end
	elseif type == 2 then -- Sell
		vehID = tonumber(vehID)
		local data = plyVehicles[vehID]
		if data.onWorld then
			local veh = Entity(data.ent)
			if IsValid(veh) then
				if veh:GetPos():Distance(ply:GetPos()) <= 700 then
					veh.storage:Remove()
					veh:Remove()
					local carData = PLUGIN.GetCar(data.class)
					local sellPrice = math.Round(carData.price / 1.5) -- 75%
					ply:GiveMoney(sellPrice)
					newData = plyVehicles
					table.remove(newData, vehID)
					ply.character:SetData("vehicles", newData, ply, false)
					nut.char.Save()
					nut.util.Notify("You have successfully sold your "..carData.name.." for "..nut.currency.GetName(sellPrice)..".", ply)
					nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) sold his "..data.class..".", LOG_FILTER_CONCOMMAND)
				else
					nut.util.Notify("Your vehicle is too far away.", ply)
				end
			end
		else
			nut.util.Notify("Your vehicle must be out of your storage.", ply)
		end
	else -- ERROR
		nut.util.Notify("ERROR: No Type!", ply)
	end
end)

netstream.Hook("GiveVehicle", function( ply, netTbl )
	local vehID = netTbl[1]
	local target = netTbl[2]
	local car = ply.character:GetData("vehicles", {})[vehID]
	local carName = PLUGIN.GetCar(car.class).name

	if target == ply then return end

	if car and not car.onWorld then
		if IsValid(target) and target.character then
			local targetCars = target.character:GetData("vehicles", {})
			local plyCars = ply.character:GetData("vehicles", {})

			table.remove(plyCars, vehID)
			ply.character:SetData("vehicles", plyCars)

			table.insert(targetCars, car)
			target.character:SetData("vehicles", targetCars)

			nut.util.Notify("Your "..carName.." is now in "..target:Name().."'s garage.", ply)
			nut.util.Notify(ply:Name().." has sent a "..carName.." to your garage.", target)

			nut.util.AddLog(ply:Name().. " ( "..ply:RealName().." ) sent his "..carName.." to "..target:Name().." ( "..target:RealName().." )'s garage.", LOG_FILTER_CONCOMMAND)

			nut.char.Save(ply)
			nut.char.Save(target)
		else
			nut.util.Notify("ERROR: Target not found!", ply)
		end
	else
		nut.util.Notify("ERROR: Vehicle not found!", ply)
	end
end)

hook.Add("PlayerLoadedChar", "VehCharChange", function( ply )
	if ply.VehiclesOut then
		if table.Count(ply.VehiclesOut) > 0 then
			for k,v in pairs(player.GetAll()) do
				nut.util.Notify(ply:Name().."'s vehicles are being removed. Reason: Changing Character", v)
			end
			nut.util.AddLog(ply:Name().." ("..ply:SteamID()..") is changing character with vehicles on the world.", LOG_FILTER_MAJOR)
			for k,v in pairs(ply.VehiclesOut) do
				if IsValid(v.storage) then
					v.storage:Remove()
				end
				if IsValid(v) then
					v:Remove()
				end
			end
			table.Empty(ply.VehiclesOut)
		end
	end
	local vehicles = ply.character:GetData("vehicles", {})
	for k,v in pairs(ply.character:GetData("vehicles", {})) do
		local newData = v
		newData.onWorld = false
		newData.ent = nil
		if not v.storage or v.storage == "N/A" then
			newData.storage = "Downtown"
		end
		vehicles[k] = newData
	end
	ply.character:SetData("vehicles", vehicles, ply, false)
end)

hook.Add("PlayerDisconnected", "VehiclesCleanup", function( ply )
	if ply.VehiclesOut then
		if table.Count(ply.VehiclesOut) > 0 then
			for k,v in pairs(player.GetAll()) do
				nut.util.Notify(ply:Name().."'s vehicles are being removed. Reason: Player Disconnected", v)
			end
			nut.util.AddLog(ply:Name().." ("..ply:SteamID()..") is disconnecting with vehicles on the world.", LOG_FILTER_MAJOR)
			for k,v in pairs(ply.VehiclesOut) do
				v.storage:Remove()
				v:Remove()
			end
		end
	end
end)

timer.Create("VehiclesAutoSave", 300, 0, function()
	for _,ply in pairs(player.GetAll()) do
		if ply.VehiclesOut then
			for k,v in pairs(ply.character:GetData("vehicles", {})) do
				if v.onWorld and v.ent then
					local ent = Entity(v.ent)
					if IsValid(ent) then
						local newData = ply.character:GetData("vehicles", {})
						if IsValid(ent.storage) then
							newData[k].inv = ent.storage:GetNetVar("inv", {})
							newData[k].money = ent.storage:GetNetVar("money", 0)
						end
						ply.character:SetData("vehicles", newData, ply, false)
					end
				end
			end
		end
	end
end)

hook.Add("InitPostEntity", "SpawnGarageEntities", function()
	for k,v in pairs(PLUGIN.Storages) do
		local ent = ents.Create("nut_garage")
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:Spawn()
		ent:Activate()
	end
	for k,v in pairs(PLUGIN.VehShops) do
		local vendor = ents.Create("npc_carvendor")
		vendor:SetPos(v.pos)
		vendor:SetAngles(v.ang)
		vendor.type = v.type
		vendor:SetModel(v.model)
		vendor:SetMoveType(MOVETYPE_NONE)
		vendor:Spawn()
		vendor:Activate()
	end	
end)

netstream.Hook("carColorSet", function( ply, color )
	if ply:GetMoney() >= 100 then
		ply:GetVehicle():SetColor(Color(color.red, color.green, color.blue))
		ply:SetMoney(ply:GetMoney() - 100)
		nut.util.Notify("You changed the color of your car for 100 €, put it back in your garage to save it!", ply)
	else
		nut.util.Notify("You do not have enough money! You need 100 € to change the color of your car.", ply)
	end
end)

timer.Create("FuelNetwork", 5, 0, function()
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "prop_vehicle_jeep" then
			if v.fuel then
				v:SetNWInt("fuel", v.fuel)
			end
		end
	end
end)

function PLUGIN.Honk( player, vehicle )
	if player:KeyDown( IN_ATTACK ) then
		if !vehicle.bool_honk then
			vehicle.bool_honk = true
			vehicle:EmitSound("horn.wav")
		end
	else
		if vehicle.bool_honk then
			vehicle.bool_honk = false
		end
	end
end

function PLUGIN.Tow( player, vehicle )
	if player:KeyDown( IN_ZOOM ) then
		if !vehicle.bool_tow then
			vehicle.bool_tow = true
			if vehicle.type == "TOW" then
				if not vehicle.tow then
					local traceData = {
						start = vehicle:GetPos(),
						endpos = vehicle:GetPos() + Angle(0, 0, 0):Forward() * 150,
						filter = vehicle
					}
					local trace = util.TraceLine(traceData)
					if trace.Entity then
						local target = trace.entity
						if target:IsVehicle() then
							local const = constraint.Rope(vehicle, target:EntIndex(), 0, 0, PLUGIN.TowTruckPos, PLUGIN.TowPos, PLUGIN.RopeLength, 0, 0, PLUGIN.RopeWidth, PLUGIN.RopeMaterial, false)
							if const then
								nut.util.Notify("Vehicle hooked!", player)
								vehicle.tow = target
							else
								nut.util.Notify("Hooking failed! (Constraints ERROR)", player)
							end
						end
					end
				else
					local removed = constraint.RemoveConstraints(vehicle, "Rope")
					if removed then
						vehicle.tow = nil
						nut.util.Notify("Vehicle released.", player)
					end
				end
			end
		end
	else
		if vehicle.bool_tow then
			vehicle.bool_tow = false
		end
	end
end

function PLUGIN:Think()
	for k, v in pairs( player.GetAll() ) do
		if v:InVehicle() then
			local vehicle = v:GetVehicle()
			if vehicle:IsValid() then
				local vel = vehicle:GetVelocity():Length()
				if vel > 0 then
					vehicle.fuel = math.Clamp( ( ( vehicle.fuel or 0 ) - vel/1000000 ), 0, 100 )
				end
				if not vehicle.fuel then vehicle.fuel = 0 end
				if vehicle.fuel <= 0 then
					local phys = vehicle:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity( phys:GetVelocity()* -1 )
					end
				end
				if vehicle:GetClass() == "prop_vehicle_jeep" then
					PLUGIN.Honk(v, vehicle)
					PLUGIN.Tow(v, vehicle)
				end
			end
		end
	end
end

function PLUGIN:CanPlayerEnterVehicle( ply, ent, role )
	if ent.disabled then return false end
end

function PLUGIN:EntityTakeDamage( ent, dmginfo )
	if not ent:IsVehicle() then return end
	local damage = dmginfo:GetDamage()

	if dmginfo:IsBulletDamage() then
		ent:SetHealth(ent:Health() - (2500 * damage))
	elseif dmginfo:IsExplosionDamage() then
		ent:SetHealth(ent:Health() - (6 * damage))
	else
		ent:SetHealth(ent:Health() - damage)
	end

	if ent:IsValid() and ent:Health() <= 250 and not ent.smoking then
		ent.smoking = true
		local att = ent:LookupAttachment("vehicle_engine")
		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, ent, att)
	end

	if ent:IsValid() and ent:Health() <= 0 and not ent.disabled then
		ent.disabled = true
		local rand = math.random(10, 25)
		ent:Ignite(rand, 100)
		timer.Simple(rand, function()
			if not ent:IsValid() then return end
			local expl = ents.Create("env_explosion")
			ParticleEffect("explosion_huge_f", ent:GetPos(), Angle(0, 0, 0))
			expl:SetPos(ent:GetPos())
			expl:SetOwner(dmginfo:GetAttacker())
			expl:Spawn()
			expl:SetKeyValue("iMagnitude", "175")
			expl:Fire("Explode", 0, 0)
			ent:SetColor(Color(0, 0, 0))

			if IsValid(ent:GetDriver()) then
				ent:GetDriver():Kill()
			end

			if ent.Seats then
				for _, v in pairs(ent.Seats) do
					if IsValid(v) then
						if IsValid(v:GetDriver()) then
							v:GetDriver():Kill()
						end

						--v:Remove() -- No need for unusable seats
					end
				end
			end

			if IsValid(ent.owner) then
				local customVehData = ent.owner.character:GetData("vehicles", {})
				for k, v in pairs(customVehData) do
					if v.onWorld and ent:EntIndex() == v.ent then
						customVehData[k] = nil
					end
				end

				ent.owner.character:SetData("vehicles", customVehData)
				table.RemoveByValue(ent.owner.VehiclesOut, ent)
				nut.util.AddLog(ent.owner:Name().." ("..ent.owner:RealName()..")'s vehicle was destroyed.", LOG_FILTER_MAJOR)
			end
		end)
	end
end
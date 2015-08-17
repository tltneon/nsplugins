local PLUGIN = PLUGIN
PLUGIN.Storages = PLUGIN.Storages or {}

function PLUGIN:LoadData()
	self.Homes = nut.util.ReadTable("homes") or {}

	for class, homeData in pairs(self.Homes) do
		for _, door in pairs(homeData.doors) do
			local doorEnt = ents.GetMapCreatedEntity(door)

			if IsValid(doorEnt) then
				doorEnt:SetNetVar("title", homeData.name)
				doorEnt:SetNetVar("unownable", true)
				doorEnt.home = class
			end
		end

		if homeData.storage then
			local storage = ents.Create("nut_container")
			storage:SetPos(homeData.storage[1] + Vector(0, 0, -20))
			storage:Spawn()
			storage:Activate()
			storage:SetModel("models/Gibs/HGIBS.mdl")
			storage:PhysicsInit(SOLID_NONE)
			storage:SetNetVar("inv", homeData.inv)
			storage:SetNetVar("money", homeData.money)
			storage:SetNetVar("name", "Home Storage")
			storage.itemID = "trunk"
			storage.Trunk = true
			storage:SetNetVar("max", homeData.storage[3])
			self.Storages[class] = storage

			local homeStorage = ents.Create("nut_homestorage")
			homeStorage:SetPos(homeData.storage[1])
			homeStorage:SetAngles(homeData.storage[2])
			homeStorage:Spawn()
			homeStorage:SetMoveType(MOVETYPE_NONE)
			homeStorage.storage = storage
		end
	end

	local npc = ents.Create("nut_property")
	npc:SetPos(self.consoleSpawn[1])
	npc:SetAngles(self.consoleSpawn[2])
	npc:Spawn()
	npc:SetMoveType(MOVETYPE_NONE)
end

function PLUGIN:SaveData()
	if table.Count(self.Homes) > 0 then
		for class, storage in pairs(self.Storages) do
			if IsValid(storage) then
				self.Homes[class].inv = storage:GetNetVar("inv")
				self.Homes[class].money = storage:GetNetVar("money")
			end
		end
		nut.util.WriteTable("homes", self.Homes)
	end
end

netstream.Hook("nut_BuyHome", function( ply, home )
	local homeData = PLUGIN.Homes[home]

	if homeData and not homeData.owner then
		if ply:CanAfford(homeData.price) then
			homeData.owner = {ply.character:GetVar("id"), ply.character:GetVar("charname")}
			homeData.leaveTime = os.time() + PLUGIN.rentTime
			PLUGIN.Homes[home] = homeData

			ply:TakeMoney(homeData.price)

			netstream.Start(nil, "nut_UpdateHomes", {key = home, value = homeData})
			nut.util.Notify("You have successfully purchased the "..homeData.name.." home!", ply)
			PLUGIN:SaveData()
			nut.char.Save(ply)
		else
			nut.util.Notify("You cannot afford this home!", ply)
		end
	else
		nut.util.Notify("Home Unavailable!", ply)
	end
end)

netstream.Hook("nut_SellHome", function( ply, home )
	local homeData = PLUGIN.Homes[home]

	if homeData and homeData.owner[1] == ply.character:GetVar("id") then
		local timeLeft = homeData.leaveTime - os.time()
		if timeLeft > PLUGIN.maxSellTime then
			homeData.owner = nil
			homeData.leaveTime = 0
			homeData.cowners = {}
			PLUGIN.Homes[home] = homeData

			local sellPrice = math.Round(timeLeft / PLUGIN.rentTime * (homeData.price * PLUGIN.sellRatio))
			ply:GiveMoney(sellPrice)

			netstream.Start(nil, "nut_UpdateHomes", {key = home, value = homeData})
			nut.util.Notify("You have successfully sold the "..homeData.name.." home for "..sellPrice.."€!", ply)
			PLUGIN:SaveData()
			nut.char.Save(ply)
		else
			nut.util.Notify("You cannot sell this home anymore!", ply)
		end
	else
		nut.util.Notify("Home Unavailable!", ply)
	end
end)

netstream.Hook("nut_GiveHome", function( ply, data )
	local homeData = PLUGIN.Homes[data[1]]
	local target

	for _, v in pairs(player.GetAll()) do
		if v.character and v.character:GetVar("id") == data[2] then
			target = v
			break
		end
	end

	if not IsValid(target) then
		nut.util.Notify("Target Unavailable!", ply)
		return
	end

	if homeData and homeData.owner[1] == ply.character:GetVar("id") then
		homeData.owner = {data[2], target.character:GetVar("charname")}
		PLUGIN.Homes[data[1]] = homeData

		netstream.Start(nil, "nut_UpdateHomes", {key = data[1], value = homeData})
		nut.util.Notify("You have successfully gave the "..homeData.name.." home to "..target.character:GetVar("charname").."!", ply)
		nut.util.Notify(ply.character:GetVar("charname").." gave you the "..homeData.name.." home!", target)
		PLUGIN:SaveData()
	else
		nut.util.Notify("Home Unavailable!", ply)
	end
end)

netstream.Hook("nut_AddCowner", function( ply, data )
	local homeData = PLUGIN.Homes[data[1]]
	local target

	for _, v in pairs(player.GetAll()) do
		if v.character and v.character:GetVar("id") == data[2] then
			target = v
			break
		end
	end

	if not IsValid(target) then
		nut.util.Notify("Target Unavailable!", ply)
		return
	end

	if homeData and homeData.owner[1] == ply.character:GetVar("id") then
		for _, v in pairs(homeData.cowners) do
			if v[1] == data[2] then
				nut.util.Notify(target.character:GetVar("charname").." is already a  Co-Owner!", ply)
				return
			end
		end

		table.insert(homeData.cowners, {data[2], target.character:GetVar("charname")})
		PLUGIN.Homes[data[1]] = homeData

		netstream.Start(nil, "nut_UpdateHomes", {key = data[1], value = homeData})
		nut.util.Notify(target.character:GetVar("charname").." is now a Co-Owner of the "..homeData.name.." home!", ply)
		nut.util.Notify("You are now a Co-Owner of the "..homeData.name.." home!", target)
		PLUGIN:SaveData()
	else
		nut.util.Notify("Home Unavailable!", ply)
	end
end)

netstream.Hook("nut_RemCowner", function( ply, data )
	local homeData = PLUGIN.Homes[data[1]]
	local target

	for _, v in pairs(player.GetAll()) do
		if v.character and v.character:GetVar("id") == data[2] then
			target = v
			break
		end
	end

	if homeData and homeData.owner[1] == ply.character:GetVar("id") then
		local removed = false
		for k, v in pairs(homeData.cowners) do
			if v[1] == data[2] then
				table.remove(homeData.cowners, k)
				removed = true
				break
			end
		end

		if removed then
			PLUGIN.Homes[data[1]] = homeData

			netstream.Start(nil, "nut_UpdateHomes", {key = data[1], value = homeData})
			nut.util.Notify(target.character:GetVar("charname").." is now a Co-Owner of the "..homeData.name.." home!", ply)

			if IsValid(target) then
				nut.util.Notify("You are now a Co-Owner of the "..homeData.name.." home!", target)
			end

			PLUGIN:SaveData()
		else
			nut.util.Notify("Co-Owner not found!", ply)
		end
	else
		nut.util.Notify("Home Unavailable!", ply)
	end
end)

local nextCheck = 0
function PLUGIN:Think()
	if CurTime() > nextCheck then
		for class, home in pairs(self.Homes) do
			if home.owner then
				if home.leaveTime < os.time() then
					for _, v in pairs(player.GetAll()) do
						if v.character and v.character:GetVar("id") == home.owner[1] then
							nut.util.Notify("The "..home.name.." is no longer yours!", v)
							break
						end
					end

					home.owner = nil
					home.cowners = {}
					home.leaveTime = 0

					self.Homes[class] = home
					self:UpdateHomes(class, home)
				end
			end
		end

		nextCheck = CurTime() + 60
	end
end

function PLUGIN:UpdateHomes( key, tbl, ply )
	if key then
		local value = {
			name = tbl.name,
			price = tbl.price,
			owner = tbl.owner,
			cowners = tbl.cowners,
			storage = tbl.storage,
			leaveTime = tbl.leaveTime,
			preview = tbl.preview
		}

		netstream.Start(nil, "nut_UpdateHomes", {key = key, value = value})
	else
		local value = {}
		for class, home in pairs(self.Homes) do
			value[class] = {
				name = home.name,
				price = home.price,
				owner = home.owner,
				cowners = home.cowners,
				storage = home.storage,
				leaveTime = home.leaveTime,
				preview = home.preview
			}
		end

		netstream.Start(ply, "nut_UpdateHomes", {reset = true, value = value})
	end
end

function PLUGIN:PlayerInitialSpawn( ply )
	self:UpdateHomes(nil, nil, ply)
end
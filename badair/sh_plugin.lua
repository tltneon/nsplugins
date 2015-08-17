local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

PLUGIN.name = "Bad Air"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Bad Air just like Metro. DrunkyBlur by Spy."
PLUGIN.deadZones = PLUGIN.deadZones or {}
PLUGIN.gasList = {} -- No Leave/Join/CharChange shit.

PLUGIN.gasDamage = 15
PLUGIN.maxGas = 100
PLUGIN.gasAmount = 10
PLUGIN.restoreAmount = 3
PLUGIN.thinkTime = 1
PLUGIN.damageTime = 3
-- to mod filter health amount, go to mask item file.

if (SERVER) then
	function PLUGIN:LoadData()
		self.deadZones = nut.util.ReadTable("gasvectors")
	end

	function PLUGIN:SaveData()
		nut.util.WriteTable("gasvectors", self.deadZones)
	end

	function PLUGIN:CanThroughBadAir(client)
		return false -- If this is true, The server will not think your breath status.
	end

	function PLUGIN:GetGasAmount(client, amount)
		if client:HasPartModel( "part_mask") then
			for k, v in pairs(client:GetItemsByClass("part_mask")) do
				local data = v.data

				if data.Equipped then
					if data.Filter and data.Filter > 0 then
						data.Filter = math.Clamp(data.Filter - 1, 0, math.huge)
						return 0
					end
				end
			end
		end
		return amount
	end
	
	function PLUGIN:GetRestoreAmount(client, amount)
		-- Add some perks/mask/item effects here.
		return amount
	end

	local damagetime = RealTime()
	function PLUGIN:OnBreathBadAir(client, damaged)
		if (damaged) then
			if damagetime < RealTime() then
				damagetime = RealTime() + self.damageTime

				client:TakeDamage(self.gasDamage)
				client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
			end
		else
			if self.gasList[client:SteamID()][client.character.index] > self.maxGas*.5 then
				if damagetime < RealTime() then
					damagetime = RealTime() + self.damageTime

					client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				end
			end
		end
	end

	function PLUGIN:DoPlayerDeath( client )
		self.gasList[client:SteamID()][client.character.index] = 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client.character.index])
	end

	function PLUGIN:PlayerLoadedChar(client)
		self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
		self.gasList[client:SteamID()][client.character.index] = self.gasList[client:SteamID()][client.character.index] or 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client.character.index])
	end

	local thinktime = RealTime()
	function PLUGIN:Think()
		if (thinktime < RealTime()) then
			thinktime = RealTime() + self.thinkTime

			for k, client in pairs(player.GetAll()) do
				local pos = client:GetPos() + client:OBBCenter() -- preventing fuckering around.
				local damaged = false

				if (!client.character) then
					continue
				end

				if (nut.schema.Call("CanThroughBadAir", client) == true) then
					continue
				end
				
				for _, vec in pairs(self.deadZones) do
					if (!vec[1] or !vec[2]) then 
						continue 
					end

					if (pos:WithinAABox(vec[1], vec[2])) then
						local gasamount = self.gasAmount
						gasamount = nut.schema.Call("GetGasAmount", client, gasamount)

						self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
						self.gasList[client:SteamID()][client.character.index] = self.gasList[client:SteamID()][client.character.index] or 0
						self.gasList[client:SteamID()][client.character.index] = math.Clamp( self.gasList[client:SteamID()][client.character.index] + gasamount, 0, self.maxGas)
						netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client.character.index])

						if (gasamount > 0) then
							if (self.maxGas <= self.gasList[client:SteamID()][client.character.index]) then -- replace 0 to player gas amount
								nut.schema.Call("OnBreathBadAir", client, true)
							else
								nut.schema.Call("OnBreathBadAir", client, false)
							end

							break
						end
					end
				end

				if (!damaged) then
					local restoreamount = self.restoreAmount
					restoreamount = nut.schema.Call("GetRestoreAmount", client, restoreamount)

					self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
					self.gasList[client:SteamID()][client.character.index] = self.gasList[client:SteamID()][client.character.index] or 0
					self.gasList[client:SteamID()][client.character.index] = math.Clamp( self.gasList[client:SteamID()][client.character.index] - restoreamount, 0, self.maxGas)
					netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client.character.index])
				end
			end
		end
	end
else
	local badair = 0
	netstream.Hook("nut_SyncBadAir", function(data)
		badair = data
	end)	

	PLUGIN.deltaBlur = SCHEMA.deltaBlur or 0

	function PLUGIN:RenderScreenspaceEffects()
		local blur = badair/self.maxGas
		self.deltaBlur = math.Approach(self.deltaBlur, blur, FrameTime() * 0.25)

		if (self.deltaBlur > 0) then
			DrawMotionBlur(0.1, self.deltaBlur, 0.01)
		end
	end
end

local function vecabs( v1, v2 )
	local fv1, fv2 = Vector( 0, 0, 0 ), Vector(0, 0, 0)

	for i = 1,3 do
		if v1[i] > v2[i] then
			fv1[i] = v2[i]
			fv2[i] = v1[i]
		else
			fv1[i] = v1[i]
			fv2[i] = v2[i]
		end
	end

	return fv1, fv2
end

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		if (!client:GetNutVar("badairMin")) then
			client:SetNutVar("badairMin", client:GetPos())

			nut.util.Notify( "Run the command again at a different position to set a maximum point.", client )
		else
			local vector1, vector2 = vecabs( client:GetNutVar("badairMin"),  client:GetPos() )
			table.insert(PLUGIN.deadZones, {vector1, vector2})
			nut.util.WriteTable("gasvectors", PLUGIN.deadZones)
			client:SetNutVar("badairMin", nil)

			nut.util.Notify("Added new bad-air area.", client)
		end
	end
}, "badairadd")

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		local pos = client:GetPos() + client:OBBCenter()

		for k, vec in pairs(PLUGIN.deadZones) do
			if (pos:WithinAABox(vec[1], vec[2])) then
				table.remove(PLUGIN.deadZones, k)
				nut.util.WriteTable("gasvectors", PLUGIN.deadZones)

				nut.util.Notify("You've removed bad-air area.", client)
				return
			end
		end

		print('Debug-Dead Zones')
		PrintTable(PLUGIN.deadZones)
		nut.util.Notify("To remove bad-air area, You have to be in bad-air area.", client)
	end
}, "badairremove")
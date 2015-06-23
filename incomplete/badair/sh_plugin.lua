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
		self.deadZones = self:setData() or {}
		PrintTable(self.deadZones)
	end

	function PLUGIN:SaveData()
		self:setData(self.deadZones)
	end
	
	function PLUGIN:OnCharCreated(client, character)
		self.gasList[client:SteamID()][character:getID()] = 0
	end

	function PLUGIN:CanThroughBadAir(client)
		return false -- If this is true, The server will not think your breath status.
	end

	function PLUGIN:GetGasAmount(client, amount)
		--if client:HasPartModel( "part_mask") then
			--for k, v in pairs(client:GetItemsByClass("part_mask")) do
				--if v:getData("equip") then
				print(client)
				local mask = client:getChar():getInv():hasItem("part_mask")
					if mask and mask > 0 then
						mask.Filter = math.Clamp(mask.Filter - 1, 0, math.huge)
						return 0
					end
				--end
			--end
		--end
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
			if self.gasList[client:SteamID()][client:getChar():getID()] > self.maxGas*.5 then
				if damagetime < RealTime() then
					damagetime = RealTime() + self.damageTime

					client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				end
			end
		end
	end

	function PLUGIN:DoPlayerDeath( client, attacker, dmg )
		self.gasList[client:SteamID()][client:getChar():getID()] = 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])
	end

	function PLUGIN:PlayerLoadedChar(client, character, lastChar)
		self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
		self.gasList[client:SteamID()][character:getID()] = self.gasList[client:SteamID()][character:getID()] or 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][character:getID()])
	end

	local thinktime = RealTime()
	function PLUGIN:Think()
		if (thinktime < RealTime()) then
			thinktime = RealTime() + self.thinkTime

			for k, client in pairs(player.GetAll()) do
				local pos = client:GetPos() + client:OBBCenter() -- preventing fuckering around.
				local damaged = false

				if (!client:getChar()) then
					continue
				end

				if (hook.Call("CanThroughBadAir", client) == true) then
					continue
				end
				
				for _, vec in pairs(self.deadZones) do
					if (!vec[1] or !vec[2]) then 
						continue 
					end

					if (pos:WithinAABox(vec[1], vec[2])) then
						local gasamount = self.gasAmount
						gasamount = hook.Call("GetGasAmount", client, gasamount)

						self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
						self.gasList[client:SteamID()][client:getChar():getID()] = self.gasList[client:SteamID()][client:getChar():getID()] or 0
						self.gasList[client:SteamID()][client:getChar():getID()] = math.Clamp( self.gasList[client:SteamID()][client:getChar():getID()] + gasamount, 0, self.maxGas)
						netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])

						if (gasamount > 0) then
							if (self.maxGas <= self.gasList[client:SteamID()][client:getChar():getID()]) then -- replace 0 to player gas amount
								hook.Call("OnBreathBadAir", client, true)
							else
								hook.Call("OnBreathBadAir", client, false)
							end

							break
						end
					end
				end

				if (!damaged) then
					local restoreamount = self.restoreAmount
					restoreamount = hook.Call("GetRestoreAmount", client, restoreamount)

					self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
					self.gasList[client:SteamID()][client:getChar():getID()] = self.gasList[client:SteamID()][client:getChar():getID()] or 0
					self.gasList[client:SteamID()][client:getChar():getID()] = math.Clamp( self.gasList[client:SteamID()][client:getChar():getID()] - restoreamount, 0, self.maxGas)
					netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])
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

nut.command.add("badairadd", {
	adminOnly = true,
	onRun = function(client, arguments)
		if (!client:getNetVar("badairMin")) then
			client:setNetVar("badairMin", client:GetPos())

			client:notify( "Run the command again at a different position to set a maximum point." )
		else
			local vector1, vector2 = vecabs( client:getNetVar("badairMin"),  client:GetPos() )
			PrintTable(PLUGIN.deadZones)
			print(vector1, vector2)
			table.insert(PLUGIN.deadZones, {vector1, vector2})
			PLUGIN:SaveData()
			client:setNetVar("badairMin", nil)

			client:notify("Added new bad-air area.")
		end
	end
} )

nut.command.add("badairremove", {
	adminOnly = true,
	onRun = function(client, arguments)
		local pos = client:GetPos() + client:OBBCenter()

		for k, vec in pairs(PLUGIN.deadZones) do
			if (pos:WithinAABox(vec[1], vec[2])) then
				table.remove(PLUGIN.deadZones, k)
				PLUGIN:SaveData()

				client:notify("You've removed bad-air area.")
				return
			end
		end

		print('Debug-Dead Zones')
		PrintTable(PLUGIN.deadZones)
		client:notify("To remove bad-air area, You have to be in bad-air area")
	end
})
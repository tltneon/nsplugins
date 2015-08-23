local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

PLUGIN.name = "Bad Air"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Bad Air just like Metro. DrunkyBlur by Spy."
PLUGIN.deadZones = PLUGIN.deadZones or {}
PLUGIN.gasList = {} -- No Leave/Join/CharChange shit.

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Bad Air Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

PLUGIN.gasDamage = 15
PLUGIN.maxGas = 100
PLUGIN.gasAmount = 10
PLUGIN.restoreAmount = 3
PLUGIN.thinkTime = 1
PLUGIN.damageTime = 3
-- to mod filter health amount, go to mask item file.

if (SERVER) then
	function PLUGIN:LoadData()
		self.deadZones = self:getData() or {}
	end

	function PLUGIN:SaveData()
		self:setData(self.deadZones)
	end

	function PLUGIN:CanThroughBadAir(client)
		return false -- If this is true, The server will not think your breath status.
	end

	function PLUGIN:GetGasAmount(client, amount)
		local char = client:getChar()

		if (char:getInv()) then
			for k, v in pairs(char:getInv():getItems()) do
				if (v.uniqueID == "mask" and v:getData("equip")) then
					if v:getData("filter") and v:getData("filter") > 0 then
						v:setData("filter", math.Clamp(v:getData("filter") - 1, 0, math.huge))
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
			if self.gasList[client:SteamID()][client:getChar():getID()] > self.maxGas*.5 then
				if damagetime < RealTime() then
					damagetime = RealTime() + self.damageTime

					client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				end
			end
		end
	end

	function PLUGIN:DoPlayerDeath( client )
		self.gasList[client:SteamID()][client:getChar():getID()] = 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])
	end

	function PLUGIN:PlayerLoadedChar(client)
		self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
		self.gasList[client:SteamID()][client:getChar():getID()] = self.gasList[client:SteamID()][client:getChar():getID()] or 0
		netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])
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
						gasamount = self:GetGasAmount(client, gasamount)
						--gasamount = hook.Call("GetGasAmount", client, gasamount)

						self.gasList[client:SteamID()] = self.gasList[client:SteamID()] or {}
						self.gasList[client:SteamID()][client:getChar():getID()] = self.gasList[client:SteamID()][client:getChar():getID()] or 0
						self.gasList[client:SteamID()][client:getChar():getID()] = math.Clamp( self.gasList[client:SteamID()][client:getChar():getID()] + gasamount, 0, self.maxGas)
						netstream.Start(client, "nut_SyncBadAir", self.gasList[client:SteamID()][client:getChar():getID()])

						if (gasamount > 0) then
							if (self.maxGas <= self.gasList[client:SteamID()][client:getChar():getID()]) then -- replace 0 to player gas amount
								self:OnBreathBadAir(client, true)
								--hook.Call("OnBreathBadAir", client, true)
							else
								self:OnBreathBadAir(client, false)
								--hook.Call("OnBreathBadAir", client, false)
							end

							break
						end
					end
				end

				if (!damaged) then
					local restoreamount = self.restoreAmount
					restoreamount = self:GetRestoreAmount(client, restoreamount)
					--restoreamount = hook.Call("GetRestoreAmount", client, restoreamount)

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

nut.command.Register({
	adminOnly = true,
	onRun = function(client, arguments)
		if (!client:getNetVar("badairMin")) then
			client:setNetVar("badairMin", client:GetPos())
			nut.util.Notify( "Run the command again at a different position to set a maximum point.", client )
		else
			local vector1, vector2 = vecabs( client:getNetVar("badairMin"),  client:GetPos() )
			table.insert(PLUGIN.deadZones, {vector1, vector2})
			PLUGIN:SaveData()
			client:setNetVar("badairMin", nil)

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
				PLUGIN:SaveData()
				nut.util.Notify("You've removed bad-air area.", client)
				return
			end
		end

		print('Debug-Dead Zones')
		PrintTable(PLUGIN.deadZones)
		nut.util.Notify("To remove bad-air area, You have to be in bad-air area.", client)
	end
}, "badairremove")
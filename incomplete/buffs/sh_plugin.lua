local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

PLUGIN.name = "Buffs and Debuffs"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Sometimes, You get sick or high. DrunkyBlur by Spy."
PLUGIN.buffs = {}

PLUGIN.Hunger = true
PLUGIN.quoteHungerThirst = true
PLUGIN.quoteThirst = {
	"My throat is burning...",
	"So thirsty....",
	"/me coughs",
}
PLUGIN.quoteHunger = {
	"",
}
PLUGIN.bleedChance = 50
PLUGIN.maxRadioactiveLevel = 1000
PLUGIN.bleedEnable = true
PLUGIN.legInjuryEnable = true
PLUGIN.legBreakEnable = true -- Enables leg break on high speed collision on the ground.
if CLIENT then
	PLUGIN.noBlur = false
end

nut.util.include("sh_buffs.lua")
nut.util.include("sh_buffhooks.lua")

-- player:GetBuffs()
-- returns table
-- This function gets one's all buffs.
function playerMeta:GetBuffs()
	return self:getNetVar( "buffs" ) or {}
end

-- player:AddBuff( string [Buff's unique name] )
-- returns table or boolean( false )
-- This function allows you handle buffs
function playerMeta:HasBuff( strBuff )
	if self:getNetVar( "buffs" ) != nil then
		return ( self:getNetVar( "buffs" )[ strBuff ] )
	else
		return false
	end
end

function PLUGIN:GetBuff( strBuff )
	return self.buffs[str]
end

if (SERVER) then
	-- player:AddBuff( string [Buff's unique name], integer [Buff's Duration Time], table [Parameters] )
	-- This function allows you to add some buffs to player.
	function playerMeta:AddBuff( strBuff, intDuration, parameter ) 
		if !intDuration then intDuration = math.huge end
		local tblBuffs = self:getNetVar( "buffs" ) or {}
		local tblBuffInfo = PLUGIN:GetBuff(strBuff)
		if tblBuffInfo and tblBuffInfo.onbuffed then
			if !self:HasBuff( strBuff ) then
				tblBuffInfo.onbuffed( self, parameter )
			end
		end
		tblBuffs[ strBuff ] = { CurTime() + intDuration, parameter }
		hook.Call( "OnBuffed", GAMEMODE, strBuff, intDuration, parameter )
		self:setNetVar( "buffs", tblBuffs )
	end
	
	-- player:RemoveBuff( string [Buff's unique name], table [Parameters] )
	-- This function allows you to add some buffs to player.
	function playerMeta:RemoveBuff( strBuff, parameter ) -- perma
		local tblBuffs = self:getNetVar( "buffs" ) or {}
			local tblBuffInfo = PLUGIN:GetBuff(strBuff)
			if tblBuffInfo and tblBuffInfo.ondebuffed then
				tblBuffInfo.ondebuffed( self, parameter )
			end
			tblBuffs[ strBuff ] = nil
			hook.Call( "OnDebuffed", GAMEMODE, strBuff, intDuration, parameter )
		self:setNetVar( "buffs", tblBuffs )
	end
	
	-- player:PlayerSpawn( player player )
	-- This hook wipes every buffs on your character.
	-- I suggest you do not touch this function unless you know what you're doing.
	function PLUGIN:PlayerSpawn( player )
		player:setNetVar( "buffs", {} )
	end

	-- player:Think( )
	-- This hook handles every player's buff effect.
	-- I suggest you do not touch this function unless you know what you're doing.
	function PLUGIN:Think()
		for k, v in pairs ( player.GetAll() ) do
			if !( v:IsValid() and v:Alive() ) then continue end 
			local tblBuffs = v:getNetVar( "buffs" ) or {}
			for name, dat in pairs( tblBuffs ) do
				local tblBuffInfo = self.buffs[ name ]
				if tblBuffInfo and tblBuffInfo.func then
					tblBuffInfo.func( v, dat[2] )
				end
				if dat[1] < CurTime() then
					v:RemoveBuff( name )
				end
			end
		end

		for class, bpnts in pairs( self.buffPoints ) do
			if self.nextBuff < CurTime() then
				for index, data in pairs(bpnts) do
					for key, ply in pairs( player.GetAll() ) do
						if data.pos:Distance( ply:GetPos() ) <= data.range then
							if ply:Alive() then
								ply:AddBuff(class, 1, data.parameter)
							end
						end
					end
				end
				self.nextBuff = CurTime() + self.nextBuffTime
			end
		end

	end

	PLUGIN.buffPoints = PLUGIN.buffPoints or {}
	PLUGIN.playerVars = PLUGIN.playerVars or {}
	PLUGIN.nextBuff = CurTime()
	PLUGIN.nextBuffTime = 1 -- to prevent exessive think.

	-- Easier commands.
	-- gotta redo this if we have more aerial buffs
	nut.command.add("radioactiveadd", {
 		syntax = "<number range> <number strength>",
		adminOnly = true,
		onRun = function(client, arguments)
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal*5

			local range = tonumber(arguments[1]) or 512
			local strength = tonumber(arguments[2])

			local buff = 'addrad'
			PLUGIN.buffPoints[buff] = PLUGIN.buffPoints[buff] or {}
			table.insert( PLUGIN.buffPoints[buff], { range = range, pos = hitpos, duration = 1, parameter = { amount = strength } })
			client:notify( "radioactive emitter has been added at your aiming position.")

		end
	})

	nut.command.add("radioactiveremove", {
		adminOnly = true,
		onRun = function(client, arguments)
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal*5
			local range = arguments[1] or 128
			local mt = 0
			local spnts = PLUGIN.buffPoints['addrad']
			for _, dat in pairs( spnts ) do
				local distance = dat.pos:Distance( hitpos )
				if distance <= tonumber(range) then
					table.remove( PLUGIN.buffPoints['addrad'], k )
					mt = mt + 1
				end
			end
			client:notify( mt .. " radioactive emitter has been removed.")
		end
	})

	local buffvars = {
		"radioactive",
	}

	function PLUGIN:DoPlayerDeath( client )
		for k, v in pairs( buffvars ) do
			client:setNetVar(v, 0)
		end
	end

	function PLUGIN:CharacterSave(client)
		local index = client:getChar().index
		self.playerVars[index] = self.playerVars[index] or {}
		for k, v in pairs( buffvars ) do
			if client:getNetVar(v) then
				self.playerVars[index][v] = client:getNetVar(v)
			end
		end
	end

	function PLUGIN:PlayerLoadedChar(client, character, lastChar)
		local index = client:getChar().index
		self.playerVars[index] = self.playerVars[index] or {}
		for k, v in pairs( buffvars ) do
			if self.playerVars[index][v] then
				client:setNetVar(v, self.playerVars[index][v])
			end
		end
	end

	function PLUGIN:LoadData()
		local data = self:getData() or {}
		self.buffPoints = data.buffPoints or {}
		self.playerVars = data.playerVars or {}
	end

	function PLUGIN:SaveData()
		local data = {}
		data.buffPoints = self.buffPoints
		data.playerVars = self.playerVars
		data:setData()
	end

	/* << BUFF POINT ADD COMMANDS. commentized due not easy enough to use.
	nut.command.add("buffPointsadd", {
 		syntax = "<string buffname> <number range> <number duration> <!string name> <!number value>",
		adminOnly = true,
		onRun = function(client, arguments)
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal*5
			local buff = arguments[1] 
			if !arguments[1] then
				client:notify("<buff uniqueid> is missing!")
				return
			end
			local range = tonumber(arguments[2]) or 200
			local duration = math.Clamp( tonumber(arguments[3]) or 0, 0, 60000 )
			if duration == 0 then
				duration = math.huge
			end
			table.remove( arguments, 1 ) -- deletes buff argument.
			table.remove( arguments, 1 ) -- deletes range argument.
			table.remove( arguments, 1 ) -- deletes range argument.

			local parameter = {}
			if #arguments >= 2 then
				for i = 1, math.floor( #arguments/2 ) do
					parameter[arguments[i]] = tonumber(arguments[i+1])
				end
				client:notify( "Caution: Putting string in the parameter value may cause the error!")
			end

			PLUGIN.buffPoints[buff] = PLUGIN.buffPoints[buff] or {}
			table.insert( PLUGIN.buffPoints[buff], { range = range, pos = hitpos, duration = duration, parameter = parameter })
			client:notify( buff .. " buffer -> " .. tostring( hitpos ) .. ": has been registered in buffer points.")

		end
	})

	nut.command.add("buffPointsremove", {
		adminOnly = true,
		onRun = function(client, arguments)
			local trace = client:GetEyeTraceNoCursor()
			local hitpos = trace.HitPos + trace.HitNormal*5
			local range = arguments[1] or 128
			local mt = 0
			for class, spnts in pairs( PLUGIN.buffPoints ) do
				for _, dat in pairs( spnts ) do
					local distance = dat.pos:Distance( hitpos )
					if distance <= tonumber(range) then
						table.remove( PLUGIN.buffPoints[class], k )
						mt = mt + 1
					end
				end
			end
			client:notify( mt .. " spawnpoints has been removed.")
		end
	})
	*/

else

	function PLUGIN:Think()
		for k, v in pairs ( player.GetAll() ) do
			if !( v:IsValid() and v:Alive() ) then continue end 
			local tblBuffs = v:getNetVar( "buffs" ) or {}
			for name, dat in pairs( tblBuffs ) do
				local tblBuffInfo = self.buffs[ name ]
				if tblBuffInfo and tblBuffInfo.cl_func then
					tblBuffInfo.cl_func( v, dat[2] )
				end
			end
		end
	end

end
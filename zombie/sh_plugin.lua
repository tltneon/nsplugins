local PLUGIN = PLUGIN
PLUGIN.name = "Zombie Director"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Zombie's Behaviors and Worls Spawns."

nut.util.Include("sh_lang.lua")
nut.util.Include("sh_effects.lua")

--ATTRIB_COOK = nut.attribs.SetUp("Cooking", "Affects how good is the result of cooking.", "cook")

local Entity = FindMetaTable("Entity")
function Entity:IsZombie()
	local class = self:GetClass()
	return ( class == "nut_bt_zombie" || class == "nut_bt_emitter" || class == "nut_bt_crawler")
end

if ( SERVER ) then

	NUT_MOB_ZOMBIE_HEALTH = CreateConVar( "nut_sk_zombie_health", 100, FCVAR_NONE, "Adjust Zombie's Health" )
	NUT_MOB_ZOMBIE_DAMAGE = CreateConVar( "nut_sk_zombie_damage", 15, FCVAR_NONE, "Adjust Zombie's Damage" )
	NUT_MOB_ZOMBIE_SPEED = CreateConVar( "nut_sk_zombie_speed", 200, FCVAR_NONE, "Adjust Zombie's Damage" )
	NUT_MOB_ZOMBIE_INTEREST = CreateConVar( "nut_sk_zombie_interest", 10, FCVAR_NONE, "Adjust Zombie's Searching Time for target when target is disappeared." )
	NUT_MOB_ZOMBIE_DETECTRANGE = CreateConVar( "nut_sk_zombie_detect", 2000, FCVAR_NONE, "Adjust Zombie's Detect Range" )
	NUT_MOB_ZOMBIE_MOBSIZE = CreateConVar( "nut_sk_zombie_maxzombie", 70, FCVAR_NONE, "Adjust Zombie's Max Zombie Amount" )
	NUT_MOB_ZOMBIE_REFRESH = CreateConVar( "nut_sk_zombie_refresh", 300, FCVAR_NONE, "Adjust Zombie's Refresh Rate" )
	NUT_MOB_ZOMBIE_MODEL = {}
	NUT_MOB_ZOMBIE_MODEL[1] = "models/player/charple.mdl"
	
	NUT_MOB_EMITTER_HEALTH = CreateConVar( "nut_sk_emitter_health", 300, FCVAR_NONE, "Adjust Emitter's Health" )
	NUT_MOB_EMITTER_DAMAGE = CreateConVar( "nut_sk_emitter_damage", 5, FCVAR_NONE, "Adjust Emitter's Damage" )
	NUT_MOB_EMITTER_SPEED = CreateConVar( "nut_sk_emitter_speed", 150, FCVAR_NONE, "Adjust Emitter's Damage" )
	NUT_MOB_EMITTER_RANGE = CreateConVar( "nut_sk_emitter_range", 300, FCVAR_NONE, "Adjust Emitter's Damage" )
	NUT_MOB_EMITTER_INTEREST = CreateConVar( "nut_sk_emitter_interest", 2, FCVAR_NONE, "Adjust Emitter's Searching Time for target when target is disappeared." )
	NUT_MOB_EMITTER_DETECTRANGE = CreateConVar( "nut_sk_emitter_detect", 1500, FCVAR_NONE, "Adjust Emitter's Detect Range" )
	NUT_MOB_EMITTER_MOBSIZE = CreateConVar( "nut_sk_emitter_maxzombie", 7, FCVAR_NONE, "Adjust Emitter's Max Zombie Amount" )
	NUT_MOB_EMITTER_REFRESH = CreateConVar( "nut_sk_emitter_refresh", 60, FCVAR_NONE, "Adjust Emitter's Refresh Rate" )
	NUT_MOB_EMITTER_MODEL = {}
	NUT_MOB_EMITTER_MODEL[1] = "models/Zombie/Poison.mdl"
	
	NUT_MOB_CRAWLER_HEALTH = CreateConVar( "nut_sk_crawler_health", 120, FCVAR_NONE, "Adjust Emitter's Health" )
	NUT_MOB_CRAWLER_DAMAGE = CreateConVar( "nut_sk_crawler_damage", 5, FCVAR_NONE, "Adjust Emitter's Damage" )
	NUT_MOB_CRAWLER_SPEED = CreateConVar( "nut_sk_crawler_speed", 333, FCVAR_NONE, "Adjust Emitter's Damage" )
	NUT_MOB_CRAWLER_INTEREST = CreateConVar( "nut_sk_crawler_interest", 4, FCVAR_NONE, "Adjust Emitter's Searching Time for target when target is disappeared." )
	NUT_MOB_CRAWLER_DETECTRANGE = CreateConVar( "nut_sk_crawler_detect", 1000, FCVAR_NONE, "Adjust Emitter's Detect Range" )
	NUT_MOB_CRAWLER_MOBSIZE = CreateConVar( "nut_sk_crawler_maxzombie", 6, FCVAR_NONE, "Adjust Emitter's Max Zombie Amount" )
	NUT_MOB_CRAWLER_REFRESH = CreateConVar( "nut_sk_crawler_refresh", 50, FCVAR_NONE, "Adjust Emitter's Refresh Rate" )
	NUT_MOB_CRAWLER_MODEL = {}
	NUT_MOB_CRAWLER_MODEL[1] = "models/Zombie/Fast.mdl"
	
	
	util.AddNetworkString("nut_SendToxic")

	PLUGIN.spawnpoint_z = PLUGIN.spawnpoint_z or {}
	
	function UselessZombie()
		for k, v in pairs( ents.GetAll() ) do
			if v:IsZombie() then
				v.timeUseless = v.timeUseless or CurTime()
				if v.timeUseless < CurTime() then
					v:Remove()
				end
			end
		end
	end
	
	local nextSpawn = CurTime()
	
	function PLUGIN:OnGunShot( owner, weapon )
		return false --** temp 
		/*
		local range = weapon.Primary.SoundRange or 1000
		for k, v in pairs( ents.FindInSphere( owner:GetPos(), range ) ) do
			if v:IsZombie() then
				v:SetTarget( owner )
				v.timeInterest = CurTime() + 3
			end
		end
		*/
	end
	
	function SpawnZombies()
		if 1 then return false end
		if !PLUGIN.spawnpoint_z or ( PLUGIN.spawnpoint_z && #PLUGIN.spawnpoint_z == 0 )  then return end
		
		if #ents.FindByClass( "nut_bt_zombie" ) <= NUT_MOB_ZOMBIE_MOBSIZE:GetInt() then
			if nextSpawn < CurTime() then
				local zombie = ents.Create( "nut_bt_zombie" )
				zombie:SetPos( PLUGIN.spawnpoint_z[ math.random( 1, #PLUGIN.spawnpoint_z ) ] + Vector( math.random( -1, 1 ), math.random( -1, 1 ), 0 ) * 30 )
				zombie:Spawn()
				zombie:Activate()
				nextSpawn = CurTime() + .1
			end
		end
		
		if #ents.FindByClass( "nut_bt_emitter" ) <= NUT_MOB_EMITTER_MOBSIZE:GetInt() then
			if nextSpawn < CurTime() then
				local zombie = ents.Create( "nut_bt_emitter" )
				zombie:SetPos( PLUGIN.spawnpoint_z[ math.random( 1, #PLUGIN.spawnpoint_z ) ] + Vector( math.random( -1, 1 ), math.random( -1, 1 ), 0 ) * 30 )
				zombie:Spawn()
				zombie:Activate()
				nextSpawn = CurTime() + .1
			end
		end
		
		if #ents.FindByClass( "nut_bt_crawler" ) <= NUT_MOB_EMITTER_MOBSIZE:GetInt() then
			if nextSpawn < CurTime() then
				local zombie = ents.Create( "nut_bt_crawler" )
				zombie:SetPos( PLUGIN.spawnpoint_z[ math.random( 1, #PLUGIN.spawnpoint_z ) ] + Vector( math.random( -1, 1 ), math.random( -1, 1 ), 0 ) * 30 )
				zombie:Spawn()
				zombie:Activate()
				nextSpawn = CurTime() + .1
			end
		end
		
	end
	
	
	ToxicZones = {}
	
	function AddToxicZone( vec, time )
		ToxicZones[ vec ] = CurTime() + time
		net.Start( "nut_SendToxic" )
			net.WriteVector( vec )
			net.WriteFloat( time )
		net.Broadcast()
	end
	
	function PLUGIN:PlayerInitialSpawn( p )
		for v, t in pairs( ToxicZones ) do
			net.Start( "nut_SendToxic" )
				net.WriteVector( v )
				net.WriteFloat( CurTime() - t )
			net.Send( p )
		end
	end
	
	function PLUGIN:ImmunePoison( ply )
		return ( IsCombine( ply ) )
	end
	
	local nextCloud = 0
	function ThinkToxicZone( )
		for v, t in pairs( ToxicZones ) do
			if t < CurTime() then
				ToxicZones[ v ] = nil
			end
			if nextCloud < CurTime() then
				for _, ply in pairs( ents.FindInSphere( v, 300 ) ) do
					if ply:IsPlayer() and !nut.schema.Call("ImmunePoison", ply) then	
						ply:AddBuff( "posion", 120 )
					end
				end
				nextCloud = CurTime() + 1
			end
		end
	end
	
	function PLUGIN:Think()
		
		ThinkToxicZone()
		UselessZombie()
		SpawnZombies()
	 
	end

	function PLUGIN:LoadData()
		self.spawnpoint_z = nut.util.ReadTable("spawnpoint_z")
	end

	function PLUGIN:SaveData()
		nut.util.WriteTable("spawnpoint_z", self.spawnpoint_z)
	end

else


	ToxicZones = ToxicZones or {}
	net.Receive( "nut_SendToxic", function() 
		local vec = net.ReadVector()
		local time = net.ReadFloat()
		ToxicZones[ vec ] = CurTime() + time
	end)
	local nextCloud = 0
	local em = ParticleEmitter( Vector( 0, 0, 0 ) )
	function PLUGIN:Think()
		if nextCloud < CurTime() then
			for v, t in pairs( ToxicZones ) do
				if t < CurTime() then
					ToxicZones[ v ] = nil
				end
				for i = 1, 3 do
					local pos =  v + Vector( math.Rand( -300, 300 ), math.Rand( -300, 300 ), math.Rand( -30, 100 ) )
					local p = em:Add( "particle/smokesprites_000"..math.random(1,9), pos ) 
					p:SetVelocity( Vector( 0, 0, 0 ) )
					p:SetDieTime(math.Rand(1,2))
					p:SetColor( 100, 255, 100 )
					p:SetStartSize( math.random( 11, 33 ) )
					p:SetEndSize( math.random( 222, 333 ) )
					p:SetRoll( 50 )
					p:SetRollDelta( math.Rand( -1, 1 ) )
				end
			end
			nextCloud = CurTime() + 1
		end
	end
	
	
end


nut.command.Register({
	adminOnly = true,
	syntax = "[bool showTime]",
	onRun = function(client, arguments)

		table.insert(PLUGIN.spawnpoint_z, client:GetPos())
		nut.util.WriteTable("spawnpoint_z", PLUGIN.spawnpoint_z)
		nut.util.Notify("Added new spawnpoint.", client)
		
	end
}, "addspawnpoint")

nut.command.Register({
	adminOnly = true,
	syntax = "[bool showTime]",
	onRun = function(client, arguments)

		local p = client:GetPos()
		for k, v in pairs( PLUGIN.spawnpoint_z ) do
			if p:Distance( v ) < 100 then
				table.remove( PLUGIN.spawnpoint_z, k )
				nut.util.Notify("Removed near spawnpoint.", client)
			end
		end

		nut.util.WriteTable("spawnpoint_z", PLUGIN.spawnpoint_z)
		
	end
}, "removespawnpoint")

nut.command.Register({
	adminOnly = true,
	syntax = "[bool showTime]",
	onRun = function(client, arguments)

		nut.util.Notify("Toggled 'Show Spawn Points' .", client)
		
	end
}, "showspawnpoint")
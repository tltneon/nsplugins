/*
	PLUGIN.buffs[ << string, Buff's Unique Name>> ] = { -- This is the unique name for identifying the buff.
		name =<< string, Buff's Display Name>>, -- This is the display name of the buff. 
		desc = << string, Buff's Description>>, -- This is the description of this buff.
		nodisp = << boolean, Buff's Display Factor >>, -- This is the factor for displaying this buff. ( For advaced scripters )
		func = << function, Buff's Think Function >>,
		onbuffed = << function, Buff's Function that executes on buffed >>, 
		onunbuffed = << function, Buff's Function that executes on Unbuffed >>, 
	}
*/

local PLUGIN = PLUGIN

/* 
	Example buffs. (a.k.a Not serious buffs)
*/

PLUGIN.buffs[ "sample_jumpy" ] = {
	name = "Random Jump",
	desc = "YOU'RE ADDICTED TO JUMP.",
	onbuffed = function( player, parameter )
		player:ChatPrint( "YOU'RE ADDICTED TO JUMP." )
	end,
	func = function( player, parameter)
		player.timeNextJump = player.timeNextJump or CurTime()
		if player.timeNextJump < CurTime() then
			if player:OnGround() then
				player:SetVelocity( Vector( 0, 0, 250 ) )
				player.timeNextJump = CurTime() + .5
			end
		end
	end,
} 

/* 
	Operational, Essense buffs.
	The buffs that you need.
*/

PLUGIN.buffs[ "heal" ] = {
	name = "Instant Heal",
	desc = "You Get Healed",
	nodisp = true, -- NO DISPLAY ( FOR HUDS )
	func = function( player, parameter)
		local medlvl = player:GetAttrib( ATTRIB_MEDICAL ) or 0
		local mul = parameter.skillmultiply or 0
		player:SetHealth( math.Clamp( player:Health() + parameter.amount + mul * medlvl, 0, player:GetMaxHealth() ) )
		player:RemoveBuff( "heal" )
	end,
}

PLUGIN.buffs[ "debuff_health" ] = {
	name = "Losing Health",
	desc = "You're losing health.",
	func = function( player, parameter)
		player.timeNextPain = player.timeNextPain or CurTime()
		if player.timeNextPain < CurTime() then
			player:TakeDamage( parameter.amount or 1 )
			player.timeNextPain = CurTime() + 1
		end
	end,
}

PLUGIN.buffs[ "leghurt" ] = {
	name = "Leg Injury",
	desc = "Your legs are injured and your movement has been handicapped.",
	onbuffed = function( player, parameter )
		if !player:HasBuff( "leghurt" ) then
			player:ChatPrint( L"buff_legs_injured" )
		end
	end,
	ondebuffed = function( player, parameter )
		if !player:Alive() then return end
		if player:HasBuff( "leghurt" ) then
			player:ChatPrint( L"buff_legs_restored" )
		end
	end,
	func = function( player, parameter)
		player.timeNextMoan = player.timeNextMoan or CurTime()
		if player.timeNextMoan < CurTime() then
			local gender = player:getChar():getNetVar( "gender" )
			player:EmitSound( Format( "vo/npc/%s01/pain0%d.wav", gender, math.random( 1, 9 ) ) )
			player.timeNextMoan = CurTime() + 5
			player:ScreenFadeOut(.5, Color(255, 50, 50, 50))
		end
	end,
} 

PLUGIN.buffs[ "starve" ] = {
	name = "Starvation",
	desc = "You're hungry.",
	onbuffed = function( player, parameter )
		if !player:HasBuff( "starve" ) then
			player:ChatPrint( "You're starving right now." )
		end
	end,
	ondebuffed = function( player, parameter )
		if player:HasBuff( "starve" ) then
			player:ChatPrint( "You're no longer starving right now." )
		end
	end,
	func = function( player, parameter)
		player.timeNextStarve = player.timeNextStarve or CurTime()
		if player.timeNextStarve < CurTime() then
			player:TakeDamage( 5 )
			player:ScreenFadeOut(.7, Color(255, 50, 50, 50))
			player.timeNextStarve = CurTime() + 40
			if PLUGIN.quoteHungerThirst then
				player:ConCommand( "say "..table.Random( PLUGIN.quoteHunger ) )
			end
		end
	end,
} 

PLUGIN.buffs[ "thirst" ] = {
	name = "Thirsty",
	desc = "You're dehydrated.",
	onbuffed = function( player, parameter )
		if !player:HasBuff( "thirst" ) then
			player:ChatPrint( "You're thirsty right now." )
		end
	end,
	ondebuffed = function( player, parameter )
		if player:HasBuff( "thirst" ) then
			player:ChatPrint( "You're no longer thirsty right now." )
		end
	end,
	func = function( player, parameter)
		player.timeNextDehydrated = player.timeNextDehydrated or CurTime()
		if player.timeNextDehydrated < CurTime() then
			player:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
			player:TakeDamage( 5 )
			player:ScreenFadeOut(.7, Color(255, 50, 50, 50))
			player.timeNextDehydrated = CurTime() + 30
			if PLUGIN.quoteHungerThirst then
				player:ConCommand( "say "..table.Random( PLUGIN.quoteThirst ) )
			end
		end
	end,
} 

PLUGIN.buffs[ "bleeding" ] = {
	name = "Bleeding",
	desc = "You're bleeding.",
	onbuffed = function( player, parameter )
		if !player:HasBuff( "bleeding" ) then
			player:ChatPrint( "You can feel you're losing your blood." )
		end
	end,
	func = function( player, parameter)
		player.timeNextPain = player.timeNextPain or CurTime()
		if player.timeNextPain < CurTime() then
			player:TakeDamage( 1 )
			player.timeNextPain = CurTime() + 5
			util.Decal( "Blood", player:GetPos() + Vector( 0, 0, 10 ), player:GetPos() - Vector( 0, 0, 100 ))
		end
	end,
	cl_func = function( player, parameter )
		parameter = parameter or {}
		-- Call bleeding effect.
		player.bloodEmit = player.bloodEmit or ParticleEmitter( player:GetPos() )
		player.bleedbone = parameter.bone or "ValveBiped.Bip01_Spine"
		local pos, ang = player:GetBonePosition( player:LookupBone( player.bleedbone ) )
		local lcol = render.GetLightColor( pos ) * 255
		lcol.r = math.Clamp( lcol.r, 50, 150 )

		if !player.decalBlood or player.decalBlood < CurTime() then
			util.Decal( "Blood", player:GetPos() + Vector( 0, 0, 10 ), player:GetPos() - Vector( 0, 0, 100 ))
			player.decalBlood = CurTime() + 2
		end
		if !player.timeBlood or player.timeBlood < CurTime() then
			for i = 1, math.random( 2, 5 ) do
				local smoke = player.bloodEmit:Add( "effects/blooddrop", pos + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )*4)
				smoke:SetVelocity( ( ang:Up()*-math.Rand( .5, 1 )+ang:Forward()*math.Rand( -1, 1)+ang:Right()*math.Rand( -1, 1) ) * 15 )
				smoke:SetDieTime( math.Rand( .4, .7 ) )
				smoke:SetStartSize(1)
				smoke:SetEndSize(4)
				smoke:SetColor( lcol.r, 0, 0 )
				smoke:SetGravity( Vector( 0, 0, -500 ) )
			end
			player.timeBlood = CurTime() + .1
		end

	end,
} 

-- 'addrad' buff adds, decreased radiation points.
-- 'radioactive' buff is the actual buff.
-- to get radioactive amount of the character,

PLUGIN.buffs[ "addrad" ] = {
	name = "Add Radioative",
	desc = "You're getting irradiated.",
	nodisp = true,
	func = function( player, parameter)
		local amt = parameter.amount or 1
		if amt then
			player:setNetVar( "radioactive", math.Clamp( player:getNetVar( "radioactive", 0 ) + amt, 0, PLUGIN.maxRadioactiveLevel ) )
			if amt > 0 then
				player:ScreenFadeOut(1, Color(50, 100, 50, 20))
				player:EmitSound( Format( "player/geiger%s.wav", math.random( 1, 3 ) ) )
			end
			nut.schema.Call( "BeingRadiated", player )
		end
		if player:getNetVar("radioactive") > 0 then
			player:AddBuff("radioactive")
		else
			player:RemoveBuff( "radioactive" )
			nut.schema.Call( "RadiatedWornOff", player )
		end
		player:RemoveBuff( "addrad" )
	end,
}

PLUGIN.buffs[ "radioactive" ] = {
	name = "Radioative Sickness",
	desc = "You're exposed to radioactive too long!",
	func = function( player, parameter)
		player.timeGeiger = player.timeGeiger or CurTime()
		local level = player:getNetVar( "radioactive" )
		nut.schema.Call( "RadioactivePoison", player, level )
	end,
	cl_func = function( player, parameter )
		local level = player:getNetVar( "radioactive" ) or 0
		local perc = math.Clamp( level / PLUGIN.maxRadioactiveLevel, 0, 1 )
		if level > 0 then
			nut.schema.Call( "RadioactivePoison", player, level )
		end
	end,
}
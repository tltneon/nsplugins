local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

/*-----------------------------------------------
				RADIOACTIVE HOOKS
------------------------------------------------*/

if SERVER then
	function PLUGIN:RadioactivePoison( client, level ) -- Restricts movement when player has leg break buff
		if !client.nextRadEffect or client.nextRadEffect < CurTime() then
			if level > 500 then
				client:ScreenFadeOut(1, Color(50, 100, 50, 100))
				client:TakeDamage( 10 )
				client:EmitSound( Format( "player/geiger%s.wav", math.random( 1, 3 ) ) )
			end
			client.nextRadEffect = CurTime() + 10
		end
	end
end

/*-----------------------------------------------
				LEG BREAK HOOKS
------------------------------------------------*/
/*function PLUGIN:Move( client, mv ) -- Restricts movement when player has leg break buff
	if client:GetMoveType() == 8 then return end
	if client:HasBuff( "leghurt" ) and client:GetMoveType() == MOVETYPE_WALK then
			local m = .25
			local f = mv:GetForwardSpeed() 
			local mf = math.Clamp( f * m, 0, client:GetWalkSpeed() )
			local mfv = math.abs( math.sin( CurTime() * 3 ) ) * mf 
			mv:SetForwardSpeed( mfv )
			mv:SetSideSpeed( 0  )
	end
end*/

function PLUGIN:GetFallDamage( client, speed ) -- Gives player leg break buff when he fell off on the ground with high speed.
	if speed >= 650 then
		if self.legBreakEnable then
			timer.Simple( .1, function()
				if client:Alive() then
					client:AddBuff( "leghurt" )
				end
			end)
		end
	end
end

function PLUGIN:PlayerBindPress( client, bind, prsd )
	if client:GetMoveType() == 8 then return end
	if client:HasBuff( "leghurt" ) then
		if ( string.find( bind, "+speed" ) ) then return true end
	end
end

/*-----------------------------------------------
				BLEEDING HOOKS
------------------------------------------------*/

local hitbones = {
	[HITGROUP_HEAD] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
	},
	[HITGROUP_CHEST] = {
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	[HITGROUP_STOMACH] = {
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine",
	},
	[HITGROUP_LEFTARM] = {
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
	},
	[HITGROUP_RIGHTARM] = {
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
	},
	[HITGROUP_LEFTLEG] = {
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
	},
	[HITGROUP_RIGHTLEG] = {
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
	},
}

function PLUGIN:ScalePlayerDamage( client, hitbox, damageinfo )
	if hitbones[hitbox] then
		local isbullet = ( damageinfo:GetDamageType() == DMG_BULLET )
		if SERVER then
			if self.bleedEnable and !hook.Call( "BleedingImmune", client ) then
				if isbullet or ( math.Rand( 1, 100 ) <= self.bleedChance ) then
					client:AddBuff( "bleeding", 600, { bone = table.Random( hitbones[hitbox] ) } )
				end
			end
			if self.legInjuryEnable and !hook.Call( "LegImmune", client ) then
				if hitbox == HITGROUP_LEFTLEG or hitbox == HITGROUP_RIGHTLEG then
					client:AddBuff( "leghurt" )
				end
			end
		end
	end
end

/*-----------------------------------------------
				STARVING HOOKS
------------------------------------------------*/

timer.Simple( 0, function() 
	local foodPLUGIN = nut.plugin.list.cookfood
	if not foodPLUGIN then
		print( 'Food hunger will not work properly without "cookfood" plugin!' )
	else
		function PLUGIN:FoodUsed( client, itemTable, data, entity )
			if itemTable.hunger > 0 then
				client:RemoveBuff( "starve" )
			end
			if itemTable.thirst > 0 then
				client:RemoveBuff( "thirst" )
			end
		end

		function PLUGIN:PlayerHunger( client )
			local character = client:getChar()
			local hunger = character:getNetVar("hunger", 0)
			if hunger <= 0 then
				client:AddBuff( "starve" )
			else
				if client:HasBuff( "starve" ) then
					client:RemoveBuff( "starve" )
				end
			end
		end

		function PLUGIN:PlayerThirst( client )
			local character = client:getChar()
			local hunger = character:getNetVar("thirst", 0)
			if hunger <= 0 then
				client:AddBuff( "thirst" )
			else
				if client:HasBuff( "thirst" ) then
					client:RemoveBuff( "thirst" )
				end
			end
		end
	end
end)


/*-------------------------------------------------
				MULTI PURPOSE HOOKS
--------------------------------------------------*/

if CLIENT then
	local trg = 0
	local cur = 0
	function PLUGIN:HUDPaint()
		if LocalPlayer():HasBuff( "bleeding" ) then 
			trg = 20 + math.abs( math.sin( RealTime()*2 )*80 )
		else
			trg = 0
		end
		cur = Lerp( FrameTime()*3, cur, trg )
		if cur > .1 then
			surface.SetDrawColor( 255, 0, 0, cur)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end
	end
end

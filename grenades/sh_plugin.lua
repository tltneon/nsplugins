PLUGIN.name = "Grenade Throwables"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Grenade Throwables."

local buffPLUGIN = nut.plugin.Get( "buffs" )
if not buffPLUGIN then
	print( 'Tear Gas Grenade will not work without "buffs" plugin!' )
else
	function PLUGIN:CanTearGassed( player )
		return true -- If some faction or item prevents from tear gassed, just mod this.
	end

	buffPLUGIN.buffs[ "teargas" ] = {
		name = "Tear Gas",
		desc = "Your action will be limited due the effect of tear gas.",
		onbuffed = function( player, parameter )
			if !player:HasBuff( "teargas" ) then
				player:ChatPrint( "You're gassed by the tear gas grenade." )
			end
		end,
		ondebuffed = function( player, parameter )
			if !player:Alive() then return end
			if player:HasBuff( "teargas" ) then
				player:ChatPrint( "Tear Gas's effect has worn out." )
			end
		end,
		func = function( player, parameter)
			player.timeNextCough = player.timeNextCough or CurTime()
			if player.timeNextCough < CurTime() then
				player:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				player.timeNextCough = CurTime() + 2
			end
		end,
	} 

	function PLUGIN:Move( ply, mv )
		if ply:GetMoveType() == 8 then return end
		if ply:HasBuff( "teargas" ) and ply:GetMoveType() == MOVETYPE_WALK then
			local m = .25
			local f = mv:GetForwardSpeed() 
			local s = mv:GetSideSpeed() 
			mv:SetForwardSpeed( f * .005 )
			mv:SetSideSpeed( s * .005 )
		end
	end

	local trg = 0
	local cur = 0
	function PLUGIN:HUDPaint()
		if LocalPlayer():HasBuff( "teargas" ) then 
			trg = 120 + math.abs( math.sin( RealTime()*2 )*70 )
		else
			trg = 0
		end
		cur = Lerp( FrameTime()*3, cur, trg )
		surface.SetDrawColor( 255, 255, 255, cur)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end


if SERVER then
	local default = {
		delay = 1, -- Delay before the support comes.
		number = 30, -- Number of attacks.
		duration = 10, -- Duration of the attack. ( each shell will strike the ground number/duration )
		range = 500, -- Area of Strike.
		type = "nut_shell", -- Type of shell.
		dmg_amount = 100, -- Damage of the shell. 
		dmg_range = 300, -- Damage range of the shell.
		speed = 500, -- <speed> units per seconds.
		filter = {},
	}
	function default:Rejected(reason)
	end

	function RequestAirSupport(pos, tbl)
		tbl = tbl or {}
		local info = table.Merge( table.Copy(default), tbl )

		local trace = {}
		trace.start = pos
		trace.endpos = pos + Vector(0, 0, 10000)
		trace.filter = info.filter
		local tr = util.TraceLine( trace )

		if !nut.schema.Call("CanCallSupport", v) then			
			if tr.HitSky then
				for i = 0, info.number - 1 do
					timer.Simple( (info.duration/info.number)*i, function()
						local ent = ents.Create(info.type)
						ent:SetPos(tr.HitPos + Vector(math.Rand(-1,1), math.Rand(-1,1), 0)*info.range - Vector( 0, 0, 100 ))
						ent:SetAngles( Angle(0, 0, 0) )
						ent.movespeed = info.speed
						ent.damage = info.dmg_amount
						ent.range = info.dmg_range
						ent:Spawn()
						ent:Activate()
					end)
				end
			else
				info:Rejected(1) -- NUMBER 1, Couldn't find the sky.
			end
		else
			info:Rejected(2) -- NUMBER 2, Not enough permission.
		end
	end
end
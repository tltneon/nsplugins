local PLUGIN = PLUGIN
PLUGIN.name = "Custom Decal"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "CUSTOM DECAL! GET YOUR GOD DAMN SPRAY(CONSOLE COMMAND)"
PLUGIN.customdecals = PLUGIN.customdecals or {}

function PLUGIN:PostDrawTranslucentRenderables( isDepth, isSkybox )
	for k, v in pairs( self.customdecals ) do
		if !( v.mat or v.pos or v.ang or v.scale or v.size ) then continue end -- NOT VALID!
		if v.pos:Distance( LocalPlayer():GetPos() ) > 1255 then continue end
		local mat = Material( v.mat )
		mat:SetShader( "UnlitGeneric" )
		cam.Start3D2D( v.pos, v.ang, v.scale)
			surface.SetMaterial( mat )
			surface.SetDrawColor( 255, 255, 255, math.Clamp( 1255 - v.pos:Distance( LocalPlayer():GetPos() ), 0, 255 ) )
			surface.DrawTexturedRect( -v.size.x/2, -v.size.y/2, v.size.x, v.size.y ) 
		cam.End3D2D()
	end
end


nut.command.Register({
	adminOnly = true,
	syntax = "[string icon] [int sizex] [int sizey] [int scale]",
	onRun = function(client, arguments)

		local dat = {}
		dat.start = client:GetShootPos()
		dat.endpos = dat.start + client:GetAimVector() * 100000
		dat.filter = client
		local trace = util.TraceLine(dat)
		local pos = trace.HitPos + trace.HitNormal * .1
		local ang = ( trace.HitNormal ):Angle()
		
		local icon = arguments[1] or "entities/combineelite.png"
		local sizex = arguments[2] or 100
		local sizey = arguments[3] or 100
		local scale = arguments[4] or .5
		
		local info = {}
		info.pos = pos
		info.ang = Angle( ang.r , ang.y + 90, ang.p + 90 )
		info.mat = icon
		info.scale = scale
		info.size = { x = sizex, y = sizey }
		if ( type( tonumber( info.scale ) ) != "number" || type( tonumber( info.size.x ) ) != "number" || type( tonumber( info.size.y ) ) != "number" ) then
			nut.util.Notify( "You entered wrong type of parameter.", client )
		return end
		netstream.Start( nil, "Nut_PushDecal", info)
		table.insert( PLUGIN.customdecals, info )
		
	end
}, "adddecal")

nut.command.Register({
	adminOnly = false,
	syntax = "[string range( def. 100 )] [int sizex] [int sizey] [int scale]",
	onRun = function(client, arguments)

		local dat = {}
		dat.start = client:GetShootPos()
		dat.endpos = dat.start + client:GetAimVector() * 100000
		dat.filter = client
		local trace = util.TraceLine(dat)
		local range = tonumber( arguments[1] ) or 100
		
		for k, v in pairs( PLUGIN.customdecals ) do
			if v.pos:Distance( trace.HitPos ) < range then
				PLUGIN.customdecals[ k ] = nil
			end
		end
		netstream.Start( nil, "Nut_DeleteDecal", { trace.HitPos, range })
		
	end
}, "removedecal")


function PLUGIN:SaveData()
	nut.util.WriteTable("decals", self.customdecals)
end

function PLUGIN:LoadData()
	self.customdecals = nut.util.ReadTable("decals")
end

function PLUGIN:PlayerInitialSpawn( player )
	netstream.Start( client, "Nut_PushDecalsOnTheMap", PLUGIN.customdecals)
end

if CLIENT then
	netstream.Hook( "Nut_PushDecalsOnTheMap", function( data )
		PLUGIN.customdecals = data
	end)
	netstream.Hook( "Nut_DeleteDecal", function( data )
		local vec = data[1]
		local range = data[2]
		for k, v in pairs( PLUGIN.customdecals ) do
			if v.pos:Distance( vec ) < range then
				PLUGIN.customdecals[ k ] = nil
			end
		end
	end)
	netstream.Hook( "Nut_PushDecal", function( data )
		table.insert( PLUGIN.customdecals, data )
	end)
end

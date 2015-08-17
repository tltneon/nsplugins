BASE.name = "Base Vehicle"
BASE.uniqueID = "base_vehicle"
BASE.weight = 1
BASE.category = "Vehicle"
BASE.functions = {}
BASE.cantdrop = true
BASE.rotate = 90
BASE.seats = {}
BASE.CanTransfer = false
BASE.sellFactor = .5
BASE.numplate = {
}

local function honk_init( vehicle )
	vehicle.snd_honk = CreateSound( vehicle, "npc/attack_helicopter/aheli_crash_alert2.wav" )
	vehicle.snd_honk:ChangePitch( 150, 0 )
end
BASE.postSpawn = honk_init

local function honk( player, vehicle ) -- pretty example of vehicle think.
	if player:KeyDown( IN_ATTACK ) then
		if !vehicle.bool_honk then
			vehicle.bool_honk = true
			vehicle.snd_honk:Play()
			player:ChatPrint( "HONK HONK" )
		end
	else
		if vehicle.bool_honk then
			vehicle.bool_honk = false
			vehicle.snd_honk:Stop()
		end
	end
end
BASE.vehicleThink = honk

local aprefix = "VR."
local asuffix = ""
function numberAssgin()
	local str = aprefix .. math.random( 11111,99999 ) .. asuffix
	return str
end
numberAssgin()
BASE.functions.Use = {
	alias = "Spawn Vehicle",
	tip = "Spawn the vehicle in front of you.",
	icon = "icon16/car_add.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
				
			local vehicle = client:SpawnVehicle( itemTable, data, entity )
			if !vehicle:IsValid() then
				nut.util.Notify(nut.lang.Get( "vehicle_failed" ), client) 
				return false
			else
				local idat = table.Copy( data )
				idat.onworld = true
				if !idat.number then
					-- TODO:add manual assign
					nut.util.Notify(nut.lang.Get( "vehicle_register_auto" ), client) 
					idat.number = numberAssgin()
					nut.util.Notify( idat.number, client) 
					vehicle:SetNetVar( "number", idat.number )
				end
				client:UpdateInv( itemTable.uniqueID, -1, data ) 
				client:UpdateInv( itemTable.uniqueID, 1, idat )
				nut.util.Notify(nut.lang.Get( "vehicle_spawned" ), client) 
				vehicle:EmitSound( "ambient/machines/teleport1.wav" )
				return false
			end
			
		end
	end,
	shouldDisplay = function( itemTable, data, entity)
		return !LocalPlayer():GetNetVar( "spawned_vehicle" )
	end
}

BASE.functions.Store = {
	alias = "Store Vehicle",
	tip = "Spawn the vehicle in front of you.",
	icon = "icon16/car_delete.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
		
			if client:GetNetVar( "spawned_vehicle" ) then	
				if data.onworld then
					local found = false
					for k, v in pairs( ents.FindInSphere( client:GetPos(), 200 ) ) do
						if v:GetClass() == "prop_vehicle_jeep" then
							if client:GetNetVar( "spawned_vehicle" ) == v:EntIndex() then
								local idat = table.Copy( data )
								idat.onworld = false
								client:UpdateInv( itemTable.uniqueID, -1, data ) 
								client:UpdateInv( itemTable.uniqueID, 1, idat )
								client:SetNetVar( "spawned_vehicle", nil )
								nut.util.Notify( nut.lang.Get( "vehicle_stored" ), client) 
								v:Remove()
								client:EmitSound( "doors/metal_stop1.wav" )
								found = true
								break
							end
						end
					end
					if !found then
						nut.util.Notify(nut.lang.Get( "vehicle_cantfind" ), client) 
					end
				else
					nut.util.Notify(nut.lang.Get( "vehicle_alreadyspawned" ), client) 
				end
				return false 
			end
			
		end
	end,
	shouldDisplay = function( itemTable, data, entity)
		if data.onworld then
			if LocalPlayer():GetNetVar( "spawned_vehicle" ) then
				return true
			end
		end
		return false
	end
}

BASE.functions.Sell = {
	alias = "Sell Vehicle",
	tip = "Spawn the vehicle in front of you.",
	icon = "icon16/money.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			if data.onworld then
				nut.util.Notify(nut.lang.Get( "vehicle_cantsell_out" ), client) 
				return false
			else
				nut.util.Notify(nut.lang.Get( "vehicle_sold", nut.currency.GetName( itemTable.price*itemTable.sellFactor ) ), client) 
				client:GiveMoney( itemTable.price*itemTable.sellFactor )
				return true
			end
			
		end
	end,
	shouldDisplay = function( itemTable, data, entity)
		if !data.onworld then
			return true
		end
		return false
	end
}
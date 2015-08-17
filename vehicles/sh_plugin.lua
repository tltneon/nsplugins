PLUGIN.name = "Vehicles"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Get some vehicles for you!"

PLUGIN.fuelSystem = true
PLUGIN.noEmptyPassenger = true -- by turning off this option, anyone can ride on empty car.

nut.util.Include("sh_lang.lua")
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
		
function PLUGIN:PlayerDisconnected( player )
	for k, v in pairs( player:GetInventory() ) do
		for a, b in pairs( v ) do
			if b.data.onworld then
				local dat = table.Copy( b.data )
				dat.onworld = false
				player:UpdateInv( k, -1, b.data ) 
				player:UpdateInv( k, 1, dat )
			end
		end
	end
	for k, v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if v:GetNetVar( "owner" ) == player:EntIndex() then
			v:Remove()
		end
	end
end

function entityMeta:IsPluginVehicle() -- If the vehicle is driveable.
	return ( self:GetClass() == "prop_vehicle_jeep" )
end

function PLUGIN:Think()
	if SERVER then
		for k, v in pairs( player.GetAll() ) do
			if v:InVehicle() then -- If player is in vehicle.

				local vehicle = v:GetVehicle()
				if vehicle:IsValid() then
					if vehicle:IsPluginVehicle() then -- If the vehicle player on is driveable?
						if vehicle.func_think then -- vehicle think payload.
							vehicle.func_think( v, vehicle )
						end
						if self.fuelSystem then -- fuel think payload. If fuelSystem is active then start the think.
							local vel = vehicle:GetVelocity():Length()
							if vel > 0 then
								vehicle.fuel = math.Clamp( ( ( vehicle.fuel or 0 ) - vel/50000 ), 0, 100 )
							end
							if vehicle.fuel == 0 then
								local phys = vehicle:GetPhysicsObject();
								if phys:IsValid() then
									phys:SetVelocity( phys:GetVelocity()* -1 )
								end
							end
						end
					else
						if self.noEmptyPassenger then -- If server does not allow empty passenger
							if vehicle.realVehicle and vehicle.realVehicle:IsValid() then -- If player is riding in passenger.
								local driver = vehicle.realVehicle:GetDriver()
								if !driver:IsValid() then
									v:ExitVehicle()
								end
							end
						end
					end
				end

			end
		end
	end
end

function PLUGIN:PlayerUse( player, entity )
	
	if !entity:IsVehicle() then -- If not a vehicle then abort this function.
		return 
	end
	if player:InVehicle() then -- If player is in vehicle then think custom exit.
		return
	end
	if !player.nextEnterVehicle or player.nextEnterVehicle < CurTime() then -- If you're not spammed.

		if entity:GetDriver():IsValid() then -- see if the vehicle is occupied. if occupied, let's get into the vehicle.

			local t = {}
			t.start = player:EyePos()
			t.endpos = t.start + player:GetAimVector() * 100
			t.filter = { player, entity } -- By adding player and the vehicle, you can get the seat.
			local tr = util.TraceLine( t ) 
			if tr.Entity:IsVehicle() then -- if you found a seat
				if tr.Entity:GetDriver():IsValid() then -- if the seat has already occupied then abort.
					nut.util.Notify( "The seat has already occupied." )
					player.nextEnterVehicle = CurTime() + 1
					return
				end
				player:EnterVehicle( tr.Entity )
			end
		end
		player.nextEnterVehicle = CurTime() + 1 -- Don't allow spam.
	end

end

function PLUGIN:PostDrawTranslucentRenderables( isDepth, isSkybox )
	for k, v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		local itemTable = nut.item.Get( v:GetNetVar( "item_uid" ) )
		if itemTable then
			if v:GetPos():Distance( LocalPlayer():GetPos() ) > 1000 then continue end
			for _, dat in pairs( itemTable.numplate ) do
				local pos = v:GetPos() + v:GetUp() * dat.pos.z + v:GetRight() * dat.pos.x + v:GetForward() * dat.pos.y
				local ang = v:GetAngles() 
				ang:RotateAroundAxis( v:GetRight(), dat.ang.pitch ) -- pitch
				ang:RotateAroundAxis( v:GetUp(),  dat.ang.yaw )-- yaw
				ang:RotateAroundAxis( v:GetForward(), dat.ang.roll )-- roll
				cam.Start3D2D( pos, ang, dat.scale)	
					surface.SetDrawColor( 0, 0, 0 )
					surface.SetTextColor( 255, 255, 255 )
					surface.SetFont( "ChatFont" )
					local size = { x = 10, y = 10 }
					size.x, size.y = surface.GetTextSize( v:GetNetVar( "number" ) )
					surface.SetTextPos( -size.x/2, -size.y/2 )
					size.x = size.x + 20; size.y = size.y + 15
					surface.DrawRect( -size.x/2, -size.y/2, size.x , size.y )
					surface.DrawText( v:GetNetVar( "number" ) )
				cam.End3D2D()
			end
		end
	end
end

function playerMeta:SpawnVehicle( itemTable, data, entity )
	
	local t = {}
	t.start = self:EyePos()
	t.endpos = t.start + self:GetAimVector() * 130
	t.filter = self
	local tr = util.TraceLine( t )
	
	local vehicle = ents.Create( "prop_vehicle_jeep" )
	vehicle:SetModel( itemTable.model )
	vehicle:SetKeyValue("vehiclescript", itemTable.vehiclescript ) 
	vehicle:SetPos( tr.HitPos )
	vehicle:Spawn()
	
	vehicle.seats = {}
	for name, dat in pairs( itemTable.seats ) do
		local seat = ents.Create( "prop_vehicle_prisoner_pod" )
		seat:SetModel( dat.model )
		seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt" ) 
		seat:SetPos( vehicle:GetPos() + vehicle:GetUp() * dat.pos.z + vehicle:GetRight() * dat.pos.x + vehicle:GetForward() * dat.pos.y )
		local ang = vehicle:GetAngles() 
		ang:RotateAroundAxis( vehicle:GetRight(), dat.ang.pitch ) -- pitch
		ang:RotateAroundAxis( vehicle:GetUp(),  dat.ang.yaw )-- yaw
		ang:RotateAroundAxis( vehicle:GetForward(), dat.ang.roll )-- roll
		seat:SetAngles( ang )
		seat:Spawn()
		seat:Activate()
		seat:SetParent( vehicle )
		vehicle.seats[ name ] = seat
		seat.realVehicle = vehicle
	end
	
	if itemTable.postSpawn then 
		itemTable.postSpawn( vehicle )
	end
	if itemTable.vehicleThink then
		vehicle.func_think = itemTable.vehicleThink
	end
	
	self:SetNetVar( "spawned_vehicle", vehicle:EntIndex() )
	vehicle:SetNetVar( "owner", self:EntIndex() )
	vehicle:SetNetVar( "number", data.number )
	vehicle:SetNetVar( "item_uid", itemTable.uniqueID )
	
	return vehicle
end


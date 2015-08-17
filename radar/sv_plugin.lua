timer.Create("VehicleRadar", 1, 0, function()
	for _, vehicle in pairs(ents.FindByClass("prop_vehicle_jeep")) do
		if vehicle.type == "ECPD" and IsValid(vehicle:GetDriver()) then
			local vehiclePos = vehicle:GetPos() + Vector(0, 0, 20)
			local vehicleAngles = vehicle:GetAngles()
			vehicleAngles.yaw = vehicleAngles.yaw + 90
			vehicleAngles.pitch = 0
			vehicleAngles.roll = 0

			local traceData = {
				start = vehiclePos,
				endpos = vehiclePos + vehicleAngles:Forward() * 5000,
				filter = vehicle
			}
			local trace = util.TraceLine(traceData)

			if IsValid(trace.Entity) and trace.Entity:IsVehicle() then
				local target = trace.Entity
				local targetAngles = target:GetAngles()
				targetAngles.yaw = targetAngles.yaw + 90

				if vehicleAngles.yaw < 0 then
					vehicleAngles.yaw = vehicleAngles.yaw + 180
				end

				if targetAngles.yaw < 0 then
					targetAngles.yaw = targetAngles.yaw + 180
				end

				if math.abs(targetAngles.yaw - vehicleAngles.yaw) > 25 then
					if vehicle:GetNWString("Radar") != "ERROR" then -- This is to avoid sending useless data over the network
						vehicle:SetNWString("Radar", "ERROR")
					end
				else
					local speed = math.Round(target:GetVelocity():Length() / (3600 * 0.0035))
					vehicle:SetNWString("Radar", speed.." Km/h")
				end
			end
		end
	end
end)
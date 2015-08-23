local PLUGIN = PLUGIN

function PLUGIN:UseGasPump( ply, entity )
	ply.gasUse = ply.gasUse or CurTime() - 1
	if ply.gasUse < CurTime() then
		ply.gasUse = CurTime() + 3
		if entity:GetModel() == "models/props_equipment/gas_pump.mdl" then
			local distance = 200
			local found
			for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 200)) do
				if ent:GetClass() == "prop_vehicle_jeep" then
					local dist = ply:GetPos():Distance(ent:GetPos())
					if dist < distance then
						distance = dist
						found = ent
					end
				end
			end
			if IsValid(found) then
				found.fuel = found.fuel or 0
				local fuel = math.floor(found.fuel)
				if fuel >= 100 then
					nut.util.Notify("Fueltank already full.", ply)
					return false
				elseif timer.Exists("GAS_PUMP_"..found:EntIndex()) then
					nut.util.Notify("This vehicle is already being refueled.", ply)
					return false
				end
				found.gasPos = found:GetPos()
				nut.util.Notify("Vehicle refueling in progress, please do not move your vehicle.", ply)
				local gasSound = CreateSound(  entity, "ambient/machines/pump_loop_1.wav")
				gasSound:Play()
				gasSound:ChangeVolume(0.5, 0)
				local ticks = 0
				timer.Create("GAS_PUMP_"..found:EntIndex(), 0.5, 100, function()
					if not IsValid(found) then return end
					if found:GetPos():Distance(found.gasPos) > 30 then
						nut.util.Notify("You moved your vehicle, refueling stopped.", ply)
						gasSound:Stop()
						timer.Destroy("GAS_PUMP_"..found:EntIndex())
						return
					elseif not ply:HasMoney(self.price) then
						nut.util.Notify("You do not have anymore money to spend.", ply)
						gasSound:Stop()
						timer.Destroy("GAS_PUMP_"..found:EntIndex())
						return
					else
						ply:TakeMoney(self.price)
						found.fuel = math.Clamp(found.fuel + 1, 0, 100)
						ticks = ticks + 1
						if found.fuel >= 100 then
							nut.util.Notify("Your vehicle has been refueled for "..self.price * ticks.."€.", ply)
							gasSound:Stop()
							timer.Destroy("GAS_PUMP_"..found:EntIndex())
						end
					end
				end)
			else
				nut.util.Notify("No vehicle in range.", ply)
			end
		end
	end
end

function PLUGIN:KeyPress( ply, key )
	if key == IN_USE then
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 84
		data.filter = ply
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		if IsValid(entity) then
			self:UseGasPump(ply, entity)
		end
	end
end
local PLUGIN = PLUGIN

-- Globals
TESTS_DRIVING_STATUS = false
TESTS_DRIVING_PLAYER = nil
TESTS_DRIVING_VEHICLE = nil

function PLUGIN:StartVehicleTest( ply )
	if ply:HasLicense("driving") then
		nut.util.Notify("You already have a driving license.", ply)
		return
	end
	if not ply.character:GetVar("testData").status then
		if not TESTS_DRIVING_STATUS then
			if ply:HasMoney(self.driving.price) then
				ply:TakeMoney(self.driving.price)
				local veh = ents.Create("prop_vehicle_jeep")
				veh:SetModel(self.driving.model)
				veh:SetKeyValue("vehiclescript", self.driving.script)
				veh:SetPos(self.driving.start[1])
				veh:SetAngles(self.driving.start[2])
				veh:Spawn()
				veh.fuel = 100
				veh.type = "CIV"
				ply:EnterVehicle(veh)
				veh:Fire("lock")
				veh.locked = true
				TESTS_DRIVING_VEHICLE = veh
				TESTS_DRIVING_PLAYER = ply
				TESTS_DRIVING_STATUS = true
				local data = {
					status = true,
					endTime = CurTime() + self.driving.time,
					test = "driving",
					points = 1
				}
				ply.character:SetVar("testData", data)
				nut.util.Notify("Reach the last checkpoint within "..tostring(self.driving.time).." seconds.", ply)
			else
				nut.util.Notify("You do not have enough money!", ply)
			end
		else
			nut.util.Notify("Someone is already taking the driving test.", ply)
		end
	else
		nut.util.Notify("You are already taking a test!", ply)
	end
end

function PLUGIN:Think()
	if not IsValid(TESTS_DRIVING_VEHICLE) or not IsValid(TESTS_DRIVING_PLAYER) then
		TESTS_DRIVING_STATUS = false
		TESTS_DRIVING_PLAYER = nil
		TESTS_DRIVING_VEHICLE = nil
	end
	if TESTS_DRIVING_STATUS then
		if TESTS_DRIVING_VEHICLE:GetDriver() != TESTS_DRIVING_PLAYER then
			TESTS_DRIVING_VEHICLE:Remove()
			TESTS_DRIVING_VEHICLE = nil
			nut.util.Notify("You have failed your driving test! (Left vehicle)", TESTS_DRIVING_PLAYER)
			self:ResetTest(TESTS_DRIVING_PLAYER)
			TESTS_DRIVING_STATUS = false
			TESTS_DRIVING_PLAYER = nil
			return
		end
		if CurTime() > TESTS_DRIVING_PLAYER.character:GetVar("testData").endTime then
			TESTS_DRIVING_VEHICLE:Remove()
			TESTS_DRIVING_VEHICLE = nil
			nut.util.Notify("You have failed the driving test! (Ran out of time)", TESTS_DRIVING_PLAYER)
			self:ResetTest(TESTS_DRIVING_PLAYER)
			TESTS_DRIVING_STATUS = false
			TESTS_DRIVING_PLAYER = nil
			return
		end
		local checkpointID = TESTS_DRIVING_PLAYER.character:GetVar("testData").points
		local traceData = {
			start = self.driving.checkpoints[checkpointID][1],
			endpos = self.driving.checkpoints[checkpointID][2],
			filter = function( ent )
				if ent == TESTS_DRIVING_VEHICLE then
					return true
				end
				return false
			end
		}
		local trace = util.TraceLine(traceData)
		if trace.Entity == TESTS_DRIVING_VEHICLE then
			if checkpointID < #self.driving.checkpoints then
				local newData = TESTS_DRIVING_PLAYER.character:GetVar("testData")
				newData.points = newData.points + 1
				TESTS_DRIVING_PLAYER.character:SetVar("testData", newData)
			else
				TESTS_DRIVING_VEHICLE:Remove()
				TESTS_DRIVING_VEHICLE = nil
				nut.util.Notify("You have passed the driving test!", TESTS_DRIVING_PLAYER)
				self:ResetTest(TESTS_DRIVING_PLAYER)
				self:GiveLicense(TESTS_DRIVING_PLAYER, "driving")
				TESTS_DRIVING_STATUS = false
				TESTS_DRIVING_PLAYER = nil
			end
		end
	end
end

netstream.Hook("ReqDriveTest", function( ply )
	if not ply.character then return end
	PLUGIN:StartVehicleTest(ply)
end)
ITEM.name = "Walmart Drill"
ITEM.uniqueID = "wdrill"
ITEM.model = Model("models/props_lab/tpplug.mdl")
ITEM.desc = "Slow... Almost seemingly useless.. Where the fuck did we get this piece of shit?!"
ITEM.drillspeed = 360

ITEM.functions = {}
ITEM.functions.Place = {
	alias = "Place Drill",
	icon = "icon16/tag_blue_edit.png",
	menuOnly = true,
	run = function(itemTable, client, data, entity, index)
	if (SERVER) then
		
		local raytrace = client:GetEyeTraceNoCursor()
		local door = raytrace.Entity
		
		if (IsValid(door)) then
			if (door:GetPos():Distance( client:GetPos() ) <= 128 ) then
				if (!IsValid(door.combinelock)) then
					if (door:GetClass() == "prop_door_rotating") then
					local angs = raytrace.HitNormal:Angle() + Angle(0, 0, 0)
					local pos = raytrace.HitPos + (raytrace.HitNormal * 1) + Vector( 0, 2, 0 )


					local drill = ents.Create("nut_drill")
					drill:SetPos(pos)
					drill:SetAngles(angs)
					drill:SetParent(door)
					drill:SetAmount("DrillTime", itemTable.drillspeed)
					drill:Spawn()

						timer.Simple(itemTable.drillspeed, function() 

							door:Fire("Unlock", 0)
							door:Fire("Open", 0)

						end)

					elseif (door:GetClass() == "nut_vault" and door:GetDTBool(2) != true) then

						door:SetAmount("DrillTime", itemTable.drillspeed)
						door:drillIntoVault();

					end

				end

			end

		end

	end

	end
	
}
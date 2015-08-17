local PLUGIN = PLUGIN
ACCESS_BUFFER = ACCESS_BUFFER or {}

function PLUGIN:LoadData()
	for k, v in pairs(nut.util.ReadTable("cardreaders")) do
		local position = v.pos
		local angles = v.angles
		local flags = v.flags
		local doors = v.doors
		local entity = ents.Create("nut_cardreader")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()
		entity.flags = flags
		entity.doors = doors
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
		for _, door in pairs(v.doors) do
			local doorEnt = ents.GetMapCreatedEntity(door)
			doorEnt:Fire("Lock", 0)
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	for k, v in pairs(ents.FindByClass("nut_cardreader")) do
		data[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
			flags = v.flags,
			doors = v.doors,
		}
	end
	nut.util.WriteTable("cardreaders", data)
end

function PLUGIN:CreateCard( owner, accessFlags, description, spawnPos )
	if IsValid(owner) then
		if not description or description == "" then
			description = "No Description"
		end
		local name = owner:Name()
		local query = "INSERT INTO `cards` (`uid`, `owner`, `access`, `active`, `description`) VALUES (NULL, '"..nut.db.Escape(name).."', '"..nut.db.Escape(accessFlags).."', 1, '"..nut.db.Escape(description).."')"
		nut.db.Query(query, function( _, data )
			nut.db.Query("SELECT LAST_INSERT_ID()", function( data )
				local uid = data['LAST_INSERT_ID()']
				if not uid then return end
				local data = {
					owner = name,
					id = uid
				}
				nut.item.Spawn(spawnPos, Angle(0, 0, 0), "keycard", data, owner)
			end)
		end)
	end
end

function PLUGIN:AddReader( accessFlags, doors, spawnPos )
	local reader = ents.Create("nut_cardreader")
	reader:SetPos(spawnPos)
	reader.flags = accessFlags
	reader.doors = doors
	reader:Spawn()
	reader:Activate()
end

netstream.Hook("accessQuery", function( ply, tbl )
	if not ply:HasFlag("d") then return end
	local reqType = tbl.req
	if reqType == 1 then -- Get all cards
		local query = "SELECT * FROM `cards`"
		nut.db.Query(query, function( _, data )
			if data then
				netstream.Start(ply, "accessSend", data)
			else
				nut.util.Notify("ERROR: No data!", ply)
			end
		end)
	elseif reqType == 2 then -- Update active
		local active
		if tbl.active then
			active = "1"
		else
			active = "0"
		end
		local query = "UPDATE `cards` SET `active` = "..active.." WHERE `uid` = "..nut.db.Escape(tostring(tbl.uid))
		nut.db.Query(query, function( data )
			ACCESS_BUFFER[tostring(tbl.uid)] = nil
			nut.util.Notify(tbl.owner.."'s access card was updated.", ply)
			nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) updated "..tbl.owner.."'s access card.", LOG_FILTER_CONCOMMAND)
		end)
	elseif reqType == 3 then -- Update access
		local query = "UPDATE `cards` SET `access` = '"..nut.db.Escape(tostring(tbl.access)).."' WHERE `uid` = "..nut.db.Escape(tostring(tbl.uid))
		nut.db.Query(query, function( data )
			ACCESS_BUFFER[tostring(tbl.uid)] = nil
			nut.util.Notify(tbl.owner.."'s access card was updated.", ply)
			nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) updated "..tbl.owner.."'s access card.", LOG_FILTER_CONCOMMAND)
		end)
	elseif reqType == 4 then -- delete card
		local query = "DELETE FROM `cards` WHERE `uid` = "..nut.db.Escape(tostring(tbl.uid))
		nut.db.Query(query, function( _, data )
			ACCESS_BUFFER[tostring(tbl.uid)] = nil
			nut.util.Notify(tbl.owner.."'s access card deleted.", ply)
			nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) deleted "..tbl.owner.."'s access card.", LOG_FILTER_CONCOMMAND)
		end)
	end
end)
local PLUGIN = PLUGIN
PLUGIN.crimeDB = "euroleplay"
PLUGIN.licensesTbl = "revokes"

function PLUGIN:PostInitEntity()
	local npc = ents.Create("npc_range")
	npc:SetPos(self.weapons.npc[1])
	npc:SetAngles(self.weapons.npc[2])
	npc:Spawn()
end

function PLUGIN:GetCharName( ply, target )
	if not IsValid(target) then
		return "Unknown person"
	end
	if ply:GetNWBool("balaclava", false) then
		return "Someone wearing a balaclava"
	elseif target.character:GetData("recog", {})[ply.character:GetVar("id", 0)] == true then
		return ply.character:GetVar("charname")
	else
		return "Unknown person"
	end
end

function PLUGIN:RequestLicences( ply, target )
	if ply.character:GetVar("faction") == FACTION_CP then
		if IsValid(target) then
			if target:IsPlayer() then
				netstream.Start(target, "reqLicenses", ply)
				nut.util.Notify(PLUGIN:GetCharName( ply, officer ).." has been requested to show his licenses.", ply)
				nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) is requesting "..ply.character:GetVar("charname").."'s ( "..ply:RealName().." ) licenses.", LOG_FILTER_CONCOMMAND)
				return
			else
				return
			end
		else
			return
		end
	end
	nut.util.Notify("You must be a member of the ECPD!", ply)
end

function PLUGIN:ShowLicenses( ply, target )
	if IsValid(target) then
		if target:IsPlayer() then
			local name = self:GetCharName( ply, target )
			if table.Count(ply.character:GetData("licenses", {})) <= 0 then
				nut.util.Notify(name.." does not have any licenses.", target)
			else
				nut.util.Notify(name.." is showing you his license(s):", target)
				for k,v in pairs(ply.character:GetData("licenses", {})) do
					if v then
						nut.util.Notify(name.." has a(n) "..k.." license.", target)
					end
				end
			end
			nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) is showing his licenses to "..ply.character:GetVar("charname").." ( "..ply:RealName().." ).", LOG_FILTER_CONCOMMAND)
			return
		end
	end
	nut.util.Notify("You must be looking at someone!", ply)
end

netstream.Hook("showLicenses", function( ply, data )
	local show = data[1]
	local officer = data[2]
	if show then
		PLUGIN:ShowLicenses( ply, officer )
	else
		nut.util.Notify(PLUGIN:GetCharName( ply, officer ).." refused to show you his licenses!", ply)
		nut.util.AddLog(ply.character:GetVar("charname").." ( "..ply:RealName().." ) refused to show his licenses to "..ply.character:GetVar("charname").." ( "..ply:RealName().." ).", LOG_FILTER_CONCOMMAND)
	end
end)

local meta = FindMetaTable("Player")

function meta:HasLicense( license )
	if not self.character then return false end
	local licenses = self.character:GetData("licenses", {})
	if licenses[license] then
		return true
	else
		return false
	end
end

-- Was here before and I'm too lazy to update these...
function PLUGIN:TakeLicense( ply, license )
	if not ply.character then return end
	local newData = ply.character:GetData("licenses", {})
	newData[license] = nil
	ply.character:SetData("licenses", newData)
end

function PLUGIN:GiveLicense( ply, license )
	if not ply.character then return end
	local newData = ply.character:GetData("licenses", {})
	newData[license] = true
	ply.character:SetData("licenses", newData)
end

function PLUGIN:ResetTest( ply )
	if not ply.character then return end
	local newData = {
		status = false,
		endTime = 0,
		test = "N/A",
		points = 0
	}
	ply.character:SetVar("testData", newData)
end

/*function PLUGIN:PlayerLoadedChar( ply )
	if ply.character:GetData("key") then
		local query = "SELECT `key` FROM `"..nut.config.dbTable.."` WHERE `steamid` = "..ply:SteamID64().." AND `id` = "..nut.db.Escape(tostring(ply.character.index))
		nut.db.Query(query, function( data )
			ply.character:SetData("key", data.key)
		end)
	end
end

timer.Create("LicensesRevokeCheck", 60, 0, function()
	local list = {}
	for k,v in pairs(player.GetAll()) do
		if v.character then
			list[v.character:GetData("key", 0)] = v
		end
	end
	local query = "SELECT `uid`, `charid`, `license` FROM `"..PLUGIN.crimeDB.."`.`"..PLUGIN.licensesTbl.."` WHERE `applied` = 0;"
	nut.db.Query(query, function( _, data )
		for k,v in pairs(data) do
			if list[v.charid] then
				local ply = list[v.charid]
				PLUGIN:TakeLicense(ply, v.license)
				nut.util.AddLog(ply.character:GetVar("charname").."'s ( "..ply:RealName().." ) "..v.license.." license was revoked.", LOG_FILTER_CONCOMMAND)
				local query = "UPDATE `"..PLUGIN.crimeDB.."`.`"..PLUGIN.licensesTbl.."` SET `applied` = '1' WHERE `uid` = "..v.uid
				nut.db.Query(query)
			end
		end
	end)
end)*/
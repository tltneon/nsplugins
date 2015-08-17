BASE.name = "Base Buff Stuffs"
BASE.uniqueID = "base_buff"
BASE.weight = .5
BASE.category = "Consumeable - Buffs"
BASE.canuseforward = true

BASE.usesound = "physics/flesh/flesh_bloody_break.wav"
BASE.uselevel = 75
BASE.usepitch = 200

BASE.addbuff = {}
BASE.removebuff = {}
BASE.postuse = function( itemTable, client, data, entity)
end

BASE.functions = {}
BASE.functions.Use = {
	alias = "Use",
	tip = "Use the item.",
	icon = "icon16/cog.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			client:EmitSound( itemTable.usesound, itemTable.uselevel, itemTable.usepitch )
			for key, dat in pairs( itemTable.addbuff ) do
				client:AddBuff( dat[1], dat[2], dat[3] ) -- name, duration, parameter
			end
			for key, dat in pairs( itemTable.removebuff ) do
				client:RemoveBuff( dat[1], dat[2] ) -- name, parameter
			end
			itemTable.postuse( itemTable, client, data, entity )
		end
		return true
	end
}
	
BASE.functions["Use Forward"] = {
	alias = "Use Forward",
	tip = "Use the item.",
	icon = "icon16/cog.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 72
				data.filter = client
			local trace = util.TraceLine(data)
			local target
			if ( !trace.Entity || !trace.Entity:IsPlayer() ) then
				nut.util.Notify("Must look at correct target.", client)
			return false else target = trace.Entity end
			target:EmitSound( itemTable.usesound, itemTable.uselevel, itemTable.usepitch )
			for key, dat in pairs( itemTable.addbuff ) do
				target:AddBuff( dat[1], dat[2], dat[3] ) -- name, duration, parameter
			end
			for key, dat in pairs( itemTable.removebuff ) do
				target:RemoveBuff( dat[1], dat[2] ) -- name, parameter
			end
		end
		return true
	end,
	shouldDisplay = function(itemTable, data, entity)
		return itemTable.canuseforward
	end
}
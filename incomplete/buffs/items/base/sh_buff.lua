ITEM.name = "Base Buff Stuffs"
ITEM.uniqueID = "base_buff"
ITEM.weight = .5
ITEM.category = "Consumeable - Buffs"
ITEM.canuseforward = true

ITEM.usesound = "physics/flesh/flesh_bloody_break.wav"
ITEM.uselevel = 75
ITEM.usepitch = 200

ITEM.addbuff = {}
ITEM.removebuff = {}
ITEM.postuse = function( itemTable, client, data, entity)
end

ITEM.functions = {}
ITEM.functions.Use = {
	alias = "Use",
	tip = "Use the item.",
	icon = "icon16/cog.png",
	onRun = function(itemTable, client, data, entity)
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
	
ITEM.functions["Use Forward"] = {
	alias = "Use Forward",
	tip = "Use the item.",
	icon = "icon16/cog.png",
	onRun = function(itemTable, client, data, entity)
		if (SERVER) then
			
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 72
				data.filter = client
			local trace = util.TraceLine(data)
			local target
			if ( !trace.Entity || !trace.Entity:IsPlayer() ) then
				client:notify("Must look at correct target.")
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
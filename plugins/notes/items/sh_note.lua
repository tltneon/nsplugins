ITEM.name = "Note"
ITEM.uniqueID = "misc_note"
ITEM.model = Model("models/props_lab/clipboard.mdl")
ITEM.desc = "A note that something can be written.\nPrivate Note: Only you can edit texts.\nPublic Note: Anyone can edit notes."

ITEM.functions = {}
ITEM.functions.Private = {
	alias = "Make Private Note",
	icon = "icon16/page_white_paintbrush.png",
	onRun = function(item)
		if (SERVER) then
		
			local position
			if (IsValid(entity)) then
				position = entity:GetPos() + Vector(0, 0, 4)
			else
				local data2 = {
					start = item.player:GetShootPos(),
					endpos = item.player:GetShootPos() + item.player:GetAimVector() * 72,
					filter = item.player
				}
				local trace = util.TraceLine(data2)
				position = trace.HitPos + Vector(0, 0, 16)
			end
			
			local entity2 = entity
			local entity = ents.Create("nut_note")
			entity:SetPos(position)
			if (IsValid(entity2)) then
				entity:SetAngles(entity2:GetAngles())
			end
			entity:setNetVar( "owner", item.player:SteamID() )
			entity:setNetVar( "private", true )
			entity:Spawn()
			entity:Activate()
			
		end
	end
}
ITEM.functions.Public = {
	alias = "Make Public Note",
	icon = "icon16/page_white_paint.png",
	onRun = function(item)
		if (SERVER) then
		
			local position
			if (IsValid(entity)) then
				position = entity:GetPos() + Vector(0, 0, 4)
			else
				local data2 = {
					start = item.player:GetShootPos(),
					endpos = item.player:GetShootPos() + item.player:GetAimVector() * 72,
					filter = item.player
				}
				local trace = util.TraceLine(data2)
				position = trace.HitPos + Vector(0, 0, 16)
			end
			
			local entity2 = entity
			local entity = ents.Create("nut_note")
			entity:SetPos(position)
			if (IsValid(entity2)) then
				entity:SetAngles(entity2:GetAngles())
			end
			entity:setNetVar( "owner", item.player )
			entity:setNetVar( "private", false )
			entity:Spawn()
			entity:Activate()
			
		end
	end
}
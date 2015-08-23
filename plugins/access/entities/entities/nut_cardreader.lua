ENT.Type = "anim"
ENT.PrintName = "Keycard Reader"
ENT.Author = "Riekelt & _FR_Starfox64"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then
	function ENT:CheckAccess( flags, cardID )
		if ACCESS_BUFFER[cardID] then
			local card = ACCESS_BUFFER[cardID]
			if card.active then
				if string.StartWith(card.access, "*") then
					return true
				end

				local flags = string.Explode("", flags)
				for _, flag in pairs(flags) do
					if string.find(card.access, flag) then
						return true
					end
				end
			end

			return false
		else
			local query = "SELECT `access`, `active` FROM `cards` WHERE `uid` = "..nut.db.Escape(cardID)
			nut.db.Query(query, function( data )
				if not data then
					return false
				end

				local active = false
				if tostring(data.active) == "1" then
					active = true
				end

				local card = {
					access = data.access,
					active = active
				}

				ACCESS_BUFFER[cardID] = card

				if card.active then
					if string.StartWith(card.access, "*") then
						return true
					end

					local flags = string.Explode("", flags)
					for _, flag in pairs(flags) do
						if string.find(card.access, flag) then
							return true
						end
					end
				end

				return false
			end)
		end
	end

	function ENT:Success()
		if not self.doors[1] then
			self:Fail()
			return
		end
		local door = ents.GetMapCreatedEntity(self.doors[1])
		if door.open then
			self:WorkDoor(false)
		else
			self:WorkDoor(true)
		end
		self:EmitSound("buttons/button9.wav")
		self.ready = false
		timer.Simple(3, function()
			self:Idle()
		end)
	end

	function ENT:WorkDoor( open )
		if not open then
			for _, door in pairs(self.doors) do
				local doorEnt = ents.GetMapCreatedEntity(door)
				doorEnt:Fire("Unlock", 0)
				doorEnt:Fire("Close", 0)
				doorEnt:Fire("Lock", 0)
				doorEnt.open = false
			end
		else
			for _, door in pairs(self.doors) do
				local doorEnt = ents.GetMapCreatedEntity(door)
				doorEnt:Fire("Unlock", 0)
				doorEnt:Fire("Open", 0)
				doorEnt:Fire("Lock", 0)
				doorEnt.open = true
			end
		end
	end
	
	function ENT:Fail()
		self:EmitSound("buttons/button8.wav")
		self.ready = false
		timer.Simple(3, function()
			self:Idle()
		end)
	end
	
	function ENT:Idle()
		self.ready = true
	end

	function ENT:Initialize()
		self.ready = true
		self:SetModel("models/props_downtown/keycard_reader.mdl");
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS) -- THIS IS NOT SUPPOSED TO MOVE.
		self:SetUseType(SIMPLE_USE)
	end
	
	function ENT:Use(ply)
		if not self.ready then return end
		local inv = ply:GetInventory()
		local flags = self.flags or ""
		if not inv["keycard"] then
			nut.util.Notify("You do not have any Keycard to swipe.", ply)
			return
		end
		for k, v in pairs(inv["keycard"]) do
			if self:CheckAccess(flags, v.data.id) then
				self:Success()
				return
			end
		end
		self:Fail()
	end	
else
	function ENT:Draw()
		self:DrawModel()
	end
end

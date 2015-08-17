PLUGIN.name = "Loot Plugin"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "You leaves your own things when you die."

PLUGIN.config = {}
PLUGIN.config.losechance = 100
PLUGIN.config.staytime = 50 -- loot stays for 50 seconds
PLUGIN.config.bagmodel = "models/props_junk/garbage_bag001a.mdl"

PLUGIN.config.fixchance = {
	["cid"] = 
	{
		[FACTION_CITIZEN] = 0, -- Citizen never drops Citizen ID
		[FACTION_CP] = 100, -- Metrocop must drops Citizen ID
	},
}


function PLUGIN:PlayerDeath( ply, dmg, att )

	local entity = ents.Create("nut_container") --** Create World Container that should not be saved in the server.
	entity:SetPos( ply:GetPos() + Vector( 0, 0, 10 ) )
	entity:Spawn()
	entity:Activate()
	entity:SetNetVar("inv", {})
	entity:SetNetVar("name", "Belongings" ) --** Yup.
	entity:SetNetVar( "max", 5000 )
	entity:SetModel( self.config.bagmodel )
	entity:PhysicsInit(SOLID_VPHYSICS)
	entity.generated = true --** This is it. Container that has this flag won't be saved in the server. 
	local physicsObject = entity:GetPhysicsObject()
	if (IsValid(physicsObject)) then
		physicsObject:Wake()
	end

	local fct = ply:Team()
	ply:StripAmmo() --** This is Normal.


	local belinv = {}
	for k,v in pairs( ply:GetInventory() ) do
		--** Place items on the bag.
		local itemtable = nut.item.Get( k ) 
		if !itemtable then continue end
		--** Item drop chances
		local dice = math.random( 0, 100 )
		local chance = math.Clamp( self.config.losechance, 0, 100 )
		if self.config.fixchance[ k ] then
			local t = type( self.config.fixchance[ k ] )
			if self.config.fixchance[ k ][ fct ] then
				chance = math.Clamp( self.config.fixchance[ k ][ fct ], 0, 100 )
			end
		end
		--** Get item's data. Including all of indexes
		if dice <= chance then
			for index, itemdat in pairs( v ) do
				local q = 1
				local dat = itemdat.data or {}
				if itemdat.quantity then
					q = math.random( 1, itemdat.quantity ) --** randomize dropping quantity
				end
				local newdat = table.Copy( dat )
				if newdat.Equipped then
					local model = ply.character:GetData("oldModel", ply:GetModel()) --** for clothes and shits.
						ply.character.model = model
						ply:SetModel(model)
					ply.character:SetData("oldModel", nil, nil, true)
					newdat.Equipped = false
				end
				--** Place the item.
				ply:UpdateInv( k, -q, dat, true ) 
				belinv = nut.util.StackInv(belinv, k, q, newdat)
			end			
		end
	end
	entity:SetNetVar("inv", belinv)

	timer.Simple( self.config.staytime, function() --** Removes the bag when It's lifetime is over.
		if entity:IsValid() then
			entity:Remove()
		end
	end)

end

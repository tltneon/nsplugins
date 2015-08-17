local PLUGIN = PLUGIN
PLUGIN.name = "Resource Distribution"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Distributes the resource randomly all over the world contianer.."
PLUGIN.generateStorage = true -- This will turn on/off converting the prop to the container. ** it will convert registered containers!

if SERVER then

	NUT_ITEM_WORLDCONTAINER_REGEN = CreateConVar( "nut_worldcontainer_regen", 600, FCVAR_NONE, "Adjust Container Regentime" )
	REGEN_FOOD = 1
	REGEN_AMMO = 2
	REGEN_WEAPON = 3
	NUT_ITEM_REGEN_GROUP = {
	
		["frdg_small"] = {
			[ REGEN_FOOD ] = { 
				["food_beans"] = { chance = 100, amount = { 1, 1 } } ,
			},
		},

		["default"] = {
			[ REGEN_FOOD ] = { 
				["food_beans"] = { chance = 1000, amount = { 1, 3 } } ,
				["food_melon"] = { chance = 1000, amount = { 1, 3 } } ,
				["food_takeout"] = { chance = 1000, amount = { 1, 3 } } ,
				["food_soda"] = { chance = 1000, amount = { 1, 3 } } ,
			},
		},
	
	}
	NUT_ITEM_REGEN_MODEL = {
		["models/props_interiors/vendingmachinesoda01a.mdl"] = "vendor",
		["models/props_c17/furniturefridge001a.mdl"] = "frdg_small",
		["models/props_wasteland/kitchen_fridge001a.mdl"] = "frdg_big",
	}
	NUT_NEXTREGEN = NUT_NEXTREGEN or CurTime()
	
	function PLUGIN:Think()
		if NUT_NEXTREGEN < CurTime() then
			print( 'Updated Contianer.' )
			for _, v in pairs(  ents.FindByClass( "nut_container" ) ) do
				if v.world then
					
					local newInv = {}
					local mdl = string.lower( v:GetModel() )
					local str = NUT_ITEM_REGEN_MODEL[ mdl ] or "default"
					local itmtbl = NUT_ITEM_REGEN_GROUP[ str ] 
					if !itmtbl then print("ITEM TABLE IS NOT EXISTS.") itmtbl = NUT_ITEM_REGEN_GROUP[ "default" ]  end
					local weight, max = v:GetInvWeight()
					local weight = 0
					
					for _, tbl in pairs( itmtbl ) do
						for item, dat in pairs( tbl ) do
							local dice = math.random( 1, 1000 )
							if dat.chance >= dice then
								local amt = math.random( dat.amount[1], dat.amount[2] )
								local itemTable = nut.item.Get(item)
								if ((weight + itemTable.weight * amt) < max) then
									newInv = nut.util.StackInv(newInv, item, amt, {})
									weight = weight + itemTable.weight * amt
								else
									break;
								end
							end
						end
					end
					
					v:SetNetVar("weight", math.ceil((weight / max) * 100))
					v:SetNetVar("inv", newInv, v.recipients)
					
				end
			end
			NUT_NEXTREGEN = CurTime() + NUT_ITEM_WORLDCONTAINER_REGEN:GetInt()
		end
	end
	
	function dbg_regen()
		NUT_NEXTREGEN = CurTime() 
	end
	
	local tblStorage = {}
	function PLUGIN:DoSearch()
		if !self.generateStorage then return end
		for uid, dat in pairs( nut.item.GetAll() ) do
			if dat.category == "Storage" then
				tblStorage[ string.lower( dat.model ) ] = dat
			end
		end
		
		for k,v in pairs( ents.GetAll() ) do
			if !v:GetModel() then continue end
			if tblStorage[ string.lower( v:GetModel() ) ] then
				local dat = tblStorage[ string.lower( v:GetModel() ) ]
				local entity = ents.Create("nut_container")
				entity:SetPos( v:GetPos() )
				entity:SetAngles( v:GetAngles() )
				entity:Spawn()
				entity:Activate()
				entity:SetNetVar("inv", {})
				entity:SetNetVar("name", dat.name)
				entity.generated = true
				entity.world = true
				entity.itemID = dat.uniqueID
				if (dat.maxWeight) then
					entity:SetNetVar("max", dat.maxWeight)
				end
				entity:SetModel(dat.model)
				entity:PhysicsInit( SOLID_VPHYSICS )
				entity:SetMoveType( MOVETYPE_NONE )
				v:Remove()
				if v:IsValid() then
					v:Remove()
				end
				
			end
		end
	end
	
	function PLUGIN:InitPostEntity( )
		do
			self:DoSearch()
		end
	end
	
end
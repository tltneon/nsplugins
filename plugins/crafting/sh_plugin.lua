local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Allows you craft some items."

PLUGIN.menuEnabled = false -- menu can be toggled off.
PLUGIN.reqireBlueprint = true

RECIPES = {}
RECIPES.recipes = {}

function RECIPES:Register( tbl )
	if !tbl.CanCraft then
		function tbl:CanCraft( player )
			for k, v in pairs( self.items ) do
				if !player:getChar():getInv():hasItem( k ) then
					return false
				elseif player:getChar():getInv():getItemCount(k) < v then
					return false
				end
			end
			return true
		end
	end
	if !tbl.ProcessCraftItems then
		function tbl:ProcessCraftItems( player )

			player:EmitSound( "items/ammo_pickup.wav" )
			for k, v in pairs( self.items ) do
				for i = 1, v do
					if player:getChar():getInv():hasItem( k ) then
						player:getChar():getInv():remove( player:getChar():getInv():hasItem( k ):getID() )
					end
				end
			end
			for k, v in pairs( self.result ) do
				--print(player:getChar():getInv():add(k, v))
				--if (!player:getChar():getInv():add(k, v)) then
					for i = 1, v do
					nut.item.spawn(k, player:getItemDropPos())
					end
				--else
					--netstream.Start(client, "vendorAdd", uniqueID)
				--end
			end
			player:notifyLocalized( "donecrafting", self.name )
		end
	end
	self.recipes[ tbl.uid ] = tbl
end

nut.util.include("sh_recipies.lua")
nut.util.include("sh_menu.lua")

function RECIPES:Get( name )
	return self.recipes[ name ]
end
function RECIPES:GetAll()
	return self.recipes
end
function RECIPES:GetItem( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.items
end
function RECIPES:GetResult( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.result
end
function RECIPES:CanCraft( player, item )
	local tblRecipe = self:Get( item )
	if PLUGIN.reqireBlueprint then
		if !tblRecipe.noBlueprint then
			local name_bp = ( tblRecipe.blueprint or tblRecipe.uid )
			if !player:getChar():getInv():hasItem( name_bp ) then
				return 2
			end
		end
	end
	if !tblRecipe:CanCraft( player ) then
		return 1
	end
	return 0
end

local entityMeta = FindMetaTable("Entity")
function entityMeta:IsCraftingTable()
	return self:GetClass() == "nut_craftingtable"	
end

if SERVER then
	util.AddNetworkString("nut_CraftItem")
	net.Receive("nut_CraftItem", function(length, client)
		local item = net.ReadString()
		local cancraft = RECIPES:CanCraft( client, item )
		local tblRecipe = RECIPES:Get( item )
		if cancraft == 0 then
			tblRecipe:ProcessCraftItems( client )
		else
			if cancraft == 2 then
				client:notifyLocalized( "req_blueprint", tblRecipe.name, tblRecipe.name )
			elseif cancraft == 1 then
				client:notifyLocalized( "req_moremat", tblRecipe.name )
			end
		end
	end)

	function PLUGIN:LoadData()
		local data = self:getData() or {}
		for k, v in pairs(data) do
			local position = v.pos
			local angles = v.angles
			local entity = ents.Create("nut_craftingtable")
			entity:SetPos(position)
			entity:SetAngles(angles)
			entity:Spawn()
			entity:Activate()
			local phys = entity:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end
		end
	end

	function PLUGIN:SaveData()
		local data = {}
		for k, v in pairs(ents.FindByClass("nut_craftingtable")) do
			data[#data + 1] = {
				pos = v:GetPos(),
				angles = v:GetAngles(),
			}
		end
		self:setData(data)
	end
end

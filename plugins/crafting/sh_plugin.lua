local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "Allows you craft some items."

if !nut.plugin.list["_oldplugins-fix"] then
	print("[Crafting Plugin] _oldplugins-fix Plugin is not found!")
	print("Download from GitHub: https://github.com/tltneon/nsplugins\n")
	return
end

PLUGIN.menuEnabled = false -- menu can be toggled off.
PLUGIN.reqireBlueprint = true

nut.lang.Add("crafting", "Crafting")
nut.lang.Add("craftingtable", "Crafting Table")
nut.lang.Add("req_moremat", "You need more materials to craft %s.")
nut.lang.Add("req_blueprint", "You need a blueprint of %s to craft %s.")
nut.lang.Add("req_morespace", "You need more space to get result.")
nut.lang.Add("donecrafting", "You have crafted %s.")
nut.lang.Add("icat_material", "Materials")

nut.lang.Add("craft_menu_tip1", "You can craft items by clicking the icons in the list.")
nut.lang.Add("craft_menu_tip2", "The icon with book means that item needs a blueprint to be crafted.")

nut.lang.Add("crft_text", "Crafting %s\n%s\n\nRequirements:\n")

RECIPES = {}
RECIPES.recipes = {}
function RECIPES:Register( tbl )
	if !tbl.CanCraft then
		function tbl:CanCraft( player )
			for k, v in pairs( self.items ) do
				if !player:HasItem( k, v ) then
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
nut.util.Include("sh_recipies.lua")
nut.util.Include("sh_menu.lua")


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
			local name_bp = ( tblRecipe.uid )
			if !player:HasItem( name_bp ) then
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

if CLIENT then return end
util.AddNetworkString("nut_CraftItem")
net.Receive("nut_CraftItem", function(length, client)
	local item = net.ReadString()
	local cancraft = RECIPES:CanCraft( client, item )
	local tblRecipe = RECIPES:Get( item )
	if cancraft == 0 then
		tblRecipe:ProcessCraftItems( client )
	else
		if cancraft == 2 then
			nut.util.Notify( nut.lang.Get( "req_blueprint", tblRecipe.name, tblRecipe.name ), client )
		elseif cancraft == 1 then
			nut.util.Notify( nut.lang.Get("req_moremat", tblRecipe.name), client)
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

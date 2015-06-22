local PLUGIN = PLUGIN

---------------------------------
--- BUYER QUEST
--- COLLECT ONE ARTIFACT FOR SOMEONE
--- THE ITEM HAS TO BE COLLECTED WILL BE RANDOMIZED IN randomItem. 

local QUEST = {}
QUEST.uniqueID = "art"
QUEST.name = "Заказ от важной шишки"
QUEST.desc = "Достань мне %s артефакт %s для важного клиента, плачу 2.5 тысячи. Только быстрее." -- If you don't know how it's working, Just check in sh_advhandler.lua in dialogue.
QUEST.quickRewards = {
	currency = 2500,
	items = {}	
}

QUEST.randomItem = { -- 
	{ uid = "battery", min = 1, max = 1 },
	{ uid = "eye", min = 1, max = 1 },
	{ uid = "jellyfish", min = 1, max = 1 },
	{ uid = "meatchunk", min = 1, max = 1 },
}
function QUEST:GenerateData( player )
	local tbl = {}
	for i = 0, 0 do
		local idat = table.Random( self.randomItem )
		tbl[ idat.uid ] = math.random( idat.min, idat.max ) 
	end
	return tbl
end

function QUEST:CanComplete( player, data )
	for uid, num in pairs( data ) do
		if !player:getChar():getInv():hasItem( uid ) then
			return false
		end
	end
	return true
end

function QUEST:RemoveQuestItem( player, data )
	for uid, num in pairs( data ) do
		player:getChar():getInv():remove(player:getChar():getInv():hasItem( uid ):getID(), false, false)
	end
end

function QUEST:PostReward( player, data )
	return true
end

PLUGIN:RegisterQuest( QUEST.uniqueID, QUEST )
---------------------------------
--- HOENYA HIDEOUT QUEST
--- COLELCT ONE ITEM FOR SOMEONE
--- THE ITEM HAS TO BE COLLECTED WILL BE RANDOMIZED IN randomItem. 

local QUEST = {}
QUEST.uniqueID = "honeya"
QUEST.name = "Honeya Hideout's Problem"
QUEST.desc = "Get %s of %s for Honeya Hideout." -- If you don't know how it's working, Just check in sh_advhandler.lua in dialogue.
QUEST.quickRewards = {
	currency = 100,
	items = {
		{ uid = "kolb", amount = 1, data = {} },
	}	
}

QUEST.randomItem = { -- 
	{ uid = "kolb", min = 1, max = 1 },
}
function QUEST:GenerateData( player )
	local tbl = {}
	for i = 0, 0 do
		local idat = table.Random( self.randomItem )
		tbl[ idat.uid ] = math.random( idat.min, idat.max ) 
		print( 'inserted '.. idat.uid )
	end
	return tbl
end

function QUEST:CanComplete( player, data )
	for uid, num in pairs( data ) do
		if !player:getChar():getInv():hasItem( uid ) then
			print( Format( "lack of %s of %s", num, uid ) )
			return false
		end
	end
	return true
end

function QUEST:RemoveQuestItem( player, data )
	for uid, num in pairs( data ) do
		player:getChar():getInv():remove(player:getChar():getInv():hasItem( uid ):getID(), false, false)
	end
end

function QUEST:PostReward( player, data )
	print( 'PostReward')
	return true
end

PLUGIN:RegisterQuest( QUEST.uniqueID, QUEST )
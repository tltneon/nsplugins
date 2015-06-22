local PLUGIN = PLUGIN
PLUGIN.name = "Quest/Journals."
PLUGIN.author = "Black Tea (NS 1.0), Neon (NS 1.1)"
PLUGIN.desc = "For someone who want to make server automatic game."

PLUGIN.curQuests = {}
PLUGIN.quests = {}

PLUGIN.journal = true -- If journal is active, you can see what you're doing now.
PLUGIN.maxQuestsim = 2 -- The number of the quest that player can do simultaneously.

local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

function PLUGIN:RegisterQuest( str, data )
	if self.quests[ str ] then
		print( 'Sorry, ' .. str .. ' is already exists.' )
		return false
	else
		self.quests[ str ] = data
		return true
	end
end
nut.util.include("sh_quests.lua")

-- Journal data form
-- [ uid ] = data >> data is for randomized quest.
-- desc will do like desc = "%s and shit"
-- derma will do like AddDesc( ... )
-- unpack( table )
-- Register quests

function playerMeta:GetQuests()
	return self:getNetVar( "questAssigned", {} )
end

function playerMeta:HasQuest( str )
	return self:GetQuests()[ str ]
end
function playerMeta:GetQuest( str )
	return self:GetQuests()[ str ]
end

function playerMeta:AddQuest( str, data ) -- if this returns false, the quest queue is full.
	local quests = self:GetQuests()
	data = data or {}
	if #quests == maxQuestsim then
		return false -- max quests reached.
	else
		quests[ str ] = data
		self:setNetVar( "questAssigned", quests )
		return true
	end
end

function playerMeta:CanCompleteQuest( str, data )
	local d_qst = PLUGIN:GetQuest( str )
	return d_qst:CanComplete( self, data )
end

function playerMeta:RemoveQuest( str )
	local quests = self:GetQuests()
	if quests[ str ] then
		quests[ str ] = nil
		self:setNetVar( "questAssigned", quests )
		return true
	else
		return false
	end
end

function playerMeta:GiveQuestReward( str )
	-- simple reward
	-- and some custion functions
	-- ( self, questtbl )
	local d_qst = PLUGIN:GetQuest( str )
	local d_rwd = PLUGIN:GetQuestReward( str )
	local qdat = self:GetQuest( str )

	if d_qst and d_rwd then
		for k, dt in pairs( d_rwd ) do
			if k == "currency" then
				self:getChar():giveMoney( dt )
			elseif k == "items" then
				for _, data in pairs( dt ) do
					self:getChar():getInv():add(data.uid, data.amount, data.data or {})
				end
			end
		end
		d_qst:RemoveQuestItem( self, qdat )
		d_qst:PostReward( self, qdat )
	end

end

function PLUGIN:GetQuests()
	return self.quests
end

function PLUGIN:GetQuest( str )
	return self.quests[ str ]
end

function PLUGIN:GetQuestReward( str )
	return self.quests[ str ].quickRewards 
end

function PLUGIN:PlayerDisconnected( player )
	if player:GetQuests() then
		self.curQuests[ player:SteamID() ] = player:GetQuests()
	end
end
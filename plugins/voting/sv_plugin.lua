local PLUGIN = PLUGIN
PLUGIN.startTime = PLUGIN.startTime or 0
PLUGIN.endTime = PLUGIN.endTime or 0
PLUGIN.votes = PLUGIN.votes or {}

function PLUGIN:LoadData()
	local votingData = self:getData() or {}

	self.startTime = votingData.startTime or 0
	self.endTime = votingData.endTime or 0
	self.votingList = votingData.votingList or {}
	self.votes = votingData.votes or {}
end

function PLUGIN:SaveData()
	local votingData = {
		startTime = self.startTime,
		endTime = self.endTime,
		votingList = self.votingList,
		votes = self.votes
	}
	self:setData(votingData)
end

function PLUGIN:CanVote( ply, silent )
	if self.votes[ply:SteamID64()] then
		if silent then return false end

		ply:notify("You can only vote once!")
		return false
	end

	if os.time() < self.startTime then
		if silent then return false end

		ply:notify("You cannot vote yet!")
		return false
	end

	if os.time() > self.endTime then
		if silent then return false end

		ply:notify("You can no longer vote!")
		return false
	end

	return true
end

function PLUGIN:PlayerLoadedChar( ply )
	if self:CanVote(ply, true) then
		ply:notify("It is time to vote for the Governor, head on to the City Hall to vote!")
	end
end

netstream.Hook("nut_Vote", function( ply, vote )
	if not PLUGIN:CanVote(ply) then return end

	if PLUGIN.votingList[vote] or vote == 0 then
		PLUGIN.votes[ply:SteamID64()] = vote
		PLUGIN:SaveData()

		local name = PLUGIN.votingList[vote] or "BLANK"
		ply:notify("Your vote for "..name.." was successfully recorded.")
	else
		ply:notify("Invalid vote, please try again.")
	end
end)
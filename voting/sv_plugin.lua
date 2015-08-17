local PLUGIN = PLUGIN
PLUGIN.startTime = PLUGIN.startTime or 0
PLUGIN.endTime = PLUGIN.endTime or 0
PLUGIN.votes = PLUGIN.votes or {}

function PLUGIN:LoadData()
	local votingData = nut.util.ReadTable("voting") or {}

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

	nut.util.WriteTable("voting", votingData)
end

function PLUGIN:CanVote( ply, silent )
	if self.votes[ply:SteamID64()] then
		if silent then return false end

		nut.util.Notify("You can only vote once!", ply)
		return false
	end

	if os.time() < self.startTime then
		if silent then return false end

		nut.util.Notify("You cannot vote yet!", ply)
		return false
	end

	if os.time() > self.endTime then
		if silent then return false end

		nut.util.Notify("You can no longer vote!", ply)
		return false
	end

	return true
end

function PLUGIN:PlayerLoadedChar( ply )
	if self:CanVote(ply, true) then
		nut.util.Notify("It is time to vote for the Governor, head on to the City Hall to vote!", ply)
	end
end

netstream.Hook("nut_Vote", function( ply, vote )
	if not PLUGIN:CanVote(ply) then return end

	if PLUGIN.votingList[vote] or vote == 0 then
		PLUGIN.votes[ply:SteamID64()] = vote
		PLUGIN:SaveData()

		local name = PLUGIN.votingList[vote] or "BLANK"
		nut.util.Notify("Your vote for "..name.." was successfully recorded.", ply)
	else
		nut.util.Notify("Invalid vote, please try again.", ply)
	end
end)
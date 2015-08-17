local PLUGIN = PLUGIN

PLUGIN.banTime = 60 * 60 * 24 * 15
PLUGIN.maxWrong = 1

PLUGIN.Quizzes = {}
PLUGIN.Quizzes[FACTION_EMT] = {
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
	{
		q = "Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay? Are you gay?",
		a = {
			"Yes",
			"No"
		},
		t = {1}
	},
}

PLUGIN.Consoles = {
	{Vector(-3832, -7093, 198), Angle(0, -180, 0), FACTION_EMT}
}

function PLUGIN:InitPostEntity()
	for _, spawn in pairs(self.Consoles) do
		local console = ents.Create("nut_factionquizz")
		console:SetPos(spawn[1])
		console:SetAngles(spawn[2])
		console:Spawn()
		console.quizz = spawn[3]
		console:SetMoveType(MOVETYPE_NONE)
	end
end

netstream.Hook("nut_Quizz", function( ply, data )
	local quizz = data[1]
	local answers = data[2]
	local wrong = 0

	if not PLUGIN:CanTakeQuizz(ply, quizz) then return end

	for k, v in pairs(PLUGIN.Quizzes[quizz]) do
		if not table.HasValue(v.t, answers[k]) then
			wrong = wrong + 1
		end
	end

	if wrong > PLUGIN.maxWrong then
		local newData = ply:GetData("quizzes", {})
		newData[quizz] = os.time() + PLUGIN.banTime
		ply:SetData("quizzes", newData)

		nut.util.Notify("You failed the quizz, you may take it again on "..os.date("%c", os.time() + PLUGIN.banTime)..".", ply)
	else
		ply:GiveWhitelist(quizz)
		nut.util.Notify("Congratulation! You passed the quizz and may now create a new character for this faction.", ply)
	end
end)
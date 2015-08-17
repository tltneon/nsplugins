local PLUGIN = PLUGIN
PLUGIN.name = "Quizz"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Faction whitelisting through quizzes."

nut.util.Include("sv_plugin.lua")

function PLUGIN:CanTakeQuizz( ply, quizz )
	local quizzData = ply:GetData("quizzes", {})

	if quizzData[quizz] and quizzData[quizz] > os.time() then
		nut.util.Notify("You are banned from taking this quizz!", ply)
		return false
	end

	return true
end

nut.command.Register({
	adminOnly = true,
	syntax = "<string player> <int factionID>",
	onRun = function(ply, arguments)
		local factionID = arguments[2]

		local target = nut.command.FindPlayer(ply, arguments[1])
		if not IsValid(target) or not factionID then return end

		local newData = target:GetData("quizzes", {})
		newData[factionID] = math.huge
		target:SetData("quizzes", newData)

		nut.util.Notify(target:Name().." is now banned from taking that quizz.", ply)
	end
}, "quizzban")

nut.command.Register({
	adminOnly = true,
	syntax = "<string player> <int factionID>",
	onRun = function(ply, arguments)
		local factionID = arguments[2]

		local target = nut.command.FindPlayer(ply, arguments[1])
		if not IsValid(target) or not factionID then return end

		local newData = target:GetData("quizzes", {})
		newData[factionID] = nil
		target:SetData("quizzes", newData)

		nut.util.Notify(target:Name().." is no longer banned from taking that quizz.", ply)
	end
}, "quizzunban")

if CLIENT then
	-- Quizz Menu --
	local PANEL = {}
	function PANEL:Init()
		if not PLUGIN.Quizz then return end

		self:SetSize(550, 450)
		self:Center()
		self:MakePopup()
		self:SetTitle("Faction Quizz")

		self.button = vgui.Create("DButton", self)
		self.button:SetText("Send")
		self.button:Dock(BOTTOM)
		self.button:DockPadding(4, 2, 4, 2)
		self.button:DockMargin(4,2,4,2)
		self.button.DoClick = function()
			if #self.answers != #PLUGIN.Quizz[2] then
				Derma_Message("You need to answer all questions!", "Error", "Ok")
				return
			end

			netstream.Start("nut_Quizz", {PLUGIN.Quizz[1], self.answers})
			self:Close()
		end

		self.panel = vgui.Create("DScrollPanel", self)
		self.panel:Dock(FILL)
		self.panel:DockPadding(4, 2, 4, 2)
		self.panel:DockMargin(4, 2, 4, 2)

		self.list = vgui.Create("DIconLayout", self.panel)
		self.list:Dock(FILL)

		self.answers = {}

		for qID, q in pairs(PLUGIN.Quizz[2]) do
			local panel = self.list:Add("DPanel")
			panel:SetSize(515, 100)

			local label = vgui.Create("DLabel", panel)
			label:SetSize(505, 50)
			label:SetPos(5, 0)
			label:SetText("Question: "..q.q)
			label:SetWrap(true)

			local comboBox = vgui.Create("DComboBox", panel)
			comboBox:SetSize(505, 25)
			comboBox:SetPos(5, 55)
			comboBox:SetValue("Answer...")
			comboBox.OnSelect = function( panel, index, value )
				self.answers[qID] = index
			end

			for aID, a in pairs(q.a) do
				comboBox:AddChoice(a)
			end
		end

		/*self.panel.label = vgui.Create("DLabel", self.panel)
		self.panel.label:SetText("Welcome to the EvoCity Voting Center. You are about to vote for your next Governor. Please select carefully who you want to vote for as you may only vote for one person, one time.")
		self.panel.label:SetTextColor(Color(210, 210, 210))
		self.panel.label:SetWrap(self.panel:GetWide() - 8)
		self.panel.label:Dock(FILL)*/
	end

	vgui.Register("nut_Quizz", PANEL, "DFrame")

	netstream.Hook("nut_OpenQuizz", function( quizz )
		PLUGIN.Quizz = quizz
		vgui.Create("nut_Quizz")
	end)

	function PLUGIN:DrawTargetID(entity, x, y, alpha)
		if (entity:GetClass() == "nut_votingcomputer") then
			local mainColor = nut.config.mainColor
			local color = Color(mainColor.r, mainColor.g, mainColor.b, alpha)
			nut.util.DrawText(x, y, "Voting Computer", color)
		end
	end

	function PLUGIN:ShouldDrawTargetEntity( entity )
		if entity:GetClass() == "nut_votingcomputer" then
			return true
		end
	end
end
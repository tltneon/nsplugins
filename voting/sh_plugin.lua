local PLUGIN = PLUGIN
PLUGIN.name = "Voting"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Voting plugin for governor elections."

PLUGIN.votingList = PLUGIN.votingList or {}

nut.util.Include("sv_plugin.lua")

nut.command.Register({
	superAdminOnly = true,
	onRun = function(ply, arguments)
		local toPrint = "EvoCity Voting Results:"
		local total = 0
		local results = {}

		for _, vote in pairs(PLUGIN.votes) do
			results[vote] = results[vote] or 0
			total = total + 1
			results[vote] = results[vote] + 1
		end

		for voteID, votes in pairs(results) do
			local name = PLUGIN.votingList[voteID] or "BLANK"
			toPrint = toPrint.."\n"..name.." -> "..votes.." ["..(votes / total * 100).."%]"
		end

		nut.util.Notify("Printing results to your console...", ply)
		ply:PrintMessage(HUD_PRINTCONSOLE, toPrint)
	end
}, "getvotes")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string option>",
	onRun = function(ply, arguments)
		if not arguments[1] then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		table.insert(PLUGIN.votingList, arguments[1])
		PLUGIN:SaveData()

		nut.util.Notify(arguments[1].." was added to the voting list.", ply)
	end
}, "addvote")

nut.command.Register({
	superAdminOnly = true,
	onRun = function(ply, arguments)
		PLUGIN.votes = {}
		PLUGIN.votingList = {}
		PLUGIN:SaveData()

		nut.util.Notify("Voting list and votes are now empty.", ply)
	end
}, "resetvoting")

nut.command.Register({
	superAdminOnly = true,
	syntax = "[int unixStart] [int unixEnd]",
	onRun = function(ply, arguments)
		local votingStart = tonumber(arguments[1])
		local votingEnd = tonumber(arguments[2])

		if arguments[1] and not arguments[2] then
			nut.util.Notify("Both timestamps are required if you wish to manually set the voting period.", ply)
			return
		elseif votingStart and votingEnd then
			PLUGIN.startTime = votingStart
			PLUGIN.endTime = votingEnd
			PLUGIN:SaveData()

			nut.util.Notify("Next voting session will start at UNIX-"..votingStart.." and will end at UNIX-"..votingEnd..".", ply)
			return
		end

		local timeData = os.date("*t", os.time())
		local hours = 23 - timeData.hour
		local minutes = 59 - timeData.min
		local seconds = 60 - timeData.sec
		local offset = hours * 60 * 60 + minutes * 60 + seconds -- Seconds left until midnight

		votingStart = os.time() + offset
		votingEnd = os.time() + offset + 24 * 60 * 60

		PLUGIN.startTime = votingStart
		PLUGIN.endTime = votingEnd
		PLUGIN:SaveData()

		nut.util.Notify("Next voting session will start at UNIX-"..votingStart.." and will end at UNIX-"..votingEnd..".", ply)
	end
}, "setupvote")

if CLIENT then
	netstream.Hook("nut_OpenVotingComputer", function( votingList )
		PLUGIN.votingList = votingList
		vgui.Create("nut_Voting")
	end)

	-- Voting Menu --
	local PANEL = {}
	function PANEL:Init()
		self:SetSize(400, 130)
		self:Center()
		self:MakePopup()
		self:SetTitle("EvoCity Voting Computer")

		self.button = vgui.Create("DButton", self)
		self.button:SetText("Select Candidate")
		self.button:Dock(BOTTOM)
		self.button:DockPadding(4, 2, 4, 2)
		self.button:DockMargin(4,2,4,2)
		self.button.DoClick = function()
			local dMenu = DermaMenu()

			local blank = dMenu:AddOption("Blank", function()
				Derma_Query("Are you sure you wish to vote blank?",
					"Voting Confirmation",
					"Yes",
					function()
						netstream.Start("nut_Vote", 0)
						self:Close()
					end,
					"No"
				)
			end)

			blank:SetIcon("icon16/page_white.png")

			dMenu:AddSpacer()

			for voteID, name in pairs(PLUGIN.votingList) do
				local vote = dMenu:AddOption(name, function()
					Derma_Query("Are you sure you wish to vote for "..name.."?",
						"Voting Confirmation",
						"Yes",
						function()
							netstream.Start("nut_Vote", voteID)
							self:Close()
						end,
						"No"
					)
				end)

				vote:SetIcon("icon16/user_suit.png")
			end

			dMenu:Open()
		end

		self.panel = vgui.Create("DPanel", self)
		self.panel:Dock(FILL)
		self.panel:DockPadding(4, 2, 4, 2)
		self.panel:DockMargin(4,2,4,2)

		self.panel.label = vgui.Create("DLabel", self.panel)
		self.panel.label:SetText("Welcome to the EvoCity Voting Center. You are about to vote for your next Governor. Please select carefully who you want to vote for as you may only vote for one person, one time.")
		self.panel.label:SetTextColor(Color(210, 210, 210))
		self.panel.label:SetWrap(self.panel:GetWide() - 8)
		self.panel.label:Dock(FILL)
	end

	vgui.Register("nut_Voting", PANEL, "DFrame")

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
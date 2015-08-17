local PLUGIN = PLUGIN
PLUGIN.name = "Property"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "Property management plugin."

PLUGIN.maxowners = 10
PLUGIN.rentTime = 60 * 60 * 24 * 7
PLUGIN.maxSellTime = 60 * 60 * 24
PLUGIN.sellRatio = 0.75
PLUGIN.defaultPreview = {Vector(-6414, -9187, 437), Angle(35, -125, 0)}
PLUGIN.consoleSpawn = {Vector(-7442, -7948, 72), Angle(0, 90, 0)}

PLUGIN.Homes = PLUGIN.Homes or {}
PLUGIN.ServTime = os.time()

nut.util.Include("sv_plugin.lua")

/* Home Data:
default_home = {
	name = "Home Name 01",
	doors = {},
	price = 500,
	owner = nil,
	cowners = {},
	storage = {Vector(0, 0, 50), Angle(), 1000},
	inv = {},
	money = 0,
	leaveTime = 0,
	preview = {Vector(), Angle()}
}
*/

nut.command.Register({
	superAdminOnly = true,
	syntax = "[bool clear]",
	onRun = function(ply, arguments)
		local entity = ply:GetEyeTrace().Entity

		if arguments[1] == "true" then
			ply.HomeDoors = {}
			ply.HomeStorage = nil
			nut.util.Notify("Cleared!", ply)
		end

		if IsValid(entity) then
			if hook.Run("IsDoor", entity) then
				if entity.home then
					nut.util.Notify("This door is already used in another home! ("..entity.home..")", ply)
					return
				end

				ply.HomeDoors = ply.HomeDoors or {}
				ply.HomeDoors[entity] = entity:MapCreationID()
				nut.util.Notify("This door has been added to your door list! ("..tostring(entity)..")", ply)
				return
			elseif entity:GetClass() == "nut_homestorage" then
				ply.HomeStorage = entity
				nut.util.Notify("This home storage will be used for the next home! ("..tostring(entity)..")", ply)
				return
			end
		end
		nut.util.Notify("You are not looking at a valid home entity!", ply)
	end
}, "addhomeent")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string name> <int price> [int maxStorage]",
	onRun = function(ply, arguments)
		local name = arguments[1]
		local price = tonumber(arguments[2])
		local maxStorage = tonumber(arguments[3]) or 500

		if not name then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		elseif not price then
			nut.util.Notify(nut.lang.Get("missing_arg", 2), ply)
			return
		end

		local class = string.Replace(string.lower(name), " ", "_")

		if PLUGIN.Homes[class] then
			nut.util.Notify(class.." already exists!", ply)
			return
		end

		local homeDoors = {}
		for door, id in pairs(ply.HomeDoors) do
			if not IsValid(door) then continue end
			table.insert(homeDoors, id)
			door:SetNetVar("title", name)
			door:SetNetVar("unownable", true)
			door.home = class
		end

		local storageData
		if IsValid(ply.HomeStorage) then
			storageData = {ply.HomeStorage:GetPos(), ply.HomeStorage:GetAngles(), maxStorage}

			local storage = ents.Create("nut_container")
			storage:SetPos(ply.HomeStorage:GetPos() + Vector(0, 0, -20))
			storage:Spawn()
			storage:Activate()
			storage:SetModel("models/Gibs/HGIBS.mdl")
			storage:PhysicsInit(SOLID_NONE)
			storage:SetNetVar("inv", {})
			storage:SetNetVar("money", 0)
			storage:SetNetVar("name", "Home Storage")
			storage.itemID = "trunk"
			storage.Trunk = true
			storage:SetNetVar("max", maxStorage)
			PLUGIN.Storages[class] = storage

			ply.HomeStorage:SetMoveType(MOVETYPE_NONE)
			ply.HomeStorage.storage = storage
		end

		local homeData = {
			name = name,
			doors = homeDoors,
			price = price,
			cowners = {},
			storage = storageData,
			inv = {},
			money = 0,
			leaveTime = 0,
			preview = {ply:GetPos(), ply:EyeAngles()}
		}

		PLUGIN.Homes[class] = homeData
		PLUGIN:UpdateHomes(class, homeData)
		PLUGIN:SaveData()
		nut.util.Notify("Added house "..name.."!", ply)
	end
}, "addhome")

nut.command.Register({
	superAdminOnly = true,
	onRun = function(ply, arguments)
		local toPrint = "Homes:"
		for class, homeData in pairs(PLUGIN.Homes) do
			toPrint = toPrint.."\n"..class.." -> "..homeData.name
		end
		nut.util.Notify("Printing homes to your console...", ply)
		ply:PrintMessage(HUD_PRINTCONSOLE, toPrint)
	end
}, "gethomes")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string classname>",
	onRun = function(ply, arguments)
		local class = arguments[1]

		if not class then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		if not PLUGIN.Homes[class] then
			nut.util.Notify(class.." not found!", ply)
			return
		end

		local homeData = PLUGIN.Homes[class]

		for _, door in pairs(homeData.doors) do
			local doorEnt = ents.GetMapCreatedEntity(door)

			if IsValid(doorEnt) then
				doorEnt:SetNetVar("title", "Door for Sale")
				doorEnt:SetNetVar("unownable", false)
				doorEnt.home = nil
			end
		end

		if IsValid(PLUGIN.Storages[class]) then
			if IsValid(PLUGIN.Storages[class].storage) then
				PLUGIN.Storages[class].storage:Remove()
			end
			PLUGIN.Storages[class]:Remove()
			PLUGIN.Storages[class] = nil
		end

		PLUGIN.Homes[class] = nil
		PLUGIN:SaveData()
		nut.util.Notify("Removed house "..name.."!", ply)
	end
}, "remhome")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string classname> <string owner> [int hours]",
	onRun = function(ply, arguments)
		local class = arguments[1]
		local owner = nut.command.FindPlayer(ply, arguments[2])
		local hours = tonumber(arguments[2])

		if not IsValid(owner) then
			nut.util.Notify("Owner not found!", ply)
			return
		end

		if not hours then
			hours = PLUGIN.rentTime
		else
			hours = hours * 60 * 60
		end

		if not class then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		if not PLUGIN.Homes[class] then
			nut.util.Notify(class.." not found!", ply)
			return
		end

		local homeData = PLUGIN.Homes[class]

		homeData.owner = {owner.character:GetVar("id"), owner.character:GetVar("charname")}
		homeData.cowners = {}
		homeData.leaveTime = os.time() + hours
		PLUGIN.Homes[class] = homeData

		PLUGIN:UpdateHomes(class, homeData)

		PLUGIN:SaveData()
		nut.util.Notify(owner:Name().." now owns "..homeData.name.."!", ply)
	end
}, "homesetowner")

nut.command.Register({
	superAdminOnly = true,
	syntax = "<string classname>",
	onRun = function(ply, arguments)
		local class = arguments[1]

		if not class then
			nut.util.Notify(nut.lang.Get("missing_arg", 1), ply)
			return
		end

		if not PLUGIN.Homes[class] then
			nut.util.Notify(class.." not found!", ply)
			return
		end

		local homeData = PLUGIN.Homes[class]

		homeData.owner = nil
		homeData.cowners = {}
		homeData.leaveTime = 0
		PLUGIN.Homes[class] = homeData

		PLUGIN:UpdateHomes(class, homeData)

		PLUGIN:SaveData()
		nut.util.Notify(homeData.name.." has been reset!", ply)
	end
}, "homedelowner")


if CLIENT then
	netstream.Hook("nut_OpenProperty", function( time )
		PLUGIN.ServTime = time
		vgui.Create("nut_Property")
	end)

	netstream.Hook("nut_UpdateHomes", function( data )
		if data.reset then
			PLUGIN.Homes = data.value
		else
			PLUGIN.Homes[data.key] = data.value
		end
	end)

	-- Property Menu --
	local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW() * 0.375, ScrH() * 0.125)
		self:SetSize(ScrW() * nut.config.menuWidth, ScrH() * nut.config.menuHeight)
		self:MakePopup()
		self:SetTitle("EvoCity Real Estate")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(7)
		noticePanel:SetText("Welcome to the EvoCity Real Estate Management Console!")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(4)
		noticePanel:SetText("From this console you will be able to buy and manage your homes.")

		self.list = self:Add("DListView")
		self.list:Dock(FILL)
		self.list:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		self.list:SetMultiSelect(false)
		self.list.OnRowSelected = function( line, id )
			self.selected = self.list:GetLines()[id].homeClass
			local homeData = PLUGIN.Homes[self.selected]

			local storage = "N/A"
			if homeData.storage then
				storage = homeData.storage[3]
			end

			local info = "Name: "..homeData.name.."\nPrice: "..homeData.price.."€\nStorage: "..storage
			if homeData.owner and LocalPlayer().character:GetVar("id") == homeData.owner[1] then
				info = info.."\nStatus: Yours\n\nOwner: "..homeData.owner[2].."\nTime Left: "..(math.Round((homeData.leaveTime - PLUGIN.ServTime) / 60 / 60 * 10) * 0.1).."H\nCo-Owners: "

				if table.Count(homeData.cowners) > 0 then
					local int = 1
					for _, owner in pairs(homeData.cowners) do
						if int <= 1 then
							info = info..owner[2]
						else
							info = info..", "..owner[2]
						end
						int = int + 1
					end
				else
					info = info.."N/A"
				end
				self.button:SetDisabled(false)
				self.button:SetText("Manage")
			elseif homeData.owner then
				info = info.."\nStatus: Owned\n\nOwner: "..homeData.owner[2].."\nTime Left: "..(math.Round((homeData.leaveTime - PLUGIN.ServTime) / 60 / 60 * 10) * 0.1).."H"
				self.button:SetDisabled(true)
				self.button:SetText("Select a Home...")
			else
				info = info.."\nStatus: Available"
				self.button:SetDisabled(false)
				self.button:SetText("Buy")
			end

			self.info:SetText(info)
		end

		self.list:AddColumn("Name"):SetDescending(true)
		self.list:AddColumn("Price")
		self.list:AddColumn("Status")

		self.panel = self:Add("DPanel")
		self.panel:Dock(FILL)
		self.panel:DockMargin(ScrW() * nut.config.menuWidth / 2, 0, 0, 0)
		self.panel:SetDrawBackground(true)

		local preview = self.panel:Add("DCollapsibleCategory")
		preview:Dock(TOP)
		preview:SetLabel("Preview")

		self.render = vgui.Create("DPanel", preview)
		self.render:Dock(TOP)
		self.render:SetSize(ScrW() * nut.config.menuWidth / 2, ScrH() * nut.config.menuHeight / 3)
		self.render.Paint = function( w, h )
			local x, y = self.render:LocalToScreen(0, 0)
			local pos
			if self.selected and PLUGIN.Homes[self.selected] and (not PLUGIN.Homes[self.selected].owner or PLUGIN.Homes[self.selected].owner[1] == LocalPlayer().character:GetVar("id")) then
				pos = PLUGIN.Homes[self.selected].preview
			else
				pos = PLUGIN.defaultPreview
			end
			render.RenderView({
				origin = pos[1],
				angles = pos[2],
				x = x,
				y = y,
				w = self.render:GetWide(),
				h = self.render:GetTall()
			})
		end

		local info = self.panel:Add("DCollapsibleCategory")
		info:Dock(TOP)
		info:SetLabel("House Info")

		self.info = vgui.Create("DLabel", info)
		self.info:Dock(TOP)
		self.info:DockMargin(5, 0, 0, 0)
		self.info:SetWide(info:GetWide())
		self.info:SetWrap(true)
		self.info:SetAutoStretchVertical(true)
		self.info:SetTextColor(Color(240, 240, 240))
		self.info:SetText("No Info...")

		self.button = self.panel:Add("DButton")
		self.button:Dock(BOTTOM)
		self.button:DockMargin(0, 5, 0, 0)
		self.button:SetDisabled(true)
		self.button:SetText("Select a Home...")
		self.button.DoClick = function()
			if self.selected then
				local homeData = PLUGIN.Homes[self.selected]
				if homeData.owner and LocalPlayer().character:GetVar("id") == homeData.owner[1] then
					local dMenu = DermaMenu()

					dMenu:AddOption("Sell", function()
						Derma_Query("Do you wish to sell your home for "..math.Round((homeData.leaveTime - os.time()) / PLUGIN.rentTime * (homeData.price * PLUGIN.sellRatio)).."€?",
							"Confirmation...",
							"Yes",
							function()
								if IsValid(self) then
									self:Close()
								end
								netstream.Start("nut_SellHome", self.selected)
							end,
							"No", function()
								-- Nothing...
							end
						)
					end):SetIcon("icon16/money_delete.png")

					local giveList = dMenu:AddSubMenu("Give Home")

					for _, v in pairs(player.GetAll()) do
						if v.character and v != LocalPlayer() then
							giveList:AddOption(v:Name(), function()
								Derma_Query("Do you wish to give your home to "..v.character:GetVar("charname").."?",
									"Confirmation...",
									"Yes",
									function()
										if IsValid(self) then
											self:Close()
										end
										netstream.Start("nut_GiveHome", {self.selected, v.character:GetVar("id")})
									end,
									"No", function()
										-- Nothing...
									end
								)
							end):SetIcon("icon16/arrow_right.png")
						end
					end

					dMenu:AddSpacer()

					local addList = dMenu:AddSubMenu("Add Co-Owners")

					for _, v in pairs(player.GetAll()) do
						if v.character and v != LocalPlayer() then
							addList:AddOption(v:Name(), function()
								Derma_Query("Do you wish to send add "..v.character:GetVar("charname").." as a Co-Owner?",
									"Confirmation...",
									"Yes",
									function()
										if IsValid(self) then
											self:Close()
										end
										netstream.Start("nut_AddCowner", {self.selected, v.character:GetVar("id")})
									end,
									"No", function()
										-- Nothing...
									end
								)
							end):SetIcon("icon16/user_add.png")
						end
					end

					local remList = dMenu:AddSubMenu("Remove Co-Owners")

					for _, v in pairs(homeData.cowners) do
						remList:AddOption(v[2], function()
							Derma_Query("Do you wish to revoke "..v[2].."'s Co-Ownership?",
								"Confirmation...",
								"Yes",
								function()
									if IsValid(self) then
										self:Close()
									end
									netstream.Start("nut_RemCowner", {self.selected, v[1]})
								end,
								"No", function()
									-- Nothing...
								end
							)
						end):SetIcon("icon16/user_delete.png")
					end

					dMenu:Open()
				elseif not homeData.owner then
					Derma_Query("Do you want to buy this house for "..homeData.price.."€?",
						"Confirmation",
						"Yes",
						function()
							if IsValid(self) then
								self:Close()
							end
							netstream.Start("nut_BuyHome", self.selected)
						end,
						"No",
						function()
							-- Nothing...
						end
					)
				end
			end
		end

		for classname, homeData in pairs(PLUGIN.Homes) do
			local available
			if homeData.owner and LocalPlayer().character:GetVar("id") == homeData.owner[1] then
				available = "Yours"
			elseif homeData.owner then
				available = "Owned"
			else
				available = "Available"
			end

			local line = self.list:AddLine(homeData.name, homeData.price.."€", available)
			line.homeClass = classname
		end
	end

	vgui.Register("nut_Property", PANEL, "DFrame")

	function PLUGIN:DrawTargetID(entity, x, y, alpha)
		if (entity:GetClass() == "nut_property") then
			local mainColor = nut.config.mainColor
			local color = Color(mainColor.r, mainColor.g, mainColor.b, alpha)
			nut.util.DrawText(x, y, "Real Estate", color)
		end
	end

	function PLUGIN:ShouldDrawTargetEntity( entity )
		if entity:GetClass() == "nut_property" then
			return true
		end
	end
end
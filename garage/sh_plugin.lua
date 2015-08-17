local PLUGIN = PLUGIN
PLUGIN.name = "Garage / Vehicles"
PLUGIN.author = "_FR_Starfox64"
PLUGIN.desc = "EuRoleplay Vehicle Mod."

PLUGIN.maxVehicles = 15
PLUGIN.maxVehiclesOut = 2
PLUGIN.TowTruckPos = Vector(0.073730, -130.310547, 57.315475)
PLUGIN.TowPos = Vector(52.448242, 71.667969, 41.064854)
PLUGIN.RopeLength = 40
PLUGIN.RopeWidth = 10
PLUGIN.RopeMaterial = "materials/rope"
PLUGIN.VehDataTable = {}
PLUGIN.Storages = {}
PLUGIN.VehShops = {}

nut.util.Include("sv_plugin.lua")

/* Structure
PLUGIN.VehDataTable = {
	CarClass = {
		name = "CarName",
		script = "CarScript.txt",
		model = "error.mdl",
		type = "CIV",
		skin = 0,
		maxWeight = 75,
		price = 5000
	}
}
CharVeh = {
	{
	class = "CarClass",
	color = Color(0, 0, 0),
	fuel = 100,
	inv = {},
	money = 0,
	storage = "Downtown",
	onWorld = false,
	ent = nil
	}
}
Storages = {
	Storage = {
		pos = Vector(),
		ang = Angle(),
		spawnPos = Vector(),
		spawnAng = Angle()
	}
}
*/

nut.command.Register({
	onRun = function(ply, arguments)
		local ang1, ang2 = Vector(-1302, 7183, 60), Vector(-2579, 6143, 447)
		OrderVectors(ang1, ang2)

		if ply:GetPos():WithinAABox(ang1, ang2) then
			if ply:InVehicle() then
				netstream.Start(ply, "carColorMenu")
			else
				nut.util.Notify("You must be inside of a vehicle!", ply)
			end
		else
			nut.util.Notify("You must be at the garage in the industrial area!", ply)
		end
	end
}, "paint")

function PLUGIN.Register( class, carTable )
	if not class then
		error("Attempted to register a vehicle without a classname!")
	elseif not carTable then
		error("Attempted to register a vehicle without a table!")
	end
	if PLUGIN.VehDataTable[class] then
		print("Warning! "..class.." will be overridden!")
	end
	PLUGIN.VehDataTable[class] = carTable
	util.PrecacheModel(carTable.model)
end

nut.util.Include("sh_vehicles.lua")

function PLUGIN.AddStorage( name, dataTable )
	if not name then
		error("Attempted to add a storage without a name!")
	elseif not dataTable then
		error("Attempted to add a storage without a table!")
	end
	if PLUGIN.Storages[name] then
		print("Warning! "..name.." will be overridden!")
	end
	PLUGIN.Storages[name] = dataTable
end

function PLUGIN.AddVehShop( dataTable )
	if not dataTable then
		error("Attempted to add a shop without a table!")
	end
	table.insert(PLUGIN.VehShops, dataTable)
end

nut.util.Include("sh_storage.lua")

function PLUGIN.GetCar( class )
	return PLUGIN.VehDataTable[class]
end

function PLUGIN.GetStorage( name )
	return PLUGIN.Storages[name] or PLUGIN.Storages["Downtown"]
end

if CLIENT then
	VehShopType = "CIV"
	local size = 16
	local border = 4
	local distance = size + border
	local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW() * 0.375, ScrH() * 0.125)
		self:SetSize(ScrW() * nut.config.menuWidth, ScrH() * nut.config.menuHeight)
		self:MakePopup()
		self:SetTitle("Garage")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(7)
		noticePanel:SetText("The house symbol means the vehicle is available at this storage, the world one means it's somewhere on the map.")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(4)
		noticePanel:SetText("Select the vehicle of your choice and hit 'Take Out' / 'Store'")

		self.bg = self:Add("DIconLayout")
		self.bg:Dock(FILL)
		self.bg:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		self.bg:SetDrawBackground(true)

		self.list = self:Add("DIconLayout")
		self.list:Dock(FILL)
		self.list:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		self.list:SetDrawBackground(false)

		self.panel = self:Add("DPanel")
		self.panel:Dock(FILL)
		self.panel:DockMargin(ScrW() * nut.config.menuWidth / 2, 0, 0, 0)
		self.panel:SetDrawBackground(true)

		local preview = self.panel:Add("DCollapsibleCategory")
		preview:Dock(TOP)
		preview:SetLabel("Vehicle Model")

		self.model = vgui.Create("DModelPanel", preview)
		self.model:Dock(TOP)
		self.model:SetSize(ScrW() * nut.config.menuWidth / 2, ScrH() * nut.config.menuHeight / 3)
		self.model:SetCamPos(Vector(50, 200, 110))
		self.model:SetLookAt(Vector(0, 0, -10))

		local info = self.panel:Add("DCollapsibleCategory")
		info:Dock(TOP)
		info:SetLabel("Vehicle Info")

		self.info = vgui.Create("DLabel", info)
		self.info:Dock(TOP)
		self.info:DockMargin(5, 0, 0, 0)
		self.info:SetSize(400, 80)
		self.info:SetTextColor(Color(240, 240, 240))
		self.info:SetText("NO DATA!")

		self.give = self.panel:Add("DButton")
		self.give:Dock(BOTTOM)
		self.give:DockMargin(0, 5, 0, 0)
		self.give:SetDisabled(true)
		self.give:SetText("Give this vehicle to...")
		self.give.DoClick = function()
			if self.request then
				local dMenu = DermaMenu()

				for _, v in pairs(player.GetAll()) do
					if v.character and v != LocalPlayer() then
						dMenu:AddOption(v:Name(), function()
							Derma_Query("Do you wish to send your "..PLUGIN.GetCar(LocalPlayer().character:GetData("vehicles", {})[self.request[1]].class).name.." to "..v:Name().."?",
								"Confirmation...",
								"Yes",
								function()
									if IsValid(self) then
										self:Close()
									end
									netstream.Start("GiveVehicle", {self.request[1], v})
								end,
								"No", function()
									-- Nothing...
								end
							)
						end)
					end
				end

				dMenu:Open()
			end
		end

		self.button = self.panel:Add("DButton")
		self.button:Dock(BOTTOM)
		self.button:DockMargin(0, 5, 0, 0)
		self.button:SetDisabled(true)
		self.button:SetText("Select a Vehicle!")
		self.button.DoClick = function()
			if self.request then
				self:Close()
				netstream.Start("GarageRequest", {self.request[1], self.request[2]})
			end
		end

		local dist = 32768
		local currentStorage
		for k,v in pairs(PLUGIN.Storages) do
			local storageDist = v.pos:Distance(LocalPlayer():GetPos())
			if storageDist < dist then
				dist = storageDist
				currentStorage = k
			end
		end
		if dist > 300 then
			nut.util.Notify("No Storages In Range!", LocalPlayer())
			self:Close()
			return
		end

		for k,v in pairs(LocalPlayer().character:GetData("vehicles", {})) do
			local data = PLUGIN.GetCar(v.class)
			local icon = self.list:Add("SpawnIcon")
			icon:SetModel(data.model, data.skin)
			icon.PaintOver = function(icon, w, h)
				surface.SetDrawColor(0, 0, 0, 45)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
				if v.onWorld or v.storage == currentStorage then
					surface.SetDrawColor(0, 0, 0, 50)
					surface.DrawRect(w - distance - 1, w - distance - 1, size + 2, size + 2)
					surface.SetDrawColor(255, 255, 255)
					if v.onWorld then
						surface.SetMaterial(Material("icon16/world.png"))
					else
						surface.SetMaterial(Material("icon16/house.png"))
					end
					surface.DrawTexturedRect(w - distance, w - distance, size, size)
				end
			end
			icon:SetTooltip(data.name)
			icon.DoClick = function()
				local hp = v.hp or 1000
				local text = "Name: "..data.name.."\nCondition: "..hp.."/1000\nColor: "..v.color.r..", "..v.color.g..", "..v.color.b.."\nFuel: "..v.fuel.."/100\nCurrent Storage: "..v.storage or "N/A"
				self.info:SetText(text)
				self.model:SetModel(data.model)
				self.model.Entity:SetSkin(data.skin)
				self.model:SetColor(v.color)
				if v.onWorld or v.storage == currentStorage then
					self.request = {k, currentStorage}
					if v.onWorld then
						self.button:SetText("Store")
						self.give:SetDisabled(true)
					elseif v.storage == currentStorage then
						self.button:SetText("Take Out")
						self.give:SetDisabled(false)
					end
					self.button:SetDisabled(false)
				else
					self.give:SetDisabled(true)
					self.button:SetDisabled(true)
					self.button:SetText("Select a Vehicle!")
				end
			end
		end
	end

	vgui.Register("nut_Garage", PANEL, "DFrame")

	local PANEL = {}
	function PANEL:Init()
		self:SetPos(ScrW() * 0.375, ScrH() * 0.125)
		self:SetSize(ScrW() * nut.config.menuWidth, ScrH() * nut.config.menuHeight)
		self:MakePopup()
		self:SetTitle("Vehicle Shop")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(7)
		noticePanel:SetText("Coins means the vehicle is buyable, a V that you can sell it, an X that the vehicle isn't near the shop.")

		local noticePanel = self:Add("nut_NoticePanel")
		noticePanel:Dock(TOP)
		noticePanel:DockMargin(0, 0, 0, 5)
		noticePanel:SetType(4)
		noticePanel:SetText("Select the vehicle of your choice and hit 'Buy' / 'Sell'")

		local panel = self:Add("DPanel")
		panel:Dock(FILL)
		panel:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		panel:SetDrawBackground(false)

		self.bg = self:Add("DIconLayout")
		self.bg:Dock(FILL)
		self.bg:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		self.bg:SetDrawBackground(true)

		self.list = self:Add("DIconLayout")
		self.list:Dock(FILL)
		self.list:DockMargin(0, 0, ScrW() * nut.config.menuWidth / 2, 0)
		self.list:SetDrawBackground(false)

		self.panel = self:Add("DPanel")
		self.panel:Dock(FILL)
		self.panel:DockMargin(ScrW() * nut.config.menuWidth / 2, 0, 0, 0)
		self.panel:SetDrawBackground(true)

		local preview = self.panel:Add("DCollapsibleCategory")
		preview:Dock(TOP)
		preview:SetLabel("Vehicle Model")

		self.model = vgui.Create("DModelPanel", preview)
		self.model:Dock(TOP)
		self.model:SetSize(ScrW() * nut.config.menuWidth / 2, ScrH() * nut.config.menuHeight / 3)
		self.model:SetCamPos(Vector(50, 200, 110))
		self.model:SetLookAt(Vector(0, 0, -10))

		local info = self.panel:Add("DCollapsibleCategory")
		info:Dock(TOP)
		info:SetLabel("Vehicle Info")

		self.info = vgui.Create("DLabel", info)
		self.info:Dock(TOP)
		self.info:DockMargin(5, 0, 0, 0)
		self.info:SetSize(400, 60)
		self.info:SetTextColor(Color(240, 240, 240))
		self.info:SetText("NO DATA!")

		self.button = self.panel:Add("DButton")
		self.button:Dock(BOTTOM)
		self.button:DockMargin(0, 5, 0, 0)
		self.button:SetDisabled(true)
		self.button:SetText("Select a Vehicle!")
		self.button.DoClick = function()
			if self.request then
				self:Close()
				local color = self.color:GetColor()
				netstream.Start("VehShopRequest", {self.request[1], self.request[2], {r = color.r, g = color.g, b = color.b}})
			end
		end

		self.color = self.panel:Add("DColorMixer")
		self.color:Dock(FILL)
		self.color:SetPalette(true)
		self.color:SetAlphaBar(false)
		self.color:SetWangs(true)
		self.color:SetColor(Color(80, 80, 80))

		for k,v in pairs(PLUGIN.VehDataTable) do
			local data = PLUGIN.GetCar(k)
			if VehShopType == data.type then
				local icon = self.list:Add("SpawnIcon")
				icon:SetModel(data.model, data.skin)
				icon.PaintOver = function(icon, w, h)
					surface.SetDrawColor(0, 0, 0, 45)
					surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					surface.SetDrawColor(0, 0, 0, 50)
					surface.DrawRect(w - distance - 1, w - distance - 1, size + 2, size + 2)
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(Material("icon16/coins.png"))
					surface.DrawTexturedRect(w - distance, w - distance, size, size)
				end
				icon:SetTooltip(data.name)
				icon.DoClick = function()
					local text = "Name: "..data.name.."\nTrunk Capacity: "..data.maxWeight.." kg\nPrice: "..nut.currency.GetName(data.price)
					self.request = {1, k}
					self.info:SetText(text)
					self.model:SetModel(data.model)
					self.model.Entity:SetSkin(data.skin)
					self.button:SetText("Buy")
					self.button:SetDisabled(false)
				end
			end
		end

		for k,v in pairs(LocalPlayer().character:GetData("vehicles", {})) do
			local data = PLUGIN.GetCar(v.class)
			local icon = self.list:Add("SpawnIcon")
			icon:SetModel(data.model, data.skin)
			icon.PaintOver = function(icon, w, h)
				surface.SetDrawColor(0, 0, 0, 45)
				surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(w - distance - 1, w - distance - 1, size + 2, size + 2)
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(Material("icon16/cross.png"))
				if v.onWorld then
					local veh = Entity(v.ent)
					if IsValid(veh) then
						if veh:GetPos():Distance(LocalPlayer():GetPos()) <= 700 then
							surface.SetMaterial(Material("icon16/tick.png"))
						end
					end
				end
				surface.DrawTexturedRect(w - distance, w - distance, size, size)
			end
			icon:SetTooltip(data.name)
			icon.DoClick = function()
				local text = "Name: "..data.name.."\nColor: "..v.color.r..", "..v.color.g..", "..v.color.b.."\nFuel: "..v.fuel.."/100\nCurrent Storage: "..v.storage or "N/A"
				self.info:SetText(text)
				self.model:SetModel(data.model)
				self.model.Entity:SetSkin(data.skin)
				self.model:SetColor(v.color)
				if v.onWorld then
					local veh = Entity(v.ent)
					if veh:GetPos():Distance(LocalPlayer():GetPos()) <= 700 then
						self.request = {2, tostring(k)}
						self.button:SetText("Sell")
						self.button:SetDisabled(false)
					else
						self.button:SetDisabled(true)
						self.button:SetText("Vehicle Too Far!")
					end
				else
					self.button:SetDisabled(true)
					self.button:SetText("Vehicle Too Far!")
				end
			end
		end
	end

	function PANEL:Think()
		if self.request then
			self.model:SetColor(self.color:GetColor())
		end
	end

	vgui.Register("nut_VehShop", PANEL, "DFrame")

	nut.bar.Add("fuel", {
		getValue = function()
			if (LocalPlayer():InVehicle()) then
				return LocalPlayer():GetVehicle():GetNWInt("fuel", 0)
			else
				return 0
			end
		end,
		color = Color(50, 50, 50)
	})

	nut.bar.Add("carHP", {
		getValue = function()
			if (LocalPlayer():InVehicle()) then
				return LocalPlayer():GetVehicle():Health() / 10
			else
				return 0
			end
		end,
		color = Color(230, 135, 50)
	})

	netstream.Hook("carColorMenu", function()
		local Frame = vgui.Create("DFrame")
		Frame:SetPos(0, 300)
		Frame:SetSize(300, 245)
		Frame:SetTitle("Car Paint")
		Frame:MakePopup()

		local Hint = vgui.Create("nut_NoticePanel", Frame)
		Hint:SetPos(10, 30)
		Hint:SetSize(280, 25)
		Hint:SetType(7)
		Hint:SetText("Pick the color of your car... Cost: 100 €")

		local Mixer = vgui.Create("DColorMixer", Frame)
		Mixer:SetPos(10, 60)
		Mixer:SetSize(280, 150)
		Mixer:SetPalette(true)
		Mixer:SetAlphaBar(false)
		Mixer:SetWangs(true)

		local Button = vgui.Create("DButton", Frame)
		Button:Dock(BOTTOM)
		Button:SetText("Paint!")
		function Button:DoClick()
			Frame:Close()
			netstream.Start("carColorSet", {red = Mixer:GetColor().r, green = Mixer:GetColor().g, blue = Mixer:GetColor().b})
		end
	end)
end
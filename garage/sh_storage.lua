local PLUGIN = PLUGIN

PLUGIN.AddStorage("Downtown", {
		pos = Vector(-7555.446289, -6801.047852, 72.294266),
		ang = Angle(0, -90, 0),
		spawnPos = Vector(-7632.113281, -7081.547852, 86.640511),
		spawnAng = Angle(0, 180, 0)
	}
)

PLUGIN.AddStorage("DowntownMotors", {
		pos = Vector(4205.823730, -4752.102539, 64.350113),
		ang = Angle(0, 90, 0),
		spawnPos = Vector(4064.409912, -4566.570801, 78.065979),
		spawnAng = Angle(0, 180, 0)
	}
)

PLUGIN.AddStorage("PoliceGarage", {
		pos = Vector(-7477.061035, -9604.142578, -183.551498),
		ang = Angle(0, 0, 0),
		spawnPos = Vector(-7628.049805, -9458.717773, -180.465805),
		spawnAng = Angle(0, -90, 0)
	}
)

PLUGIN.AddStorage("EMTHQ", {
		pos = Vector(-3905.892822, -8367.042969, 198.390945),
		ang = Angle(0, 0, 0),
		spawnPos = Vector(-3715.228271, -8230.407227, 233.285416),
		spawnAng = Angle(0, 90, 0)
	}
)

PLUGIN.AddStorage("Hospital", {
		pos = Vector(-9370.954102, 9773.664063, 72.373451),
		ang = Angle(0, 0, 0),
		spawnPos = Vector(-8588.426758, 9542.157227, 74.637161),
		spawnAng = Angle(0, 50, 0)
	}
)

PLUGIN.AddStorage("Mansart", {
		pos = Vector(2982.848145, 11601.046875, 58.389637),
		ang = Angle(0, 90, 0),
		spawnPos = Vector(2971.750000, 11742.433594, 60.677673),
		spawnAng = Angle(0, -90, 0)
	}
)

PLUGIN.AddStorage("Impound", {
		pos = Vector(1187.061279, 4303.395508, 68.300888),
		ang = Angle(0, 180, 0),
		spawnPos = Vector(845.536194, 4432.294922, 67.042305),
		spawnAng = Angle(0, -180, 0)
	}
)

PLUGIN.AddStorage("Market", {
		pos = Vector(-2573.018555, 3867.009277, 64.447853),
		ang = Angle(0, 0, 0),
		spawnPos = Vector(-2700.199951, 3874.336670, 68.602577),
		spawnAng = Angle(0, 0, 0)
	}
)

-- Shops
PLUGIN.AddVehShop({
	pos = Vector(5441.568359, -3649.084473, 64.031250),
	ang = Angle(0, -135, 0),
	model = "models/breen.mdl",
	type = "CIV"
})

PLUGIN.AddVehShop({
	pos = Vector(-6805.083496, -9048.903320, -183.968750),
	ang = Angle(0, 180, 0),
	model = "models/odessa.mdl",
	type = "ECPD"
})

PLUGIN.AddVehShop({
	pos = Vector(-3890.968750, -8474.092773, 198.031250),
	ang = Angle(0, 45, 0),
	model = "models/Humans/Group03m/male_07.mdl",
	type = "EMT"
})
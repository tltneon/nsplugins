PLUGIN.name = "Forcefield Braker"
PLUGIN.author = "pack"
PLUGIN.desc = "Adds a weapon that breaks the forcefields."

nut.config.add(
	"forcefieldBrakeTime",
	4,
	"How long does it take to break the forcefield.",
	nil,
	{
		category = PLUGIN.name,
		data = {min = 0, max = 60}
	}
)

nut.config.add(
	"forcefieldBrakeStrip",
	true,
	"Get the forcefield braker after use.",
	nil,
	{
		category = PLUGIN.name,
		data = {min = 0, max = 60}
	}
)

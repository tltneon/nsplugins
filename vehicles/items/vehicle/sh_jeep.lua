ITEM.name = "Wireframe Jeep"
ITEM.uniqueID = "vehicle_jeep"
ITEM.model = Model("models/buggy.mdl")
ITEM.vehiclescript = "scripts/vehicles/jeep_test.txt"
ITEM.desc = "Simple jeep. seems rusty and old. \nThis car's number is %number|not registed%"

ITEM.numplate = {
	{ pos = Vector( -55, 0, 35 ), ang = Angle( 180, 0, 90 ), scale = .2} -- SWAPPED X, Y POSITION. 2014-01-07 :rebel1324:
}
ITEM.seats =
{
	["passenger2" ] = { model = "models/nova/jeep_seat.mdl", pos = Vector( 0, -110, 20 ), ang = Angle( 0, 180, 0 ) },
	["passenger1" ] = { model = "models/nova/jeep_seat.mdl", pos = Vector( 14.284, -36.873, 19 ), ang = Angle( 0, 0, 0 ) },
	-- PAC POS VECTOR( 14.284, -36.873, 19 )
}
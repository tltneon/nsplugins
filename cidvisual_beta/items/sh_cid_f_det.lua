ITEM.name = "Fake CID Detector"
ITEM.model = Model("models/props_lab/reciever01a.mdl")
ITEM.desc = "Can detect fake CID.\nThis item will be removed after used.\nThis device is currently %On|off%. "
ITEM.uniqueID = "cid_fdet"
ITEM.functions = {}
ITEM.functions.Toggle = {
	text = "Toggle",
	menuOnly = true,
	tip = "Toggle this device.",
	icon = "icon16/weather_sun.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local data = table.Copy(data)
			if (!data.On or data.On == "off") then
				data.On = "on"
			else
				data.On = "off"
			end
			client:EmitSound( "buttons/button16.wav" )
			client:ConCommand( nut.lang.Get( "vcid_det_me" ) )
			client:UpdateInv("cid_fdet", 1, data)
			return true
		end
	end
}

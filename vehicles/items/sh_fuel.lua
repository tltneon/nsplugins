ITEM.name = "Fuel"
ITEM.model = Model("models/props_junk/gascan001a.mdl")
ITEM.desc = "A fuel for vehicles. It will fill vehicle's fuel tank when it used."
ITEM.functions = {}
ITEM.functions.Use = {
	alias = "Fill Vehicle",
	icon = "icon16/box.png",
	run = function(itemTable, client, data)
		if (SERVER) then
			local dat = {
				start = client:GetShootPos(),
				endpos = client:GetShootPos() + client:GetAimVector() * 72,
				filter = client
			}
			local trace = util.TraceLine(dat)
			if trace.Entity:IsValid() then
				if trace.Entity:IsPluginVehicle() then
					local snd = CreateSound(  trace.Entity, "ambient/water/water_flow_loop1.wav" )
					snd:Play()
					client:Freeze( true )
					timer.Simple( 2, function()
						snd:Stop()
						client:Freeze( false )
					end)
					trace.Entity.fuel = 100
				end
			end			
		end
	end
}
ITEM.name = "Artillery Beacon"
ITEM.model = "models/Items/grenadeAmmo.mdl"
ITEM.desc = "Calls artillery support."
ITEM.throwent = "nut_beacon"
ITEM.throwforce = 500

ITEM.functions = {}
ITEM.functions.Throw = {
	text = "Throw",
	tip = "Throws the item.",
	icon = "icon16/box.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local grd = ents.Create( itemTable.throwent )
			grd:SetPos( client:EyePos() + client:GetAimVector() * 50 )
			grd:Spawn()
			grd:SetDTInt(0,2)
			function grd:Payload()
				RequestAirSupport( self:GetPos() + Vector( 0, 0, 50 ) )
			end
			local phys = grd:GetPhysicsObject()
			phys:SetVelocity( client:GetAimVector() * itemTable.throwforce * math.Rand( .8, 1 ) )
			phys:AddAngleVelocity( client:GetAimVector() * itemTable.throwforce  )
			return true
		end
	end,
}
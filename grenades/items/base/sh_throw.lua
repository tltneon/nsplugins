BASE.name = "Base Throwable"
BASE.weight = .5
BASE.category = "Throwable"

BASE.throwent = "item_healthkit"
BASE.throwforce = 2500

-- You can use hunger table? i guess? 
BASE.functions = {}
BASE.functions.Throw = {
	text = "Throw",
	tip = "Throws the item.",
	icon = "icon16/box.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			local grd = ents.Create( itemTable.throwent )
			grd:SetPos( client:EyePos() + client:GetAimVector() * 50 )
			grd:Spawn()
			local phys = grd:GetPhysicsObject()
			phys:SetVelocity( client:GetAimVector() * itemTable.throwforce * math.Rand( .8, 1 ) )
			phys:AddAngleVelocity( client:GetAimVector() * itemTable.throwforce  )
			return true
		end
	end,
}
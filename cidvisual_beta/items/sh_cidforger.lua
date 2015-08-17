local ITEM = ITEM
ITEM.name = "Citizen ID Forging Kit"
ITEM.model = Model("models/props_c17/BriefCase001a.mdl")
ITEM.uniqueID = "cid_forger"
ITEM.forgeuid = "cid2"
ITEM.desc = "You can Forge Fake CID with this kit."
ITEM.functions = {}
ITEM.functions.ForgeID = {
	menuOnly = true,
	text = "Forge ID",
	tip = "Show this CID to someone in front of you.",
	icon = "icon16/page_white.png",
	run = function(itemTable, client, data, entity)
		if (SERVER) then
			netstream.Start( client, "Nut_ClientCIDForgeMenu") 
			return false
		end
	end
}

if ( CLIENT ) then
	netstream.Hook( "Nut_ClientCIDForgeMenu", function( data )
		Derma_StringRequest( "CID Forging", "Write the name that you want to use in CID", "John Connor", 
		function( t )
			netstream.Start( "Nut_CIDForgeData", t) 
		end,
		function() end, "Forge CID", "Cancel" )
		-- Place some derma requests.
	end)
else
	netstream.Hook( "Nut_CIDForgeData", function( client, data )
		if client:HasItem( ITEM.uniqueID ) then
			client:UpdateInv( ITEM.uniqueID, -1)
			client:UpdateInv( ITEM.forgeuid, 1, {
				Digits = math.random(55555, 99999), 
				Owner = data,
				Model = client:GetModel(),
				Forged = true,
			})
			client:EmitSound( "buttons/lever5.wav" )
			nut.util.Notify( nut.lang.Get( "vcid_forge_success", data ) , client ) 
		else
			nut.util.Notify( nut.lang.Get( "vcid_forge_afford" ) , client ) 
		end
	end)
end
local PLUGIN = PLUGIN
PLUGIN.name = "PAC3 Outfits"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Allows you use PAC3."
PLUGIN.slots = {
	"e_head",
	"e_chest",
	"e_back",
}

nut.util.Include("sh_lang.lua")

PAC3_OUTFITS = {}
nut.util.Include("sh_outfits.lua")

--ATTRIB_COOK = nut.attribs.SetUp("Cooking", "Affects how good is the result of cooking.", "cook")

function PLUGIN:CreateCharVars(character)

end


PAC_UPDATEDIST = 1500


function PLUGIN:Think()
	if SERVER then
		for _, p in pairs( player.GetAll() ) do
			if p:IsValid() then
				for _, slot in pairs( self.slots ) do
					if ( p[ slot ] != p:GetNetVar( slot ) ) then
						hook.Call( "OnOutfitChanged", GAMEMODE, p, slot )
						p[slot] = p:GetNetVar( slot )
					end
				end
			end
		end
	else
		for _, p in pairs( player.GetAll() ) do
			if p:IsValid() then
				for _, slot in pairs( self.slots ) do
					if ( p[ slot ] != p:GetNetVar( slot ) ) && ( p:GetPos():Distance( LocalPlayer():GetPos() ) < 1500  ) then
						hook.Call( "OnOutfitChanged", GAMEMODE, p, slot )
						p[slot] = p:GetNetVar( slot )
					end
				end
			end
		end
	end
end

function PLUGIN:PlayerLoadedChar( p )
	if SERVER then
		for _, slot in pairs( self.slots ) do
			p:SetNetVar( slot, "null" )
		end
	end
end

function PLUGIN:OnOutfitChanged( p, slot )
	if SERVER then
		-- idk.. spec change or something?
	else					
		pac.SetupENT( p )
		local old = p[slot]
		local new = p:GetNetVar( slot )
		
		if old then
			local outfit = PAC3_OUTFITS[ old ]
			p:RemovePACPart( outfit )
		end
		
		if new then
			local outfit = PAC3_OUTFITS[ new ]
			p:AttachPACPart( outfit )
		end
		
	end
end

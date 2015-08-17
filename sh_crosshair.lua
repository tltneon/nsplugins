PLUGIN.name = "Crosshiar"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Why?"

PLUGIN.config = {}
PLUGIN.config.activated = true
PLUGIN.config.gap = 10
PLUGIN.config.nodrawWeapon = {

}

if CLIENT then
	
	local function drawdot( pos, size, col )
		pos[1] = math.Round( pos[1] )
		pos[2] = math.Round( pos[2] )
		draw.RoundedBox( 0, pos[1] - size/2, pos[2] - size/2 , size, size, col[1] )
		size = size-2
		draw.RoundedBox( 0, pos[1] - size/2, pos[2] - size/2, size, size, col[2] )
	end
	
	function PLUGIN:HUDPaint()
	
		local ply = LocalPlayer()
		if 
			( ply:IsValid() &&
			ply:Alive() &&
			ply:GetActiveWeapon() &&
			ply:GetActiveWeapon():IsValid() &&
			!self.config.nodrawWeapon[ ply:GetActiveWeapon():GetClass() ] )
		then
			local t = util.QuickTrace( ply:GetShootPos(), ply:GetAimVector() * 15000, ply )
			local pos = t.HitPos:ToScreen()
			local col = { color_black, color_white }
			if ply:WepRaised() == false then
				col = { Color( 50, 15, 15) , Color( 220, 60, 60 ) }
			end
			drawdot( {pos.x, pos.y},4, col )
			drawdot( {pos.x + self.config.gap, pos.y},4, col )
			drawdot( {pos.x - self.config.gap, pos.y},4, col ) 
			drawdot( {pos.x, pos.y + self.config.gap * .8},4, col ) 
			drawdot( {pos.x, pos.y - self.config.gap * .8},4, col ) 
		end
		
	end
	
end
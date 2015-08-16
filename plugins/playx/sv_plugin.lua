local PLUGIN = PLUGIN

function PLUGIN:LoadData()
	if not PlayX then return end

	local screen = ents.Create("gmod_playx")
	screen:SetModel("models/dav0r/camera.mdl")
	screen:SetPos(self.screenPos)
	screen:SetAngles(self.screenAng)
	screen:SetRenderMode(RENDERMODE_TRANSALPHA)
	screen:SetColor(Color(255, 255, 255, 1))
	screen:Spawn()
	screen:Activate()

	local phys = screen:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end
end

function PLUGIN:KeyPress( ply, key )
	if not PlayX then return end

	if key == IN_USE then
		local data = {}
		data.start = ply:GetShootPos()
		data.endpos = data.start + ply:GetAimVector() * 84
		data.filter = ply
		local entity = util.TraceLine(data).Entity
		local isController = false

		if IsValid(entity) then
			for _, v in pairs(self.controllers) do
				if entity:MapCreationID() == v then
					isController = true
				end
			end
		end

		if isController then
			if not ply:HasFlag("m") then
				PlayX.SendError(ply, "You do not have permission to use the player")
				return
			end
			ply.nextMusicUse = ply.nextMusicUse or 0

			if CurTime() > ply.nextMusicUse then
				netstream.Start(ply, "nut_RequestPlayxURL")
				ply.nextMusicUse = CurTime() + 1.5
			end
		end
	end
end

netstream.Hook("nut_MediaRequest", function( ply, url )
	if not PlayX then return end

	if not ply:hasFlag("m") and not ply:IsAdmin() then
		PlayX.SendError(ply, "You do not have permission to use the player")
		return
	end

	local result, err = PlayX.OpenMedia("", url, 0, false, true, false)

	if not result then
		PlayX.SendError(ply, err)
	end
end)
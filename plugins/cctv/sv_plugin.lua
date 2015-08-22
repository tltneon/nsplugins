local PLUGIN = PLUGIN

function PLUGIN:StartCCTV( ply )
	for k,v in pairs(ents.FindByClass("nut_cctv")) do
		if ply:GetPos():Distance(v:GetPos()) <= self.cctvDistance then
			netstream.Start(ply, "cctvStart")
			return
		end
	end
	nut.util.Notify("You must be within "..self.cctvDistance.." units of a CCTV Prompt!", ply)
end

function PLUGIN:LoadData()
	local data = self:getData() or {}
	data.cameras = data.cameras or {}
	data.cctv = data.cctv or {}
	for k, v in pairs(data.cameras) do
		local position = v.pos
		local angles = v.angles
		local camname = v.camname
		local entity = ents.Create("nut_cctv_camera")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:SetNWString("name", camname)
		entity:Spawn()
		entity:Activate()
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
	for k, v in pairs(data.cctv) do
		local position = v.pos
		local angles = v.angles
		local entity = ents.Create("nut_cctv")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	data.cameras = {}
	data.cctv = {}
	for k, v in pairs(ents.FindByClass("nut_cctv_camera")) do
		if v:GetNWString("name", "Unknown") != "Unknown" then
			data.cameras[#data + 1] = {
				pos = v:GetPos(),
				angles = v:GetAngles(),
				camname = v:GetNWString("name", "Unknown"),
			}
		end
	end
	for k, v in pairs(ents.FindByClass("nut_cctv")) do
		data.cctv[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
		}
	end
	self:setData(data)
end

netstream.Hook("cctvUpdate", function( ply, camera )
	local cameraFound
	for k,v in pairs(ents.FindByClass("nut_cctv_camera")) do
		if v:GetNWString("name", "Unknown") == camera then
			cameraFound = v
			break
		end
	end

	if not cameraFound then
		nut.util.Notify("ERROR: Failure to find camera ( "..camera.." )!", ply)
		return
	end

	if not IsValid(CCTVCamera) then
		CCTVCamera = ents.Create( "point_camera" )
		CCTVCamera:SetKeyValue( "GlobalOverride", 1 )
		CCTVCamera:Spawn()
		CCTVCamera:Activate()
		CCTVCamera:Fire( "SetOn", "", 0.0 )
	end

	pos = cameraFound:LocalToWorld( Vector( 15,33,-5 ) )
	CCTVCamera:SetPos(pos)
	local ang = cameraFound:GetAngles()
	ang[1] = ang[1] + 27
	ang[2] = ang[2] + 30
	CCTVCamera:SetAngles(ang)
	CCTVCamera:SetParent(cameraFound)

	for k,v in pairs(ents.FindByClass("nut_cctv")) do
		v:SetNWString("camera", camera)
	end
end)

hook.Add("SetupPlayerVisibility", "CCTVRender", function( ply )
	if IsValid(CCTVCamera) then
		AddOriginToPVS( CCTVCamera:GetPos() ) 
	end
end)
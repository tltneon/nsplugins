ENT.Type = "anim"
ENT.PrintName = "Noti-Board"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH


if CLIENT then
	local ftbl = {
		font = mainFont,
		size = 27,
		weight = 500,
		antialias = true,
	}
	surface.CreateFont("nut_NotiBoardFont", ftbl)
	ftbl.blursize = 2
	surface.CreateFont("nut_NotiBoardFont2", ftbl)

	local ftbl = {
		font = mainFont,
		size = 33,
		weight = 1000,
		antialias = true
	}
	surface.CreateFont("nut_NotiBoardTitle", ftbl)
	ftbl.blursize = 2
	surface.CreateFont("nut_NotiBoardTitle2", ftbl)
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/hunter/plates/plate1x4.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetColor(Color(0,0,0))
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end
	function ENT:OnRemove()
	end
	function ENT:Use(client)
		if client:IsAdmin() then
			netstream.Start(client, "nut_ShowNotiMenu", self)
		end
	end

	netstream.Hook("nut_NotiRequest", function(client, data)
		if !(client:IsValid() and client:IsAdmin() and data[3] and data[3]:IsValid()) then return end
		data[3]:setNetVar(data[1], data[2])
	end)
else

	netstream.Hook("nut_ShowNotiMenu", function(data)
		local menu = DermaMenu()

		menu:AddOption( "Set Title", function()
			Derma_StringRequest("Text Request", "Enter the title for the Noti-Board.", "A Sample Text", function(text)
				netstream.Start("nut_NotiRequest", {"title", tostring(text), data})
			end, nil, "Submit", "Cancel")
		end):SetImage("icon16/page.png")
		menu:AddOption( "Set Text", function()
			Derma_StringRequest("Text Request", "Enter the text for the Noti-Board.", "A Sample Text", function(text)
				netstream.Start("nut_NotiRequest", {"text", tostring(text), data})
			end, nil, "Submit", "Cancel")
		end):SetImage("icon16/page.png")

		menu:Open()
		menu:Center()
	end)

	function ENT:Initialize()
	end
	function ENT:Draw()
		self:DrawModel()
	end
	local scale = .5
	local sx, sy = 95*4, 95
	local distance = 1000
	local SCREEN_OVERLAY
	function ENT:DrawTranslucent()
		local rt = RealTime()
		local pos, ang = self:GetPos(), self:GetAngles()
		pos = pos + self:GetUp()*2
		ang:RotateAroundAxis( self:GetUp(), 90 )

		local up = self:GetUp()
		local right = self:GetRight()
		local forward = self:GetForward()

		local ch = up*sy*0.5*scale
		local cw = right*sx*0.5*scale
		local dist = LocalPlayer():GetPos():Distance(pos)
		local distalpha = math.Clamp(distance-dist, 0, 255)

		if (!SCREEN_OVERLAY) then
			SCREEN_OVERLAY = Material("effects/combine_binocoverlay")
			SCREEN_OVERLAY:SetFloat("$alpha", "0.7")
			SCREEN_OVERLAY:Recompute()
		end
		
		local text = self:getNetVar("text", "This Noti-Board is not assigned yet.")
		local title = self:getNetVar("title", "A Noti-Board")

		if dist <= distance then
			render.PushCustomClipPlane(up, up:Dot( pos-ch ))
			render.PushCustomClipPlane(-up, (-up):Dot( pos+ch ))
			render.PushCustomClipPlane(right, right:Dot( pos-cw ))
			render.PushCustomClipPlane(-right, (-right):Dot( pos+cw ))
			render.EnableClipping( true )

				cam.Start3D2D(pos, ang, scale)
					surface.SetDrawColor(22 , 22, 22, distalpha)
					surface.DrawRect(-sx/2, -sy/2, sx, sy)

					surface.SetFont("nut_NotiBoardTitle")
					local tx, ty = surface.GetTextSize(title)
					local tposx, tposy = -tx/2,-ty/2-19
					surface.SetTextPos(tposx, tposy)
					surface.SetTextColor(222, 222, 222, distalpha)
					surface.DrawText(title)
					surface.SetFont("nut_NotiBoardTitle2")
					surface.SetTextPos(tposx, tposy)
					surface.DrawText(title)

					surface.SetFont("nut_NotiBoardFont")
					local tx, ty = surface.GetTextSize(text)
					local tposx, tposy = sx/2-((RealTime()*100)%(tx+sx)),-ty/2+23
					surface.SetTextPos(tposx, tposy)
					surface.DrawText(text)
					surface.SetFont("nut_NotiBoardFont2")
					surface.SetTextPos(tposx, tposy)
					surface.DrawText(text)

					surface.SetDrawColor(255, 255, 255, math.Clamp(distalpha,0,50))
					surface.SetMaterial(SCREEN_OVERLAY)
					surface.DrawTexturedRect(-sx/2, -sy/2, sx, sy)
				cam.End3D2D()

			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.EnableClipping( false )
		end
	end
end
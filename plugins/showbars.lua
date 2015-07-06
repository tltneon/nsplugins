PLUGIN.name = "Show Bars"
PLUGIN.author = "Neon"
PLUGIN.desc = "Shows you all bars while content menu is active."
--# Configuration: true - show bar, false - don't show bar.
-- stm = stamina bar, health = health bar, hunger = hunger bar (only for cookfood plugin)
PLUGIN.wlist = {
	health = true,
	stm = true, 
	hunger = false
 }

if CLIENT then
	function PLUGIN:OnContextMenuOpen()
		local w, h = surface.ScreenWidth() * 0.35, 10
		local x, y = 4, 4
		local deltas = nut.bar.delta
		local frameTime = FrameTime()
		local curTime = CurTime()

		for k, v in ipairs(nut.bar.list) do
			if self.wlist[v.identifier] then
				local realValue = v.getValue()
				local value = math.Approach(deltas[k] or 0, realValue, frameTime * 0.6)
				deltas[k] = value
				v.visible = true
				nut.bar.draw(x, y, w, h, value, v.color, v)
				y = y + (h + 2)
			end
		end
		nut.bar.drawAction()
	end
	function PLUGIN:OnContextMenuClose()
		local w, h = surface.ScreenWidth() * 0.35, 10
		local x, y = 4, 4
		local deltas = nut.bar.delta
		local frameTime = FrameTime()
		local curTime = CurTime()
		for k, v in ipairs(nut.bar.list) do
			local realValue = v.getValue()
			local value = math.Approach(deltas[k] or 0, realValue, frameTime * 0.6)
			deltas[k] = value
			v.visible = false
		end
		nut.bar.drawAction()
	end
end
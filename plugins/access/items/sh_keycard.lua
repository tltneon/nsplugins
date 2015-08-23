ITEM.name = "Keycard"
ITEM.uniqueID = "keycard"
ITEM.weight = 0
ITEM.model = Model("models/gibs/metal_gib4.mdl")
ITEM.desc = "A Keycard for accessing different areas of EvoCity."
function ITEM:getDesc()
	local description = self.desc
	if self:getData("owner") != nil then description = description.." Owner: "..self:getData("owner", "Unknown").."," end
	if self:getData("id") != nil then description = description.." ID: "..self:getData("id", "Unknown").."." end
	return description
end
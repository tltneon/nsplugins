ITEM.name = "Oranges"
ITEM.uniqueID = "oranges"
ITEM.model = Model("models/props/cs_italy/orange.mdl")
ITEM.GetDropModel = Model("models/props/cs_italy/it_mkt_container2.mdl")
ITEM.desc = "Can be sold at the market."
ITEM.price = 115
ITEM.weight = 5
function ITEM:GetDropModel()
	return Model("models/props/cs_italy/it_mkt_container2.mdl")
end
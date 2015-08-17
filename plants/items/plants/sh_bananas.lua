ITEM.name = "Bananas"
ITEM.uniqueID = "bananas"
ITEM.model = Model("models/props/cs_italy/bananna_bunch.mdl")
ITEM.GetDropModel = Model("models/props/cs_italy/it_mkt_container2.mdl")
ITEM.desc = "Can be sold at the market."
ITEM.price = 135
ITEM.weight = 5
function ITEM:GetDropModel()
	return Model("models/props/cs_italy/it_mkt_container2.mdl")
end
function PLUGIN:GetDefaultInv(inventory, client, data)
if (data.faction == FACTION_CIVILWORKER) then
data.chardata.digits = nut.util.GetRandomNum(5)

inventory:Add("cid2", 1, {
Name = data.charname,
Digits = data.chardata.digits
})

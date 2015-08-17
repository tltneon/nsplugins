BASE.name = "Base Junk"
BASE.uniqueID = "base_junk"
BASE.category = "Junk"
BASE.worth = 5
BASE.noBusiness = true
BASE.isJunk = true
BASE.functions = {}
BASE.functions.Scrap = {
	run = function(itemTable, client, data)
		if (SERVER) then
			local amount = math.max(itemTable.worth + math.random(-5, 5), 1)

			timer.Simple(0.7, function()
				if (!IsValid(client)) then
					return
				end

				nut.util.Notify("You have received "..nut.currency.GetName(amount).." for scrapping this item.", client)
				client:GiveMoney(amount)
			end)
		else
			surface.PlaySound("buttons/button5.wav")
		end
	end
}
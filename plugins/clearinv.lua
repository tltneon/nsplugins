PLUGIN.name = "Clear Inventory"
PLUGIN.author = "Neon"
PLUGIN.desc = "Removing all items from player's inventory when character was died."

if SERVER then
  function PLUGIN:PlayerDeath(client)
    if client:getChar() then
      for k, v in pairs(client:getChar():getInv():getItems()) do
        v:remove()
      end
    end
  end
end

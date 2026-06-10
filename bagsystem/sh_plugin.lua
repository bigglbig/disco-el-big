local PLUGIN = PLUGIN

PLUGIN.name = "Bag System"
PLUGIN.author = "Fruity"
PLUGIN.description = "A simple bag system."

function PLUGIN:CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
    if (isSellingToVendor) then return end

    if (uniqueID == "smallbag" or uniqueID == "largebag") then
        if (client:GetCharacter():GetInventory():HasItem(uniqueID)) then
            return false
        end
    end
end
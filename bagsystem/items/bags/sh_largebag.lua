ITEM.name = "Большая сумка"
ITEM.description = "Рюкзак с эмблемой Арасаки на нём."
ITEM.invWidth = 4
ITEM.invHeight = 4
ITEM.bodygroup = "bag"
ITEM.model = Model("models/bybig/bag_big.mdl")

ITEM.hooks.View = function(item, data)
    local client = item.player
    local inventory = client:GetCharacter():GetInventory()
    local items = inventory:GetItemsByUniqueID(item.uniqueID)
    if (#items > 1) then
        table.SortByMember(items, "id", true)
        if (items[1].id != item.id) then
            return false
        end
    end
end
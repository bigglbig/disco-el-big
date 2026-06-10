netstream.Hook("ixRequestCredits", function(client, receiverCardID, amount)
    local clientName = hook.Run("GetCharacterName", client, "ic") or client:GetName()
    local cards = {}

    for _, v in pairs(LocalPlayer():GetCharacter():GetInventory():GetItemsByUniqueID("id_card")) do
        table.insert(cards, {
            text = v:GetName(),
            value = v
        })
    end

    local cardsCount = table.Count(cards)

    if (cardsCount > 1) then
        Derma_Select("Запрос кредитов", clientName.." запрашивает у вас "..amount.." кредит(ов). Какой картой вы желаете расплатиться?",
            cards, "Select ID Card",
            "Подтвердить", function(value, name)
                netstream.Start("ixConfirmOperation", client, receiverCardID, value:GetID(), amount)
            end, "Отказать")
    elseif (cardsCount == 1) then
        Derma_Query(clientName.." запрашивает у вас "..amount.." кредит(ов). Подтвердить транзакцию?", "Запрос кредитов",
        "Подтвердить", function()
            netstream.Start("ixConfirmOperation", client, receiverCardID, cards[1].value:GetID(), amount)
        end, "Отказать")
    else
        LocalPlayer():NotifyLocalized("У вас запросили кредиты, но у вас нет карты чтобы осуществить его.")
    end
end)
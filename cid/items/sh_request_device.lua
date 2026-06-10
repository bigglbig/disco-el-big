
local PLUGIN = PLUGIN

ITEM.name = "Устройство запроса"
ITEM.model = Model("models/gibs/shield_scanner_gib1.mdl")
ITEM.description = "Небольшое круглое устройство с символикой Альянса и одной кнопокй в середине.\n\nПриведены инструкции: приложите идентификационную карту к устройству. После, зажмите кнопку в середине устройства и четко проговорите ваш запрос. Ваше имя и CID автоматически включены в запрос.\nЛожные показания и хулиганство преследуется по закону."
ITEM.price = 20

function ITEM:GetDescription()
    local idCard = ix.item.instances[self:GetData("cardID")]
    return idCard and string.format(self.description.."\n\nПривязано к #%s.", idCard:GetData("cardNumber")) or self.description
end

ITEM.functions.Request = {
    name = "Сделать запрос",
    icon = "icon16/help.png",
    OnClick = function(itemTable)
        Derma_StringRequest("Запросить помощь Гражданской Обороны", "Введите ваш запрос Гражданской Обороне. Ваше имя и CID автоматически включены в запрос.", PLUGIN.text, function(text)
            if (text and string.utf8len(text) > 0) then
                netstream.Start("ixRequest", itemTable:GetID(), text)
			end

			PLUGIN.text = nil
		end, function(text)
			if (text == PLUGIN.text) then
				PLUGIN.text = text
			elseif (text and string.utf8len(text) > 0) then
				PLUGIN.text = text
			else
				PLUGIN.text = nil
			end
		end, "СДЕЛАТЬ ЗАПРОС", "ОТМЕНА")
    end,
    OnRun = function(itemTable)
        return false
    end,
    OnCanRun = function(itemTable)
        if (IsValid(itemTable.entity)) then
            return false
        end

        if (!itemTable:GetData("cardID", false)) then
            return false
        end

        return true
    end
}

ITEM.functions.Bind = {
	name = "Привязать карту",
	icon = "icon16/lock_edit.png",
	OnClick = function(itemTable)
		local cards = {}

		for _, v in pairs(LocalPlayer():GetCharacter():GetInventory():GetItemsByUniqueID("id_card")) do
			table.insert(cards, {
				text = v:GetName(),
				value = v
			})
		end

		local cardsCount = table.Count(cards)
		if (cardsCount > 1) then
			Derma_Select("Привязать карту к УЗ", "Выберите идентификационную карту для привязки:",
				cards, "Выбрать идентификацинную карту",
				"Подтвердить", function(value, name)
					netstream.Start("ixBindRequestDevice", itemTable:GetID(), value:GetID())
				end, "Отмена")
		elseif (cardsCount == 1) then
			Derma_Query("Вы уверены что хотите привязать вашу карту к этому устройству запроса?", "Привязать карту к УЗ",
			"Подтвердить", function()
				netstream.Start("ixBindRequestDevice", itemTable:GetID(), cards[1].value:GetID())
			end, "Отмена")
		else
			LocalPlayer():NotifyLocalized("У вас нет идентификационной карты.")
		end
	end,
	OnRun = function(itemTable)
		return false
	end,
	OnCanRun = function(itemTable)
		if (IsValid(itemTable.entity)) then
			return false
		end

		if (!IsValid(itemTable.player)) then
			return false
		end

		local inventory = itemTable.player:GetCharacter():GetInventory()
		if (!inventory:HasItem("id_card")) then
			return false
		end

		if (!itemTable:GetData("cardID", false)) then
			return true
		end

		if (inventory:GetItemCount("id_card") == 1 and inventory:GetItemByID(itemTable:GetData("cardID"))) then
			return false
		end

		return true
	end
}

if (CLIENT) then
	netstream.Hook("rdMoreThanOneText", function(text)
		PLUGIN.rdText = text
	end)
end

ITEM.name = "Терминал - касса"
ITEM.model = Model("models/willardnetworks/props/posterminal.mdl")
ITEM.description = "Устройство, позволяющая запрашивать кредиты и переводить на карту."

function ITEM:GetDescription()
  local idCard = ix.item.instances[self:GetData("cardID")]
  return idCard and string.format(self.description.."\n\nПривязано к #%s.", idCard:GetData("cardNumber")) or self.description
end

ITEM.functions.RequestCredits = {
  name = "Запросить кредиты",
  icon = "icon16/vcard_add.png",
  OnClick = function(itemTable)
	local client = itemTable.player

	Derma_StringRequest("Запросить кредиты", "Сколько кредитов вы хотите запросить?", itemTable:GetData("lastAmount", 0), function(text)
	  local amount = tonumber(text)

	  if (amount and math.floor(amount) > 0) then
		netstream.Start("ixRequestCredits", itemTable:GetID(), math.floor(amount))
	  else
		client:NotifyLocalized("numNotValid")
	  end
	end)
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
			Derma_Select("Привязать карту к терминалу", "Выберите идентификационную карту для привязки:",
				cards, "Выбрать идентификацинную карту",
				"Подтвердить", function(value, name)
					netstream.Start("ixBindTerminal", itemTable:GetID(), value:GetID())
				end, "Отмена")
		elseif (cardsCount == 1) then
			Derma_Query("Вы уверены что хотите привязать вашу карту к этому терминалу?", "Привязать карту к терминалу",
			"Подтвердить", function()
				netstream.Start("ixBindTerminal", itemTable:GetID(), cards[1].value:GetID())
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

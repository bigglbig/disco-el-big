
local PLUGIN = PLUGIN

PLUGIN.name = "CID"
PLUGIN.author = "Gr4Ss"
PLUGIN.description = "Adds identification cards and credits as digital currency."

CAMI.RegisterPrivilege({
	Name = "Helix - Set Credits",
	MinAccess = "superadmin"
})

ix.char.RegisterVar("cid", {
	field = "cid",
	fieldType = ix.type.string,
	default = nil,
	bNoDisplay = true
})

ix.char.RegisterVar("idCardBackup", {
	field = "idCardBackup",
	default = {},
	bNoDisplay = true,
	bNoNetworking = true
})

ix.char.RegisterVar("idCard", {
	field = "idcard",
	fieldType = ix.type.number,
	default = nil,
	bNoDisplay = true,
	OnSet = function(self, value)
		local client = self:GetPlayer()

		if (IsValid(client)) then
			self.vars.idCard = value

			net.Start("ixCharacterVarChanged")
				net.WriteUInt(self:GetID(), 32)
				net.WriteString("idCard")
				net.WriteType(self.vars.idCard)
			net.Broadcast()
		end
	end,
	OnGet = function(self, default)
		local idCard = self.vars.idCard

		return tonumber(idCard) or 0
	end,
	OnAdjust = function(self, client, data, value, newData)
		newData.idCard = value
	end
})

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

ix.lang.AddTable("english", {
	cmdCharSetCredits = "Set a character's Credits.",
	cmdCharGiveCredits = "Give a character Credits.",
	cmdRequest = "Make a request for assistance to Civil Protection. Will use a ID card-bound request device from your inventory.",

	setCredits = "You have set %s's credits to %s.",
	giveCredits = "You have given %s %s credits.",

	scanning = "Scanning...",
	idNotFound = "ERROR: Biological signature not found.",
	idNoBlank = "ERROR: No blank card inserted.",
	idCardAdded = "SUCCESS: ID Card created.",
	idNotAllowed = "Device does not respond when you try to use it.",

	posBound = "SUCCESS: POS terminal bound to the specified ID Card.",
	posBoundInactiveCard = "ERROR: ID Card is no longer active. Please dispose of inactive card immediately.",

	posRequestSent = "INFO: Performing credit transaction...",
	posRequestExecuting = "INFO: Executing transaction... please wait...",
	posTransactionSuccess = "SUCCESS: Transaction complete.",
	posError = "ERROR: Unexpected error occurred. Transaction was terminated.",
	posBoundCardNotActive = "ERROR: Bound ID Card no longer active. Please dispose of inactive card immediately.",
	posCardNotActive = "ERROR: Used ID Card no longer active. Please dispose of inactive card immediately.",

	numNotValid = "You specified invalid amount of credits!",
	transactionNoMoney = "ERROR: Insufficient credits.",
	transactionOwnChars = "ERROR: You cannot transfer credits between your own characters!",

	rdBound = "SUCCESS: Request Device successfully bound to the specified ID Card.",
	rdError = "ERROR: Unexpected error occurred. Please find a Civil Protection officer to file your request manually.",
	rdMoreThanOne = "You have more than one bound request device, please select in your inventory which one you want to use.",
	rdNoRD = "You do not have a request device, or it is not bound to an ID card!",
	rdFreqLimit = "Please wait at least 10 seconds between requests."
})

ix.lang.AddTable("russian", {
	cmdCharSetCredits = "Установить кредиты персонажа.",
	cmdCharGiveCredits = "Дать кредиты персонажу.",
	cmdRequest = "Совершить запрос гражданской обороны, используя устройство запроса в инвентаре.",

	setCredits = "Вы установили кредиты персонажа %s на %s.",
	giveCredits = "Вы выдали персонажу %s %s кредитов.",

	scanning = "Сканирование...",
	idNotFound = "ОШИБКА: Биологические сигнатуры не найдены.",
	idNoBlank = "ОШИБКА: Не найдено пустой карты.",
	idCardAdded = "УСПЕШНО: Идентификационная карта создана.",
	idNotAllowed = "Устройство не реагирует на ваши запросы.",

	posBound = "УСПЕШНО: Терминал был привязан к идентификационной карте.",
	posBoundInactiveCard = "ОШИБКА: Данная идентификационная карта была деактивирована. Немедленно уничтожьте эту карту.",

	posRequestSent = "ИНФО: Обработка запроса транзакции...",
	posRequestExecuting = "ИНФО: Выполняю транзакцию...",
	posTransactionSuccess = "УСПЕШНО: Транзакция выполнена.",
	posError = "ОШИБКА: Произошла неизвестная ошибка. Транзакция отменена.",
	posBoundCardNotActive = "ОШИБКА: Привязанная идентификационная карта была деактивирована. Немедленно уничтожьте эту карту.",
	posCardNotActive = "ОШИБКА: Использованная идентификационная карта была деактивирована. Немедленно уничтожьте эту карту.",

	numNotValid = "Вы ввели неверное количество кредитов!",
	transactionNoMoney = "ОШИБКА: Недостаточно кредитов.",
	transactionOwnChars = "ОШИБКА: Вы не можете отправлять кредиты своим персонажам!",

	rdBound = "УСПЕШНО: Устройство запроса привязано к идентификационной карте.",
	rdError = "ОШИБКА: Произошла неизвестная ошибка. Пожалуйста, найдите ближайший отряд Гражданской Обороны.",
	rdMoreThanOne = "У вас имеется несколько устройств запроса. Выберите устройство в инвентаре, которое вы хотите использовать.",
	rdNoRD = "У вас нет устройства запроса или оно не привязано к идентификационной карте!",
	rdFreqLimit = "Ожидайте не менее 10 секунд между запросами."
})

ix.command.Add("CharSetCredits", {
	description = "@cmdCharSetMoney",
	privilege = "Установить Кредиты",
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, amount)
		amount = math.Round(amount)

		if (amount <= 0) then
			return "@invalidArg", 2
		end

		target:SetCredits(amount)
		client:NotifyLocalized("setCredits", target:GetName(), tostring(amount))
	end
})

ix.command.Add("CharGiveCredits", {
	description = "@cmdCharGiveCredits",
	privilege = "Установить Кредиты",
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, amount)
		amount = math.Round(amount)

		target:GiveCredits(amount)
		client:NotifyLocalized("giveCredits", target:GetName(), tostring(amount))
	end
})

ix.command.Add("Request", {
	description = "@cmdRequest",
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, text)
		local items = client:GetCharacter():GetInventory():GetItems()
		local requestDevices = {}

		for _, item in pairs(items) do
			if (item.uniqueID == "request_device" and item:GetData("cardID")) then
				requestDevices[#requestDevices + 1] = item
			end
		end

		if (#requestDevices > 1) then
			client:NotifyLocalized("rdMoreThanOne")
			netstream.Start(client, "rdMoreThanOneText", text)
			return
		elseif (#requestDevices == 0) then
			client:NotifyLocalized("rdNoRD")
			return
		end

		local idCard = ix.item.instances[requestDevices[1]:GetData("cardID")]
		if (!idCard) then
			client:NotifyLocalized("rdError")
			return
		end

		if (client.ixNextRequest and client.ixNextRequest > CurTime()) then
			client:NotifyLocalized("rdFreqLimit")
		else
			client.ixNextRequest = CurTime() + 10
		end

		idCard:LoadOwnerGenericData(PLUGIN.RequestSuccess, PLUGIN.RequestError, client, text)
	end
})

ix.command.Add("WithdrawCredit", {
	description = "Withdraws credits from the specified character's active CID card.",
	OnCheckAccess = function(self, client)
		return client:GetCharacter() and client:GetCharacter():GetFaction() == FACTION_ADMIN
	end,
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, amount)
		amount = math.Round(amount)

		if (amount <= 0) then
			return "@invalidArg", 2
		end

		if (target:HasCredits(amount)) then
			local receiverCardId = client:GetCharacter():GetIdCard()
			local senderCardId = target:GetIdCard()

			PLUGIN:CreditTransaction(receiverCardId, senderCardId, amount, target, client)

			target:GetPlayer():Notify("Городская Администрация вывела "..amount.." кредитов с вашей карты.")
		else
			client:Notify("Персонаж не имеет такое количество кредитов.")
		end
	end
})

do
	local CLASS = {}
	CLASS.color = Color(175, 125, 100)
	CLASS.format = "%s, #%s запрашивает \"%s\""

	function CLASS:CanHear(speaker, listener)
		return listener == speaker or listener:IsCombine() or listener:Team() == FACTION_ADMIN
	end

	function CLASS:OnChatAdd(speaker, text, aonymous, data)
		chat.AddText(self.color, string.format(self.format, data.name, data.cid, text))
	end

	ix.chat.Register("request", CLASS)
end

if (ix.plugin.list.doors) then
	-- Overriding Helix door plugin command to use credits instead
	ix.command.Add("DoorBuy", {
		description = "@cmdDoorBuy",
		OnRun = function(self, client, arguments)
			-- Get the entity 96 units infront of the player.
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local trace = util.TraceLine(data)
			local entity = trace.Entity

			-- Check if the entity is a valid door.
			if (IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled")) then
				if (!entity:GetNetVar("ownable") or entity:GetNetVar("faction") or entity:GetNetVar("class")) then
					return "@dNotAllowedToOwn"
				end

				if (IsValid(entity:GetDTEntity(0))) then
					return "@dOwnedBy", entity:GetDTEntity(0):Name()
				end

				entity = IsValid(entity.ixParent) and entity.ixParent or entity

				-- Get the price that the door is bought for.
				local price = entity:GetNetVar("price", ix.config.Get("doorCost"))
				local character = client:GetCharacter()

				-- Check if the player can actually afford it.
				if (character:HasCredits(price)) then
					-- Set the door to be owned by this player.
					entity:SetDTEntity(0, client)
					entity.ixAccess = {
						[client] = DOOR_OWNER
					}

					ix.plugin.list.doors:CallOnDoorChildren(entity, function(child)
						child:SetDTEntity(0, client)
					end)

					local doors = character:GetVar("doors") or {}
						doors[#doors + 1] = entity
					character:SetVar("doors", doors, true)

					-- Take their money and notify them.
					character:TakeCredits(price)
					hook.Run("OnPlayerPurchaseDoor", client, entity, true, ix.plugin.list.doors.CallOnDoorChildren)

					ix.log.Add(client, "buydoor")
					return "@dPurchased", price..(price == 1 and " credit" or " credits")
				else
					-- Otherwise tell them they can not.
					return "@canNotAfford"
				end
			else
				-- Tell the player the door isn't valid.
				return "@dNotValid"
			end
		end
	})

	ix.command.Add("DoorSell", {
		description = "@cmdDoorSell",
		OnRun = function(self, client, arguments)
			-- Get the entity 96 units infront of the player.
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local trace = util.TraceLine(data)
			local entity = trace.Entity

			-- Check if the entity is a valid door.
			if (IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled")) then
				-- Check if the player owners the door.
				if (client == entity:GetDTEntity(0)) then
					entity = IsValid(entity.ixParent) and entity.ixParent or entity

					-- Get the price that the door is sold for.
					local price = math.Round(entity:GetNetVar("price", ix.config.Get("doorCost")) * ix.config.Get("doorSellRatio"))
					local character = client:GetCharacter()

					-- Remove old door information.
					entity:RemoveDoorAccessData()

					local doors = character:GetVar("doors") or {}

					for k, v in ipairs(doors) do
						if (v == entity) then
							table.remove(doors, k)
						end
					end

					character:SetVar("doors", doors, true)

					-- Take their money and notify them.
					character:GiveCredits(price)
					hook.Run("OnPlayerPurchaseDoor", client, entity, false, PLUGIN.CallOnDoorChildren)

					ix.log.Add(client, "selldoor")
					return "@dSold", price..(price == 1 and " credit" or " credits")
				else
					-- Otherwise tell them they can not.
					return "@notOwner"
				end
			else
				-- Tell the player the door isn't valid.
				return "@dNotValid"
			end
		end
	})
end
local PLUGIN = PLUGIN

function PLUGIN.RequestSuccess(card, genericdata, client, text)
	local location = client:GetArea()
	if location == "" then
		location = "НЕИЗВЕСТНАЯ ЛОКАЦИЯ"
	end

	if !card:GetData("active", false) then
		Schema:AddImportantCombineDisplayMessage("ДЕАКТИВИРОВАННАЯ КАРТА БЫЛА ИСПОЛЬЗОВАНА НА 10-20 "..location)
		client:NotifyLocalized("posBoundCardNotActive")
		return
	end

	if genericdata.anticitizen or genericdata.bol then
		Schema:AddImportantCombineDisplayMessage(genericdata.anticitizen and "НАРУШИТЕЛЬ ИСПОЛЬЗОВАЛ УСТРОЙСТВО ЗАПРОСА НА 10-20 " or "РАЗЫСКИВАЕМОЕ ЛИЦО ИСПОЛЬЗОВАЛО УСТРОЙСТВА ЗАПРОСА НА 10-20 "..location, genericdata.anticitizen and Color(255, 0, 0, 255) or Color(255, 255, 0, 255))
	end

	local name = card:GetData("name", "Nobody")
	local cid = card:GetData("cid", "00000")

	ix.chat.Send(client, "request", text, nil, nil, {
		name = name,
		cid = cid
	})

	ix.chat.Send(client, "request_eavesdrop", text)

	Schema:AddImportantCombineDisplayMessage(string.format("%s, %s ЗАПРОС НА 10-20 %s", name, cid, location))
end

function PLUGIN.RequestError(card, client, text)
	client:NotifyLocalized("rdError")
end

function PLUGIN:CreditTransaction(receiverCardId, senderCardId, amount, target, client)
	amount = amount or 0

	if amount <= 0 then
		return false
	end

	local receiverCard = ix.item.instances[receiverCardId]
	local senderCard = ix.item.instances[senderCardId]

	if !receiverCard or !senderCard then
		return false
	end

	if !senderCard:HasCredits(amount) then
		return false
	end

	receiverCard:GiveCredits(amount)
	senderCard:TakeCredits(amount)

	return true
end

netstream.Hook("ixBindTerminal", function(client, itemID, cardID)
	local character = client:GetCharacter()

	if !character then
		return
	end
	
	local posDevice = character:GetInventory():GetItemByID(itemID)
	local card = character:GetInventory():GetItemByID(cardID)

	if !card or !posDevice then
		return
	end

	--if posDevice:GetData("cardID", false) then
	--	return
	--end

	if !card:GetData("active", false) then
		client:NotifyLocalized("posBoundInactiveCard")
		return
	end

	posDevice:SetData("cardID", cardID)

	client:NotifyLocalized("posBound")
end)

ix.log.AddType("creditsRequest", function(client, recvname, recvcid, amount, target)
	return string.format("%s (%s #%s) запросил %s кредит(ов) у %s.", client:GetName(), recvname, recvcid, amount, target)
end)

ix.log.AddType("creditsRequestSent", function(client, recvname, recvcid, amount, target, sendername, sendercid)
	return string.format("%s (%s #%s) отправил %s кредит(ов)  %s (%s #%s) (запрос).", client:GetName(), recvname, recvcid, amount, target, sendername, sendercid)
end)

netstream.Hook("ixRequestCredits", function(client, itemID, amount)
	local character = client:GetCharacter()

	if !character then
		return
	end
	
	local posDevice = character:GetInventory():GetItemByID(itemID)

	if !posDevice then
		return
	end

	if !posDevice:GetData("cardID", false) then
		return
	end

	if !amount or math.floor(amount) <= 0 then
		client:NotifyLocalized("numNotValid")
		return
	end

	local cardID = posDevice:GetData("cardID", false)
	local card = ix.item.instances[cardID]

	if !card then
		client:NotifyLocalized("posError")
		return
	end

	if !card:GetData("active", false) then
		client:NotifyLocalized("posBoundCardNotActive")
		return
	end

	local target = client:GetEyeTraceNoCursor().Entity

	if !target or !target:IsPlayer() then
		target = client
	end

	if IsValid(target) then
		client.ixTransaction = target

		client:NotifyLocalized("posRequestSent")

		netstream.Start(target, "ixRequestCredits", client, cardID, amount)

		ix.log.Add(client, "creditsRequest", card:GetData("name", "Н/Д"), card:GetData("cid", "Н/Д"), amount, target:GetName())
	end
end)

netstream.Hook("ixConfirmOperation", function(client, user, receiverCardID, cardID, amount)
	local receiverCard = ix.item.instances[receiverCardID]
	local senderCard = ix.item.instances[cardID]

	if user.ixTransaction != client then
		return
	end

	if !receiverCard or !senderCard then
		return
	end

	amount = amount and math.floor(amount) or 0

	if !amount or amount <= 0 then
		client:NotifyLocalized("numNotValid")
		return
	end

	if !senderCard:HasCredits(amount) then
		client:NotifyLocalized("transactionNoMoney")
		user:NotifyLocalized("transactionNoMoney")
		return
	end

	local ritemPlayerID = receiverCard:GetPlayerID()
	local ritemCharacterID = receiverCard:GetCharacterID()
	local sitemPlayerID = senderCard:GetPlayerID()
	local sitemCharacterID = senderCard:GetCharacterID()

	if ritemPlayerID == sitemPlayerID and ritemCharacterID != sitemCharacterID then
		client:NotifyLocalized("transactionOwnChars")
		user:NotifyLocalized("transactionOwnChars")
		return
	end

	if !receiverCard:GetData("active", false) then
		client:NotifyLocalized("posBoundCardNotActive")
		user:NotifyLocalized("posBoundCardNotActive")
		return
	end

	if !senderCard:GetData("active", false) then
		client:NotifyLocalized("posCardNotActive")
		user:NotifyLocalized("posCardNotActive")
		return
	end

	local combineutils = ix.plugin.list["combineutilities"]

	timer.Simple(1, function()
		if !IsValid(user) or !IsValid(client) then
			return
		end

		client:NotifyLocalized("posRequestExecuting")
		user:NotifyLocalized("posRequestExecuting")

		timer.Simple(2, function()
			if !IsValid(client) then
				return
			end

			if PLUGIN:CreditTransaction(receiverCardID, cardID, amount, user, client) then
				client:NotifyLocalized("posTransactionSuccess")
				user:NotifyLocalized("posTransactionSuccess")

				local senderName, senderCID = senderCard:GetData("name", "Н/Д"), senderCard:GetData("cid", "Н/Д")
				local recvName, recvCID = receiverCard:GetData("name", "Н/Д"), receiverCard:GetData("cid", "Н/Д")

				ix.log.Add(client, "creditsRequestSent", recvName, recvCID, amount, user:GetName(), senderName, senderCID)
				
				combineutils:DatafileFetchFields(receiverCard:GetData("owner"), function(files)
					combineutils:DatafileAddLog(files.datafilelogs, files.genericdata, "ТЕРМИНАЛ - КАССА", nil, string.format("ПОЛУЧЕНО %s КРЕДИТ(ОВ) ОТ %s, #%s", amount, senderName, senderCID))
				end)

				combineutils:DatafileFetchFields(senderCard:GetData("owner"), function(files)
					combineutils:DatafileAddLog(files.datafilelogs, files.genericdata, "ТЕРМИНАЛ - КАССА", nil, string.format("ОТПРАВЛЕНО %s КРЕДИТ(ОВ) %s, #%s", amount, recvName, recvCID))
				end)
			else
				client:NotifyLocalized("posError")
				user:NotifyLocalized("posError")
			end

			user.ixTransaction = nil
		end)
	end)
end)

netstream.Hook("ixRequest", function(client, itemID, text)
	local character = client:GetCharacter()

	if !character then
		return
	end

	if !text or string.utf8len(text) <= 0 then
		return
	end

	local requestDevice = character:GetInventory():GetItemByID(itemID)

	if !requestDevice then
		return
	end

	if !requestDevice:GetData("cardID", false) then
		return
	end

	local card = ix.item.instances[requestDevice:GetData("cardID", false)]

	if !card then
		client:NotifyLocalized("rdError")
		return
	end

	if client.ixNextRequest and client.ixNextRequest > CurTime() then
		client:NotifyLocalized("rdFreqLimit")
		return
	else
		client.ixNextRequest = CurTime() + 10
	end

	card:LoadOwnerGenericData(PLUGIN.RequestSuccess, PLUGIN.RequestError, client, text)
end)

netstream.Hook("ixBindRequestDevice", function(client, itemID, cardID)
	local character = client:GetCharacter()

	if !character then
		return
	end
	
	local requestDevice = character:GetInventory():GetItemByID(itemID)
	local card = character:GetInventory():GetItemByID(cardID)

	if !card or !requestDevice then
		return
	end

	if requestDevice:GetData("cardID", false) then
		return
	end

	if !card:GetData("active", false) then
		client:NotifyLocalized("posBoundInactiveCard")
		return
	end

	requestDevice:SetData("cardID", cardID)

	client:NotifyLocalized("rdBound")
end)


--netstream.Hook("ixRequestCredits", function(client, receiverCardID, amount)
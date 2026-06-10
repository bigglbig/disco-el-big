
ITEM.name = "Устройство заполнения идентификационных карт"
ITEM.model = Model("models/props_lab/reciever01d.mdl")
ITEM.description = "Устройство, используемое для привязки идентификационных карт к гражданину."

ITEM.functions.CreateIDTarget = {
	name = "Создать идентификационную карту для цели.",
	icon = "icon16/vcard_add.png",
	OnRun = function(itemTable)
		local client = itemTable.player

		if (itemTable:CheckAccess(client, itemTable) == false) then
			client:EmitSound("buttons/combine_button_locked.wav", 60, 100, 0.5)
			return false
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity
			
		if (IsValid(target) and target:IsPlayer() and target:GetCharacter()) then
			client:SetAction("@scanning", 5)
			client:EmitSound("buttons/button18.wav", 60, 100, 0.5)
			client:DoStaredAction(target, function()
				itemTable:CreateIDCard(client, target)
			end, 5, function()
				client:SetAction()
				client:EmitSound("buttons/combine_button_locked.wav", 60, 100, 0.5)
			end)
		else
			client:NotifyLocalized("plyNotValid")
		end

		return false
	end,
	OnCanRun = function(itemTable)
		return !IsValid(itemTable.entity)
	end
}

ITEM.functions.CreateIDSelf = {
	name = "Создать идентификационную карту для себя.",
	icon = "icon16/vcard.png",
	OnRun = function(itemTable)
		local client = itemTable.player
		if (itemTable:CheckAccess(client, itemTable) == false) then
			client:EmitSound("buttons/combine_button_locked.wav", 60, 100, 0.5)
			return false
		end

		client:SetAction("@scanning", 5, function()
			itemTable:CreateIDCard(client, client)
		end)
		client:EmitSound("buttons/button18.wav", 60, 100, 0.5)
		return false
	end
}

function ITEM:CreateIDCard(client, target)
	local character = target:GetCharacter()
	local cid = character:GetCid()

	if (!cid) then
		client:NotifyLocalized("idNotFound")
		client:EmitSound("buttons/combine_button_locked.wav", 60, 100, 0.5)
		return
	end

	local inventory = client:GetCharacter():GetInventory()
	local blankCard = inventory:HasItem("id_card_blank")

	if (!blankCard) then
		client:NotifyLocalized("idNoBlank")
		client:EmitSound("buttons/combine_button_locked.wav", 60, 100, 0.5)
		return
	end

	blankCard:Remove()
	character:CreateIDCard()
	client:EmitSound("buttons/button4.wav", 60, 100, 0.5)
	client:NotifyLocalized("idCardAdded")
end

function ITEM:CheckAccess(client, itemTable)
	if (!client:IsCombine() and client:Team() != FACTION_ADMIN and client:Team() != FACTION_SERVERADMIN) then
		client:NotifyLocalized("idNotAllowed")
		return false
	end
end

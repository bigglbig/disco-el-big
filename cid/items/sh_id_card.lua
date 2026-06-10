
ITEM.name = "Идентификационная карта #%s"
ITEM.model = Model("models/bybig/idcard.mdl")
ITEM.description = "Идентификационная карта гражданина, привязанная к %s, CID #%s.\n\nНомер карты: %s\nОписание персонажа:\n%s.\n\nДанная карта является собственностью Найт-Сити. Незаконная траспортировка, предоставление ложных данных преследуется по закону. Если эта карта не принадлежит вам, немедленно сдайте ее сотрудникам NCPD."

ITEM.iconCam = {
	pos = Vector(0, 0, 10),
	ang = Angle(90, 90, 0),
	fov = 45,
}

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("active")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

function ITEM:GetName()
	return string.format(self.name, self:GetData("cid", "00000"))
end

-- It's also possible to use ITEM.KeepOnDeath = true
function ITEM:KeepOnDeath(client)
	return self:GetData("owner") == client:GetCharacter():GetID() and self:GetData("active")
end

function ITEM:GetDescription()
	return string.format(self.description,
		self:GetData("name", "Nobody"),
		self:GetData("cid", "00000"),
		self:GetData("cardNumber", "00-0000-0000-00"),
		self:GetData("geneticDesc", "Н/Д | Н/Д | Н/Д ГЛАЗА | Н/Д ВОЛОСЫ"))
end

local prime = 9999999787 -- prime % 4 = 3! DO NOT CHANGE EVER
local offset = 100000 -- slightly larger than sqrt(prime) is ok. DO NOT CHANGE EVER
local block = 100000000
local function generateCardNumber(id)
	id = (id + offset) % prime

	local cardNum = 0

	for _ = 1, math.floor(id/block) do
		cardNum = (cardNum + (id * block) % prime) % prime
	end

	cardNum = (cardNum + (id * (id % block) % prime)) % prime

	if (2 * id < prime) then
		return cardNum
	else
		return prime - cardNum
	end
end

function ITEM:GetCredits()
	return self:GetData("credits", 0)
end

function ITEM:HasCredits(amount)
	return amount <= self:GetData("credits", 0)
end

if (SERVER) then
	function ITEM:SetCredits(amount)
		self:SetData("credits", math.floor(amount))

		return true
	end

	function ITEM:GiveCredits(amount)
		if (amount < 0 and !self:HasCredits(math.abs(amount))) then
			return false
		end
		return self:SetCredits(amount + self:GetCredits())
	end

	function ITEM:TakeCredits(amount)
		if (amount > 0 and !self:HasCredits(amount)) then
			return false
		end
		return self:SetCredits(self:GetCredits() - amount)
	end

	function ITEM:OnInstanced()
		local cardNum = Schema:ZeroNumber(generateCardNumber(self:GetID()), 10)
		self:SetData("cardNumber", string.utf8sub(cardNum, 1, 2).."-"..string.utf8sub(cardNum, 3, 6).."-"..string.utf8sub(cardNum, 7, 10)..
			"-"..Schema:ZeroNumber(cardNum % 97, 2))
	end

	function ITEM:TransferData(newCard, wipe)
		newCard:SetData("credits", self:GetData("credits", 0))
		newCard:SetData("nextRationTime", self:GetData("nextRationTime", 0))

		if (wipe) then
			self:SetData("active", false)
			self:SetData("credits", 0)
			self:SetData("nextRationTime", 0)
		end
	end

	function ITEM:OnRemoved()
		if (self:GetData("active") != false) then
			local ownerId = self:GetData("owner")
			local data = {credits = self:GetData("credits", 0), ration = self:GetData("nextRationTime", 0)}
			if (ix.char.loaded[ownerId]) then
				ix.char.loaded[ownerId]:SetIdCardBackup(data)
				ix.char.loaded[ownerId]:SetIdCard(nil)
			end

			local updateQuery = mysql:Update("ix_characters_data")
				updateQuery:Update("data", util.TableToJSON(data))
				updateQuery:Where("id", ownerId)
				updateQuery:Where("key", "idCardBackup")
			updateQuery:Execute()

			local idCardQuery = mysql:Update("ix_characters")
				idCardQuery:Update("idCard", "NULL")
				idCardQuery:Where("id", ownerId)
				idCardQuery:Where("schema", Schema and Schema.folder or "helix")
			idCardQuery:Execute()

			self:SetData("active", false)
		end
	end

	function ITEM:LoadOwnerGenericData(callback, error, ...)
		if (!callback) then return end

		local arg = {...}
		local queryObj = mysql:Select("ix_characters_data")
			queryObj:Where("id", self:GetData("owner", 0))
			queryObj:Where("key", "genericdata")
			queryObj:Select("data")
			queryObj:Callback(function(result)
				if (!istable(result) or !result[1]) then
					if (error) then
						error(self, unpack(arg))
					end
				else
					callback(self, util.JSONToTable(result[1].data or ""), unpack(arg))
				end
			end)
		queryObj:Execute()
	end

	netstream.Hook("ixSetIDCardCredits", function(client, itemID, amount)
		if (!CAMI.PlayerHasAccess(client, "Helix - Set Credits")) then
			return
		end

		ix.item.instances[itemID]:SetCredits(amount)
	end)
end

ITEM.functions.SetCredits = {
	name = "Установить кредиты",
	icon = "icon16/vcard_add.png",
	OnClick = function(itemTable)
		local client = itemTable.player
		Derma_StringRequest("Установить кредиты", "На какую сумму вы хотите установить кредиты?", itemTable:GetData("credits", 0), function(text)
			local amount = tonumber(text)

			if (amount and amount >= 0) then
				netstream.Start("ixSetIDCardCredits", itemTable:GetID(), math.floor(amount))
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

		if (!CAMI.PlayerHasAccess(itemTable.player, "Helix - Set Credits")) then
			return false
		end

		if (!itemTable:GetData("active", false)) then
			return false
		end

		return true
	end
}
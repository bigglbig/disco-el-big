ITEM.name = "Bodygroup Clothing"
ITEM.model = Model("models/props_c17/BriefCase001a.mdl")
ITEM.description = "Обычный предмет одежды."

-- Slot names translation
local SLOT_NAMES = {
	["Голова"] = "Голова",
	["Торс"] = "Торс",
	["Ноги"] = "Ноги",
	["Глаза"] = "Глаза",
	["Руки"] = "Руки",
	["Позвоночник"] = "Позвоночник",
	["Костный мозг"] = "Костный мозг",
	["Сердце"] = "Сердце",
	["Лёгкие"] = "Лёгкие",
	["Кожа"] = "Кожа"
}

-- Skill names translation
local SKILL_NAMES = {
	["crafting"] = "Ремесло",
	["cooking"] = "Кулинария",
	["guns"] = "Оружие",
	["bartering"] = "Торговля",
	["medicine"] = "Медицина",
	["speed"] = "Скорость",
	["vort"] = "Вортэссенция",
	["melee"] = "Ближний бой",
	["netrunning"] = "Нетраннинг"
}

-- Attribute names translation
local ATTRIBUTE_NAMES = {
	["strength"] = "Сила",
	["perception"] = "Восприятие",
	["agility"] = "Ловкость",
	["intelligence"] = "Интеллект"
}

-- Tier names
local TIER_NAMES = {
	[1] = "I - Легендарный",
	[2] = "II - Эпический",
	[3] = "III - Редкий",
	[4] = "IV - Обычный"
}

function ITEM:GetDescription()
	if (!self.requiresNPC) then
		return self.description or "Обычный предмет одежды."
	end

	local description = {self.description or "Имплант."}
	return table.concat(description, "")
end

function ITEM:GetBaseInfo()
	if (!self.requiresNPC) then
		return ""
	end

	local baseInfo = {}

	if (self.tier) then
		baseInfo[#baseInfo + 1] = "Тир: "
		baseInfo[#baseInfo + 1] = TIER_NAMES[self.tier] or ("Тир " .. tostring(self.tier))
	end

	if (self.outfitCategory) then
		if (#baseInfo > 0) then
			baseInfo[#baseInfo + 1] = "\n"
		end
		baseInfo[#baseInfo + 1] = "Слот: "
		baseInfo[#baseInfo + 1] = SLOT_NAMES[self.outfitCategory] or self.outfitCategory
	end

	if (self.cyberpsychosis) then
		baseInfo[#baseInfo + 1] = "\nКиберпсихоз: "
		baseInfo[#baseInfo + 1] = tostring(self.cyberpsychosis)
		baseInfo[#baseInfo + 1] = "%"
	end

	if (self.netrunningradius) then
		baseInfo[#baseInfo + 1] = "\nРадиус взлома: "
		baseInfo[#baseInfo + 1] = tostring(self.netrunningradius)
		baseInfo[#baseInfo + 1] = " м"
	end

	return table.concat(baseInfo, "")
end

function ITEM:GetExtendedInfo()
	if (!self.requiresNPC) then
		return ""
	end

	local extendedInfo = {}
	local hasBonuses = false

	if (self.skillBoosts) then
		for skillID, boost in pairs(self.skillBoosts) do
			if (SKILL_NAMES[skillID]) then
				if (!hasBonuses) then
					extendedInfo[#extendedInfo + 1] = "Бонусы:\n"
					hasBonuses = true
				end
				extendedInfo[#extendedInfo + 1] = "  "
				extendedInfo[#extendedInfo + 1] = SKILL_NAMES[skillID]
				extendedInfo[#extendedInfo + 1] = ": +"
				extendedInfo[#extendedInfo + 1] = tostring(boost)
				extendedInfo[#extendedInfo + 1] = "\n"
			end
		end
	end

	if (self.attributeBoosts) then
		for attrID, boost in pairs(self.attributeBoosts) do
			if (ATTRIBUTE_NAMES[attrID]) then
				if (!hasBonuses) then
					extendedInfo[#extendedInfo + 1] = "Бонусы:\n"
					hasBonuses = true
				end
				extendedInfo[#extendedInfo + 1] = "  "
				extendedInfo[#extendedInfo + 1] = ATTRIBUTE_NAMES[attrID]
				extendedInfo[#extendedInfo + 1] = ": "
				if (boost >= 0) then
					extendedInfo[#extendedInfo + 1] = "+"
				end
				extendedInfo[#extendedInfo + 1] = tostring(boost)
				extendedInfo[#extendedInfo + 1] = "\n"
			end
		end
	end

	if (self.iceBlockBonus) then
		if (!hasBonuses) then
			extendedInfo[#extendedInfo + 1] = "Бонусы:\n"
			hasBonuses = true
		else
			if (extendedInfo[#extendedInfo] == "\n") then
				extendedInfo[#extendedInfo] = nil
			end
		end
		extendedInfo[#extendedInfo + 1] = "  ICE блок: +"
		extendedInfo[#extendedInfo + 1] = tostring(math.floor(self.iceBlockBonus * 100))
		extendedInfo[#extendedInfo + 1] = "%"
	end

	return table.concat(extendedInfo, "")
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("equip")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		if (self.maxArmor) then
			local panel = tooltip:AddRowAfter("name", "armor")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("Защита: " .. (self:GetData("equip") and LocalPlayer():Armor() or self:GetData("armor", self.maxArmor)))
			panel:SizeToContents()
		end

		if (self.requiresNPC) then
			local baseInfo = self:GetBaseInfo()
			if (baseInfo and baseInfo != "") then
				local panel = tooltip:AddRowAfter("description", "implantBase")
				panel:SetBackgroundColor(Color(70, 130, 180))
				panel:SetText(baseInfo)
				panel:SizeToContents()
			end

			local extendedInfo = self:GetExtendedInfo()
			if (extendedInfo and extendedInfo != "") then
				local panel = tooltip:AddRowAfter("implantBase", "implantExtended")
				panel:SetBackgroundColor(Color(60, 179, 113))
				panel:SetText(extendedInfo)
				panel:SizeToContents()
			end
		end
	end
end

function ITEM:RemoveOutfit(client)
	self:SetData("equip", false)
	if (self.maxArmor) then
		self:SetData("armor", math.Clamp(client:Armor(), 0, self.maxArmor))
		client:SetArmor(0)
	end

	for k in pairs(self.bodyGroups) do
		local index = client:FindBodygroupByName(k)
		local char = client:GetCharacter()
		local groups = char:GetData("groups", {})

		if (index > -1) then
			groups[index] = 0
			char:SetData("groups", groups)
			client:SetBodygroup(index, 0)

			netstream.Start(client, "ItemEquipBodygroups", index, 0)
		end
	end
end

ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item:RemoveOutfit(item:GetOwner())
	end
end)

ITEM.functions.Repair = {
	name = "Ремонт",
	tip = "repairTip",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		item:Repair(item.player)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return (item.maxArmor != nil and item:GetData("equip") == false and !IsValid(item.entity) and IsValid(client) and client:GetCharacter():GetInventory():HasItem("tool_repair") and item:GetData("armor") < item.maxArmor)
	end
}

ITEM.functions.EquipUn = {
	name = "Снять",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		if (item.player) then
			item:RemoveOutfit(item.player)

			if item.OnUnEquip then
				item:OnUnEquip()
			end
		else
			item:SetData("equip", false)

			if item.OnUnEquip then
				item:OnUnEquip()
			end
		end
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		if item.requiresNPC then
			return false
		end

		if item.requiresNPC then
			local character = client:GetCharacter()
			if character then
				local cyberValue = character:GetCyberpsychosis()
				if cyberValue >= 75 then
					client:Notify("Невозможно снять имплант при критическом уровне киберпсихоза!")
					return false
				end
			end
		end

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item:CanUnequipOutfit()
	end
}

ITEM.functions.Equip = {
	name = "Одеть",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item, creationClient)
		local client = item.player or creationClient
		local char = client:GetCharacter()
		local items = char:GetInventory():GetItems()
		local groups = char:GetData("groups", {})

		if (item.maxArmor) then
			client:SetArmor(item:GetData("armor", item.maxArmor))
		end

		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]

				if (v.outfitCategory == item.outfitCategory and itemTable:GetData("equip")) then
					client:NotifyLocalized(item.equippedNotify or "outfitAlreadyEquipped")
					return false
				end
			end
		end

		item:SetData("equip", true)

		if (item.bodyGroups) then
			for k, value in pairs(item.bodyGroups) do
				local index = client:FindBodygroupByName(k)

				if (index > -1) then
					groups[index] = value
					char:SetData("groups", groups)
					client:SetBodygroup(index, value)

					netstream.Start(client, "ItemEquipBodygroups", index, value)

					if item.OnEquip then
						item:OnEquip(client)
					end
				end
			end
		end

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		if item.requiresNPC then
			return false
		end

		if item.factionList and !table.HasValue(item.factionList, client:GetCharacter():GetFaction()) then
			client:NotifyLocalized("Этот предмет одежды не для вашей фракции!")
			return false
		end

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item:CanEquipOutfit()
	end
}

function ITEM:Repair(client, amount)
	amount = amount or self.maxArmor
	local repairItem = client:GetCharacter():GetInventory():HasItem("tool_repair")

	if (repairItem) then
		repairItem:Remove()
		self:SetData("armor", math.Clamp(self:GetData("armor") + amount, 0, self.maxArmor))
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnInstanced()
	if (self.maxArmor) then
		self:SetData("armor", self.maxArmor)
	end
end

function ITEM:OnRemoved()
	if (self.invID != 0 and self:GetData("equip")) then
		self.player = self:GetOwner()
		self:RemoveOutfit(self.player)

		if self.OnUnEquip then
			self:OnUnEquip()
		end

		self.player = nil
	end
end

function ITEM:OnLoadout()
	if (self.maxArmor and self:GetData("equip")) then
		self.player:SetArmor(self:GetData("armor", self.maxArmor))
	end
end

function ITEM:OnSave()
	if (self.maxArmor and self:GetData("equip")) then
		self:SetData("armor", math.Clamp(self.player:Armor(), 0, self.maxArmor))
	end
end

function ITEM:CanEquipOutfit()
	if (self.maxArmor) then
		local bgItems = self.player:GetCharacter():GetInventory():GetItemsByBase("base_bgclothes", true)
		for _, v in ipairs(bgItems) do
			if (v:GetData("equip") and v.maxArmor) then
				return false
			end
		end
	end

	return true
end

function ITEM:CanUnequipOutfit()
	return true
end

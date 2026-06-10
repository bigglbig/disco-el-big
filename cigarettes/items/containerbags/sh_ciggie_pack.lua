--[[
| This file was obtained through the combined efforts
| of Madbluntz & Plymouth Antiquarian Society.
|
| Credits: lifestorm, Gregory Wayne Rossel JR.,
| 	Maloy, DrPepper10 @ RIP, Atle!
|
| Visit for more: https://plymouth.thetwilightzone.ru/
--]]


ITEM.name = "Пачка сигарет"
ITEM.model = Model("models/hls/alyxports/cigarette_pack.mdl")
ITEM.description = "Сигаретная пачка, вмещающая ровно 8 сигарет."
ITEM.allowNesting = true
ITEM.restriction = {"cigarette", "lighter"}
ITEM.noEquip = true
ITEM.category = "Сигареты"

function ITEM:GetName()
	return self:GetData("relabeled", false) and "Пачка сигарет с новой этикеткой" or "Пачка сигарет Удачный Выстрел"
end

function ITEM:GetDescription()
	return self:GetData("relabeled", false) and "Новая маркированная сигаретная пачка, вмещающая ровно 8 сигарет." or "A Combine-issued cigarette pack capable of holding precisely 8 cigarettes."
end

function ITEM:GetModel()
	return self:GetData("relabeled", false) and "models/hls/alyxports/cigarette_pack.mdl" or "models/hls/alyxports/cigarette_pack.mdl"
end

function ITEM:OnBagInitialized(inventory)
	inventory:Add("Сигарет", 8)
end

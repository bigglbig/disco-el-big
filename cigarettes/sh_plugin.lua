--[[
| This file was obtained through the combined efforts
| of Madbluntz & Plymouth Antiquarian Society.
|
| Credits: lifestorm, Gregory Wayne Rossel JR.,
| 	Maloy, DrPepper10 @ RIP, Atle!
|
| Visit for more: https://plymouth.thetwilightzone.ru/
--]]

local ix = ix


local PLUGIN = PLUGIN

PLUGIN.name = "Cigarettes"
PLUGIN.author = "Fruity"
PLUGIN.description = "Adds non PAC3 cigarettes."

ix.util.Include("sv_plugin.lua")

PLUGIN.allowedModels = {
    [1] = "models/ulman/",
	[2] = "models/bybig/"
}

if (CLIENT) then
	ix.option.Add("firstPersonCigarette", ix.type.bool, true, {
		category = "Сигареты"
	})
end

ix.lang.AddTable("english", {
	optFirstPersonCigarette = "Show Cigarette in First Person",
	optdFirstPersonCigarette = "Toggles whether you want the cigarette to show in first person or not."
})

ix.lang.AddTable("spanish", {
	optFirstPersonCigarette = "Mostrar el Cigarro en Primera Persona",
	optdFirstPersonCigarette = "Alterna si quieres que el cigarro se muestre en primera persona o no."
})

ix.lang.AddTable("russian", {
	optFirstPersonCigarette = "Показать сигарету от первого лица",
	optdFirstPersonCigarette = "Переключите, хотите ли вы, чтобы сигара была показана от первого лица или нет."
})
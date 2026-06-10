--[[
| This file was obtained through the combined efforts
| of Madbluntz & Plymouth Antiquarian Society.
|
| Credits: lifestorm, Gregory Wayne Rossel JR.,
| 	Maloy, DrPepper10 @ RIP, Atle!
|
| Visit for more: https://plymouth.thetwilightzone.ru/
--]]

local PLUGIN = PLUGIN

PLUGIN.name = "Better Lethal Gas"
PLUGIN.author = "Asimo but mainly Gr4ss x big.txt"
PLUGIN.description = "По сути, это разбитая копия плагина Better Gas. Огромное спасибо Gr4ss за то, что он придумал 90% всего этого."

ix.util.Include("meta/sh_player.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

if (SERVER) then
    PLUGIN.timerLethalGasChangeCallback = function(_, newVal)
        for k, v in ipairs(player.GetAll()) do
            local uniqueID = "ixLethalGas"..v:SteamID64()
            if (timer.Exists(uniqueID)) then
                timer.Adjust(uniqueID, newVal)
            end
        end
    end
end

ix.config.Add("LethalGasDamageTimer", 5, "Как часто, в секундах, должен срабатывать таймер урона при нахождении в смертоносном газе.", PLUGIN.timerLethalGasChangeCallback, {
    data = {min = 1, max = 10, decimals = 0},
    category = "LethalGas"
})
ix.config.Add("LethalGasDamage", 5, "Сколько должен составлять стандартный ущерб от газа?", nil, {
    data = {min = 1, max = 100, decimals = 1},
    category = "LethalGas"
})
ix.config.Add("GasVorts", true, "Должен ли смертоносный газ наносить урон тем фракциям, у которых есть иммунитет к нему?", nil, {
	category = "LethalGas"
})
ix.config.Add("GasBleedout", true, "Должен ли смертоносный газ наносить урон игрокам при кровотечении?", nil, {
	category = "LethalGas"
})

ix.lang.AddTable("english", {
	lethalGasEntered = "Something in the air weighs heavy on your body. You feel like you shouldn't stick around here without proper protection."
})

ix.lang.AddTable("russian", {
	lethalGasEntered = "Что-то в воздухе тяготит ваше тело. Вы чувствуете, что не должны оставаться здесь без надлежащей защиты."
})
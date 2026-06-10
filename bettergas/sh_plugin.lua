--[[
| This file was obtained through the combined efforts
| of Madbluntz & Plymouth Antiquarian Society.
|
| Credits: lifestorm, Gregory Wayne Rossel JR.,
| 	Maloy, DrPepper10 @ RIP, Atle!
|
| Visit for more: https://plymouth.thetwilightzone.ru/
--]]

local CAMI = CAMI
local math = math
local ix = ix

local PLUGIN = PLUGIN

PLUGIN.name = "Better Gas"
PLUGIN.author = "Gr4Ss"
PLUGIN.description = "An improved gas zone system, aiming to facilitate roleplay both in and out of gas zones."

PLUGIN.TIMER_INTERVAL = 10
PLUGIN.LETHAL_GAS = 70
PLUGIN.GAS_DEATH = 100
PLUGIN.GAS_COOLDOWN_DELAY = 30
PLUGIN.GAS_DECREASE_DELAY = 2

ix.config.Add("gasPermakill", false, "Активируется ли пермакилл от газа.", nil, {
	category = "Permakill"
})
ix.config.Add("gasPointGainScale", 1, "Сколько дополнительного газа получают все персонажи, находясь в зоне газа. Это не влияет на фильтры. 1 => 1 минута = 1 очко газа, 2 => 1 минута = 2 очка газа, 0,5 => 1 минута = 0,5 очка газа", nil, {
	data = {min = 0, max = 5, decimals = 2},
	category = "Areas"
})
ix.config.Add("gasPointRecoveryPenalty", 1, "Как долго все персонажи должны восстанавливаться после газа. 1 = та же скорость, 2 = в два раза медленнее, 0,5 = в два раза дольше", nil, {
	data = {min = 0, max = 5, decimals = 2},
	category = "Areas"
})

ix.config.Add("gasPointInjuryScale", 1, "Сколько дополнительного газа получают раненые персонажи, находясь в зоне газа. Эффект применяется постепенно. Указанное число является целью на уровне 1hp. 1 = та же скорость, что и при 100hp, 2 = в два раза быстрее, 0,5 = в два раза дольше.", nil, {
	data = {min = 0, max = 5, decimals = 2},
	category = "Areas"
})

ix.config.Add("gasPointInjuryRecoveryPenalty", 1, "Как долго раненые персонажи должны восстанавливаться после газа. Эффект применяется постепенно. Указанное число является целью при 1hp. 1 = та же скорость, что и при 100hp, 2 = в два раза медленнее, 0,5 = в два раза дольше.", nil, {
	data = {min = 0, max = 5, decimals = 2},
	category = "Areas"
})
ix.config.Add("gasReverseZones", false, "Сделайте газ активным везде на карте, кроме газовых зон.", nil, {
	category = "Areas"
})

ix.lang.AddTable("english", {
	gasDeathNotif = "%s умер от яда.",
	gasLethal = "ЛЕТАЛЬНЫЙ УРОВЕНЬ ЯДА",
	gasHigh = "ВЫСОКИЙ УРОВЕНЬ ЯДА",
	optGasNotificationWarnings = "Предупреждения о наличии газа",
	optdGasNotificationWarnings = "Получайте предупреждающие уведомления при поступлении газа и при достижении высокого уровня газа.",
	gasCDStart = "Вы не были в канализации достаточно долго, чтобы уровень яда продолжал медленно снижаться, пока вы находитесь в оффлайне или на другом персонаже.",
	gasEntered = "Здесь плохо пахнет, и от этого становится плохо. Лучше не задерживаться здесь надолго.",
	gasHighNotif = "Воздух становится тяжелым для вас, а тело странно покалывает. Как долго вы еще сможете это терпеть?",
	gasNearLethalNotif = "Дышать становится трудно, вы чувствуете себя растерянным и очень устали. Уходите, пока еще можете, смерть не за горами.",
	gasLethalNotif = "Каждый шаг становится испытанием, и где-то в глубине души вы чувствуете: вы задержались и зашли слишком далеко. Возврата уже нет, вас ждет только смерть.",
	gasLethalNotifOOC = "OOC Примечание: вы достигли смертельного количества яда. Это невозможно вылечить или исправить. Вам дается некоторое время, чтобы отыграть смерть вашего персонажа, так как вы входите в септический шок.",
	filterOut = "У вас закончился фильтр.",
	filterDecay = "Ваш фильтр начинает портиться, скоро он закончится."
})

ix.lang.AddTable("spanish", {
	gasLethal = "NIVELES DE VENENO LETAL",
	optdGasNotificationWarnings = "Obtenga notificaciones de advertencia cuando entre gas y cuando alcance niveles altos de gas.",
	optGasNotificationWarnings = "Avisos de peligro gas",
	gasDeathNotif = "%s fue asesinado por el gas.",
	gasHigh = "ALTOS NIVELES DE VENENO",
	gasLethalNotifOOC = "Nota OOC: has alcanzado cantidades letales de veneno. No hay cura o arreglo para ello. Se te permite un tiempo para rolear la muerte de tu personaje mientras entras en shock séptico.",
	gasCDStart = "Has estado fuera de las alcantarillas el tiempo suficiente para que tus niveles de veneno sigan disminuyendo lentamente mientras estás desconectado o con otro personaje.",
	gasLethalNotif = "A medida que cada paso se convierte en un desafío, en algún lugar de tu interior puedes sentirlo: Te has quedado mucho tiempo y has forzado tu cuerpo demasiado lejos. Ya no hay vuelta atrás, sólo te espera la muerte.",
	gasNearLethalNotif = "Respiras con dificultad, te sientes confuso y estás muy cansado. Vete mientras puedas, la muerte está a la vuelta de la esquina.",
	gasEntered = "El aire huele mal aquí, te pone enfermo. Es mejor no quedarse mucho tiempo.",
	gasHighNotif = "El aire empieza a pesarte y tu cuerpo siente un extraño cosquilleo. ¿Cuánto tiempo más podrás seguir así?",
	filterOut = "Tu filtro se ha agotado.",
	filterDecay = "Tu filtro está empezando a deteriorarse, se agotará pronto."
})


ix.option.Add("gasNotificationWarnings", ix.type.bool, true, {
	bNetworked = true,
	category = "notice"
})


CAMI.RegisterPrivilege({
	Name = "Helix - Manage Gas",
	MinAccess = "admin"
})

do
	local a, b, c = 50, 1.04, 49
	local gasToCooldown = {b}
	PLUGIN.gasToCooldown = gasToCooldown

	for i = 2, PLUGIN.LETHAL_GAS do
		gasToCooldown[i] = gasToCooldown[i - 1] * b
		gasToCooldown[i - 1] = (gasToCooldown[i - 1] * a) - c
	end
	gasToCooldown[0] = a - c
	gasToCooldown[PLUGIN.LETHAL_GAS] = (gasToCooldown[PLUGIN.LETHAL_GAS] * a) - c
end

ix.util.Include("meta/sh_player.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

-- Accumalated gas points
ix.char.RegisterVar("gasPoints", {
	field = "gas_points",
	fieldType = ix.type.number,
	default = 0,
	bNoDisplay = true,
})

-- Detection for when the player left a gas area
ix.char.RegisterVar("gasCooldownPoints", {
	field = "gas_cd_points",
	fieldType = ix.type.number,
	default = 0,
	bNoDisplay = true,
    bNoNetworking = true
})

-- Time when player left character with enough points for gas cooldown
ix.char.RegisterVar("gasCooldownStart", {
	field = "gas_cd_start",
	fieldType = ix.type.number,
	default = 0,
	bNoDisplay = true,
    bNoNetworking = true
})

ix.char.RegisterVar("filterItem", {
	default = 0,
	bNoDisplay = true,
	isLocal = true,
})

ix.command.Add("CharSetGasPoints", {
	description = "Установите очки газа персонажа (1 очко = 1 минута в газе; более "..PLUGIN.LETHAL_GAS.." = летальный исход; от 0 до "..PLUGIN.GAS_DEATH..")",
	arguments = {
		ix.type.character,
		ix.type.number
	},
	privilege = "Manage Gas",
	OnRun = function(self, client, character, amount)
		character:SetGasPoints(math.Clamp(amount, 0, PLUGIN.GAS_DEATH))
		client:Notify(character:GetName().."'s gas points were set to "..math.Clamp(amount, 0, PLUGIN.GAS_DEATH))
	end
})
local PLUGIN = PLUGIN

PLUGIN.name = "Junk Items"
PLUGIN.author = "M!NT, Fruity"
PLUGIN.description = "Allow players to search trash for junk items."

ix.config.Add(
    "Trash Search Time",
    10,
    "Сколько времени уйдет на то, чтобы обыскать кучу мусора.",
    nil,
    {
	    data = {min = 1, max = 60},
	    category = "Мусор"
    }
)

ix.config.Add(
    "Trash Search Chance",
    30,
    "Шанс найти что-нибудь в куче мусора",
    nil,
    {
        data = {min = 1, max = 100},
        category = "Мусор"
    }
)
ix.config.Add(
    "Trash Search Multiplier",
    0.75,
    "Повышает шанс найти несколько предметов в куче мусора",
    nil,
    {
        data = {min = 0.0, max = 3.0, decimals = 2},
        category = "Мусор"
    }
)
ix.config.Add(
    "Trash Search Max Items",
    3,
    "Максимальное количество предметов, которое можно найти в куче мусора",
    nil,
    {
        data = {min = 1, max = 10},
        category = "Мусор"
    }
)
ix.config.Add(
    "Trash Spawner Respawn Time",
    60,
    "Среднее число минут, нужно для спауна новой кучи мусора.",
    nil,
    {
        data = {min = 1, max = 240},
        category = "Мусор"
    }
)

ix.config.Add(
    "Trash Spawner Respawn Variation",
    30,
    "Сколько минут вариации должно быть в спауне мусора.",
    nil,
    {
        data = {min = 1, max = 240},
        category = "Мусор"
    }
)

ix.lang.AddTable("russian", {
    trashName = "Мусор",
    trashSearching = "Вы роетесь в мусоре...",
    trashFound = "Вы нашли: \"%s\"!",
    trashRemoved = "Мусор был убран до того как вы успели его собрать.",
    trashCrouch = "Вы должны присесть чтобы начать рыться в мусоре.",
    trashAway = "Вы отошли от мусора.",
    trashFailed = "Вам не удалось ничего найти.",
})

ix.util.Include("sv_plugin.lua")

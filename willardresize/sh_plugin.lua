local PLUGIN = PLUGIN

PLUGIN.name = "Character Playermodel Resize"
PLUGIN.author = "M!NT"
PLUGIN.description = "Resizes a character's playermodel based on their actual IC height."

ix.config.Add("Enable Model Scaling", true, "Позволяет серверу масштабировать модели игроков в зависимости от их роста, выбранного при создании персонажа.", nil, {
	category = "Other"
})

ix.util.Include("sv_hooks.lua")

local PLUGIN = PLUGIN

PLUGIN.name = "Writing Essentials"
PLUGIN.author = "Fruity"
PLUGIN.description = "Newspapers, notepads, papers."
PLUGIN.storedNewspapers = {}

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_hooks.lua")

ix.char.RegisterVar("handwriting", {
	field = "handwriting",
	fieldType = ix.type.string,
	default = "",
	isLocal = true,
	bNoDisplay = true
})

PLUGIN.validHandwriting = {
	BookSatisfy = true,
	BookChilanka = true,
	BookDancing = true,
	BookHandlee = true,
	BookAmita = true
}
ix.command.Add("SetHandwriting", {
	description = "Устанавливает почерк игрока на\n(BookSatisfy, BookChilanka, BookDancing, BookHandlee, BookAmita).",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.text},
	OnRun = function(self, client, target, text)
		if (PLUGIN.validHandwriting[text]) then
			target:SetHandwriting(text)
		else
			client:Notify(text.." не подходящий почерк.")
		end
	end
})
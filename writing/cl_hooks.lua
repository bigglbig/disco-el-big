
local PLUGIN = PLUGIN

surface.CreateFont( "NewspaperTitle", {
	font = "Open Sans Extrabold",
	extended = false,
	size = SScaleMin(80 / 3),
	extended = true,
	weight = 550,
	antialias = true,
} )

surface.CreateFont( "NewspaperColumnTitle", {
	font = "Open Sans Bold",
	extended = false,
	size = SScaleMin(40 / 3),
	extended = true,
	weight = 550,
	antialias = true,
} )

surface.CreateFont( "NewspaperColumnSubtitle", {
	font = "Open Sans",
	extended = false,
	size = SScaleMin(28 / 3),
	extended = true,
	weight = 550,
	antialias = true,
} )

surface.CreateFont( "NewspaperColumn", {
	font = "Open Sans",
	extended = false,
	size = SScaleMin(18 / 3),
	extended = true,
	weight = 550,
	antialias = true,
} )

surface.CreateFont( "NewspaperColumnItalic", {
	font = "Open Sans",
	extended = false,
	size = SScaleMin(18 / 3),
	extended = true,
	weight = 550,
	antialias = true,
	italic = true,
} )

surface.CreateFont( "BookSatisfy", {
	font = "Satisfy",
	extended = false,
	size = SScaleMin(30 / 3),
	extended = true,
	weight = 550,
	antialias = true
} )

surface.CreateFont( "BookChilanka", {
	font = "Chilanka",
	extended = false,
	size = SScaleMin(30 / 3),
	extended = true,
	weight = 550,
	antialias = true
} )

surface.CreateFont( "BookAmita", {
	font = "Amita",
	extended = false,
	size = SScaleMin(30 / 3),
	extended = true,
	weight = 550,
	antialias = true
} )

surface.CreateFont( "BookHandlee", {
	font = "Handlee",
	extended = false,
	size = SScaleMin(30 / 3),
	extended = true,
	weight = 550,
	antialias = true
} )

surface.CreateFont( "BookDancing", {
	font = "Dancing Script",
	extended = false,
	size = SScaleMin(30 / 3),
	extended = true,
	weight = 550,
	antialias = true
} )

local function CheckForHandwriting()
	local handWriting = LocalPlayer():GetCharacter():GetHandwriting()
	if (!handWriting or !PLUGIN.validHandwriting[handWriting]) then
		LocalPlayer():NotifyLocalized("Вы ещё не выбрали почерк вашего персонажа!")
		vgui.Create("HandwritingSelector")
		return false
	end

	return true
end

netstream.Hook("OpenBookEditor", function(itemID, title1, title2, font, leftEntry, rightEntry, writtenIn)
	if CheckForHandwriting() then
		LocalPlayer().activeBookID = itemID
		LocalPlayer().activeBookTitle1 = title1
		LocalPlayer().activeBookTitle2 = title2
		LocalPlayer().activeBookFont = font
		LocalPlayer().activeBookLeftEntry = leftEntry
		LocalPlayer().activeBookRightEntry = rightEntry
		LocalPlayer().activeBookWrittenIn = writtenIn
		vgui.Create("BookEditor")
	end
end)

netstream.Hook("OpenNotepadEditor", function(itemID, title, font, entry, owner, editedTimes)
	if CheckForHandwriting() then
		LocalPlayer().activeNotepadID = itemID
		LocalPlayer().activeNotepadTitle = title
		LocalPlayer().activeNotepadFont = font
		LocalPlayer().activeNotepadEntry = entry
		LocalPlayer().activeNotepadOwner = owner
		LocalPlayer().activeNotepadEditedTimes = editedTimes
		vgui.Create("NotepadEditor")
	end
end)

netstream.Hook("OpenPaperEditor", function(itemID, title, font, entry)
	if CheckForHandwriting() then
		LocalPlayer().activePaperID = itemID
		LocalPlayer().activePaperTitle = title
		LocalPlayer().activePaperFont = font
		LocalPlayer().activePaperEntry = entry
		vgui.Create("PaperEditor")
	end
end)
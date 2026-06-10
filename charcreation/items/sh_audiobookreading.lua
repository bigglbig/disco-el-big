local PLUGIN = PLUGIN

ITEM.name = "[Аудио-плеер] Учимся читать"
ITEM.uniqueID = "audiobook_reading"
ITEM.model = "models/props_lab/reciever01d.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Прослушивание данной записи поможет вам лучше читать."
ITEM.category = "Аудиокниги"

ITEM.functions.Listen = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		
		character:SetCanread(true)
		
		client:NotifyLocalized("Я теперь могу читать гораздо лучше.")
	end
}
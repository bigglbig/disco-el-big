local PLUGIN = PLUGIN

ITEM.name = "Бумага"
ITEM.uniqueID = "paper"
ITEM.model = "models/props_c17/paper01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Бумага для записей."
ITEM.category = "Бумага"
ITEM.bAllowMultiCharacterInteraction = true

ITEM.functions.Write = {
	name = "Читать/Писать",
	tip = "Читать/Писать",
	icon = "icon16/text_align_center.png",
	OnRun = function(item)
		local client = item.player
		
		if client.CantPlace then
			client:NotifyLocalized("Вам нужно подождать перед тем как начать читать/писать в этом!..")
			return false
		end
		
		client.CantPlace = true
		
		timer.Simple(3, function()
			if client then
				client.CantPlace = false
			end
		end)
		
		netstream.Start(client, "OpenPaperEditor", item.id, item:GetData("Название", ""), item:GetData("font", ""), item:GetData("Entry", ""))
		
		return false
	end
}

function ITEM:PublishPaper(entry, title, font)
	if title then
		self:SetData("Название", title)
	end
	
	self:SetData("font", font)	
	self:SetData("Entry", entry)
	
	return true
end
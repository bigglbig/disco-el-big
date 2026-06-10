local PLUGIN = PLUGIN

ITEM.name = "Блокнот"
ITEM.uniqueID = "notepad"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Блокнот для записей."
ITEM.category = "Бумага"
ITEM.bAllowMultiCharacterInteraction = true

ITEM.functions.Edit = {
	tip = "Отредактировать данный блокнот.",
	icon = "icon16/text_align_center.png",
	OnRun = function(item)
		local client = item.player
		
		-- This check is not necessary but better safe than sorry
		if item:GetData("owner", "") != client:GetCharacter():GetID() then
			client:NotifyLocalized("Вы не являетесь владельцем этого блокнота или блокнот еще не опубликован!")
			return false
		end
		
		if item:GetData("editedTimes") == 3 then
			client:NotifyLocalized("Этот блокнот редактировался уже трижды, это максимум.")
			return false
		end
		
		netstream.Start(client, "OpenNotepadEditor", item.id, item:GetData("Название", ""), item:GetData("font", ""), item:GetData("Entry", ""), item:GetData("owner", ""), item:GetData("editedTimes", -1))
		
		return false
	end,
	OnCanRun = function(item)
		if item:GetData("owner") then
			local client = item.player
			
			if client:GetCharacter():GetID() == item:GetData("owner") then
				return true
			end
		end
		
		return false
	end
}

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
		
		
		netstream.Start(client, "OpenNotepadEditor", item.id, item:GetData("Название", ""), item:GetData("font", ""), item:GetData("Entry", ""))
		
		return false
	end
}

function ITEM:PublishNotepad(entry, title, font, client, editedTimes)
	if title then
		self:SetData("Название", title)
	end
	
	editedTimes = editedTimes or -1
	
	self:SetData("font", font)	
	self:SetData("Entry", entry)
	self:SetData("owner", client:GetCharacter():GetID())

	self:SetData("editedTimes", editedTimes + 1)
	
	return true
end
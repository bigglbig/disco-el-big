local PLUGIN = PLUGIN

ITEM.name = "Книга"
ITEM.uniqueID = "book"
ITEM.model = "models/willardnetworks/misc/book.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Книга, в которой можно писать."
ITEM.category = "Бумага"

function ITEM:OnInstanced()
	if !self:GetData("bodygroups") then
		self:SetData("bodygroups", "000000000")
	end

	self:SetData("Title1", "")
	self:SetData("Title2", "")
	self:SetData("font", "")
	self:SetData("LeftEntry", "")
	self:SetData("RightEntry", "")
end

function ITEM:SetBodygroups(bodygroups)
	self:SetData("bodygroups", bodygroups)
end

function ITEM:GetModelBodygroups()
	return self:GetData("bodygroups")
end

function ITEM:GetName()
	local title1 = self:GetData("Title1")
	if title1 and title1 != "" then return title1 end
	
	return self.name
end

function ITEM:GetDescription()
	if self:GetData("LeftEntry") and self:GetData("LeftEntry") != "" then
		local LeftEntry = self:GetData("LeftEntry")
		local shortenedEntry = string.utf8sub(LeftEntry, 0, 40).."..."

		return shortenedEntry
	end

	if self:GetData("RightEntry") and self:GetData("RightEntry") != "" then
		local RightEntry = self:GetData("RightEntry")
		local shortenedEntry = string.utf8sub(RightEntry, 0, 40).."..."

		return shortenedEntry
	end

	return self.description
end

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
		
		local writtenIn = item:GetData("WrittenIn") or false

		netstream.Start(client, "OpenBookEditor", item.id, item:GetData("Title1", ""), item:GetData("Title2", ""), item:GetData("font", ""), item:GetData("LeftEntry", ""), item:GetData("RightEntry", ""), writtenIn)

		return false
	end
}

function ITEM:PublishBook(title1, title2, leftEntry, rightEntry, font)
	title1 = title1 or ""
	title2 = title2 or ""
	font = font or "BookChilanka"
	leftEntry = leftEntry or ""
	rightEntry = rightEntry or ""

	self:SetData("Title1", title1)
	self:SetData("Title2", title2)
	
	self:SetData("font", font)
	self:SetData("LeftEntry", leftEntry)
	self:SetData("RightEntry", rightEntry)
	self:SetData("WrittenIn", true)

	return true
end
local PLUGIN = PLUGIN

netstream.Hook("PrintNewsPaper", function(client, activeNewspaper, pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture, unionDatabase)
	if !IsValid(activeNewspaper) and activeNewspaper.PrintNewspaper then
		return
	end

	if activeNewspaper:GetPos():Distance(client:GetPos()) > 96 then
		return
	end

	if activeNewspaper.canUse then
		return
	end

	activeNewspaper:PrintNewspaper(client, pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture)

	if unionDatabase then
		PLUGIN.storedNewspapers[#PLUGIN.storedNewspapers + 1] = {pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture}
	end
end)

netstream.Hook("CloseNewspaper", function(client, activeNewspaper)
	if activeNewspaper then
		if IsEntity(activeNewspaper) then
			if activeNewspaper.Close then
				activeNewspaper:Close()
			end
		end
	end
end)

netstream.Hook("SetHandwriting", function(client, handwriting)
	local character = client:GetCharacter()

	if !character or !PLUGIN.validHandwriting[handwriting] then
		return
	end

	character:SetHandwriting(handwriting)
end)

netstream.Hook("SetBookColor", function(client, bookID, bodyGroups)
	local character = client:GetCharacter()
	local item = ix.item.instances[bookID]
	local entity
	local inventory

	if !character or !item then
		return
	end

	entity = item:GetEntity()
	inventory = ix.item.inventories[item.invID]

	if !inventory:OnCheckAccess(client) then
		return
	end

	if entity then
		if entity:GetPos():Distance(client:GetPos()) > 96 then
			return
		end
	elseif !inventory:GetItemByID(bookID) then
		return
	end

	item:SetBodygroups(bodyGroups)

	if IsValid(entity) then
		entity:SetBodyGroups(bodyGroups)
	end
end)

netstream.Hook("PublishBook", function(client, title1, title2, leftEntry, rightEntry, bookID, font)
	local character = client:GetCharacter()
	local item = ix.item.instances[bookID]
	local entity
	local inventory

	if !character or !item or !item.PublishBook then
		return
	end

	entity = item:GetEntity()
	inventory = ix.item.inventories[item.invID]

	if !inventory:OnCheckAccess(client) then
		return
	end

	if entity then
		if entity:GetPos():Distance(client:GetPos()) > 96 then
			return
		end
	elseif !inventory:GetItemByID(bookID) then
		return
	end

	if !item.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter() then
		local itemPlayerID = item:GetPlayerID()
		local itemCharacterID = item:GetCharacterID()
		local playerID = client:SteamID64()
		local characterID = client:GetCharacter():GetID()

		if itemPlayerID and itemCharacterID and itemPlayerID == playerID and itemCharacterID != characterID then
			return
		end
	end

	item:PublishBook(title1, title2, leftEntry, rightEntry, font)
	client:NotifyLocalized("Вы успешно написали в этой книге!")
end)

netstream.Hook("PublishNotepad", function(client, text, label, itemID, font)
	local character = client:GetCharacter()
	local item = ix.item.instances[itemID]
	local entity
	local inventory

	if !character or !item or !item.PublishNotepad then
		return
	end

	entity = item:GetEntity()
	inventory = ix.item.inventories[item.invID]

	if !inventory:OnCheckAccess(client) then
		return
	end

	if entity then
		if entity:GetPos():Distance(client:GetPos()) > 96 then
			return
		end
	elseif !inventory:GetItemByID(itemID) then
		return
	end

	if !item.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter() then
		local itemPlayerID = item:GetPlayerID()
		local itemCharacterID = item:GetCharacterID()
		local playerID = client:SteamID64()
		local characterID = client:GetCharacter():GetID()

		if itemPlayerID and itemCharacterID and itemPlayerID == playerID and itemCharacterID != characterID then
			return
		end
	end

	item:PublishNotepad(text, label, font, client)
	client:NotifyLocalized("Вы успешно написали в этом блокноте!")
end)

netstream.Hook("PublishPaper", function(client, text, label, itemID, font)
	local character = client:GetCharacter()
	local item = ix.item.instances[itemID]
	local entity
	local inventory

	if !character or !item or !item.PublishPaper then
		return
	end

	entity = item:GetEntity()
	inventory = ix.item.inventories[item.invID]

	if !inventory:OnCheckAccess(client) then
		return
	end

	if entity then
		if entity:GetPos():Distance(client:GetPos()) > 96 then
			return
		end
	elseif !inventory:GetItemByID(itemID) then
		return
	end

	item:PublishPaper(text, label, font)
	client:NotifyLocalized("Вы успешно написали на этой бумаге!")
end)

netstream.Hook("RemoveStoredNewspaper", function(client, key)
	table.remove(PLUGIN.storedNewspapers, key)
	client:NotifyLocalized("Удалённая газета")
end)

-- FIX of POOR OVERRIDE
net.Receive("ixShipmentUse", function(length, client)
	local uniqueID = net.ReadString()
	local drop = net.ReadBool()

	local entity = client.ixShipment
	local itemTable = ix.item.list[uniqueID]

	if (itemTable and IsValid(entity)) then
		if (entity:GetPos():Distance(client:GetPos()) > 128) then
			client.ixShipment = nil

			return
		end

		local amount = entity.items[uniqueID]

		if (amount and amount > 0) then
			if (entity.items[uniqueID] <= 0) then
				entity.items[uniqueID] = nil
			end

			if (drop) then
				ix.item.Spawn(uniqueID, entity:GetPos() + Vector(0, 0, 16), function(item, itemEntity)
					if entity.itemData then
						item:SetData("data", entity.itemData)
					end

					if (IsValid(client)) then
						itemEntity.ixSteamID = client:SteamID()
						itemEntity.ixCharID = client:GetCharacter():GetID()
					end
				end)
			else
				status, _ = client:GetCharacter():GetInventory():Add(uniqueID, 1, entity.itemData and {data = entity.itemData} or nil)
				
				if (!status) then
					return client:NotifyLocalized("noFit")
				end
			end

			hook.Run("ShipmentItemTaken", client, uniqueID, amount)

			entity.items[uniqueID] = entity.items[uniqueID] - 1

			if (entity:GetItemCount() < 1) then
				entity:GibBreakServer(Vector(0, 0, 0.5))
				entity:Remove()
			end
		end
	end
end)


function PLUGIN:PlayerButtonDown( client, key )		
	if IsFirstTimePredicted() then
		if key == KEY_LALT then
			local entity = client:GetEyeTraceNoCursor().Entity
			local getInk = entity.ink or 0
			local getPaper = entity.paper or 0
			local registeredCID = entity.registeredCID or "00000"
			if (IsValid(entity) and entity:GetClass() == "ix_newspaperprinter") then					
				if client:GetCharacter():GetID() != entity:GetNWInt("owner") then
					return false
				end
				
				if !entity.canUse then
					return false
				end
				
				if (client:GetShootPos():Distance(entity:GetPos()) > 100) then
					return false
				end
				
				local pos = entity:GetPos()
				
				ix.item.Spawn("newspaper_printer", pos + Vector( 0, 0, 2 ), function(item, entityCreated) 
					item:SetData("ink", getInk) 
					item:SetData("paper", getPaper) 
					item:SetData("registeredCID", registeredCID) 
				end, entity:GetAngles())
				
				entity:Remove()
			else
				return false
			end
		end
	end
end


function PLUGIN:LoadPlotters()
	local plotters = ix.data.Get("plotters")

	if plotters then
		for k, v in pairs(plotters) do
			local entity = ents.Create("ix_newspaperprinter")
			entity:SetAngles(v.angles)
			entity:SetPos(v.position)
			entity:Spawn()
			entity.paper = v.paper or 0
			entity.ink = v.ink or 0
			entity:SetInk(v.ink or 0)
			entity:SetPaper(v.paper or 0)
			entity.registeredCID = v.registeredCID
			entity:SetNWInt("owner", v.owner)
		end
	end
end

function PLUGIN:LoadNewspapersUnion()
	self.storedNewspapers = ix.data.Get("dbnewpapers") or {}
end

function PLUGIN:SavePlotters()
	local plotters = {}
	
	for k, v in pairs(ents.FindByClass("ix_newspaperprinter")) do
		plotters[#plotters + 1] = {
			angles = v:GetAngles(),
			position = v:GetPos(),
			paper = v.paper,
			ink = v.ink,
			registeredCID = v.registeredCID,
			owner = v:GetNWInt("owner")
		}
	end
	
	ix.data.Set("plotters", plotters)
end

function PLUGIN:SaveStoredNewspapers()
	ix.data.Set("StoredNewspapers", self.storedNewspapers, false, true)
	
	if #self.storedNewspapers > 20 then
		local amountOver = #self.storedNewspaper - 20
		
		for i = 1, amountOver do
			table.remove(self.storedNewspapers, i)
		end
	end
end

function PLUGIN:InitializedPlugins()		
	if !ix.data.Get("StoredNewspapers") then
		ix.data.Set("StoredNewspapers", {})
	end
	
	self.storedNewspapers = ix.data.Get("StoredNewspapers", {}, false, true)
	
	timer.Create("StoredNewspapersSaveTick", 60 * 10, 0, function()
		self:SaveStoredNewspapers()
	end)
end

function PLUGIN:InitPostEntity()
	self:LoadPlotters()
end

function PLUGIN:SaveData()
	self:SavePlotters()
	
	self:SaveStoredNewspapers()
end

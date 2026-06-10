do
	local CHAR = ix.meta.character

	function CHAR:CreateIDCard()
		local id = Schema:ZeroNumber(math.random(1, 99999), 5)
		local inventory = self:GetInventory()
		local x, y, invID = inventory:Add("id_card", 1, {
			owner = self:GetID(),
			name = self:GetName(),
			cid = id,
			active = true,
			geneticDesc = string.utf8upper(self:GetGeneticDesc())
		})

		self:SetCid(id)
		
		local backupData = self:GetIdCardBackup()

		if x then
			timer.Simple(1, function() -- HACK
				local item = inventory:GetItemAt(x, y)
				local oldCard = self:GetIdCard()
				if oldCard then
					oldCard = ix.item.instances[oldCard]
				end

				if backupData and table.Count(backupData) > 0 then
					item:SetData("credits", backupData.credits)
					item:SetData("nextRationTime", backupData.ration)
				elseif oldCard then
					oldCard:TransferData(item, true)
				end

				self:SetIdCard(item.id)
			end)
		else
			ix.item.Spawn("id_card", self:GetPlayer(), function(item)
				local oldCard = self:GetIdCard()
				if oldCard then
					oldCard = ix.item.instances[oldCard]
				end

				if backupData and table.Count(backupData) > 0 then
					item:SetData("credits", backupData.credits)
					item:SetData("nextRationTime", backupData.ration)
				elseif oldCard then
					oldCard:TransferData(item, true)
				end

				self:SetIdCard(item.id)
			end)
		end

		self:SetIdCardBackup(nil)
	end

	function CHAR:GetGeneticDesc()
		local geneticAge = self:GetAge() or "Н/Д"
		local geneticHeight = self:GetHeight() or "Н/Д"
		local geneticEyecolor = self:GetEyeColor() or "Н/Д"
		local geneticHaircolor = self:GetHairColor() or "Н/Д"

		return string.format("%s | %s | %s глаза | %s волосы", geneticAge, geneticHeight, geneticEyecolor, geneticHaircolor)
	end

	function CHAR:SetCredits(amount)
		local itemID = self:GetIdCard()
		local item = ix.item.instances[itemID]

		if item then
			item:SetCredits(amount)
		end
	end

	function CHAR:GiveCredits(amount)
		local itemID = self:GetIdCard()
		local item = ix.item.instances[itemID]

		if item then
			item:GiveCredits(amount)
		end
	end

	function CHAR:TakeCredits(amount)
		local itemID = self:GetIdCard()
		local item = ix.item.instances[itemID]

		if item then
			item:TakeCredits(amount)
		end
	end

	function CHAR:HasCredits(amount)
		local itemID = self:GetIdCard()
		local item = ix.item.instances[itemID]

		return item and item:HasCredits(amount) or false
	end
end
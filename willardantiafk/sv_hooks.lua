local PLUGIN = PLUGIN

function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()

	if (IsValid(client)) then
		client.isAFK = nil
		client:SetNetVar("isAFK", false)

		local uniqueID = "ixAntiAFK"..client:SteamID64()

		timer.Create(uniqueID, 60, 0, function()
			if (IsValid(client) and character) then
				self:UpdateAFK(client, character)	
			else
				timer.Remove(uniqueID)
			end
		end)
	end
end

function PLUGIN:CanPlayerEarnSalary(client, faction)
	if (client:GetNetVar("isAFK", false)) then
		return false
	end
end

function PLUGIN:ShouldCalculatePlayerNeeds(client, character)
	if (client:GetNetVar("isAFK", false)) then
		return false
	end
end
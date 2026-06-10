local PLUGIN = PLUGIN

function PLUGIN:PrePlayerLoadedCharacter(client, character, lastChar)
	for k, v in pairs(client:GetBodyGroups()) do
		client:SetBodygroup(k, 0)
	end

	client:SetNetVar("requiresGlasses", character:GetData("glasses", false)) -- WHY?
end

netstream.Hook("SetBeardBodygroup", function(client, newBeard)
	local curTime = CurTime()
	local character = client:GetCharacter()

	if !client.nextBeardChange or client.nextBeardChange >= curTime then
		return
	end

	if character then
		local faction = character:GetFaction()

		if (faction == FACTION_CITIZEN or faction == FACTION_ADMIN) and character:GetGender() == "male" then
			local beardIndex = client:FindBodygroupByName("beard")
			local beard = client:GetBodygroup(beardIndex)

			if beard != 5 and beard != 8 then return end

			local groups = character:GetData("groups", {})

			if beardIndex then
				groups[beardIndex] = newBeard

				client:SetBodygroup(beardIndex, newBeard)
			end

			character:SetData("groups", groups)
		end
	end

	client.nextBeardChange = curTime + PLUGIN.TIMER_DELAY
end)

netstream.Hook("RemoveBeardBodygroup", function(client)
	local character = client:GetCharacter()

	if !client.nextBeardChange or client.nextBeardChange >= curTime then
		return
	end

	if character then
		if character:GetGender() == "male" then
			local beardIndex = client:FindBodygroupByName("beard")
			local beard = client:GetBodygroup(beardIndex)

			if beard <= 0 then return end

			local groups = character:GetData("groups", {})

			if beardIndex then
				groups[beardIndex] = 0

				client:SetBodygroup(beardIndex, 0)
			end

			character:SetData("groups", groups)
		end
	end

	client.nextBeardChange = curTime + PLUGIN.TIMER_DELAY
end)

local PLUGIN = PLUGIN

ITEM.name = "Бритва для бороды"
ITEM.uniqueID = "beard_razor"
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Бритва для стрижки или укладки бороды."
ITEM.category = "Уход"

ITEM.functions.Style = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		local index = client:FindBodygroupByName("facialhair")
		local faction = character:GetFaction()

		if (faction == FACTION_CITIZEN or faction == FACTION_ADMIN or faction == FACTION_WORKERS) and character:GetGender() == "male" then
			if !client.CantPlace then
				client.CantPlace = true
				netstream.Start(client, "OpenBeardStyling")
				
				timer.Simple(3, function()
					if client then
						client.CantPlace = false
					end
				end)
			else
				client:NotifyLocalized("Вы должны подождать прежде чем совершить это действие!")
				return false
			end
		else
			client:NotifyLocalized("У вас нет бороды!")
			return false
		end
		
		return false
	end
}
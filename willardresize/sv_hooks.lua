local PLUGIN = PLUGIN

PLUGIN.HeightTable = {
	["4'10\""] = 0.03,
	["5'0\""] = 0.036,
	["5'2\""] = 0.042,
	["5'4\""] = 0.048,
	["5'5\""] = 0.054,
	["5'6\""] = 0.060,
	["5'8\""] = 0.066,
	["5'10\""] = 0.072,
	["6'0\""] = 0.078,
	["6'2\""] = 0.084,
	["6'4\""] = 0.090,
	["6'6\""] = 0.097,
	["6'8\""] = 0.103,
	["6'11\""] = 0.109
}

function PLUGIN:ScaleModel(player, scale)
	local multiplier = 0.2
	local scale_multiplied
	local base_scale = 0.97

	if scale == 0 then
	    scale_multiplied = base_scale
	else
	    scale_multiplied = base_scale + ((scale / 50) * multiplier)
	end

	-- females models are smaller, therefore, need more scaling
	if player:IsFemale() then
	    scale_multiplied = scale_multiplied + 0.05
	end

	player:SetModelScale(scale_multiplied, 0)
end

function PLUGIN:CharacterLoaded(character)
	if (!ix.config.Get("Enable Model Scaling", false)) then
		return
	end

	local height = character:GetHeight()

	if self.HeightTable[height] then
		self:ScaleModel(character:GetPlayer(), self.HeightTable[height] or 0)
	else
		character:GetPlayer():SetModelScale(1, 0)
	end
end

function PLUGIN:OnCharacterCreated(client, character)
   	if (!ix.config.Get("Enable Model Scaling", false)) then
		return
	end

	local height = character:GetHeight()

	if self.HeightTable[height] then
		self:ScaleModel(client, self.HeightTable[height] or 0)
	else
		client:SetModelScale(1, 0)
	end
end

function PLUGIN:PlayerModelChanged(client, model)
    if (!ix.config.Get("Enable Model Scaling", false)) then
		return
	end

	local height = client:GetCharacter():GetHeight()

	if self.HeightTable[height] then
		self:ScaleModel(client, self.HeightTable[height] or 0)
	else
		client:SetModelScale(1, 0)
	end
end
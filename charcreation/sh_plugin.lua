local PLUGIN = PLUGIN

PLUGIN.name = "Char Creation Necessities"
PLUGIN.author = "Fruity"
PLUGIN.description = "Required stuff for the char creation such as gender etc."
PLUGIN.TIMER_DELAY = PLUGIN.TIMER_DELAY or 60

ix.util.Include("sv_plugin.lua")

ix.char.RegisterVar("glasses", {
	field = "glasses",
	fieldType = ix.type.bool,
	default = false,
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("canread", {
	field = "canread",
	fieldType = ix.type.bool,
	default = true,
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("beardProgress", {
	field = "beard",
	fieldType = ix.type.number,
	default = 0,
	bNoNetworking = true,
	bNoDisplay = true
})

function PLUGIN:AdjustCreationPayload(client, payload, newPayload)
    if (newPayload.data.glasses != nil) then
        newPayload.glasses = newPayload.data.glasses
        newPayload.data.glasses = nil
    end
	
    if (newPayload.data.canread != nil) then
        newPayload.canread = newPayload.data.canread
        newPayload.data.canread = nil
    end
end

if (CLIENT) then
	-- Glasses stuff
	ix.option.Add("UseImmersiveGlasses", ix.type.bool, false, {
		category = "Glasses"
	})

	netstream.Hook("OpenBeardStyling", function()
		if (IsValid(ix.gui.menu)) then
			ix.gui.menu:Remove()
		end

		vgui.Create("BeardStyling")
	end)

	-- Called when blurry screen space effects should be rendered.
	function PLUGIN:RenderScreenspaceEffects()
		local client = LocalPlayer()
		local character = client:GetCharacter()

		if (ix.option.Get("UseImmersiveGlasses", false) and client:GetNetVar("requiresGlasses") and
			(client:GetMoveType() != MOVETYPE_NOCLIP or client:InVehicle()) and
			character and !character:HasGlasses()) then
			DrawToyTown(28,ScrH())
		end
	end
end

do
	local CHAR = ix.meta.character
	function CHAR:HasGlasses()
		for _, v in pairs(self:GetInventory():GetItems()) do
			if (v.glasses and v:GetData("equip")) then
				return true
			end
		end

		return false
	end
end

ix.char.vars["model"].OnDisplay = function(self, container, payload) end
ix.char.vars["model"].OnValidate = function(self, value, payload, client)
	local faction = ix.faction.indices[payload.faction]

	if (faction) then
		local gender = payload.gender
		local models
		if gender == "male" and faction:GetModelsMale(client) then
			models = faction:GetModelsMale(client)
		elseif gender == "female" and faction:GetModelsFemale(client) then
			models = faction:GetModelsFemale(client)
		else
			models = faction:GetModels(client)
		end

		if (!payload.model or !models[payload.model]) then
			return false, "Вы не выбрали модель!"
		end
	else
		return false, "Вы не выбрали модель!"
	end
end

ix.char.vars["model"].OnAdjust = function(self, client, data, value, newData)
	local faction = ix.faction.indices[data.faction]

	if (faction) then
		local gender = data.gender
		local model
		if gender == "male" and faction:GetModelsMale(client) then
			model = faction:GetModelsMale(client)[value]
		elseif gender == "female" and faction:GetModelsFemale(client) then
			model = faction:GetModelsFemale(client)[value]
		else
			model = faction:GetModels(client)[value]
		end

		if (isstring(model)) then
			newData.model = model
		elseif (istable(model)) then
			newData.model = model[1]
		end
	end
end

ix.char.vars["model"].ShouldDisplay = function(self, container, payload)
	local faction = ix.faction.indices[payload.faction]

	if faction then
		local gender = payload.gender
		if gender == "male" and faction:GetModelsMale(LocalPlayer()) then
			return #faction:GetModelsMale(LocalPlayer()) > 1
		elseif gender == "female" and faction:GetModelsFemale(LocalPlayer()) then
			return #faction:GetModelsFemale(LocalPlayer()) > 1
		else
			return #faction:GetModels(LocalPlayer()) > 1
		end
	end
end

-- Registers the var "Gender"
ix.char.RegisterVar("gender", {
	field = "gender",
	fieldType = ix.type.string,
	default = "male",
	bNoDisplay = true,
	OnSet = function(self, value)
		local client = self:GetPlayer()

		if (IsValid(client)) then
			self.vars.gender = value

			-- @todo refactor networking of character vars so this doesn't need to be repeated on every OnSet override
			net.Start("ixCharacterVarChanged")
				net.WriteUInt(self:GetID(), 32)
				net.WriteString("gender")
				net.WriteType(self.vars.gender)
			net.Broadcast()
		end
	end,
	OnGet = function(self, default)
		local gender = self.vars.gender

		return gender or 0
	end,
	OnValidate = function(self, data, payload, client)
		local faction = ix.faction.indices[payload.faction]
		if (payload.gender == "female" or payload.gender == "male") then
			return true
		end

		if faction then
			if faction:GetNoGender(client) == true then
				return true
			end
		end

		return false, "Вы не выбрали пол!"
	end,
	OnAdjust = function(self, client, data, value, newData)
		newData.gender = value
	end
})

ix.char.vars["data"].OnValidate = function(self, datas, payload, client)
	local faction = ix.faction.indices[payload.faction]

	if faction then
		if (!payload.data["background"] or payload.data["background"] == "") and faction:GetNoBackground(client) != true then
			return false, "Вы не выбрали происхождение!"
		end

		if faction:GetNoGenetics(client) then
			return true
		end

		if !payload.data.age or payload.data["age"] == "" then
			return false, "Вы не выбрали возраст!"
		end

		if !payload.data.height or payload.data["height"] == "" then
			return false, "Вы не выбрали рост!"
		end
		
		if faction.name != "Vortigaunt" then
			if !payload.data["eye color"] or payload.data["eye color"] == "" then
				return false, "Вы не выбрали цвет глаз!"
			end

			if !payload.data["hair color"] or payload.data["hair color"] == "" then
				return false, "Вы не выбрали цвет волос!"
			end
		end

		if payload.data.skin < 0 then
			return false, "Вы не выбрали допустимый вид!"
		end

		if payload.data.groups then
			if payload.data.groups["2"]then
				if payload.data.groups["2"] < 0 then
					return false, "Вы не выбрали допустимую верхнюю одежду!"
				end
			end

			if payload.data.groups["3"] then
				if payload.data.groups["3"] < 0 then
					return false, "Вы не выбрали допустимые штаны!"
				end
			end
		end

		if faction:GetNoAppearances(client) then
			return true
		end
		
		if faction:GetReadOptionDisabled(client) then
			return true
		end
	end

	return true
end

ix.char.vars["data"].OnAdjust = function(self, client, datas, value, newData)
	newData.data = value
end
local PLUGIN = PLUGIN

PLUGIN.name = "Willard UI"
PLUGIN.author = "Fruity"
PLUGIN.description = "The UI for Willard Industries."

ix.util.Include("sh_fonts.lua")
ix.util.Include("sh_hud.lua")
ix.util.Include("cl_overrides.lua")

ix.char.RegisterVar("background", {
	field = "background",
	fieldType = ix.type.string,
	default = "",
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("age", {
	field = "age",
	fieldType = ix.type.string,
	default = "Н/Д",
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("height", {
	field = "height",
	fieldType = ix.type.string,
	default = "Н/Д",
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("eyeColor", {
	field = "eyeColor",
	fieldType = ix.type.string,
	default = "Н/Д",
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("hairColor", {
	field = "hairColor",
	fieldType = ix.type.string,
	default = "Н/Д",
	isLocal = true,
	bNoDisplay = true
})

function PLUGIN:AdjustCreationPayload(client, payload, newPayload)
    if (newPayload.data.background) then
        newPayload.background = newPayload.data.background
        newPayload.data.background = nil
	end

	if (newPayload.data.age) then
        newPayload.age = newPayload.data.age
        newPayload.data.age = nil
	end

	if (newPayload.data.height) then
        newPayload.height = newPayload.data.height
        newPayload.data.height = nil
	end

	if (newPayload.data["eye color"]) then
        newPayload.eyeColor = newPayload.data["eye color"]
        newPayload.data["eye color"] = nil
	end

	if (newPayload.data["hair color"]) then
        newPayload.hairColor = newPayload.data["hair color"]
        newPayload.data["hair color"] = nil
    end
end

if (CLIENT) then
	hook.Add("CreateMenuButtons", "ixConfig", function(tabs)
		if (!CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Config", nil)) then
			return
		end

			tabs["Сервер"] = {

			RowNumber = 7,

			Width = 16,

			Height = 17,

			Right = true,

			Icon = "willardnetworks/tabmenu/navicons/admin.png",

			Create = function(info, container)
				local settings = container:Add("ixSettings")
				settings:SetSearchEnabled(true)

				if settings.settingsTitle then
					settings.settingsTitleIcon:SetImage("willardnetworks/tabmenu/navicons/admin.png")
					settings.settingsTitleIcon:SetSize(SScaleMin(16 / 3), SScaleMin(17 / 3))

					settings.settingsTitle:SetFont("TitlesFontNoClamp")
					settings.settingsTitle:SetText("Администратор")
					settings.settingsTitle:SetPos(SScaleMin(26 / 3))
					settings.settingsTitle:SizeToContents()
					settings.settingsTitle:SetPos(SScaleMin(26 / 3), settings.settingsTitleIcon:GetTall() * 0.5 - settings.settingsTitle:GetTall() * 0.5)
				end
				
				-- gather categories
				local categories = {}
				local categoryIndices = {}

				for k, v in pairs(ix.config.stored) do
					local index = v.data and v.data.category or "misc"

					categories[index] = categories[index] or {}
					categories[index][k] = v
				end

				-- sort by category phrase
				for k, _ in pairs(categories) do
					categoryIndices[#categoryIndices + 1] = k
				end

				table.sort(categoryIndices, function(a, b)
					return L(a) < L(b)
				end)

				-- add panels
				for _, category in ipairs(categoryIndices) do
					local categoryPhrase = L(category)
					settings:AddCategory(categoryPhrase)

					-- we can use sortedpairs since configs don't have phrases to account for
					for k, v in SortedPairs(categories[category]) do
						if (isfunction(v.hidden) and v.hidden()) then
							continue
						end

						local data = v.data.data
						local type = v.type
						local value = ix.util.SanitizeType(type, ix.config.Get(k))

						-- @todo check ix.gui.properties
						local row = settings:AddRow(type, categoryPhrase)
						row:SetText(ix.util.ExpandCamelCase(k))

						-- type-specific properties
						if (type == ix.type.number) then
							row:SetMin(data and data.min or 0)
							row:SetMax(data and data.max or 1)
							row:SetDecimals(data and data.decimals or 0)
						end

						row:SetValue(value, true)
						row:SetShowReset(value != v.default, k, v.default)

						row.OnValueChanged = function(panel)
							local newValue = ix.util.SanitizeType(type, panel:GetValue())

							panel:SetShowReset(newValue != v.default, k, v.default)

							net.Start("ixConfigSet")
								net.WriteString(k)
								net.WriteType(newValue)
							net.SendToServer()
						end

						row.OnResetClicked = function(panel)
							panel:SetValue(v.default, true)
							panel:SetShowReset(false)

							net.Start("ixConfigSet")
								net.WriteString(k)
								net.WriteType(v.default)
							net.SendToServer()
						end

						row:GetLabel():SetHelixTooltip(function(tooltip)
							local title = tooltip:AddRow("name")
							title:SetImportant()
							title:SetText(k)
							title:SizeToContents()
							title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

							local description = tooltip:AddRow("description")
							description:SetText(v.description)
							description:SizeToContents()
						end)
					end
				end

				settings:SizeToContents()
				container.panel = settings
				
				if settings.titlePanel then
					local pluginManager = settings.titlePanel:Add("DButton")
					pluginManager:Dock(RIGHT)
					pluginManager:SetWide(SScaleMin(100 / 3))
					pluginManager:SetFont("TitlesFontNoClamp")
					pluginManager:SetText("ПЛАГИНЫ")
					pluginManager:DockMargin(0, 0, 0, settings.titlePanel:GetTall() - SScaleMin(29 / 3))
					pluginManager.Paint = function(self, w, h)
						surface.SetDrawColor(ColorAlpha(color_white, 100))
						surface.DrawOutlinedRect(0, 0, w, h)
					end
					
					pluginManager.DoClick = function()
						for _, v in pairs(container.panel:GetChildren()) do
							v:SetVisible(false)
						end
						
						ix.gui.pluginManager = container.panel:Add("ixPluginManager")
						
						if ix.gui.pluginManager.settingsTitle then
							ix.gui.pluginManager.settingsTitle:SetText("Плагины")
							
							local configManager = ix.gui.pluginManager.titlePanel:Add("DButton")
							configManager:Dock(RIGHT)
							configManager:SetWide(SScaleMin(100 / 3))
							configManager:SetFont("TitlesFontNoClamp")
							configManager:SetText("КОНФИГ")
							configManager:DockMargin(0, 0, 0, settings.titlePanel:GetTall() - SScaleMin(29 / 3))
							configManager.Paint = function(self, w, h)
								surface.SetDrawColor(ColorAlpha(color_white, 100))
								surface.DrawOutlinedRect(0, 0, w, h)
							end
							
							configManager.DoClick = function()
								for _, v in pairs(container.panel:GetChildren()) do
									v:SetVisible(true)
								end
								
								ix.gui.pluginManager:Remove()
							end
						end
					end
				end
			end,

			OnSelected = function(info, container)
				container.panel.searchEntry:RequestFocus()
			end,

			RowNumber = 6
		}
	end)

	hook.Add("Think", "F1Menu", function()
		if input.IsKeyDown( KEY_F1 ) then
			if ix.gui.menu and ix.gui.menu:IsVisible() then
				return
			end

			if ix.gui.characterMenu and ix.gui.characterMenu:IsVisible() then
				return
			end

			if ix.gui.protectionTeams and ix.gui.protectionTeams:IsVisible() then
				return
			end

			if LocalPlayer():GetCharacter() then
				if ix.gui.F1Menu and ix.gui.F1Menu:IsVisible() then
					return
				end

				ix.gui.F1Menu = vgui.Create("ixF1Menu")
			end
		end
	end)
end

ix.config.Add("CharCreationDisabled", false, "Включено ли создание персонажей.", nil, {
	category = "Character Creation"
})
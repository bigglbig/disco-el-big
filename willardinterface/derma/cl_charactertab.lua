local PANEL = {}

function PANEL:Init()
	local titlePushDown = SScaleMin(30 / 3)
	local padding = SScaleMin(30 / 3)
	local margin = SScaleMin(10 / 3)
	local iconSize = SScaleMin(18 / 3)
	local topPushDown = SScaleMin(150 / 3)
	local scale780 = SScaleMin(780 / 3)
	local scale120 = SScaleMin(120 / 3)

	self:SetWide(ScrW() - (topPushDown * 2))

	local sizeXtitle, sizeYtitle = self:GetWide(), scale120
	local sizeXcontent, sizeYcontent = self:GetWide(), (scale780)

	self.titlePanel = self:Add("Panel")
	self.titlePanel:SetSize(sizeXtitle, sizeYtitle)
	self.titlePanel:SetPos(self:GetWide() * 0.5 - self.titlePanel:GetWide() * 0.5)

	self:CreateTitleText()

	self.contentFrame = self:Add("Panel")
	self.contentFrame:SetSize(sizeXcontent, sizeYcontent)
	self.contentFrame:SetPos(self:GetWide() * 0.5 - self.contentFrame:GetWide() * 0.5, titlePushDown)
	
	self:SetTall(scale120 + scale780 + titlePushDown)
	self:Center()

	self.informationFrame = self.contentFrame:Add("Panel")
	self.informationFrame:SetSize(self.contentFrame:GetWide() * 0.5 - padding, self.contentFrame:GetTall())
	self.informationFrame:Dock(LEFT)
	self.informationFrame:DockMargin(0, 0, padding, 0)

	self.informationFrame.Paint = function( self, w, h )
		surface.SetDrawColor(Color(255, 255, 255, 30))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local informationSubframe = self.informationFrame:Add("Panel")
	informationSubframe:SetSize(self.informationFrame:GetSize())
	informationSubframe:DockMargin(padding, padding, padding, padding)
	informationSubframe:Dock(FILL)

	local function CreatePart(parent, title, text, icon, boolLast, editButton)
		parent:Dock(TOP)
		parent:SetSize(informationSubframe:GetWide(), SScaleMin(16.666666666667))
		parent.Paint = function(self, w, h)
			if boolLast then
				return
			end

			surface.SetDrawColor(Color(255, 255, 255, 30))
			surface.DrawLine(0, h - 1, w, h - 1)
		end

		local leftSide = parent:Add("Panel")
		leftSide:Dock(LEFT)
		leftSide:SetWide(parent:GetWide() * 0.25)
		leftSide:DockMargin(0, 0, margin, 0)

		local parentIcon = leftSide:Add("DImage")
		parentIcon:SetImage("willardnetworks/tabmenu/charmenu/"..icon..".png")
		parentIcon:SetSize(iconSize, iconSize)
		parentIcon:Dock(LEFT)
		parentIcon:DockMargin(0, parent:GetTall() * 0.5 - iconSize * 0.5, 0, parent:GetTall() * 0.5 - iconSize * 0.5)

		local parentTitle = leftSide:Add("DLabel")
		parentTitle:SetText(title)
		parentTitle:SetFont("MenuFontLargerNoClamp")
		parentTitle:Dock(LEFT)
		parentTitle:DockMargin(margin, 0, 0, 0)
		parentTitle:SetTextColor(Color(255, 255, 255, 255))
		parentTitle:SizeToContents()

		local parentTextPanel = parent:Add("Panel")
		parentTextPanel:Dock(FILL)

		parent.Text = parentTextPanel:Add("DLabel")
		parent.Text:SetText(text)
		parent.Text:SetFont("MenuFontLargerNoClamp")
		parent.Text:Dock(LEFT)
		parent.Text:SetTextColor(Color(220, 220, 220, 255))
		parent.Text:SetContentAlignment(4)
		parent.Text:SizeToContents()

		local editButtonPanel = parent:Add("Panel")
		editButtonPanel:Dock(RIGHT)
		editButtonPanel:SetWide(iconSize)
		editButtonPanel:DockMargin(padding, 0, 0, 0)

		if editButton then
			editButton:SetParent(editButtonPanel)
			editButton:SetSize(iconSize, iconSize)
			editButton:Dock(RIGHT)
			editButton:DockMargin(0, parent:GetTall() * 0.5 - editButton:GetTall() * 0.5, 0, parent:GetTall() * 0.5 - editButton:GetTall() * 0.5)
		end
	end

	-- Name
	local namePanel = informationSubframe:Add("Panel")
	CreatePart(namePanel, "Имя:", LocalPlayer():GetName(), "name")

	-- Fake name
	local fakeNamePanel = informationSubframe:Add("Panel")

	local editfakenameIcon = fakeNamePanel:Add("DImageButton")
	editfakenameIcon:SetImage("willardnetworks/tabmenu/charmenu/edit_desc.png")

	local fakeName = LocalPlayer():GetCharacter():GetFakeName()
	local displayFakeName = fakeName and (utf8.len(fakeName) <= 34 and fakeName or utf8.sub(fakeName, 1, 34).."...") or "--"

	CreatePart(fakeNamePanel, "Ложное Имя:", displayFakeName, "fakename", false, editfakenameIcon)

	editfakenameIcon.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")

		Derma_StringRequest(L("fakeNameTitle"), L("fakeNameText"), fakeName, function(text)
			local minLength = ix.config.Get("minNameLength", 4)
			local maxLength = ix.config.Get("maxNameLength", 32)
			local nameLength = utf8.len(text)

			if (text != "" and (nameLength > maxLength or nameLength < minLength)) then
				ix.util.NotifyLocalized("fakeNameLength", minLength, maxLength)

				return
			end

			net.Start("ixFakeName")
				net.WriteString(text)
			net.SendToServer()

			if fakeNamePanel.Text then
				fakeNamePanel.Text:SetText(text == "" and "--" or (nameLength <= 34 and text or utf8.sub(text, 1, 34).."..."))
				fakeNamePanel.Text:SizeToContents()
			end
		end)
	end

	-- Genetics
	local geneticAge = string.utf8lower(LocalPlayer():GetCharacter():GetAge())
	local geneticHeight = string.utf8lower(LocalPlayer():GetCharacter():GetHeight())
	local geneticEyecolor = string.utf8lower(LocalPlayer():GetCharacter():GetEyeColor())
	local geneticHaircolor = string.utf8lower(LocalPlayer():GetCharacter():GetHairColor())

	local function firstUpper(str)
		return string.utf8upper(string.utf8sub(str, 1, 1))..string.utf8sub(str, 2)
	end

	local geneticDescPanel = informationSubframe:Add("Panel")
	if LocalPlayer():GetCharacter():IsVortigaunt() then
		CreatePart(geneticDescPanel, "Ген. описание:", firstUpper(geneticAge).." | "..firstUpper(geneticHeight), "genetics")
	else
		CreatePart(geneticDescPanel, "Ген. описание:", firstUpper(geneticAge).." | "..firstUpper(geneticHeight).." | "..firstUpper(geneticEyecolor).." Глаза | "..firstUpper(geneticHaircolor).." Волосы", "genetics")
	end
	-- Description
	local description = LocalPlayer():GetCharacter():GetDescription()

	if string.utf8len(description) > 34 then
		description = string.utf8sub(description, 1, 34)
	end

	local descPanel = informationSubframe:Add("Panel")

	local editdescIcon = descPanel:Add("DImageButton")
	editdescIcon:SetImage("willardnetworks/tabmenu/charmenu/edit_desc.png")

	CreatePart(descPanel, "Описание:", description, "description", false, editdescIcon)

	editdescIcon.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		Derma_StringRequest(LocalPlayer():Name(), "Изменить ваше описание", LocalPlayer():GetCharacter():GetDescription(), function(desc)
			ix.command.Send("CharDesc", desc)

			if (string.utf8len( desc ) < ix.config.Get("minDescriptionLength")) then
				return
			end

			if (!string.find(desc, "%s")) then
				return
			end

			if IsValid(descPanel.Text) then
				if string.utf8len(desc) > 34 then
					local shortenedDesc = string.utf8sub(desc, 1, 34)
					descPanel.Text:SetText(shortenedDesc.."...")
				else
					descPanel.Text:SetText(desc)
				end
			end
		end)
	end

	-- CID
	local citizenID = LocalPlayer():GetCharacter():GetCid() or "Н/Д"

	local cidPanel = informationSubframe:Add("Panel")
	CreatePart(cidPanel, "Гражданский ID:", citizenID, "cid")

	-- Faction
	local faction = ix.faction.indices[LocalPlayer():GetCharacter():GetFaction()]

	local factionPanel = informationSubframe:Add("Panel")
	CreatePart(factionPanel, "Фракция:", faction.name, "faction")

	-- Licenses
	local licensesPanel = informationSubframe:Add("Panel")
	local license = LocalPlayer():GetCharacter():GetGenericdata().permits
	if license then
		CreatePart(licensesPanel, "Лицензии:", "Торговая Лицензия", "licenses", true)
	else
		CreatePart(licensesPanel, "Лицензии:", "Нет лицензии", "licenses", true)
	end

	-- Right side
	local charFrame = self.contentFrame:Add("CharFrame")
end

function PANEL:CreateTitleText()
	local characterTitleIcon = self.titlePanel:Add("DImage")
	characterTitleIcon:SetImage("willardnetworks/tabmenu/charmenu/name.png")
	characterTitleIcon:SetSize(SScaleMin(20 / 3), SScaleMin(20 / 3))

	local characterTitle = self.titlePanel:Add("DLabel")
	characterTitle:SetFont("TitlesFontNoClamp")
	characterTitle:SetText("Персонаж")
	characterTitle:SizeToContents()
	characterTitle:SetPos(SScaleMin(32 / 3), SScaleMin(20 / 3) * 0.5 - characterTitle:GetTall() * 0.5)
end

vgui.Register("CharacterTab", PANEL, "Panel")

hook.Add("CreateMenuButtons", "CharacterTab", function(tabs)
	tabs["Персонаж"] = {

		RowNumber = 1,

		Width = 17,

		Height = 19,

		Icon = "willardnetworks/tabmenu/navicons/character.png",

		Create = function(info, container)
			local panel = container:Add("CharacterTab")
			ix.gui.characterpanel = panel
		end
	}
end)

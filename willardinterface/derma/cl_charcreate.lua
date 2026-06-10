
-- create character panel
DEFINE_BASECLASS("ixCharMenuPanel")
local PANEL = {}
local animationTime = 1

local function DrawFinishButtonAvailable(self, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
	surface.DrawOutlinedRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/tick.png"))
	surface.DrawTexturedRect(w - SScaleMin(15 / 3) - SScaleMin(10 / 3), h * 0.5 - SScaleMin(36 / 3) * 0.5, SScaleMin(15 / 3), SScaleMin(36 / 3))
end

local function DrawFinishButtonNonAvailable(self, w, h)
	surface.SetDrawColor(0, 0, 0, 5)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0, 30)
	surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/tick.png"))
	surface.DrawTexturedRect(w - SScaleMin(15 / 3) - SScaleMin(10 / 3), h * 0.5 - SScaleMin(36 / 3) * 0.5, SScaleMin(15 / 3), SScaleMin(36 / 3))
end

local randomClickSounds = {"aftermath/ui/gui_journal_windowin_r001_01.ogg", "aftermath/ui/gui_journal_windowin_r002_01.ogg", "aftermath/ui/gui_journal_windowin_r003_01.ogg"}

function PANEL:Dim(length, callback)
	self.currentDimAmount = 0
	self.currentY = 0
	self.currentScale = 1
	self.currentAlpha = 255
	self.targetDimAmount = 255
	self.targetScale = 0.9

	length = length or animationTime
	self.currentDimAmount = 0

	self:CreateAnimation(length, {
		target = {
			currentDimAmount = self.targetDimAmount,
			currentScale = self.targetScale,
			OnComplete = callback
		},
		easing = "outCubic"
	})
end

function PANEL:Init()
	local parent = self:GetParent()
	local halfWidth = ScrW() * 0.5

	-- Whitelist Count
	local Count = 0

	for k, v in pairs(ix.faction.teams) do
		if (ix.faction.HasWhitelist(v.index)) then
			Count = Count + 1
		end
	end

	self.WhitelistCount = Count

	self:ResetPayload(true)

	self.repopulatePanels = {}

	local margin = SScaleMin(20 / 3)

	-- faction selection subpanel
	self.factionPanel = self:AddSubpanel("faction", true)
	self.factionPanel:SetTitle("")
	self.factionPanel:SetSize(parent:GetSize())
	self.factionPanel.avoidPadding = true

	local factionImageW = SScaleMin(300 / 3)
	local padding = SScaleMin(150 / 3)

	local panelFaction = self.factionPanel:Add("Panel")

	local titleLabel = panelFaction:Add("DLabel")
	titleLabel:SetTextColor(color_black)
	titleLabel:SetFont("WNMenuTitleNoClamp")
	titleLabel:SetText("Фракции")
	titleLabel:SizeToContents()
	titleLabel:SetContentAlignment(5)
	titleLabel:Dock(TOP)

	local subtitleLabel = panelFaction:Add("DLabel")
	subtitleLabel:SetTextColor(Color(0, 0, 0, 255))
	subtitleLabel:SetFont("WNMenuSubtitleNoClamp")
	subtitleLabel:SetText("Выберите фракцию")
	subtitleLabel:SizeToContents()
	subtitleLabel:DockMargin(0, 0, 0, margin)
	subtitleLabel:SetContentAlignment(5)
	subtitleLabel:Dock(TOP)
	
	local listContentHeight = SScaleMin(500 / 3)
	local textFactionSize = SScaleMin(70 / 3)
	
	if self.WhitelistCount >= 1 and self.WhitelistCount <= 4 then
		panelFaction:SetSize(self.WhitelistCount * (factionImageW + margin), titleLabel:GetTall() + subtitleLabel:GetTall() + listContentHeight + textFactionSize + SScaleMin(30 / 3) + margin)
	elseif self.WhitelistCount > 4 then
		panelFaction:SetSize(4 * (factionImageW + margin), titleLabel:GetTall() + subtitleLabel:GetTall() + listContentHeight + textFactionSize + SScaleMin(30 / 3) + margin)
	end

	panelFaction:Center()

	local factionListContent = panelFaction:Add("Panel")
	factionListContent:SetSize(panelFaction:GetWide(), listContentHeight + textFactionSize)
	factionListContent:Dock(TOP)

	self.factionList = factionListContent:Add("Panel")
	self.factionList:SetSize(self.WhitelistCount * (factionImageW + margin), listContentHeight)

	self.textFaction = factionListContent:Add("Panel")
	self.textFaction:SetSize(self.WhitelistCount * (factionImageW + margin), textFactionSize)
	self.textFaction:SetPos(0, self.factionList:GetTall())

	if self.WhitelistCount > 4 then
		local nextBut = self.factionPanel:Add("DImageButton")
		nextBut:SetSize(SScaleMin(32 / 3), SScaleMin(32 / 3))
		nextBut:SetImage("willardnetworks/charselect/arrow_right.png")
		nextBut:SetColor(Color(0, 0, 0, 255))

		nextBut:Center()
		local x, y = nextBut:GetPos()
		nextBut:MoveRightOf(panelFaction)
		local x2, y2 = nextBut:GetPos()
		
		nextBut:SetPos(x2 + margin, y)

		nextBut.OnCursorEntered = function()
			surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
			nextBut:SetColor( Color( 0, 0, 0, 255 ) )
		end

		nextBut.OnCursorExited = function()
			nextBut:SetColor( Color( 0, 0, 0, 255 ) )
		end

		nextBut.DoClick = function()
			local x, y = self.factionList:GetPos()
			local x2, y2 = self.textFaction:GetPos()

			if math.Round(math.abs( x ), 0) == math.Round((self.WhitelistCount - 5) * (factionImageW + margin), 0) then
				nextBut:SetVisible(false)
			end

			self.factionList:MoveTo( x - (factionImageW + margin), y, 0.1, 0, 1 )
			self.textFaction:MoveTo( x2 - (factionImageW + margin), y2, 0.1, 0, 1 )
			surface.PlaySound("aftermath/ui/gui_journal_windowin_r001_01.ogg")

			if IsValid(self.prevBut) then
				return
			else
				self.prevBut = self.factionPanel:Add("DImageButton")
				local x, y = nextBut:GetPos()

				self.prevBut:SetSize(SScaleMin(32 / 3), SScaleMin(32 / 3))
				self.prevBut:SetImage("willardnetworks/charselect/arrow_left.png")
				self.prevBut:SetColor( Color( 0, 0, 0, 255 ) )
				
				self.prevBut:Center()
				local x, y = self.prevBut:GetPos()
				self.prevBut:MoveLeftOf(panelFaction)
				local x2, y2 = self.prevBut:GetPos()
				
				self.prevBut:SetPos(x2 - margin, y)

				self.prevBut.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_main_toggle_r004_01.ogg")
					self.prevBut:SetColor( Color( 0, 0, 0, 255 ) )
				end

				self.prevBut.OnCursorExited = function()
					self.prevBut:SetColor( Color( 0, 0, 0, 255 ) )
				end

				self.prevBut.DoClick = function()
					local x, y = self.factionList:GetPos()
					local x2, y2 = self.textFaction:GetPos()

					if IsValid(nextBut) then
						nextBut:SetVisible(true)
					end

					surface.PlaySound("aftermath/ui/gui_journal_windowin_r001_01.ogg")
					self.factionList:MoveTo( x + (factionImageW + margin), y, 0.1, 0, 1 )
					self.textFaction:MoveTo( x2 + (factionImageW + margin), y2, 0.1, 0, 1 )

					if IsValid(self.prevBut) then
						if math.Round(x, 0) == math.Round(0 - (factionImageW + margin), 0) then
							self.prevBut:Remove()
						end
					end
				end
			end
		end
	end

	for k, v in SortedPairs(ix.faction.teams) do
		if (ix.faction.HasWhitelist(v.index)) then
			local factionImage = v.factionImage
			local button = self.factionList:Add("DImageButton")
			button:SetImage(factionImage or "scripted/breen_fakemonitor_1")
			button:Dock(LEFT)
			button:DockMargin(margin * 0.5, 0, margin * 0.5, 0)
			button:SetSize( factionImageW, self.factionList:GetTall() )
			button.faction = v.index

			button.PaintOver = function(self, w, h)
				surface.SetDrawColor(Color(73, 82, 87, 255))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			button.Paint = function ( self, w, h )
				surface.SetDrawColor(Color(0, 0, 0, 0))

				if button:IsHovered() then
					button:SetColor( Color( 255, 255,255, 255 ) )
				else
					button:SetColor( Color( 255, 255,255, 255 ) )
				end
			end

			self.torsoBodygroups = "2"
			self.legsBodygroups = "3"
			self.shoesBodygroups = "4"
			self.beardBodygroups = "10"

			button.DoClick = function(panel)
				faction = ix.faction.indices[panel.faction]
				local models = faction:GetModelsFemale(LocalPlayer()) or {"models/willardnetworks/citizens/female_01.mdl"}
				self.payload:Set("faction", panel.faction)
				self.payload:Set("model", 1)
				self.payload:Set("gender", "female")
				self.payload:Set("data", {})
				self.payload.data["languages"] = nil

				if faction:GetModelsFemale(LocalPlayer()) then
					self.characterModel.Entity:SetModel(faction:GetModelsFemale(LocalPlayer())[1] or "models/willardnetworks/citizens/female_01.mdl")
				end

				self.payload.data["age"] = ""
				self.payload.data["height"] = ""
				self.payload.data["eye color"] = ""
				self.payload.data["hair color"] = ""

				self.torsoBodygroups = "2"
				self.legsBodygroups = "3"
				self.shoesBodygroups = "4"
				self.beardBodygroups = "10"

				self.payload.data["groups"] = {}
				self.payload.data["skin"] = 0
				self.payload.data["chosenClothes"] = {}
				self.payload.data.chosenClothes[self.shoesBodygroups] = 0
				self.payload.data.chosenClothes[self.beardBodygroups] = 0

				if self.payload.faction == FACTION_ADMIN then
					self.payload.data.chosenClothes[self.torsoBodygroups] = 28
					self.payload.data.chosenClothes[self.legsBodygroups] = 9

					self.characterModel.Entity:SetBodygroup(2, 28)
					self.characterModel.Entity:SetBodygroup(3, 9)
				else
					self.payload.data.chosenClothes[self.torsoBodygroups] = 0
					self.payload.data.chosenClothes[self.legsBodygroups] = 0
					self.characterModel.Entity:SetBodygroup(2, 0)
					self.characterModel.Entity:SetBodygroup(3, 0)
				end

				self.payload.data["glasses"] = false
				self.payload.data["canread"] = true

				self.payload:Set("special", {})
				self.payload.special["strength"] = 0
				self.payload.special["perception"] = 0
				self.payload.special["agility"] = 0
				self.payload.special["intelligence"] = 0

				self.payload.data["background"] = ""

				surface.PlaySound("aftermath/ui/gui_journal_windowin_r001_01.ogg")

				self.progress:IncrementProgress()

				self:Populate()
				self:SetActiveSubpanel("персонаж")
				self:CheckIfFinished()
				ix.gui.blackBarBottom:ColorTo( Color(0, 0, 0, 255), 1, 1 )
				ix.gui.blackBarTop:ColorTo( Color(0, 0, 0, 255), 1, 1 )
				ix.gui.blackBarTop:SetVisible(true)
				ix.gui.blackBarBottom:SetVisible(true)
				characterButton.DoClick()
				ix.panelCreationActive = true
				ix.gui.mapsceneActive = faction.name
			end

			button.OnCursorEntered = function()
				surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
			end
		end
	end

	for _, v in SortedPairs(ix.faction.teams) do
		if (ix.faction.HasWhitelist(v.index)) then
			local insidePanel = self.textFaction:Add("Panel")
			insidePanel:Dock(LEFT)
			insidePanel:SetSize(factionImageW, self.textFaction:GetTall())
			insidePanel:DockMargin(margin * 0.5, 0, margin * 0.5, 0)

			local text = insidePanel:Add("DLabel")
			text:SetFont("TitlesFontNoBoldNoClamp")
			text:SetText(string.utf8upper(v.name))
			text:SetTextColor(Color(0, 0, 0, 255))
			text:SizeToContents()
			text:Center()
		end
	end

	local backPanel = panelFaction:Add("Panel")
	backPanel:Dock(TOP)
	backPanel:SetSize(panelFaction:GetWide(), SScaleMin(30 / 3))

	local factionBack = backPanel:Add("DButton")
	factionBack:SetText("Назад")
	factionBack:SetContentAlignment(6)
	factionBack:SetSize(SScaleMin(80 / 3), SScaleMin(30 / 3))
	factionBack:SetTextColor(Color(255, 255, 255, 255))
	factionBack:SetFont("WNBackFontNoClamp")
	factionBack:SetTextInset(SScaleMin(10 / 3), 0)
	factionBack:Center()
	factionBack.Paint = function( self, w, h )
		draw.RoundedBox( 10, 0, 0, factionBack:GetWide(), factionBack:GetTall(), Color(78, 79, 100, 240) )

		if factionBack:IsHovered() then
			draw.RoundedBox( 10, 0, 0, factionBack:GetWide(), factionBack:GetTall(), Color(78, 79, 100, 255) )
		end

		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(Material("willardnetworks/mainmenu/back_arrow.png"))
		surface.DrawTexturedRect(SScaleMin(10 / 3), (SScaleMin(30 / 3) * 0.5) - (margin * 0.5), margin, margin)
	end

	factionBack.OnCursorEntered = function()
		surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
		factionBack:SetTextColor(Color(255, 255, 255, 255))
	end

	factionBack.OnCursorExited = function()
		factionBack:SetTextColor(Color(255, 255, 255, 255))
	end

	factionBack.DoClick = function()
		self.progress:DecrementProgress()

		self:SetActiveSubpanel("faction", 0)
		self:SlideDown()

		parent.mainPanel:Undim()
	end

	---------------------------------------------

	-- character customization subpanel
	self.characterPanel = self:AddSubpanel("персонаж")
	self.characterPanel:SetTitle("")
	self.characterPanel:SetSize(self:GetSize())
	self.characterPanel.avoidPadding = true

	local function CreateBlackBar(parent, dock)
		parent:SetType( "Rect" ) -- This is the only type it can be
		parent:SetColor( Color(0, 0, 0, 0) )
		if (dock) == "top" then
			parent:Dock(TOP)
		else
			parent:Dock(BOTTOM)
		end
		parent:SetSize( ScrW(), math.Clamp(VScale(75 / 3), 0, 75) )
	end

	local panelCreationW = SScaleMin(1500 / 3)
	local modelListW = SScaleMin(400 / 3)

	-- new stuff
	local panelCreation = self.characterPanel:Add("Panel")
	panelCreation:SetSize(panelCreationW, ScrH())
	panelCreation:Center()
	local x, y = panelCreation:GetPos()

	local characterModelList = panelCreation:Add("Panel")
	characterModelList:SetSize(modelListW, ScrH())
	characterModelList:Center()

	self.characterModel = characterModelList:Add("ixModelPanel")
	self.characterModel:Dock(FILL)
	self.characterModel:SetModel("models/willardnetworks/citizens/female_01.mdl")
	self.characterModel:SetFOV(26)
	self.characterModel.PaintModel = self.characterModel.Paint

	local innerContent = panelCreation:Add("Panel")
	local margin = SScaleMin(20 / 3)

	local rightCreation = innerContent:Add("Panel")
	rightCreation:Dock(RIGHT)
	rightCreation:SetSize(SScaleMin(460 / 3), panelCreation:GetTall())
	rightCreation:DockMargin(margin, 0, 0, 0)

	local leftCreation = innerContent:Add("Panel")
	leftCreation:Dock(RIGHT)
	leftCreation:SetSize(SScaleMin(160 / 3), panelCreation:GetTall())

	innerContent:SetSize(rightCreation:GetWide() + leftCreation:GetWide() + margin, panelCreation:GetTall())
	innerContent:Center()
	
	local x, y = innerContent:GetPos()
	innerContent:SetPos(x, ScrH() * 0.5 - SScaleMin(743 / 3) * 0.5 + (padding * 0.2))

	characterModelList:MoveLeftOf(innerContent)

	local function CreationTitle(parent, text, topMargin, bottomMargin)
		parent:SetFont("CharCreationBoldTitleNoClamp")
		parent:SetText(string.utf8upper(text))
		parent:SizeToContents()
		parent:DockMargin(0, topMargin, 0, bottomMargin)
		parent:Dock(TOP)
	end

	local leftCreationTitle = leftCreation:Add("DLabel")
	local leftCreationTitle2 = leftCreation:Add("DLabel")
	CreationTitle(leftCreationTitle, "новый", 0, 0)
	leftCreationTitle:SetTextColor(Color(0, 0, 0, 255))
	CreationTitle(leftCreationTitle2, "персонаж", SScaleMin((0 - 5) / 3), SScaleMin(10 / 3))
	leftCreationTitle2:SetTextColor(Color(0, 0, 0, 255))
	

	local buttonList = {}

	local function drawButtonUnselected(text, self, w, h, boolMainButton)
		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
		surface.DrawOutlinedRect(0, 0, w, h)
		if boolMainButton then
			if self:IsHovered() then
				self:SetTextColor(Color(0, 0, 0, 255))
				surface.SetDrawColor(Color(0, 0, 0, 255))
			else
				self:SetTextColor(Color(0, 0, 0, 255))
				surface.SetDrawColor(Color(0, 0, 0, 160))
			end

			surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/"..text..".png"))
			surface.DrawTexturedRect(SScaleMin(9 / 3), SScaleMin(9 / 3), margin, margin)
		end
	end

	local function drawButtonSelected(text, self, w, h, boolMainButton)
		surface.SetDrawColor(Color(78, 79, 100, 240))
		surface.DrawRect(0, 0, w, h)

		if boolMainButton then
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/"..text..".png"))
			surface.DrawTexturedRect(SScaleMin(9 / 3), SScaleMin(9 / 3), margin, margin)
		end
	end

	local function ClearSelected()
		for k, v in pairs(buttonList) do
			v:SetTextColor(Color(0, 0, 0, 255))
			v.Paint = function(self, w, h)
				drawButtonUnselected(v.id, self, w, h, true)
			end
		end

		for k, v in pairs(rightCreation:GetChildren()) do
			v:SetVisible(false)
		end

		if IsValid(dropdownMenu) then
			dropdownMenu:Remove()
		end
	end

	local function createButton(parent, text, id)
		parent:SetText(string.utf8upper(text))
		parent:SetFont("WNMenuFontNoClamp")
		parent:SetContentAlignment(4)
		parent:SetTextInset(SScaleMin(35 / 3), 0)
		parent:SetTextColor(Color(0, 0, 0, 255))
		parent:Dock(TOP)
		parent:SetSize(SScaleMin(160 / 3), SScaleMin(36 / 3))
		parent:DockMargin(0, 0, 0, SScaleMin(10 / 3))
		parent.name = text
		parent.id = id

		parent.OnCursorEntered = function()
			surface.PlaySound("aftermath/ui/gui_main_toggle_r004_01.ogg")
		end

		parent.Paint = function(self, w, h)
			drawButtonUnselected(id, self, w, h, true)
		end

		table.insert(buttonList, parent)
	end

	local function SetSelected(parent, text, boolMainButton)
		parent:SetTextColor(Color(0, 0, 0, 255))
		parent.Paint = function(self, w, h)
			drawButtonSelected(self.id, self, w, h, boolMainButton)
		end
	end

	-- Right side stuff
	-- Create text panel
	local function CreateRightMenuTextPanel(text, topMargin)
		local textPanel = rightCreation:Add("Panel")
		textPanel:Dock(TOP)
		textPanel:SetTall(margin)
		textPanel:DockMargin(0, SScaleMin(topMargin / 3), 0, SScaleMin(10 / 3))

		local panelText = textPanel:Add("DLabel")
		panelText:SetText(string.utf8upper(text))
		panelText:SetTextColor(Color(0, 0, 0, 255))
		panelText:SetFont("MenuFontNoClamp")
		panelText:SizeToContents()
		panelText:Dock(LEFT)
		panelText:SetContentAlignment(4)
	end

	-- Create Text Entry
	local function CreateRightMenuTextEntry(parent, text, height, boolMultiline, maxChars, name)
		parent:Dock(TOP)
		parent:SetTall(SScaleMin(height / 3))
		parent:DockMargin(0, 0, 0, SScaleMin(10 / 3))
		parent:SetMultiline( boolMultiline )
		parent:SetVerticalScrollbarEnabled( boolMultiline )
		parent:SetEnterAllowed( boolMultiline )
		parent:SetTextColor(Color(0, 0, 0, 255))
		parent:SetCursorColor(Color(0, 0, 0, 255))
		parent:SetFont("MenuFontNoClamp")
		if name == "name" then
			parent:SetText(self.payload.name or text)
		elseif name == "desc" then
			parent:SetText(self.payload.description or text)
		end

		parent.Paint = function(self, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 100))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
			surface.DrawOutlinedRect(0, 0, w, h)

			self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
		end

		parent.MaxChars = maxChars
		parent.OnTextChanged = function(parentSelf)
			if name == "name" then
				self.payload:Set("name", parentSelf:GetValue())
			end

			if name == "desc" then
				self.payload:Set("description", parentSelf:GetValue())
			end

			self:CheckIfFinished()
		end
	end

	local function GetActiveSkinEyeColorTable()
		local eyeColorBrownSkins = { 0, 1, 2, 3, 4 }
		local eyeColorBlueSkins = { 5, 6, 7, 8, 9 }
		local eyeColorGreenSkins = { 10, 11, 12, 13, 14 }
		local entityModel = self.characterModel.Entity:GetModel()

		if (string.match(entityModel, "/male02")) then
			eyeColorBrownSkins = { 0, 1, 2, 3, 4, 5, 6, 7, 8 }
			eyeColorBlueSkins = { 9, 10, 11, 12, 13, 14, 15, 16, 17 }
			eyeColorGreenSkins = { 18, 19, 20, 21, 22, 23, 24, 25, 26 }
		end

		if (string.match(entityModel, "/male06")) then
			eyeColorBrownSkins = { 0, 1, 2, 3, 4, 5 }
			eyeColorBlueSkins = { 6, 7, 8, 9, 10, 11 }
			eyeColorGreenSkins = { 12, 13, 14, 15, 16, 17 }
		end

		if (string.match(entityModel, "/male07")) then
			eyeColorBrownSkins = { 0, 1, 2, 3, 4, 5, 6 }
			eyeColorBlueSkins = { 7, 8, 9, 10, 11, 12, 13 }
			eyeColorGreenSkins = { 14, 15, 16, 17, 18, 19, 20 }
		end

		if (string.match(entityModel, "/male10")) then
			eyeColorBrownSkins = { 0 }
			eyeColorBlueSkins = { 1 }
			eyeColorGreenSkins = { 2 }
		end

		if (string.match(entityModel, "/female_03")) then
			eyeColorBrownSkins = { 0, 1, 2, 3 }
			eyeColorBlueSkins = { 4, 5, 6, 7 }
			eyeColorGreenSkins = { 8, 9, 10, 11 }
		end

		local activeEyeColor = eyeColorBrownSkins

		if self.payload.data["eye color"] == "СИНИЕ" or self.payload.data["eye color"] == "СЕРЫЕ" then
			activeEyeColor = eyeColorBlueSkins
		end

		if self.payload.data["eye color"] == "ЗЕЛЁНЫЕ" then
			activeEyeColor = eyeColorGreenSkins
		end

		if self.payload.data["eye color"] == "КАРИЕ" or self.payload.data["eye color"] == "КОРИЧНЕВЫЕ"
		or self.payload.data["eye color"] == "ЯНТАРНЫЕ"  then
			activeEyeColor = eyeColorBrownSkins
		end

		return activeEyeColor
	end

	local originPos = self.characterModel:GetCamPos()
	local originLookAt = self.characterModel:GetLookAt()

	-- Create gender button
	local function CreateGenderButton(self, parent, icon, w, h, rightMargin, gender)
		parent:SetSize( SScaleMin(w / 3), SScaleMin(h / 3) )
		parent:SetImage( icon )
		parent:Dock(RIGHT)
		parent:DockMargin(0, 0, SScaleMin(rightMargin / 3), 0)
		parent:SetColor(Color(150, 150, 150, 255))

		if self.payload.gender != "male" and self.payload.gender != "female" then
			self.payload:Set("gender", "female")
		end

		if gender == "male" and self.payload.gender == "male" then
			parent:SetColor(Color(230, 30, 30, 255))
		end

		if gender == "female" and self.payload.gender == "female" then
			parent:SetColor(Color(230, 30, 30, 255))
		end

		parent.OnCursorEntered = function()
			surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
		end

		parent.DoClick = function()
			local faction = ix.faction.indices[self.payload.faction]
			surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
			parent:SetColor(Color(230, 30, 30, 255))

			if gender == "female" then
				if genderButtonMale then
					genderButtonMale:SetColor(Color(150, 150, 150, 255))
				end

				self.payload:Set("gender", "female")
				self.payload:Set("model", 1)
			else
				if genderButtonFemale then
					genderButtonFemale:SetColor(Color(150, 150, 150, 255))
				end

				self.payload:Set("gender", "male")
				self.payload:Set("model", 1)
			end

			self.characterModel:SetFOV(26)
			self.characterModel:SetCamPos(originPos)
			self.characterModel:SetLookAt(originLookAt)

			local eyeColorTable = GetActiveSkinEyeColorTable()

			self.characterModel.Entity:SetSkin(eyeColorTable[1] or 0)
			self.payload.data["skin"] = eyeColorTable[1]

			self.payload.data["groups"] = {}
			self.payload.data["glasses"] = false
			self.payload.data["canread"] = true
			if self.payload.faction == FACTION_ADMIN then
				self.payload.data.chosenClothes[self.torsoBodygroups] = 28
				self.payload.data.chosenClothes[self.legsBodygroups] = 9

				self.characterModel.Entity:SetBodygroup(2, 28)
				self.characterModel.Entity:SetBodygroup(3, 9)
			else
				self.payload.data.chosenClothes[self.torsoBodygroups] = 0
				self.payload.data.chosenClothes[self.legsBodygroups] = 0
			end

			self.payload.data.chosenClothes[self.shoesBodygroups] = 0
			self.payload.data.groups[self.beardBodygroups] = 0

			self:CheckIfFinished()
		end
	end

	-- Create custom DComboBox
	local function CreateSelectionMenu(self, parent, width, text, dataid, selections)
		local faction = ix.faction.indices[self.payload.faction]

		if self.payload.data == nil then
			self.payload:Set("data", {})
			self.payload.data["age"] = ""
			self.payload.data["height"] = ""
			self.payload.data["eye color"] = ""
			self.payload.data["hair color"] = ""
			self.payload.data["languages"] = {}
		end

		parent:Dock(LEFT)
		parent:SetWide(SScaleMin(width / 3))

		if (self.payload.data[dataid] != nil and self.payload.data[dataid] != "") then
			if (string.utf8len(self.payload.data[dataid]) > 7) and faction.name != "Вортигонт" then
				parent:SetText(string.utf8sub(self.payload.data[dataid], 1, 7).."..")
			elseif faction.name == "Вортигонт" and string.utf8len(self.payload.data[text]) > 20 then
				parent:SetText(string.utf8sub(self.payload.data[dataid], 1, 20).."..")
			else
				parent:SetText(self.payload.data[dataid])
			end
		else
			parent:SetText(string.utf8upper(text))
		end
		parent:DockMargin(0, 0, SScaleMin(13 / 3), 0)
		parent:SetFont("MenuFontNoClamp")
		parent:SetTextColor(Color(0, 0, 0, 255))
		parent:SetContentAlignment(4)
		parent:SetTextInset(SScaleMin(10 / 3), 0)
		parent.Paint = function(self, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 100))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
			surface.DrawOutlinedRect(0, 0, w, h)

			local alpha = (self:IsHovered()) and 255 or 100
			surface.SetDrawColor(ColorAlpha(Color(0, 0, 0, 255), alpha))
			surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/combodownarrow.png"))
			surface.DrawTexturedRect(w - SScaleMin(9 / 3) - SScaleMin(10 / 3), h * 0.5 - SScaleMin(5 / 3) * 0.5, SScaleMin(9 / 3), SScaleMin(5 / 3))
		end

		local savedText = parent:GetText()

		parent.OnCursorEntered = function()
			surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
			savedText = parent:GetText()
			parent:SetText(string.utf8upper(text))
		end

		parent.OnCursorExited = function()
			parent:SetText(string.utf8upper(savedText))
		end

		parent.DoClick = function()
			if dataid == "eye color" and (self.payload.faction == FACTION_CITIZEN or self.payload.faction == FACTION_ADMIN or self.payload.faction == FACTION_WORKERS) then
				if self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") then
					local eyepos = self.characterModel.Entity:GetBonePosition( self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") )
					if eyepos then
						self.characterModel:SetLookAt(eyepos)

						self.characterModel:SetCamPos(eyepos-Vector(-12, -12, 0))	-- Move cam in front of eyes
						self.characterModel:SetFOV(34)
					end
				end
			else
				self.characterModel:SetFOV(26)
				self.characterModel:SetCamPos(originPos)
				self.characterModel:SetLookAt(originLookAt)
			end

			surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
			if IsValid(dropdownMenu) then
				dropdownMenu:Remove()
				return
			end

			dropdownMenu = panelCreation:Add("DScrollPanel")

			if #selections < 8 then
				dropdownMenu:SetSize( SScaleMin(width / 3), #selections * (SScaleMin(36 / 3) / 2) - (#selections * 1) )
			else
				dropdownMenu:SetSize( SScaleMin(width / 3), (SScaleMin(36 / 3) / 2 ) * 8 - (#selections * 1) )
			end

			dropdownMenu:SetPos(panelCreation:ScreenToLocal( parent:LocalToScreen( 0, SScaleMin(36 / 3) ) ))

			dropdownMenu.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			for k, v in pairs(selections) do
				local selectionButton = dropdownMenu:Add("DButton")
				selectionButton:Dock(TOP)
				selectionButton:SetTall( SScaleMin(36 / 3) / 2 )
				selectionButton:SetText(string.utf8upper(v))
				selectionButton:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
				selectionButton:SetContentAlignment(4)
				selectionButton:SetTextInset(SScaleMin(10 / 3), 0)
				selectionButton:SetFont("WNBackFontNoClamp")

				if dataid == "language" then
					local languageText = ix.languages:FindByID(v).name or v
					selectionButton:SetText(string.utf8upper(languageText))
				end

				selectionButton.Paint = function(self, w, h)
					surface.SetDrawColor(Color(0, 0, 0, 100))
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
					surface.DrawRect(0, 0, w, h)
				end

				selectionButton.DoClick = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
					if self.payload.data == nil then
						self.payload.data = {}
					end

					self.payload.data[dataid] = selectionButton:GetText() or ""

					if dataid == "eye color" then
						local eyeColorTable = GetActiveSkinEyeColorTable()

						self.characterModel.Entity:SetSkin(eyeColorTable[1] or 0)
						self.payload.data["skin"] = eyeColorTable[1]
					end

					if dataid == "language" then
						self.payload.data["languages"] = {v}
					end

					if string.utf8len(selectionButton:GetText()) > 7 and faction.name != "Вортигонт" then
						parent:SetText(string.utf8sub(selectionButton:GetText(), 1, 7).."..")
					elseif faction.name == "Вортигонт" and string.utf8len(selectionButton:GetText()) > 20 then
						parent:SetText(string.utf8sub(selectionButton:GetText(), 1, 20).."..")
					else
						parent:SetText(selectionButton:GetText())
					end

					if IsValid(dropdownMenu) then
						dropdownMenu:Remove()
					end

					self:CheckIfFinished()
				end
			end

			self:CheckIfFinished()
		end
	end

	-- Create important textpanel
	local function CreateRightMenuYellowTextPanel(text, topMargin)
		local textPanel = rightCreation:Add("Panel")
		textPanel:Dock(TOP)
		textPanel:SetTall(margin)
		textPanel:DockMargin(0, SScaleMin(topMargin / 3), 0, SScaleMin(10 / 3))

		local warningIcon = textPanel:Add("DImage")
		warningIcon:SetSize(SScaleMin(12 / 3), margin)
		warningIcon:Dock(LEFT)
		warningIcon:DockMargin(0, 0, SScaleMin(8 / 3), 0)
		warningIcon:SetImage("willardnetworks/mainmenu/charcreation/warning.png")
		warningIcon:SetImageColor(Color(0, 0, 0))

		local panelText = textPanel:Add("DLabel")
		panelText:SetText(text)
		panelText:SetFont("WNBackFontNoClamp")
		panelText:SizeToContents()
		panelText:SetTextColor(Color(0, 0, 0, 255))
		panelText:Dock(LEFT)
		panelText:SetContentAlignment(4)
	end

	-- Create bot right side part (next, back, finish)
	local function createNextBackFinishButtons(parentBack, parentNext, parentFinish, boolNext)
		local function Paint(self, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 100))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		parentBack:Dock(LEFT)
		parentBack:SetWide(SScaleMin(100 / 3))
		parentBack:SetText(string.utf8upper("назад"))
		parentBack:SetContentAlignment(6)
		parentBack:SetTextInset(SScaleMin(10 / 3), 0)
		parentBack:SetFont("MenuFontNoClamp")
		parentBack.Paint = function(self, w, h)
			Paint(self, w, h)

			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/leftarrow.png"))
			surface.DrawTexturedRect(SScaleMin(10 / 3), h * 0.5 - SScaleMin(36 / 3) * 0.5, SScaleMin(7 / 3), SScaleMin(36 / 3))
		end

		parentBack.OnCursorEntered = function()
			surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
		end

		parentBack.DoClick = function()
			ix.gui.background_url = "aftermath/"..table.Random(ix.gui.backgrounds)..".jpg"
			self.progress:DecrementProgress()
			ix.panelCreationActive = false
			ix.gui.mapsceneActive = nil
			ix.gui.blackBarBottom:ColorTo( Color(0, 0, 0, 0), 0, 0 )
			ix.gui.blackBarTop:ColorTo( Color(0, 0, 0, 0), 0, 0 )
			ix.gui.blackBarTop:SetVisible(false)
			ix.gui.blackBarBottom:SetVisible(false)

			if (self.WhitelistCount == 1) then
				factionBack:DoClick()
			else
				self:SetActiveSubpanel("faction")
			end

			self.characterModel:SetFOV(26)
			self.characterModel:SetCamPos(originPos)
			self.characterModel:SetLookAt(originLookAt)
		end

		parentNext:Dock(LEFT)
		parentNext:DockMargin(SScaleMin(10 / 3), 0, 0, 0)
		parentNext:SetWide(SScaleMin(100 / 3))
		parentNext:SetText(string.utf8upper("далее"))
		parentNext:SetContentAlignment(4)
		parentNext:SetTextInset(SScaleMin(10 / 3), 0)
		parentNext:SetFont("MenuFontNoClamp")
		parentNext.Paint = function(self, w, h)
			if boolNext then
				parentNext:SetTextColor(Color(0, 0, 0, 30))
				surface.SetDrawColor(0, 0, 0, 5)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(0, 0, 0, 30)
				surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/rightarrow.png"))
				surface.DrawTexturedRect(w - SScaleMin(7 / 3) - SScaleMin(10 / 3), h * 0.5 - SScaleMin(36 / 3) * 0.5, SScaleMin(7 / 3), SScaleMin(36 / 3))

				return
			else
				Paint(self, w, h)
			end

			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetMaterial(Material("willardnetworks/mainmenu/charcreation/rightarrow.png"))
			surface.DrawTexturedRect(w - SScaleMin(7 / 3) - SScaleMin(10 / 3), h * 0.5 - SScaleMin(36 / 3) * 0.5, SScaleMin(7 / 3), SScaleMin(36 / 3))
		end

		parentNext.OnCursorEntered = function()
			if boolNext then
				return
			end

			surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
		end

		parentFinish:Dock(LEFT)
		parentFinish:DockMargin(SScaleMin(10 / 3), 0, 0, 0)
		parentFinish:SetWide(SScaleMin(100 / 3))
		parentFinish:SetTextColor(Color(0, 0, 0, 30))
		parentFinish:SetText(string.utf8upper("готово"))
		parentFinish:SetContentAlignment(4)
		parentFinish:SetTextInset(SScaleMin(10 / 3), 0)
		parentFinish:SetFont("MenuFontNoClamp")
		parentFinish.Paint = function(self, w, h)
			DrawFinishButtonNonAvailable(self, w, h)
		end
	end

	-- Character Button
	characterButton = leftCreation:Add("DButton")
	createButton(characterButton, "персонаж", "character")
	characterButton.DoClick = function()
		ClearSelected()
		SetSelected(characterButton, "персонаж", true)
		if ix.panelCreationActive == true then
			surface.PlaySound(table.Random(randomClickSounds))
		end

		CreateRightMenuTextPanel(faction:GetNoGender(LocalPlayer()) != true and "имя/пол" or "name", 60)

		-- Name
		local nameGenderPanel = rightCreation:Add("DTextEntry")
		CreateRightMenuTextEntry(nameGenderPanel, "", 36, false, 35, "name")

		if faction:GetNoGender(LocalPlayer()) != true then
			-- Gender
			genderButtonFemale = nameGenderPanel:Add("DImageButton")
			CreateGenderButton(self, genderButtonFemale, "willardnetworks/mainmenu/charcreation/female.png", 13, 36, 10, "female")

			genderButtonMale = nameGenderPanel:Add("DImageButton")
			CreateGenderButton(self, genderButtonMale, "willardnetworks/mainmenu/charcreation/male.png", 16, 36, 5, "male")
		end

		local minLength = ix.config.Get("minNameLength", 4)
		local maxLength = ix.config.Get("maxNameLength", 32)

		CreateRightMenuYellowTextPanel("Ваше имя должно состоять из минимум "..minLength.." букв и максимум из "..maxLength.." буквы", -1)

		if faction:GetNoGenetics(LocalPlayer()) != true then
			-- Genetics
			CreateRightMenuTextPanel("генетическое описание", 10)

			local comboBoxPanel = rightCreation:Add("Panel")
			comboBoxPanel:Dock(TOP)
			comboBoxPanel:SetTall(SScaleMin(36 / 3))

			local ageComboBox = comboBoxPanel:Add("DButton")
			if faction.name == "Вортигонт" then
				CreateSelectionMenu(self, ageComboBox, 200 + 13 + 10, "возраст", "age", {"молодой (0 - 100)", "зрелый-молодой (100 - 500)", "взрослый (500 - 1000)", "мудрый (1000 - 1500)", "старейший (1500 - 2000)"})
			else
				CreateSelectionMenu(self, ageComboBox, 100, "возраст", "age", {"молодой", "взрослый", "средних-лет", "пожилой"})
			end

			local heightComboBox = comboBoxPanel:Add("DButton")

			if faction.name == "Гражданская Оборона" then
				CreateSelectionMenu(self, heightComboBox, 100, "рост", "height", {"5'5\"", "5'6\"", "5'8\"", "5'10\"", "6'0\"", "6'2\"", "6'4\"", "6'6\""})
			elseif faction.name == "Вортигонт" then
				CreateSelectionMenu(self, heightComboBox, 200 + 13 + 10, "рост", "height", {"5'6\"", "5'7\"", "5'8\"", "5'10\"", "6'0\"", "6'2\"", "6'4\"", "6'6\"", "6'8\"", "6'11\""})
			else
				CreateSelectionMenu(self, heightComboBox, 100, "рост", "height", {"4'10\"", "5'0\"", "5'2\"", "5'4\"", "5'6\"", "5'8\"", "5'10\"", "6'0\"", "6'2\"", "6'4\"", "6'6\""})
			end

			if faction.name != "Вортигонт" then
				local eyeColorBox = comboBoxPanel:Add("DButton")
				CreateSelectionMenu(self, eyeColorBox, 110, "цвет глаз", "eye color", {"синие", "зелёные", "коричневые", "карие", "янтарные", "серые"})

				local hairColorBox = comboBoxPanel:Add("DButton")
				CreateSelectionMenu(self, hairColorBox, 110, "цвет волос", "hair color", {"тёмно-коричневые", "светлые", "чёрные", "тёмно-рыжие", "каштановые", "рыжие", "серые", "белые", "лысый"})
			end

			CreateRightMenuYellowTextPanel("Генетическое описание вашего персонажа остается неизменным.", 10)
		end

		if faction.name != "ИИ Надзора" then
			local languages = {}
			if (ix.languages) then
				for _, v in pairs(ix.languages.stored) do
					if (!v.notSelectable) then
						table.insert(languages, v.uniqueID)
					end
				end
			end

			CreateRightMenuTextPanel("второй язык", 10)

			local languageBoxPanel = rightCreation:Add("Panel")
			languageBoxPanel:Dock(TOP)
			languageBoxPanel:SetTall(SScaleMin(36 / 3))

			local languageComboBox = languageBoxPanel:Add("DButton")
			CreateSelectionMenu(self, languageComboBox, 100, "язык", "language", languages)
		end

		-- Description
		CreateRightMenuTextPanel("описание персонажа", 20)
		local charDescPanel = rightCreation:Add("DTextEntry")
		CreateRightMenuTextEntry(charDescPanel, "Напишите описание своего персонажа здесь...", 130, true, 1000, "desc")

		local minDescLength = ix.config.Get("minDescriptionLength", 16)
		CreateRightMenuYellowTextPanel("Описание должно содержать не менее "..minDescLength.." букв", -1)

		-- Bottom part
		local buttonPanel = rightCreation:Add("Panel")
		buttonPanel:Dock(TOP)
		buttonPanel:DockMargin(SScaleMin(140 / 3), SScaleMin(20 / 3), 0, 0)
		buttonPanel:SetTall(SScaleMin(36 / 3))

		local backButton = buttonPanel:Add("DButton")
		local nextButton = buttonPanel:Add("DButton")
		finishButton = buttonPanel:Add("DButton")
		createNextBackFinishButtons(backButton, nextButton, finishButton)
		nextButton.DoClick = function()
			appearancesButton.DoClick()
		end
		self:CheckIfFinished()
	end

	appearancesButton = leftCreation:Add("DButton")
	createButton(appearancesButton, "внешность", "appearances")

	appearancesButton.DoClick = function()
		local faction = ix.faction.indices[self.payload.faction]

		local function GetFactionModelsGender()
			if self.payload.gender == "male" and faction:GetModelsMale(LocalPlayer()) then
				return faction:GetModelsMale(LocalPlayer())
			elseif self.payload.gender == "female" and faction:GetModelsFemale(LocalPlayer()) then
				return faction:GetModelsFemale(LocalPlayer())
			else
				return faction:GetModels(LocalPlayer())
			end
		end

		ClearSelected()
		SetSelected(appearancesButton, "внешность", true)
		surface.PlaySound(table.Random(randomClickSounds))

		CreateRightMenuTextPanel("выбор модели", 60)

		local modelSelectionPanel = rightCreation:Add("DScrollPanel")
		modelSelectionPanel:Dock(TOP)

		local modelSelectionGrid = modelSelectionPanel:Add( "DGrid" )

		local iconSize = SScaleMin(94 / 3)

		if (rightCreation:GetWide() - (SScaleMin(94 / 3) * 6)) >= SScaleMin(94 / 3) then
			modelSelectionGrid:SetCols( 6 )
		elseif (rightCreation:GetWide() - (SScaleMin(94 / 3) * 7)) >= SScaleMin(94 / 3) then
			modelSelectionGrid:SetCols( 7 )
		elseif (rightCreation:GetWide() - (SScaleMin(94 / 3) * 8)) >= SScaleMin(94 / 3) then
			modelSelectionGrid:SetCols( 8 )
		else
			modelSelectionGrid:SetCols( 5 )
		end
		
		local rowCount = math.ceil(#GetFactionModelsGender() / modelSelectionGrid:GetCols())
		modelSelectionGrid:SetColWide( rowCount > 2 and iconSize - 5 or iconSize )
		modelSelectionGrid:SetRowHeight( iconSize )
		
		modelSelectionPanel:SetTall(math.Clamp(rowCount, 0, 2) * iconSize)

		local skinButtonList = {}
		local beardButtonList = {}
		local glassesButtonList = {}
		local canreadButtonList = {}

		local function ClearSelectedSkins()
			for k, v in pairs(skinButtonList) do
				v.Paint = function(self, w, h)
					drawButtonUnselected(v.name, self, w, h, false)
				end
			end
		end

		local function RefreshSkins()
			if !table.IsEmpty(skinButtonList) then
				table.Empty(skinButtonList)
			end

			if !table.IsEmpty(beardButtonList) then
				table.Empty(beardButtonList)
			end

			if !table.IsEmpty(glassesButtonList) then
				table.Empty(glassesButtonList)
			end

			for k, v in pairs(skinButtonPanel:GetChildren()) do
				v:Remove()
			end

			if self.payload.gender == "male" then
				for k, v in pairs(beardButtonPanel:GetChildren()) do
					v:Remove()
				end
			end

			for k, v in pairs(glassesButtonPanel:GetChildren()) do
				v:Remove()
			end

			if self.payload.data == nil then
				self.payload:Set("data", {})
				self.payload.data["skin"] = 0
				self.payload.data.groups[self.beardBodygroups] = 0
				self.payload.data["glasses"] = false
			end

			local eyeColorTable = GetActiveSkinEyeColorTable()

			for k, v in pairs(eyeColorTable) do
				local skinButton = skinButtonPanel:Add("DButton")
				skinButton:Dock(LEFT)
				skinButton:SetWide(math.Round(rightCreation:GetWide() / (#eyeColorTable)) - SScaleMin(10 / 3))
				skinButton:DockMargin(0, 0, SScaleMin(10 / 3), 0)
				skinButton:SetText(k)
				skinButton:SetTextColor(Color(0, 0, 0, 255))
				skinButton:SetFont("MenuFontNoClamp")
				skinButton.name = k

				table.insert(skinButtonList, skinButton)

				if self.payload.data["skin"] == v then
					SetSelected(skinButton, k, false)
				else
					skinButton.Paint = function(selfSkin, w, h)
						surface.SetDrawColor(Color(0, 0, 0, 100))
						surface.DrawRect(0, 0, w, h)

						surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
						surface.DrawOutlinedRect(0, 0, w, h)
					end
				end

				skinButton.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				skinButton.DoClick = function()
					ClearSelectedSkins()
					SetSelected(skinButton, k, false)
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
					self.payload.data["skin"] = v
					self.characterModel.Entity:SetSkin(v)
					if (self.payload.faction == FACTION_CITIZEN or self.payload.faction == FACTION_ADMIN or self.payload.faction == FACTION_WORKERS) then
						local bone = self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
						if (bone) then
							local eyepos = self.characterModel.Entity:GetBonePosition(bone)
							self.characterModel:SetLookAt(eyepos)

							self.characterModel:SetCamPos(eyepos-Vector(-12, -12, 0))	-- Move cam in front of eyes
							self.characterModel:SetFOV(34)
						end
					end
				end
			end

			if self.payload.gender == "male" then
				for i = 0, 8 do
					local beardButton = beardButtonPanel:Add("DButton")
					beardButton:Dock(LEFT)
					if i == 0 then
						beardButton:SetText("НЕТ БОРОДЫ")
						beardButton:SetTextColor(Color(0, 0, 0, 255))
						beardButton:SetWide((math.Round(rightCreation:GetWide() / 9) * 2) - SScaleMin(10 / 3))
					else
						beardButton:SetText(i + 1)
						beardButton:SetWide(math.Round(rightCreation:GetWide() / 10) - SScaleMin(10 / 3))
					end
					beardButton:DockMargin(0, 0, SScaleMin(10 / 3), 0)
					beardButton:SetFont("MenuFontNoClamp")
					beardButton.name = i

					table.insert(beardButtonList, beardButton)

					if self.payload.data.groups[self.beardBodygroups] == i then
						SetSelected(beardButton, i, false)
					else
						beardButton.Paint = function(selfSkin, w, h)
							surface.SetDrawColor(Color(0, 0, 0, 100))
							surface.DrawRect(0, 0, w, h)

							surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
							surface.DrawOutlinedRect(0, 0, w, h)
						end
					end

					beardButton.OnCursorEntered = function()
						surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
					end

					beardButton.DoClick = function()
						for k, v in pairs(beardButtonList) do
							v.Paint = function(self, w, h)
								drawButtonUnselected(v.name, self, w, h, false)
							end
						end

						SetSelected(beardButton, i, false)
						surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
						self.payload.data.groups[self.beardBodygroups] = i
						self.characterModel.Entity:SetBodygroup(10, i)
						if (self.payload.faction == FACTION_CITIZEN or self.payload.faction == FACTION_ADMIN or self.payload.faction == FACTION_WORKERS) then
							if self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") then
								local eyepos = self.characterModel.Entity:GetBonePosition( self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") )
								if eyepos then
									self.characterModel:SetLookAt(eyepos)

									self.characterModel:SetCamPos(eyepos-Vector(-12, -12, 0))	-- Move cam in front of eyes
									self.characterModel:SetFOV(34)
								end
							end
						end
					end
				end
			end

			for i = 1, 2 do
				local glassesButton = glassesButtonPanel:Add("DButton")
				glassesButton:Dock(LEFT)
				if i == 1 then
					glassesButton:SetText("НЕТ")
					glassesButton:SetTextColor(Color(0, 0, 0, 255))
				else
					glassesButton:SetText("ДА")
					glassesButton:SetTextColor(Color(0, 0, 0, 255))
				end
				glassesButton:SetWide((math.Round(rightCreation:GetWide() / 2) - SScaleMin(10 / 3)))
				glassesButton:DockMargin(0, 0, SScaleMin(10 / 3), 0)
				glassesButton:SetFont("MenuFontNoClamp")
				glassesButton.name = glassesButton:GetText()

				table.insert(glassesButtonList, glassesButton)

				if self.payload.data.glasses == true and i == 2 then
					SetSelected(glassesButton, "ДА", false)
				elseif self.payload.data.glasses == false and i == 1 then
					SetSelected(glassesButton, "НЕТ", false)
				else
					glassesButton.Paint = function(selfSkin, w, h)
						surface.SetDrawColor(Color(0, 0, 0, 100))
						surface.DrawRect(0, 0, w, h)

						surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
						surface.DrawOutlinedRect(0, 0, w, h)
					end
				end

				glassesButton.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				glassesButton.DoClick = function()
					for k, v in pairs(glassesButtonList) do
						v.Paint = function(self, w, h)
							drawButtonUnselected(v.name, self, w, h, false)
						end
					end

					SetSelected(glassesButton, glassesButton.name, false)
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
					if i == 2 then
						self.payload.data["glasses"] = true
						self.characterModel.Entity:SetBodygroup(8, 1)
						self.payload.data.chosenClothes["8"] = 1
					else
						self.payload.data["glasses"] = false
						self.characterModel.Entity:SetBodygroup(8, 0)
						self.payload.data.chosenClothes["8"] = 0
					end

					self.characterModel:SetFOV(26)
					self.characterModel:SetCamPos(originPos)
					self.characterModel:SetLookAt(originLookAt)
				end
			end
		end

		local function CheckForSkinCount(model)
			for k2, v2 in pairs(skinButtonList) do
				if v2.name == 1 then
					SetSelected(v2, k, false)
				end
			end
		end

		for k, v in pairs(GetFactionModelsGender()) do
			local iconbg = vgui.Create("Panel")
			iconbg:SetSize(SScaleMin(84 / 3), SScaleMin(84 / 3))
			iconbg.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			local icon = iconbg:Add("SpawnIcon")
			icon:SetSize(SScaleMin(82 / 3), SScaleMin(82 / 3))
			icon:Center()
			icon:InvalidateLayout(true)

			icon.OnCursorEntered = function()
				surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
			end

			icon.DoClick = function(this)
				CheckForSkinCount(v)

				self.payload:Set("model", k)

				if self.payload.data.chosenClothes[self.torsoBodygroups] then
					self.characterModel.Entity:SetBodygroup(tonumber(self.torsoBodygroups), tonumber(self.payload.data.chosenClothes[self.torsoBodygroups]))
				end

				if self.payload.data.chosenClothes[self.legsBodygroups] then
					self.characterModel.Entity:SetBodygroup(tonumber(self.legsBodygroups), tonumber(self.payload.data.chosenClothes[self.legsBodygroups]))
				end

				if self.payload.data.chosenClothes[self.shoesBodygroups] then
					self.characterModel.Entity:SetBodygroup(tonumber(self.shoesBodygroups), tonumber(self.payload.data.chosenClothes[self.shoesBodygroups]))
				end

				if self.payload.data["glasses"] == true then
					self.characterModel.Entity:SetBodygroup(8, 1)
				end

				local eyeColorTable = GetActiveSkinEyeColorTable()

				self.characterModel.Entity:SetSkin(eyeColorTable[1] or 0)
				self.payload.data["skin"] = eyeColorTable[1]

				self.payload.data.groups[self.beardBodygroups] = 0

				if faction:GetNoAppearances(LocalPlayer()) != true then
					RefreshSkins()
				end

				self.characterModel:SetFOV(26)
				self.characterModel:SetCamPos(originPos)
				self.characterModel:SetLookAt(originLookAt)

				surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
			end

			icon.PaintOver = function(this, w, h)
				if (self.payload.model == k) then
					surface.SetDrawColor(255, 78, 69, 100)

					for i = 1, 3 do
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
					end
				end
			end

			if (isstring(v)) then
				icon:SetModel(v)
			else
				icon:SetModel(v[1], v[2] or 0, v[3])
			end
			
			modelSelectionGrid:AddItem( iconbg )
		end

		CreateRightMenuYellowTextPanel("Ваша постоянная модель, выбирайте с умом", 10)

		local function CreateButtonPanel(parent)
			parent:Dock(TOP)
			parent:DockMargin(0, 0, 0, 0)
			parent:SetSize(rightCreation:GetWide(), SScaleMin(36 / 3))
		end

		if faction:GetNoAppearances(LocalPlayer()) != true then
			CreateRightMenuTextPanel("лицевые черты", 10)

			skinButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(skinButtonPanel)

			if self.payload.gender == "male" then
				CreateRightMenuTextPanel("борода", 20)
				beardButtonPanel = rightCreation:Add("Panel")
				CreateButtonPanel(beardButtonPanel)
			end

			CreateRightMenuTextPanel("Вашему персонажу требуются очки?", 20)

			glassesButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(glassesButtonPanel)

			CreateRightMenuYellowTextPanel("Ваш экран не будет размыт без очков, до тех пор пока это не включено", 10)

			RefreshSkins()
		end

		if !faction.ReadOptionDisabled then
			CreateRightMenuTextPanel("Ваш персонаж умеет читать?", 5)

			local canreadButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(canreadButtonPanel)

			-- Can read

			if !table.IsEmpty(canreadButtonList) then
				table.Empty(canreadButtonList)
			end

			if self.payload.data.canread == nil then
				self.payload.data["canread"] = true
			end

			for i = 1, 2 do
				local canreadButton = canreadButtonPanel:Add("DButton")
				canreadButton:Dock(LEFT)
				if i == 1 then
					canreadButton:SetText("НЕТ")
					canreadButton:SetTextColor(Color(0, 0, 0, 255))
				else
					canreadButton:SetText("ДА")
					canreadButton:SetTextColor(Color(0, 0, 0, 255))
				end

				canreadButton:SetWide((math.Round(rightCreation:GetWide() / 2) - SScaleMin(10 / 3)))
				canreadButton:DockMargin(0, 0, SScaleMin(10 / 3), 0)
				canreadButton:SetFont("MenuFontNoClamp")
				canreadButton.name = canreadButton:GetText()

				table.insert(canreadButtonList, canreadButton)

				if self.payload.data.canread == true and i == 2 then
					SetSelected(canreadButton, "ДА", false)
				elseif self.payload.data.canread == false and i == 1 then
					SetSelected(canreadButton, "НЕТ", false)
				else
					canreadButton.Paint = function(selfSkin, w, h)
						surface.SetDrawColor(Color(0, 0, 0, 100))
						surface.DrawRect(0, 0, w, h)

						surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
						surface.DrawOutlinedRect(0, 0, w, h)
					end
				end

				canreadButton.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				canreadButton.DoClick = function()
					for k, v in pairs(canreadButtonList) do
						v.Paint = function(self, w, h)
							drawButtonUnselected(v.name, self, w, h, false)
						end
					end

					SetSelected(canreadButton, canreadButton.name, false)
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
					if i == 2 then
						self.payload.data["canread"] = true
					else
						self.payload.data["canread"] = false
					end
				end
			end

			CreateRightMenuYellowTextPanel("Текст в книгах, блокнотах и.т.д. будет неразборчив, хотя некоторая читабельность будет сохранена если вы выберете 'НЕТ'.", 10)
		end

		local buttonPanel = rightCreation:Add("Panel")
		buttonPanel:Dock(TOP)
		buttonPanel:DockMargin(SScaleMin(140 / 3), margin, 0, 0)
		buttonPanel:SetTall(SScaleMin(36 / 3))

		local backButton = buttonPanel:Add("DButton")
		local nextButton = buttonPanel:Add("DButton")
		finishButton = buttonPanel:Add("DButton")
		createNextBackFinishButtons(backButton, nextButton, finishButton)
		backButton.DoClick = function()
			characterButton.DoClick()
		end

		nextButton.DoClick = function()
			faceButton.DoClick()
		end

		self:CheckIfFinished()
	end

	faceButton = leftCreation:Add("DButton")
	createButton(faceButton, "одежда", "clothes")
	faceButton.DoClick = function()
		self.characterModel:SetFOV(26)
		self.characterModel:SetCamPos(originPos)
		self.characterModel:SetLookAt(originLookAt)

		ClearSelected()
		SetSelected(faceButton, "одежда", true)

		surface.PlaySound(table.Random(randomClickSounds))

		local function CreateButtonPanel(parent)
			parent:Dock(TOP)
			parent:DockMargin(0, 0, 0, 0)
			parent:SetSize(rightCreation:GetWide(), SScaleMin(36 / 3))
		end

		local function CreateBodyGroupButtons(parent, bodygroup)
			local torsoButtonList = {}
			local shoesButtonList = {}
			local trouserButtonList = {}

			local function ClearSelectedBodygroups(bodygroup)
				if bodygroup == "torso" then
					for k, v in pairs(torsoButtonList) do
						v.Paint = function(self, w, h)
							drawButtonUnselected(v.name, self, w, h, false)
						end
					end
				elseif bodygroup == "shoes" then
					for k, v in pairs(shoesButtonList) do
						v.Paint = function(self, w, h)
							drawButtonUnselected(v.name, self, w, h, false)
						end
					end
				else
					for k, v in pairs(trouserButtonList) do
						v.Paint = function(self, w, h)
							drawButtonUnselected(v.name, self, w, h, false)
						end
					end
				end
			end

			if !table.IsEmpty(torsoButtonList) then
				table.Empty(torsoButtonList)
			end

			if !table.IsEmpty(trouserButtonList) then
				table.Empty(trouserButtonList)
			end

			if !table.IsEmpty(shoesButtonList) then
				table.Empty(shoesButtonList)
			end

			if self.payload.data == nil then
				self.payload:Set("data", {})
				self.payload.data["groups"] = {}
				self.payload.data.chosenClothes[self.torsoBodygroups] = 0
				self.payload.data.chosenClothes[self.legsBodygroups] = 0
				self.payload.data.chosenClothes[self.shoesBodygroups] = 0
			end

			local caTorsos = { 28, 29, 30, 31, 32, 33, 34, 35 }
			local caLegs = { 9, 10, 11, 12, 13, 14 }
			local caShoes = { 0, 1, 2, 5 }
			local torsos = { 0, 1, 2, 15, 16 }
			local legs = { 0, 1, 2, 3, 4, 5 }
			local shoes = { 0, 1, 2, 3, 6 }

			local usedTorsoTable = torsos
			local usedLegsTable = legs
			local usedShoesTable = shoes

			if self.payload.faction == FACTION_ADMIN then
				usedTorsoTable = caTorsos
				usedLegsTable = caLegs
				usedShoesTable = caShoes
			end

			local activeTable = usedTorsoTable

			if bodygroup == "legs" then
				activeTable = usedLegsTable
			end

			if bodygroup == "shoes" then
				activeTable = usedShoesTable
			end

			local amount = #activeTable

			local actualAmount = amount

			for k, v in pairs(activeTable) do
				local bodygroupButton = parent:Add("DButton")
				bodygroupButton:Dock(LEFT)
				bodygroupButton:SetWide(math.Round(rightCreation:GetWide() / actualAmount) - SScaleMin(10 / 3))
				bodygroupButton:SetText(k)
				bodygroupButton:SetTextColor(Color(0, 0, 0, 255))
				bodygroupButton:SetFont("MenuFontNoClamp")
				bodygroupButton:DockMargin(0, 0, SScaleMin(10 / 3), 0)
				bodygroupButton.name = v

				if bodygroup == "torso" then
					table.insert(torsoButtonList, bodygroupButton)
				elseif bodygroup == "shoes" then
					table.insert(shoesButtonList, bodygroupButton)
				else
					table.insert(trouserButtonList, bodygroupButton)
				end

				bodygroupButton.Paint = function(self, w, h)
					surface.SetDrawColor(Color(0, 0, 0, 100))
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
					surface.DrawOutlinedRect(0, 0, w, h)
				end

				if bodygroup == "torso" and self.payload.data.chosenClothes[self.torsoBodygroups] == v then
					SetSelected(bodygroupButton, v, false)
				end

				if bodygroup == "legs" and self.payload.data.chosenClothes[self.legsBodygroups] == v then
					SetSelected(bodygroupButton, v, false)
				end

				if bodygroup == "shoes" and self.payload.data.chosenClothes[self.shoesBodygroups] == v then
					SetSelected(bodygroupButton, v, false)
				end

				bodygroupButton.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				bodygroupButton.DoClick = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
					if bodygroup == "legs" then
						ClearSelectedBodygroups("legs")
						SetSelected(bodygroupButton, v, false)
						self.payload.data.chosenClothes[self.legsBodygroups] = v
						self.characterModel.Entity:SetBodygroup(tonumber(self.legsBodygroups), v)

						self.characterModel:SetFOV(26)
						self.characterModel:SetCamPos(originPos)
						self.characterModel:SetLookAt(originLookAt)
					elseif bodygroup == "torso" then
						ClearSelectedBodygroups("torso")
						SetSelected(bodygroupButton, v, false)
						self.payload.data.chosenClothes[self.torsoBodygroups] = v
						self.characterModel.Entity:SetBodygroup(tonumber(self.torsoBodygroups), v)

						self.characterModel:SetFOV(26)
						self.characterModel:SetCamPos(originPos)
						self.characterModel:SetLookAt(originLookAt)
					elseif bodygroup == "shoes" then
						ClearSelectedBodygroups("shoes")
						SetSelected(bodygroupButton, v, false)
						self.payload.data.chosenClothes[self.shoesBodygroups] = v
						self.characterModel.Entity:SetBodygroup(tonumber(self.shoesBodygroups), v)

						local footpos = self.characterModel.Entity:GetBonePosition( self.characterModel.Entity:LookupBone("ValveBiped.Bip01_L_Foot") )

						if footpos then
							if self.payload.gender == "female" then
								footpos:Add(Vector(2, 0, 5))	-- Move right slightly
							else
								footpos:Add(Vector(4, 0, 5))	-- Move right slightly
							end

							self.characterModel:SetLookAt(footpos)

							self.characterModel:SetCamPos(footpos-Vector(-12, -12, 0))	-- Move cam in front of feet
							self.characterModel:SetFOV(54)
						end
					end
				end
			end
		end

		if faction:GetNoAppearances(LocalPlayer()) != true then
			CreateRightMenuTextPanel("верхняя одежда", 60)

			local jacketButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(jacketButtonPanel)
			CreateBodyGroupButtons(jacketButtonPanel, "torso")

			CreateRightMenuTextPanel("штаны", 30)

			local trouserButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(trouserButtonPanel)
			CreateBodyGroupButtons(trouserButtonPanel, "legs")

			CreateRightMenuTextPanel("обувь", 30)

			local shoesButtonPanel = rightCreation:Add("Panel")
			CreateButtonPanel(shoesButtonPanel)
			CreateBodyGroupButtons(shoesButtonPanel, "shoes")

			CreateRightMenuYellowTextPanel("Новая одежда может быть приобретена в магазинах", 10)
		else
			CreateRightMenuTextPanel("Внешность", 60)

			local noAppearances = rightCreation:Add("Panel")
			noAppearances:Dock(TOP)
			noAppearances:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
			noAppearances:SetTall(SScaleMin(140 / 3))
			noAppearances.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			local noAppearancesAvailable = noAppearances:Add("DLabel")
			noAppearancesAvailable:Dock(FILL)
			noAppearancesAvailable:SetFont("MenuFontNoClamp")
			noAppearancesAvailable:SetText("Нет доступного выбора одежды для этой фракции")
			noAppearancesAvailable:SetTextColor(Color(0, 0, 0, 255))
			noAppearancesAvailable:SetContentAlignment(5)
		end

		local buttonPanel = rightCreation:Add("Panel")
		buttonPanel:Dock(TOP)
		buttonPanel:DockMargin(SScaleMin(140 / 3), SScaleMin(20 / 3), 0, 0)
		buttonPanel:SetTall(SScaleMin(36 / 3))

		local backButton = buttonPanel:Add("DButton")
		local nextButton = buttonPanel:Add("DButton")
		finishButton = buttonPanel:Add("DButton")
		createNextBackFinishButtons(backButton, nextButton, finishButton)
		backButton.DoClick = function()
			appearancesButton.DoClick()
		end

		nextButton.DoClick = function()
			attributesButton.DoClick()
		end

		self:CheckIfFinished()
	end

	attributesButton = leftCreation:Add("DButton")
	createButton(attributesButton, "атрибуты", "attributes")
	attributesButton.DoClick = function()

		self.characterModel:SetFOV(26)
		self.characterModel:SetCamPos(originPos)
		self.characterModel:SetLookAt(originLookAt)

		local str = 0
		local per = 0
		local agl = 0
		local int = 0

		ClearSelected()
		SetSelected(attributesButton, "атрибуты", true)
		surface.PlaySound(table.Random(randomClickSounds))

		local textPanel = rightCreation:Add("Panel")
		textPanel:Dock(TOP)
		textPanel:SetTall(SScaleMin(20 / 3))
		textPanel:DockMargin(0, SScaleMin(55 / 3), 0, SScaleMin(10 / 3))

		local panelText = textPanel:Add("DLabel")
		panelText:SetText(string.utf8upper("выбор атрибутов"))
		panelText:SetFont("MenuFontNoClamp")
		panelText:SizeToContents()
		panelText:Dock(LEFT)
		panelText:SetContentAlignment(4)
		panelText:SetTextColor(Color(0, 0, 0, 255))

		if self.payload.special == nil then
			self.payload:Set("special", {})
			self.payload.special["strength"] = 0
			self.payload.special["perception"] = 0
			self.payload.special["agility"] = 0
			self.payload.special["intelligence"] = 0
		end

		if faction.noAttributes then
			local noAttributes = rightCreation:Add("Panel")
			noAttributes:Dock(TOP)
			noAttributes:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
			noAttributes:SetTall(SScaleMin(140 / 3))
			noAttributes.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			local noAttributesAvailable = noAttributes:Add("DLabel")
			noAttributesAvailable:Dock(FILL)
			noAttributesAvailable:SetFont("MenuFontNoClamp")
			noAttributesAvailable:SetText("Нет доступного выбора атрибутов для этой фракции")
			noAttributesAvailable:SetContentAlignment(5)

		else
			local function GetPointsSpend()
				local pointsSpend = 0
				for _, v in pairs(self.payload.special) do
					pointsSpend = pointsSpend + v
				end

				return pointsSpend
			end

			local function GetPointsLeft()
				return self:GetMaxAttributePoints() - GetPointsSpend()
			end

			local attributesRemaining = textPanel:Add("DLabel")
			attributesRemaining:SetFont("TitlesFontNoClamp")
			attributesRemaining:DockMargin(0, 0, 0, SScaleMin(3 / 3))
			attributesRemaining:Dock(RIGHT)
			attributesRemaining:SetContentAlignment(6)
			attributesRemaining:SetText(GetPointsLeft()..string.utf8upper(" очков осталось"))
			attributesRemaining:SizeToContents()
			attributesRemaining:SetTextColor(Color(0, 0, 0, 255))

			local function attributesRefresh(attribute, number)
				self.payload.special[attribute] = number
				attributesRemaining:SetText(GetPointsLeft()..string.utf8upper(" очков осталось"))
			end

			local function CreateAttribute(icon, wIcon, hIcon, title, desc, attribute)
				local attributePanel = rightCreation:Add("Panel")
				attributePanel:Dock(TOP)
				attributePanel:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
				attributePanel:SetTall(SScaleMin(105 / 3))
				attributePanel.Paint = function(self, w, h)
					surface.SetDrawColor(Color(0, 0, 0, 100))
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
					surface.DrawOutlinedRect(0, 0, w, h)

					surface.SetDrawColor(Color(0, 0, 0, 255))
					surface.SetMaterial(Material(icon))
					surface.DrawTexturedRect(SScaleMin(90 / 3) * 0.5 - SScaleMin(wIcon / 3) * 0.5, attributePanel:GetTall() * 0.5 - SScaleMin(hIcon / 3) * 0.5, SScaleMin(wIcon / 3), SScaleMin(hIcon / 3))
				end

				local textPanel = attributePanel:Add("Panel")
				textPanel:Dock(LEFT)
				textPanel:DockMargin(SScaleMin(90 / 3), 0, 0, 0)
				textPanel:SetSize(SScaleMin(460 / 3) - (SScaleMin(50 / 3) + SScaleMin(wIcon / 3)) - (SScaleMin(15 / 3) + SScaleMin(50 / 3)), attributePanel:GetTall())

				local titleText = textPanel:Add("DLabel")
				titleText:SetText(string.utf8upper(title))
				titleText:SetFont("LargerTitlesFontNoClamp")
				titleText:SizeToContents()
				titleText:Dock(TOP)
				titleText:SetTextColor(Color(230, 30, 30, 255))

				local descText = textPanel:Add("DLabel")
				descText:SetText(desc)
				descText:SetFont("SmallerTitleFontNoBoldNoClamp")
				descText:SetWrap(true)
				descText:SetAutoStretchVertical(true)
				descText:Dock(TOP)
				descText:SetTextColor(Color(0, 0, 0, 255))

				titleText:DockMargin(0, textPanel:GetTall() * 0.5 - titleText:GetTall() * 0.5 - descText:GetTall() - SScaleMin(2 / 3), 0, 0)

				local attributePointsPanel = attributePanel:Add("Panel")
				attributePointsPanel:Dock(RIGHT)
				attributePointsPanel:DockMargin(0, 0, SScaleMin(25 / 3), 0)
				attributePointsPanel:SetSize(SScaleMin(15 / 3), attributePanel:GetTall())

				local upArrow = attributePointsPanel:Add("DImageButton")
				upArrow:Dock(TOP)
				upArrow:SetTall(SScaleMin(9 / 3))
				upArrow:SetImage("willardnetworks/mainmenu/charcreation/uparrow.png")
				upArrow:SetColor(Color(0, 0, 0, 255))

				local attributePoint = attributePointsPanel:Add("DLabel")
				attributePoint:SetFont("LargerTitlesFontNoClamp")
				attributePoint:Dock(TOP)
				attributePoint:SetText(self.payload.special[attribute] or "0")
				attributePoint:SetTextColor(Color(0, 0, 0, 255))
				attributePoint:SetContentAlignment(5)
				attributePoint:SizeToContents()

				local downArrow = attributePointsPanel:Add("DImageButton")
				downArrow:Dock(TOP)
				downArrow:DockMargin(0, SScaleMin(5 / 3), 0, 0)
				downArrow:SetTall(SScaleMin(9 / 3))
				downArrow:SetImage("willardnetworks/mainmenu/charcreation/downarrow.png")
				downArrow:SetColor(Color(0, 0, 0, 255))

				upArrow:DockMargin(0, attributePointsPanel:GetTall() * 0.5 - upArrow:GetTall() * 0.5 - attributePoint:GetTall() * 0.5 - downArrow:GetTall() * 0.5 - SScaleMin(5 / 3), 0, SScaleMin(5 / 3))

				downArrow.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				downArrow.DoClick = function()
					if tonumber(attributePoint:GetText()) == 0 then
						return
					end

					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")

					attributePoint:SetText(tostring(tonumber(attributePoint:GetText()) - 1))
					attributePoint:SetTextColor(Color(0, 0, 0, 255))

					attributesRefresh(attribute, tonumber(attributePoint:GetText()))
				end

				upArrow.OnCursorEntered = function()
					surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
				end

				upArrow.DoClick = function()
					if tonumber(attributePoint:GetText()) == 5 then
						return
					end

					if GetPointsLeft() <= 0 then
						return
					end

					surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")

					attributePoint:SetText(tostring(tonumber(attributePoint:GetText()) + 1))
					attributePoint:SetTextColor(Color(0, 0, 0, 255))

					attributesRefresh(attribute, tonumber(attributePoint:GetText()))
				end
			end

			CreateAttribute("willardnetworks/mainmenu/charcreation/strength.png", 45, 61, "Сила", "Сильный бонус к навыку Оружие \nСлабый бонус к навыкам Скорости и Ремеслу", "strength")
			CreateAttribute("willardnetworks/mainmenu/charcreation/perception.png", 45, 30, "Восприятие", "Сильный бонус к навыкам Торговля и Готовка \nСлабый бонус к навыку Оружие", "perception")
			CreateAttribute("willardnetworks/mainmenu/charcreation/agility.png", 38, 47, "Ловкость", "Сильный бонус к навыку Скорость \nСлабый бонус к навыку Медицина", "agility")
			CreateAttribute("willardnetworks/mainmenu/charcreation/intelligence.png", 48, 29, "Интеллект", "Сильный бонус к навыкам Медицина и Ремесло \nСлабый бонус к навыкам Готовка и Торговля", "intelligence")
			CreateRightMenuYellowTextPanel("Атрибуты остаются неизменными, но могут быть временно изменены от надбавок предметов", 5)
		end


		local buttonPanel = rightCreation:Add("Panel")
		buttonPanel:Dock(TOP)
		buttonPanel:DockMargin(SScaleMin(140 / 3), SScaleMin(20 / 3), 0, 0)
		buttonPanel:SetTall(SScaleMin(36 / 3))

		local backButton = buttonPanel:Add("DButton")
		local nextButton = buttonPanel:Add("DButton")
		finishButton = buttonPanel:Add("DButton")
		createNextBackFinishButtons(backButton, nextButton, finishButton)
		backButton.DoClick = function()
			faceButton.DoClick()
		end
		nextButton.DoClick = function()
			backgroundButton.DoClick()
		end

		self:CheckIfFinished()
	end

	backgroundButton = leftCreation:Add("DButton")
	createButton(backgroundButton, "предыстория", "background")
	backgroundButton.DoClick = function()
		self.characterModel:SetFOV(26)
		self.characterModel:SetCamPos(originPos)
		self.characterModel:SetLookAt(originLookAt)

		ClearSelected()
		SetSelected(backgroundButton, "background", true)
		surface.PlaySound(table.Random(randomClickSounds))

		CreateRightMenuTextPanel("выбор предыстории", 60)

		local backgroundButtonList = {}

		if !table.IsEmpty(backgroundButtonList) then
			table.Empty(backgroundButtonList)
		end

		local function CreateBackgroundSelectionPanels(icon, iconW, iconH, title, desc, minusMargin, difficultyText)
			iconW = SScaleMin(iconW / 3)
			iconH = SScaleMin(iconH / 3)
			
			if self.payload.data == nil then
				self.payload:Set("data", {})
				self.payload.data["background"] = ""
			end
			
			local backgroundPanel = rightCreation:Add("DSizeToContents")
			backgroundPanel:Dock(TOP)
			backgroundPanel:DockPadding(SScaleMin(90 / 3), SScaleMin(10 / 3), SScaleMin(10 / 3), SScaleMin(15 / 3))
			backgroundPanel:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
			backgroundPanel:SetSizeX( false )
			backgroundPanel:InvalidateLayout()
			backgroundPanel.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, 255))
				surface.SetMaterial(Material(icon))
				surface.DrawTexturedRect(SScaleMin(90 / 3) * 0.5 - iconW * 0.5, h * 0.5 - iconH * 0.5, iconW, iconH)
			end

			local textPanel = backgroundPanel:Add("DSizeToContents")
			textPanel:Dock(TOP)
			textPanel:SetSizeX( false )

			local titleText = textPanel:Add("DLabel")
			titleText:SetText(title)
			titleText:SetFont("LargerTitlesFontNoClamp")
			titleText:SizeToContents()
			titleText:Dock(TOP)
			titleText:SetTextColor(Color(230, 30, 30, 255))

			local descText = textPanel:Add("DLabel")
			descText:SetText(desc)
			descText:SetFont("MenuFontNoClamp")
			descText:SetWrap(true)
			descText:SetAutoStretchVertical(true)
			descText:Dock(TOP)
			descText:SetTextColor(Color(0, 0, 0, 255))

			if difficultyText then
				local textDifficulty = textPanel:Add("DLabel")
				textDifficulty:Dock(TOP)
				textDifficulty:SetText(difficultyText)
				textDifficulty:SetFont("MenuFontNoClamp")
				textDifficulty:SetWrap(true)
				textDifficulty:SetAutoStretchVertical(true)
				textDifficulty:DockMargin(0, SScaleMin(10 / 3), 0, 0)

				if string.match(difficultyText, "сложность") then
					textDifficulty:SetTextColor(Color(255, 78, 69, 255))
				elseif string.match(difficultyText, "Эта предыстория не имеет идентификационный карты.") then
					textDifficulty:SetTextColor(Color(236, 218, 101, 255))
				else
					textDifficulty:SetTextColor(Color(101, 235, 130, 255))
				end
			end

			local function PaintSelected(self, w, h)
				local color = ix.config.Get("color", color_black)

				surface.SetDrawColor(color.r, color.g, color.b, 200)
				for i = 1, 2 do
					local i2 = i * 2
					surface.DrawOutlinedRect(i, i, w - i2, h - i2)
				end
			end

			local buttonCover = rightCreation:Add("DButton")
			buttonCover:Dock(TOP)
			buttonCover.PerformLayout = function(self)
				buttonCover:SetWide(backgroundPanel:GetWide())
				buttonCover:SetTall(backgroundPanel:GetTall())
				buttonCover:DockMargin(0, 0 - backgroundPanel:GetTall(), 0, 0)
			end
			
			buttonCover:SetSize(SScaleMin(100 / 3), SScaleMin(100 / 3))
			
			buttonCover.Paint = function(selfButton, w, h)
				if self.payload.data["background"] == title then
					PaintSelected(selfButton, w, h)
				end
			end
			buttonCover:SetText("")

			table.insert(backgroundButtonList, buttonCover)

			buttonCover.OnCursorEntered = function()
				surface.PlaySound("aftermath/ui/gui_journal_toggle_r006_01.ogg")
			end

			buttonCover.DoClick = function()
				self.payload.data["background"] = title

				surface.PlaySound("aftermath/ui/gui_journal_toggle_r001_02.ogg")
				for k, v in pairs(backgroundButtonList) do
					v.Paint = function(self, w, h ) end
				end

				buttonCover.Paint = function(self, w, h)
					PaintSelected(self, w, h)
				end

				self:CheckIfFinished()
			end
		end

		if faction:GetNoBackground(LocalPlayer()) != true then
			if faction.name == "Наёмники" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Шельмы" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Мусорщики" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Тигриные когти" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Валентино" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Вудуисты" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Мальстрем" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Соло", "Соло - наёмники обладающие боевыми навыками, готовые сражаться на стороне тех, кто платит.", 0, "Подходит для новых игроков")
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "Нетраннеры - профессионалы в сфере компьютерных технологий, кодеры и хакеры, которые способны перемещаться по потокам данных киберпространства, могут написать или модифицировать вирус.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Техники - технические специалисты по сборке, настройке и разборке оборудования, работе одновременно с аппаратным и программным обеспечением, монтажу брейндансов.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Барыга", "Вы выбрали путь денег, а не силы. Вы вечно крутитесь в поисках денег и способов сколотить капитал. Ваша сила - деньги и влияние. Все в этом мире можно купить и продать.", 0)
			elseif faction.name == "Арасака" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Корпорат", "Вы сотрудник корпорации. Занимаетесь бумажной работой, пытаетесь любыми способами пробиться выше по иерархии. Сейчас вы на достаточно низкой должность, но все же может измениться.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "У каждой корпорации должен быть нетраннер. Это уже необходимость. Защита интересов корпорации и их данных в сети ваша главная задача.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Вы инженер корпорации. Ваша задача обеспечивать работу всех устройств и приборов, что корпорации поставляет куда либо.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Сотрудник охраны", "Вы рядовой солдат корпорации. Ваша задача это выполнять приказы, что дает вам корпорация и не думать. Думать это не ваша задача. Ваша задача - охранять.", 0)
			elseif faction.name == "Милитех" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/fixer.png", 55, 55, "Корпорат", "Вы сотрудник корпорации. Занимаетесь бумажной работой, пытаетесь любыми способами пробиться выше по иерархии. Сейчас вы на достаточно низкой должность, но все же может измениться.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "У каждой корпорации должен быть нетраннер. Это уже необходимость. Защита интересов корпорации и их данных в сети ваша главная задача.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Вы инженер корпорации. Ваша задача обеспечивать работу всех устройств и приборов, что корпорации поставляет куда либо.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Сотрудник охраны", "Вы рядовой солдат корпорации. Ваша задача это выполнять приказы, что дает вам корпорация и не думать. Думать это не ваша задача. Ваша задача - охранять.", 0)
			elseif faction.name == "Полицейский департамент Найт-Сити" then
				CreateBackgroundSelectionPanels("big_ui/mainmenu/gun.png", 55, 55, "Офицер полиции", "Вы рядовой сотрудник полиции, служитель закона. Возможно вы не очень честный полицейский, возможно все совершенно наоборот. Решать исключительно вам, но не забывайте - вы тут закон.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/code.png", 55, 55, "Нетраннер", "У каждого департамента полиции должен быть нетраннер. Пока остальные переходят на сторону криминала, вы служите букве закона и помогаете своим коллегам из сети.", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/tech.png", 55, 55, "Техник", "Технический специалист высоко востребован в полиции. Никогда не знаешь когда твое оружие может заклинить, а машина сломаться. Техник тебе обязательно поможет!", 0)
				CreateBackgroundSelectionPanels("big_ui/mainmenu/character.png", 55, 55, "Детектив", "Детективная работа тяжела... Приходится часто общаться с людьми, искать следы в сети и применять различные уловки в поиске преступников, но вы выбрали такой путь!", 0)
			end
		else
			local backgroundPanel = rightCreation:Add("Panel")
			backgroundPanel:Dock(TOP)
			backgroundPanel:DockMargin(0, 0 - SScaleMin(1 / 3), 0, 0)
			backgroundPanel:SetTall(SScaleMin(140 / 3))
			backgroundPanel.Paint = function(self, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 100))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			local noBackground = backgroundPanel:Add("DLabel")
			noBackground:Dock(FILL)
			noBackground:SetFont("MenuFontNoClamp")
			noBackground:SetText("Нет доступного выбора предыстории для этой фракции")
			noBackground:SetTextColor(Color(0, 0, 0, 255))
			noBackground:SetContentAlignment(5)
		end

		local buttonPanel = rightCreation:Add("Panel")
		buttonPanel:Dock(TOP)
		buttonPanel:DockMargin(SScaleMin(140 / 3), SScaleMin(30 / 3), 0, 0)
		buttonPanel:SetTall(SScaleMin(36 / 3))

		local backButton = buttonPanel:Add("DButton")
		local nextButton = buttonPanel:Add("DButton")
		finishButton = buttonPanel:Add("DButton")
		createNextBackFinishButtons(backButton, nextButton, finishButton, true)

		backButton.DoClick = function()
			attributesButton.DoClick()
		end

		self:CheckIfFinished()
	end

	ix.gui.blackBarTop = self.characterPanel:Add("DShape")
	CreateBlackBar(ix.gui.blackBarTop, "top")

	ix.gui.blackBarBottom = self.characterPanel:Add("DShape")
	CreateBlackBar(ix.gui.blackBarBottom, "bottom")

	--newstuff conclude

	-- creation progress panel
	self.progress = self:Add("ixSegmentedProgress")
	self.progress:SetBarColor(ix.config.Get("color"))
	self.progress:SetSize(parent:GetWide(), 0)
	self.progress:SetVisible(false)
	--self.progress:SizeToContents()
	self.progress:SetPos(0, parent:GetTall() - self.progress:GetTall())

	-- setup payload hooks
	self:AddPayloadHook("model", function(value)
		local faction = ix.faction.indices[self.payload.faction]

		if (faction) then
			local model = "models/willardnetworks/citizens/female_01.mdl"
			if self.payload.gender == "male" and faction:GetModelsMale(LocalPlayer()) then
				model = faction:GetModelsMale(LocalPlayer())[value]
			elseif self.payload.gender == "female" and faction:GetModelsFemale(LocalPlayer()) then
				model = faction:GetModelsFemale(LocalPlayer())[value]
			else
				model = faction:GetModels(LocalPlayer())[value]
			end

			-- assuming bodygroups
			if (istable(model)) then
				self.characterModel:SetModel(model[1], model[2] or 0, model[3])
			else
				self.characterModel:SetModel(model or faction:GetModelsFemale(LocalPlayer())[1])
			end
		end
	end)

	-- setup character creation hooks
	net.Receive("ixCharacterAuthed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local id = net.ReadUInt(32)
		local indices = net.ReadUInt(6)
		local charList = {}

		for _ = 1, indices do
			charList[#charList + 1] = net.ReadUInt(32)
		end

		ix.characters = charList

		self:SlideDown()

		ix.panelCreationActive = false
		ix.gui.mapsceneActive = nil
		ix.gui.background_url = "aftermath/"..table.Random(ix.gui.backgrounds)..".png"

		if (!IsValid(self) or !IsValid(parent)) then
			return
		end

		if (id) then
			self.bMenuShouldClose = true

			net.Start("ixCharacterChoose")
				net.WriteUInt(id, 32)
			net.SendToServer()
		else
			self:SlideDown()
		end
	end)

	net.Receive("ixCharacterAuthFailed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local fault = net.ReadString()
		local args = net.ReadTable()

		self:SlideDown()

		parent.mainPanel:Undim()
		parent:ShowNotice(3, L(fault, unpack(args)))
	end)
end

function PANEL:SendPayload()
	if (self.awaitingResponse or !self:VerifyProgression()) then
		return
	end

	self.awaitingResponse = true

	timer.Create("ixCharacterCreateTimeout", 10, 1, function()
		if (IsValid(self) and self.awaitingResponse) then
			local parent = self:GetParent()

			self.awaitingResponse = false
			self:SlideDown()

			parent.mainPanel:Undim()
			parent:ShowNotice(3, L("unknownError"))
		end
	end)

	if self.payload.Prepare then
		self.payload:Prepare()
	end

	net.Start("ixCharacterCreate")
		net.WriteTable(self.payload)
	net.SendToServer()
end

function PANEL:GetMaxAttributePoints()
	return hook.Run("GetDefaultAttributePoints", LocalPlayer(), self.payload) or ix.config.Get("maxAttributes", 30)
end

function PANEL:OnSlideUp()
	self:ResetPayload()
	self:Populate()
	self.progress:SetProgress(1)

	-- the faction subpanel will skip to next subpanel if there is only one faction to choose from,
	-- so we don't have to worry about it here
	self:SetActiveSubpanel("faction", 0)
end

function PANEL:OnSlideDown()
end

function PANEL:ResetPayload(bWithHooks)
	if (bWithHooks) then
		self.hooks = {}
	end

	self.payload = {}

	-- TODO: eh..
	function self.payload.Set(payload, key, value)
		self:SetPayload(key, value)
	end

	function self.payload.AddHook(payload, key, callback)
		self:AddPayloadHook(key, callback)
	end

	function self.payload.Prepare(payload)
		self.payload.Set = nil
		self.payload.AddHook = nil
		self.payload.Prepare = nil
	end
end

function PANEL:SetPayload(key, value)
	self.payload[key] = value
	self:RunPayloadHook(key, value)
end

function PANEL:AddPayloadHook(key, callback)
	if (!self.hooks[key]) then
		self.hooks[key] = {}
	end

	self.hooks[key][#self.hooks[key] + 1] = callback
end

function PANEL:RunPayloadHook(key, value)
	local hooks = self.hooks[key] or {}

	for _, v in ipairs(hooks) do
		v(value)
	end
end

function PANEL:AttachCleanup(panel)
	self.repopulatePanels[#self.repopulatePanels + 1] = panel
end

function PANEL:Populate()

	-- remove panels created for character vars
	for i = 1, #self.repopulatePanels do
		self.repopulatePanels[i]:Remove()
	end

	self.repopulatePanels = {}

	-- payload is empty because we attempted to send it - for whatever reason we're back here again so we need to repopulate
	if (!self.payload.faction) then
		self.payload.faction = FACTION_MERC
	end


	if (!self.bInitialPopulate) then
		-- setup progress bar segments
		if self.WhitelistCount > 1 then
			self.progress:AddSegment("@faction")
		end

		self.progress:AddSegment("персонаж")

		self.progress:SetVisible(false)
	end

	self.bInitialPopulate = true
end

function PANEL:VerifyProgression(name)
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (name ~= nil and (v.category or "персонаж") != name) then
			continue
		end

		local value = self.payload[k]

		if (!v.bNoDisplay or v.OnValidate) then
			if (v.OnValidate) then
				local result = {v:OnValidate(value, self.payload, LocalPlayer())}

				if (result[1] == false) then
					self:GetParent():ShowNotice(3, L(unpack(result, 2)))
					return false
				end
			end

			self.payload[k] = value
		end
	end

	return true
end

function PANEL:CheckIfFinished(name)
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		if (name ~= nil and (v.category or "персонаж") != name) then
			continue
		end

		local value = self.payload[k]

		if (!v.bNoDisplay or v.OnValidate) then
			if (v.OnValidate) then
				local result = {v:OnValidate(value, self.payload, LocalPlayer())}

				if (result[1] == false) then
					if IsValid(finishButton) then
						finishButton:SetTextColor(Color(0, 0, 0, 30))
						finishButton.Paint = function(self, w, h)
							DrawFinishButtonNonAvailable(self, w, h)
						end
					end

					return false
				end
			end
		end
	end

	if IsValid(finishButton) then
		finishButton:SetTextColor(Color(0, 0, 0, 255))
		finishButton.Paint = function(self, w, h)
			DrawFinishButtonAvailable(self, w, h)
		end

		finishButton.DoClick = function()
			surface.PlaySound("aftermath/start.mp3")
			self:SendPayload()
		end
	end

	return true
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(255, 255, 255, 0)
	surface.DrawTexturedRect(0, 0, width, height)
	BaseClass.Paint(self, width, height)
end

vgui.Register("ixCharMenuNew", PANEL, "ixCharMenuPanel")

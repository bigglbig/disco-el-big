local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5, 0)
	self.maxLength = 1170
	self:MakePopup()
	self.Paint = function(self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 150))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end

	self.functionsPanel = self:Add("Panel")
	self.functionsPanel:SetSize(SScaleMin((1297 + 50) / 3), SScaleMin((809 + 40) / 3))
	self.functionsPanel:Center()

	self.panel = self.functionsPanel:Add("Panel")
	self.panel:SetSize(self.functionsPanel:GetWide() - SScaleMin(50 / 3), self.functionsPanel:GetTall() - SScaleMin(40 / 3))
	self.panel:Center()
	self.panel:SetZPos(0)
	self.panel.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(Material("willardnetworks/writing/book.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end

	if LocalPlayer().activeBookID then
		self.activeItemID = LocalPlayer().activeBookID
		LocalPlayer().activeBookID = nil
	end

	if !self.activeItemID then
		LocalPlayer():NotifyLocalized("Что-то пошло не так!")
		self:Remove()
		return
	end

	if LocalPlayer().activeBookWrittenIn then
		local canRead = LocalPlayer():GetCharacter():GetCanread()
		self.writtenTitle1 = canRead and LocalPlayer().activeBookTitle1 or Schema:ShuffleText(LocalPlayer().activeBookTitle1)
		self.writtenTitle2 = canRead and LocalPlayer().activeBookTitle2 or Schema:ShuffleText(LocalPlayer().activeBookTitle2)
		self.writtenFont = LocalPlayer().activeBookFont
		self.writtenLeftEntry = canRead and LocalPlayer().activeBookLeftEntry or Schema:ShuffleText(LocalPlayer().activeBookLeftEntry)
		self.writtenRightEntry = canRead and LocalPlayer().activeBookRightEntry or Schema:ShuffleText(LocalPlayer().activeBookRightEntry)

		self.writtenIn = true
	end

	self:CreateExitButton()
	self:CreateInnerPanel()

	if self.writtenIn then
		return
	end

	self:CreateColorSelection()
	self:CreatePublishButton()
end

function PANEL:CreateExitButton()
	local exit = self.functionsPanel:Add("DButton")
	exit:Dock(TOP)
	exit:SetTall(SScaleMin(25 / 3))
	exit:DockMargin(SScaleMin(34 / 3), SScaleMin(10 / 3), 0, 0)
	exit:SetContentAlignment(4)
	exit:SetFont("MenuFontLargerBoldNoFix")
	exit.Paint = nil

	if !self.writtenIn then
		exit:SetText("ЗАКРЫТЬ РЕДАКТОР")
	else
		exit:SetText("ЗАКРЫТЬ КНИГУ")
	end

	exit:SizeToContents()

	exit.DoClick = function()
		self:Remove()
		surface.PlaySound("helix/ui/press.wav")
	end
end

function PANEL:CreateColorSelection()
	local colors = {
		["СИНИЙ"] = "000000000",
		["ЧЕРНЫЙ"] = "100000000",
		["ЗЕЛЕНЫЙ"] = "200000000",
		["ОРАНЖЕВЫЙ"] = "300000000",
		["ФИОЛЕТОВЫЙ"] = "400000000",
		["КРАСНЫЙ"] = "500000000",
		["СЕРЫЙ"] = "600000000",
		["ЖЕЛТЫЙ"] = "700000000"
	}

	self.bottomPanel = self.functionsPanel:Add("Panel")
	self.bottomPanel:Dock(BOTTOM)
	self.bottomPanel:SetTall(SScaleMin(25 / 3))
	self.bottomPanel:DockMargin(SScaleMin(34 / 3), SScaleMin(10 / 3), SScaleMin(34 / 3), 0)

	local colorLabel = self.bottomPanel:Add("DLabel")
	colorLabel:Dock(LEFT)
	colorLabel:SetFont("MenuFontBoldNoClamp")
	colorLabel:SetText("ЦВЕТ КНИГИ: ")
	colorLabel:SizeToContents()

	local canClick = true
	for k, v in SortedPairs(colors) do
		local colorButton = self.bottomPanel:Add("DButton")
		colorButton:Dock(LEFT)
		colorButton:SetText(k)
		colorButton:SetFont("MenuFontBoldNoClamp")
		colorButton:SetContentAlignment(5)
		colorButton:SizeToContents()
		colorButton.Paint = nil

		colorButton.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			if canClick then
				canClick = false
				netstream.Start("SetBookColor", self.activeItemID, v)
				LocalPlayer():NotifyLocalized("Вы установили цвет книги на "..string.utf8lower(k))

				timer.Simple(1, function()
					canClick = true
				end)
			else
				LocalPlayer():NotifyLocalized("Вы пока что не можете нажать на это!")
			end
		end

		if k != "ЖЕЛТЫЙ" then
			local scale5 = SScaleMin(5 / 3)
			local divider = self.bottomPanel:Add("DShape")
			divider:SetType( "Rect" )
			divider:SetWide(1)
			divider:Dock(LEFT)
			divider:DockMargin(scale5, scale5, scale5, scale5)
		end
	end
end

function PANEL:CreateInnerPanel()
	self.innerPanel = self.panel:Add("Panel")
	self.innerPanel:Dock(FILL)
	self.innerPanel:DockMargin(SScaleMin(68 / 3), SScaleMin(30 / 3), SScaleMin(70 / 3), SScaleMin(58 / 3))

	self.leftSide = self.innerPanel:Add("Panel")
	self.leftSide:Dock(LEFT)
	self.leftSide:SetWide(SScaleMin(556 / 3))
	self.leftSide:DockPadding(0, 0, SScaleMin(50 / 3), 0)

	self.rightSide = self.innerPanel:Add("Panel")
	self.rightSide:Dock(FILL)
	self.rightSide:DockPadding(SScaleMin(50 / 3), 0, 0, 0)

	self:CreateTitleEntries()
	self:CreateNotepadEntries()
end

function PANEL:CreateTitleEntries()
	self.titleList = {}
	local function CreateTitleLabel(side, id, text, font)
		local titleLabel = side:Add("DLabel")
		titleLabel:SetText(text)
		titleLabel:Dock(TOP)
		titleLabel.id = id
		titleLabel:SetFont(font or "BookChilanka")
		titleLabel:SetContentAlignment(5)
		titleLabel:SetTall(SScaleMin(45 / 3))
		titleLabel:DockMargin(0, 0, 0, SScaleMin(5 / 3))
		titleLabel:SetTextColor(Color(0, 0, 0, 255))
	end

	local function CreateTitleButton(parent, id)
		parent:Dock(TOP)
		parent:SetTall(SScaleMin(45 / 3))
		parent:DockMargin(0, 0, 0, SScaleMin(5 / 3))
		parent:SetText("ДОБАВИТЬ НАЗВАНИЕ")
		parent:SetFont("MenuFontNoClamp")
		parent.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			Derma_StringRequest(
				"Название",
				"Напишите своё название здесь.",
				"",
				function(text)
					if string.utf8len(text) >= 40 then LocalPlayer():NotifyLocalized("Название слишком длинное") return end
					CreateTitleLabel(parent:GetParent(), id, text, LocalPlayer():GetCharacter():GetHandwriting())

					if id == 1 then
						self.titleList[1] = text
					else
						self.titleList[id] = text
					end

					parent:Remove()
				end,
				nil
			)
		end
	end

	if !self.writtenIn then
		local leftTitleButton = self.leftSide:Add("DButton")
		CreateTitleButton(leftTitleButton, 1)

		local rightTitleButton = self.rightSide:Add("DButton")
		CreateTitleButton(rightTitleButton, 2)
	else
		if self.writtenTitle1 then
			CreateTitleLabel(self.leftSide, 1, self.writtenTitle1, self.writtenFont)
		else
			CreateTitleLabel(self.leftSide, 1, "", "BookChilanka")
		end

		if self.writtenTitle2 then
			CreateTitleLabel(self.rightSide, 2, self.writtenTitle2, self.writtenFont)
		else
			CreateTitleLabel(self.rightSide, 2, "", "BookChilanka")
		end

		if !self.writtenTitle1 and !self.writtenTitle2 then
			CreateTitleLabel(self.leftSide, 1, "", "BookChilanka")
			CreateTitleLabel(self.rightSide, 2, "", "BookChilanka")
		end
	end
end

function PANEL:CreateNotepadEntries()
	local function CreateTextEntry(parent)
		parent:Dock(FILL)
		parent:MoveToFront()
		parent:SetMultiline(true)
		parent.MaxChars = 1170
		parent:SetFont(self.writtenFont or LocalPlayer():GetCharacter():GetHandwriting())
		parent.Paint = function(self, w, h)
			self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
		end

		parent.OnTextChanged = function(self)
			local txt = self:GetValue()
			local amt = string.utf8len(txt)
			if amt > self.MaxChars then
				if self.OldText then
					self:SetText(self.OldText)
					self:SetValue(self.OldText)
				end
			else
				self.OldText = txt
			end
		end
	end

	self.leftEntry = self.leftSide:Add("DTextEntry")
	CreateTextEntry(self.leftEntry)

	self.rightEntry = self.rightSide:Add("DTextEntry")
	CreateTextEntry(self.rightEntry)

	if self.writtenIn then
		self.leftEntry:SetEditable(false)
		self.leftEntry:SetText(self.writtenLeftEntry)

		self.rightEntry:SetEditable(false)
		self.rightEntry:SetText(self.writtenRightEntry)
	end
end

function PANEL:CreatePublishButton()
	self.publish = self.bottomPanel:Add("DButton")
	self.publish:Dock(RIGHT)
	self.publish:SetText("ОПУБЛИКОВАТЬ")
	self.publish:SetFont("MenuFontBoldNoClamp")
	self.publish:SizeToContents()
	self.publish.Paint = nil
	self.publish.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		local font = LocalPlayer():GetCharacter():GetHandwriting()
		local bookID = self.activeItemID or nil

		if string.utf8len(self.leftEntry:GetText()) > self.maxLength then
			LocalPlayer():NotifyLocalized("Длина текста левой страницы выше допустимой!")
			return false
		end

		if string.utf8len(self.rightEntry:GetText()) > self.maxLength then
			LocalPlayer():NotifyLocalized("Длина текста правой страницы выше допустимой!")
			return false
		end

		if istable(self.titleList) then
			if !table.IsEmpty(self.titleList) then
				if self.titleList[1] and self.titleList[2] then
					netstream.Start("PublishBook", self.titleList[1], self.titleList[2], self.leftEntry:GetText(), self.rightEntry:GetText(), bookID, font)
				elseif self.titleList[1] and !self.titleList[2] then
					netstream.Start("PublishBook", self.titleList[1], nil, self.leftEntry:GetText(), self.rightEntry:GetText(), bookID, font)
				elseif self.titleList[2] and !self.titleList[1] then
					netstream.Start("PublishBook", nil, self.titleList[2], self.leftEntry:GetText(), self.rightEntry:GetText(), bookID, font)
				end
			else
				netstream.Start("PublishBook", nil, nil, self.leftEntry:GetText(), self.rightEntry:GetText(), bookID, font)
			end
		else
			netstream.Start("PublishBook", nil, nil, self.leftEntry:GetText(), self.rightEntry:GetText(), bookID, font)
		end

		self:Remove()
	end
end

vgui.Register("BookEditor", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetSize(SScaleMin(400 / 3), SScaleMin(100 / 3))
	self:Center()
	self:MakePopup()
	self.Paint = function(self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local topbar = self:Add("Panel")
	topbar:SetSize(self:GetWide(), SScaleMin(50 / 3))
	topbar:Dock(TOP)
	topbar.Paint = function( self, w, h )
		surface.SetDrawColor(0, 0, 0, 130)
		surface.DrawRect(0, 0, w, h)
	end

	local titleText = topbar:Add("DLabel")
	titleText:SetFont("CharCreationBoldTitleNoClamp")
	titleText:Dock(LEFT)
	titleText:SetText("Почерк")
	titleText:DockMargin(SScaleMin(10 / 3), 0, 0, 0)
	titleText:SetContentAlignment(4)
	titleText:SizeToContents()

	local exit = topbar:Add("DImageButton")
	exit:SetImage("willardnetworks/tabmenu/navicons/exit.png")
	exit:SetSize(SScaleMin(20 / 3), SScaleMin(20 / 3))
	exit:DockMargin(0, SScaleMin(15 / 3), SScaleMin(10 / 3), SScaleMin(15 / 3))
	exit:Dock(RIGHT)
	exit.DoClick = function()
		self:Remove()

		surface.PlaySound("helix/ui/press.wav")
	end

	local buttonBox = self:Add("Panel")
	buttonBox:Dock(TOP)
	buttonBox:SetTall(SScaleMin(50 / 3))

	local function CreateFontButton(parent, font, text)
		parent:Dock(LEFT)
		parent:SetWide(self:GetWide() / 5)
		parent:SetText(text)
		parent:SetFont(font)
		parent:SetContentAlignment(5)
		parent.Paint = function(self, w, h)
			surface.SetDrawColor(Color(0, 0, 0, 100))
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		parent.DoClick = function()
			netstream.Start("SetHandwriting", font)
			LocalPlayer():NotifyLocalized("Вы успешно задали свой почерк на "..text)
			self:Remove()
		end
	end

	local satisfy = buttonBox:Add("DButton")
	CreateFontButton(satisfy, "BookSatisfy", "Satisfy")

	local chilanka = buttonBox:Add("DButton")
	CreateFontButton(chilanka, "BookChilanka", "Chilanka")

	local amita = buttonBox:Add("DButton")
	CreateFontButton(amita, "BookAmita", "Amita")

	local handlee = buttonBox:Add("DButton")
	CreateFontButton(handlee, "BookHandlee", "Handlee")

	local dancing = buttonBox:Add("DButton")
	CreateFontButton(dancing, "BookDancing", "Dancing")
end

function PANEL:Think()
	if (self) then
		self:MoveToFront()
	end
end

vgui.Register("HandwritingSelector", PANEL, "Panel")
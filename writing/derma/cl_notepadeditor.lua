local PANEL = {}

local notepadW = SScaleMin(623 / 3)
local notepadH = SScaleMin(987 / 3)
local SScaleMin38 = SScaleMin(38 / 3)
local SScaleMin110 = SScaleMin(110 / 3)
local SScaleMin90 = SScaleMin(90 / 3)
local SScaleMin650 = SScaleMin(650 / 3)
local SScaleMin55 = SScaleMin(55 / 3)
local SScaleMin7 = SScaleMin(7 / 3)

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5, 0)
	self:MakePopup()
	self.maxLength = 830
	self.Paint = function(self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 150))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end

	self.writtenIn = self.writtenIn or false
	self.charHandwriting = LocalPlayer():GetCharacter():GetHandwriting()

	if LocalPlayer().activeNotepadID then
		self.activeItemID = LocalPlayer().activeNotepadID
		LocalPlayer().activeNotepadID = nil
	end

	if !self.activeItemID then
		LocalPlayer():NotifyLocalized("Что-то пошло не так!")
		self:Remove()
	end

	if LocalPlayer().activeNotepadEntry then
		if LocalPlayer().activeNotepadEntry != "" then
			local canRead = LocalPlayer():GetCharacter():GetCanread()
			self.writtenTitle = canRead and LocalPlayer().activeNotepadTitle or Schema:ShuffleText(LocalPlayer().activeNotepadTitle)
			self.writtenFont = LocalPlayer().activeNotepadFont
			self.writtenEntry = canRead and LocalPlayer().activeNotepadEntry or Schema:ShuffleText(LocalPlayer().activeNotepadEntry)
			self.editedTimes = LocalPlayer().activeNotepadEditedTimes

			self.writtenIn = true

			LocalPlayer().activeNotepadTitle = nil
			LocalPlayer().activeNotepadFont = nil
			LocalPlayer().activeNotepadEntry = nil
			LocalPlayer().activeNotepadEditedTimes = nil
		end
	end

	self.canEdit = false

	if LocalPlayer().activeNotepadOwner then
		self.canEdit = true
	end

	self:CreateNotepadFrame()
	self:CreateExitButton()
	self:CreateInnerNotepad()

	if !self.writtenIn then
		self:CreatePublishButton()
	end

	if self.canEdit then
		self:CreatePublishButton()
	end
end

function PANEL:CreateNotepadFrame()
	self.notepad = self:Add("Panel")
	self.notepad:SetSize(notepadW, notepadH)
	self.notepad:Center()
	self.notepad.Paint = function(self, w, h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("willardnetworks/writing/notepad.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:CreateExitButton()
	local exit = self.notepad:Add("DButton")
	exit:Dock(TOP)
	exit:SetTall(SScaleMin(25 / 3))
	exit:SetContentAlignment(4)
	exit:DockMargin(SScaleMin38, SScaleMin38, 0, 0)
	exit:SetFont("MenuFontLargerBoldNoFix")
	exit.Paint = nil

	if !self.writtenIn then
		exit:SetText("ЗАКРЫТЬ РЕДАКТОР")
	else
		exit:SetText("ЗАКРЫТЬ БЛОКНОТ")
	end

	exit.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		self:Remove()
	end
end

function PANEL:CreateInnerNotepad()
	self.innerNotepad = self.notepad:Add("Panel")
	self.innerNotepad:Dock(TOP)
	self.innerNotepad:DockMargin(SScaleMin110, SScaleMin110, SScaleMin90, 0)
	self.innerNotepad:SetTall(SScaleMin650)

	if !self.writtenIn then
		self:CreateTitleOption()
	else
		self:CreateTitleLabel(self.writtenTitle, self.writtenFont)
	end

	self:CreateTextEntry()
end

function PANEL:CreateTitleOption()
	local titleOption = self.innerNotepad:Add("DButton")
	titleOption:Dock(TOP)
	titleOption:SetTall(SScaleMin55)
	titleOption:SetText("ДОБАВИТЬ НАЗВАНИЕ")
	titleOption:SetFont("MenuFontNoClamp")
	titleOption:DockMargin(0, 0, 0, SScaleMin7)
	titleOption.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		Derma_StringRequest(
			"Название",
			"Напишите своё название здесь.",
			"",
			function(text)
				if string.utf8len(text) >= 35 then LocalPlayer():NotifyLocalized("Название слишком длинное") return end
				if self.writtenFont then
					self:CreateTitleLabel(text, self.writtenFont)
				else
					self:CreateTitleLabel(text, self.charHandwriting)
				end

				titleOption:Remove()
			end,
		nil)
	end
end

function PANEL:CreateTitleLabel(text, font)
	self.titleLabel = self.innerNotepad:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetTall(SScaleMin55)
	self.titleLabel:SetText(text or "")
	self.titleLabel:SetFont(font or self.charHandwriting)
	self.titleLabel:DockMargin(0, 0, 0, SScaleMin7)
	self.titleLabel:SetContentAlignment(5)
	self.titleLabel:SetTextColor(color_black)
end

function PANEL:CreateTextEntry()
	self.textEntry = self.innerNotepad:Add("DTextEntry")
	self.textEntry:Dock(FILL)
	self.textEntry:MoveToFront()
	self.textEntry:SetMultiline(true)
	self.textEntry.MaxChars = self.maxLength
	self.textEntry:SetFont(self.writtenFont or self.charHandwriting)
	self.textEntry.Paint = function(self, w, h)
		self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
	end

	if self.writtenIn then
		self.textEntry:SetEditable(false)
		self.textEntry:SetText(self.writtenEntry)
	end

	if self.canEdit and self.writtenEntry then
		self.textEntry:SetEditable(true)
		self.textEntry:SetText(self.writtenEntry)
	end

	self.textEntry.OnTextChanged = function(self)
		local txt = self:GetValue()
		local amt = string.utf8len(txt)
		local rows = string.Explode( "\n", self:GetValue() )

		if amt > self.MaxChars or #rows > 19 then
			if self.OldText then
				self:SetText(self.OldText)
				self:SetValue(self.OldText)
			end
		else
			self.OldText = txt
		end
	end
end

function PANEL:CreatePublishButton()
	local publishButton = self.notepad:Add("DButton")
	publishButton:Dock(BOTTOM)
	publishButton:SetTall(SScaleMin(25 / 3))
	publishButton:SetContentAlignment(6)
	publishButton:DockMargin(0, 0, SScaleMin38 - SScaleMin7, 0)
	publishButton:SetFont("MenuFontLargerBoldNoFix")
	publishButton.Paint = nil
	publishButton:SetText("СОХРАНИТЬ")
	publishButton.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		if !self.activeItemID then
			LocalPlayer():NotifyLocalized("Невозможно найти предмет!")
			return
		end

		if string.utf8len(self.textEntry:GetText()) > self.maxLength then
			LocalPlayer():NotifyLocalized("Длина текста выше допустимой!")
			return false
		end

		if self.titleLabel then
			netstream.Start("PublishNotepad", self.textEntry:GetText(), self.titleLabel:GetText(), self.activeItemID, self.charHandwriting, self.editedTimes)
		else
			netstream.Start("PublishNotepad", self.textEntry:GetText(), nil, self.activeItemID, self.charHandwriting, self.editedTimes)
		end

		self:Remove()
	end
	
	if self.editedTimes then
		if self.editedTimes > -1 then
			local editedNum = 3 - self.editedTimes
			
			local editsLeft = publishButton:Add("DLabel")
			editsLeft:Dock(LEFT)
			editsLeft:SetText("РЕДАКЦИЙ ОСТАЛОСЬ: "..editedNum)
			editsLeft:SetFont("MenuFontLargerBoldNoFix")
			editsLeft:SizeToContents()
		end
	end
end

vgui.Register("NotepadEditor", PANEL, "EditablePanel")
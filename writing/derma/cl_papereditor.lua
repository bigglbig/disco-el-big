local PANEL = {}

local paperW = SScaleMin(710 / 3)
local paperH = SScaleMin(995 / 3)
local SScaleMin55 = SScaleMin(55 / 3)
local SScaleMin84 = SScaleMin(84 / 3)
local SScaleMin26 = SScaleMin(26 / 3)
local SScaleMin33 = SScaleMin(33 / 3)
local SScaleMin885 = SScaleMin(885 / 3)

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5, 0)
	self:MakePopup()
	self.maxLength = 1468
	self.Paint = function(self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 150))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end

	self.writtenIn = self.writtenIn or false
	self.charHandwriting = LocalPlayer():GetCharacter():GetHandwriting()

	if LocalPlayer().activePaperID then
		self.activeItemID = LocalPlayer().activePaperID
		LocalPlayer().activePaperID = nil
	end

	if !self.activeItemID then
		LocalPlayer():NotifyLocalized("Что-то пошло не так!")
		self:Remove()
	end

	if LocalPlayer().activePaperEntry != "" then
		local canRead = LocalPlayer():GetCharacter():GetCanread()
		self.writtenTitle = canRead and LocalPlayer().activePaperTitle or Schema:ShuffleText(LocalPlayer().activePaperTitle)
		self.writtenFont = LocalPlayer().activePaperFont
		self.writtenEntry = canRead and LocalPlayer().activePaperEntry or Schema:ShuffleText(LocalPlayer().activePaperEntry)

		self.writtenIn = true

		LocalPlayer().activePaperTitle = nil
		LocalPlayer().activePaperFont = nil
		LocalPlayer().activePaperEntry = nil
	end

	self:CreatePaperFrame()
	self:CreateExitButton()
	self:CreateInnerPaper()

	if !self.writtenIn then
		self:CreatePublishButton()
	end
end

function PANEL:CreatePaperFrame()
	self.paper = self:Add("Panel")
	self.paper:SetSize(paperW, paperH)
	self.paper:Center()
	self.paper.Paint = function(self, w, h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("willardnetworks/writing/paper.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:CreateExitButton()
	local exit = self.paper:Add("DButton")
	exit:Dock(TOP)
	exit:SetTall(SScaleMin(30 / 3))
	exit:SetContentAlignment(4)
	exit:DockMargin(SScaleMin55, 0, 0, 0)
	exit:SetFont("MenuFontLargerBoldNoFix")
	exit.Paint = nil

	if !self.writtenIn then
		exit:SetText("ЗАКРЫТЬ РЕДАКТОР")
	else
		exit:SetText("ЗАКРЫТЬ ГАЗЕТУ")
	end

	exit.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		self:Remove()
	end
end

function PANEL:CreateInnerPaper()
	self.innerPaper = self.paper:Add("Panel")
	self.innerPaper:Dock(TOP)
	self.innerPaper:DockMargin(SScaleMin84, SScaleMin26, SScaleMin55, 0)
	self.innerPaper:SetTall(SScaleMin885)

	if !self.writtenIn then
		self:CreateTitleOption()
	else
		self:CreateTitleLabel(self.writtenTitle, self.writtenFont)
	end

	self:CreateTextEntry()
end

function PANEL:CreateTitleOption()
	local titleOption = self.innerPaper:Add("DButton")
	titleOption:Dock(TOP)
	titleOption:SetTall(SScaleMin55)
	titleOption:SetText("ДОБАВИТЬ НАЗВАНИЕ")
	titleOption:SetFont("MenuFontNoClamp")
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
	self.titleLabel = self.innerPaper:Add("DLabel")
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetTall(SScaleMin55)
	self.titleLabel:SetText(text or "")
	self.titleLabel:SetFont(font or self.charHandwriting)
	self.titleLabel:SetContentAlignment(5)
	self.titleLabel:SetTextColor(color_black)
end

function PANEL:CreateTextEntry()
	self.textEntry = self.innerPaper:Add("DTextEntry")
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

	self.textEntry.OnTextChanged = function(self)
		local txt = self:GetValue()
		local amt = string.utf8len(txt)
		local rows = string.Explode( "\n", self:GetValue() )

		if amt > self.MaxChars or #rows > 26 then
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
	local publishButton = self.paper:Add("DButton")
	publishButton:Dock(BOTTOM)
	publishButton:SetTall(SScaleMin(30 / 3))
	publishButton:SetContentAlignment(6)
	publishButton:DockMargin(0, 0, SScaleMin33, 0)
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
			LocalPlayer():NotifyLocalized("Эта страница длиннее допустимой!")
			return false
		end

		if self.titleLabel then
			netstream.Start("PublishPaper", self.textEntry:GetText(), self.titleLabel:GetText(), self.activeItemID, self.charHandwriting)
		else
			netstream.Start("PublishPaper", self.textEntry:GetText(), nil, self.activeItemID, self.charHandwriting)
		end

		self:Remove()
	end
end

vgui.Register("PaperEditor", PANEL, "EditablePanel")
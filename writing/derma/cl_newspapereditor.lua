local PANEL = {}
local allowTextEntry = true
local padding = 10
local savedText = {}

local PLUGIN = PLUGIN

local function textEntryPaint(self, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
	surface.DrawOutlinedRect(0, 0, w, h)

	self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
end

function PANEL:Init()			
	self:SetSize(ScrW(), ScrH())
	self:SetAlpha(0)
	self:AlphaTo(255, 0.5, 0)
	self:MakePopup()
	self.Paint = function(self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 150))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end

	self.panel = self:Add("Panel")
	self.panel:SetSize(SScaleMin(632 / 3), SScaleMin(819 / 3))
	self.panel:Center()
	self.panel.master = self
	self.panel:SetZPos(0)
	self.panel.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(Material("willardnetworks/writing/newspaper_sheet.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:CreateFunctionsPanel(canEdit, entity)
	self.editable = canEdit or false
	
	local functionsPanelTop = self:Add("Panel")
	local x, y = self.panel:GetPos()
	functionsPanelTop:SetPos(x, y - SScaleMin(30 / 3))
	functionsPanelTop:SetSize(self.panel:GetWide(), SScaleMin(30 / 3))

	local function CreateDividerLine(where, dock)
		local dividerLine = where:Add("DShape")
		dividerLine:SetWide(1)
		dividerLine:Dock(LEFT)
		dividerLine:DockMargin(SScaleMin(padding / 3), SScaleMin(5 / 3), SScaleMin(padding / 3), SScaleMin(5 / 3))
		dividerLine:SetType("Rect")
		dividerLine:SetColor(Color(255, 255, 255, 255))
	end

	local function CreateFunctionsButton(parent, text)
		parent:Dock(LEFT)
		parent:SetFont("MenuFontLargerBoldNoFix")
		parent:SetText(text or "")
		parent:SizeToContents()
		parent.Paint = nil
	end

	-- Exit
	local exit = functionsPanelTop:Add("DButton")
	CreateFunctionsButton(exit)

	if self.editable then
		exit:SetText("ЗАКРЫТЬ РЕДАКТОР")
	else
		exit:SetText("СЛОЖИТЬ ГАЗЕТУ")
	end

	exit:SizeToContents()

	exit.DoClick = function()
		self:Remove()
		surface.PlaySound("helix/ui/press.wav")
		netstream.Start("CloseNewspaper", entity)
	end

	if self.editable then
		local functionsPanelBot = self:Add("Panel")
		functionsPanelBot:SetPos(x, y + self.panel:GetTall())
		functionsPanelBot:SetSize(self.panel:GetWide(), SScaleMin(30 / 3))

		self.panel.print = functionsPanelBot:Add("DButton")
		CreateFunctionsButton(self.panel.print, "НАПЕЧАТАТЬ")

		CreateDividerLine(functionsPanelBot)

		self.panel.preview = functionsPanelBot:Add("DButton")
		CreateFunctionsButton(self.panel.preview, "ПРЕДПРОСМОТР")

		CreateDividerLine(functionsPanelBot)

		self.panel.unionDatabase = functionsPanelBot:Add( "DCheckBoxLabel" )
		self.panel.unionDatabase:Dock(LEFT)
		self.panel.unionDatabase:SetText("")
		self.panel.unionDatabase:SetValue( false )
		self.panel.unionDatabase:SizeToContents()

		local unionDatabaseLabel = functionsPanelBot:Add( "DLabel" )
		unionDatabaseLabel:Dock(LEFT)
		unionDatabaseLabel:SetFont("MenuFontLargerBoldNoFix")
		unionDatabaseLabel:SetText("Загрузить в базу данных Союза")
		unionDatabaseLabel:SizeToContents()
	end
end

function PANEL:CreateInnerContent(entity, newspaper)	
	if !self.IsCreated then
		self.panel.entity = entity
		self.panel.data = newspaper
		
		local editorPanel = vgui.Create("NewspaperEditorPanel", self.panel)
		editorPanel:SetSize(self.panel:GetSize())
	end

	self.IsCreated = true
end

function PANEL:SetEditable(boolCanEdit)
	for k, v in pairs(self.panel:GetChildren()) do
		if v:GetClassName() == "TextEntry" then
			if boolCanEdit then
				v:SetEditable(true)

				v.Paint = function(self, w, h)
					textEntryPaint(self, w, h)
				end
			else
				v:SetEditable(false)

				v.Paint = function(self, w, h)
					self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
				end
			end
		end
	end
end

vgui.Register("NewspaperEditor", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()	
	local parent = self:GetParent()
	local function OnTextChanged(parent)
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

	self.titleEntry = parent:Add("DTextEntry")
	self.titleEntry:SetSize(SScaleMin(607 / 3), SScaleMin(90 / 3))
	self.titleEntry:MoveToFront()
	self.titleEntry:SetPos(SScaleMin(14 / 3), SScaleMin(11 / 3))
	self.titleEntry:SetFont("NewspaperTitle")
	self.titleEntry.MaxChars = 15
	self.titleEntry:SetValue("ЗАГОЛОВОК")
	self.titleEntry.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	OnTextChanged(self.titleEntry)

	self.columnTitle = parent:Add("DTextEntry")
	self.columnTitle:SetSize(SScaleMin(170 / 3), SScaleMin(30 / 3))
	self.columnTitle:MoveToFront()
	self.columnTitle:SetPos(SScaleMin(34 / 3), SScaleMin(203 / 3))
	self.columnTitle:SetFont("NewspaperColumnTitle")
	self.columnTitle.MaxChars = 9
	self.columnTitle:SetValue("ЗАГОЛОВОК")
	self.columnTitle.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	OnTextChanged(self.columnTitle)

	local leftColumnX, leftColumnY = self.columnTitle:GetPos()
	self.columnSubtitle = parent:Add("DTextEntry")
	self.columnSubtitle:SetSize(SScaleMin(170 / 3), SScaleMin(20 / 3))
	self.columnSubtitle:MoveToFront()
	self.columnSubtitle:SetPos(leftColumnX, leftColumnY + SScaleMin(72 / 3))
	self.columnSubtitle:SetFont("NewspaperColumnSubtitle")
	self.columnSubtitle.MaxChars = 13
	self.columnSubtitle:SetValue("ПОДЗАГОЛОВОК")
	self.columnSubtitle.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	OnTextChanged(self.columnSubtitle)

	self.leftContent = parent:Add("DTextEntry")
	self.leftContent:SetSize(SScaleMin(170 / 3), SScaleMin(465 / 3))
	self.leftContent:MoveToFront()
	self.leftContent:SetEnterAllowed(true)
	self.leftContent:SetMultiline(true)
	self.leftContent:SetPos(leftColumnX, leftColumnY + SScaleMin(72 / 3) + SScaleMin(50 / 3))
	self.leftContent:SetFont("NewspaperColumn")
	self.leftContent.MaxChars = 457
	self.leftContent:SetValue("ТЕКСТ")
	self.leftContent.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	OnTextChanged(self.leftContent)

	self.imagePanel = parent:Add("Panel")
	self.imagePanel:SetPos(SScaleMin(230 / 3), SScaleMin(184 / 3))
	self.imagePanel:SetSize(SScaleMin(383 / 3), SScaleMin(228 / 3))

	self.addColumn = self.imagePanel:Add("DButton")
	self.addColumn:Dock(TOP)
	self.addColumn:SetTall(self.imagePanel:GetTall() * 0.5)
	self.addColumn:SetText("ДОБАВИТЬ КОЛОНКУ")
	self.addColumn:SetFont("NewspaperColumnSubtitle")

	self.addPicture = self.imagePanel:Add("DButton")
	self.addPicture:Dock(FILL)
	self.addPicture:SetText("ДОБАВИТЬ КАРТИНКУ")
	self.addPicture:SetFont("NewspaperColumnSubtitle")

	self.columnTextEntry = self.imagePanel:Add("DTextEntry")
	self.columnTextEntry:Dock(FILL)
	self.columnTextEntry:SetEnterAllowed(true)
	self.columnTextEntry:SetMultiline(true)
	self.columnTextEntry:MoveToFront()
	self.columnTextEntry:SetFont("NewspaperColumn")
	self.columnTextEntry.MaxChars = 651
	self.columnTextEntry:SetValue("ТЕКСТ")
	self.columnTextEntry.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	self.columnTextEntry:SetVisible(false)

	self.addColumn.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		self.addColumn:SetVisible(false)
		self.addPicture:SetVisible(false)

		self.columnTextEntry:SetVisible(true)
		self.addColumn.removed = true

		OnTextChanged(self.columnTextEntry)
	end

	local x, y = self.imagePanel:GetPos()
	self.pictureEntry = parent:Add("DTextEntry")
	self.pictureEntry:SetPos(x, y + self.imagePanel:GetTall() + SScaleMin(7 / 3))
	self.pictureEntry:SetSize(self.imagePanel:GetWide(), SScaleMin(20 / 3))
	self.pictureEntry:MoveToFront()
	self.pictureEntry:SetFont("NewspaperColumnItalic")
	self.pictureEntry:SetValue("ПОДЗАГОЛОВОК ИЗОБРАЖЕНИЯ")
	self.pictureEntry.MaxChars = 46
	self.pictureEntry.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	self.pictureEntry:SetVisible(false)

	self.picture = self.imagePanel:Add("DHTML")
	self.picture:Dock(FILL)
	self.picture:SetScrollbars( false )
	local urlPicture = "temp"

	local cover = self.picture:Add("Panel")
	cover:Dock(FILL)
	cover.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 50))
		surface.SetMaterial(Material("willardnetworks/writing/cover.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end

	self.picture:SetVisible(false)

	OnTextChanged(self.pictureEntry)

	self.addPicture.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		Derma_StringRequest(
			"ССЫЛКА (любое изображение порнографического характера приведёт к бану)",
			"Ссылка на изображение. Желательный размер: 383х228",
			"",
			function(url)
				self.addColumn:SetVisible(false)
				self.addPicture:SetVisible(false)
				self.picture:SetVisible(true)

				urlPicture = url
				self.picture:OpenURL( url )

				self.pictureEntry:SetVisible(true)
				self.addColumn.removed = true
			end,
			nil
		)
	end

	self.rightColumn = parent:Add("DTextEntry")
	self.rightColumn:SetSize(SScaleMin(383 / 3), SScaleMin(340 / 3))
	self.rightColumn:SetPos(SScaleMin(230 / 3), SScaleMin(450 / 3))
	self.rightColumn:SetEnterAllowed(true)
	self.rightColumn:SetMultiline(true)
	self.rightColumn:MoveToFront()
	self.rightColumn:SetFont("NewspaperColumn")
	self.rightColumn.MaxChars = 765
	self.rightColumn:SetValue("ТЕКСТ")
	self.rightColumn.Paint = function(self, w, h)
		textEntryPaint(self, w, h)
	end

	OnTextChanged(self.rightColumn)

	local columnTextEntry, pictureEntryText

	if self.columnTextEntry then
		columnTextEntryText = self.columnTextEntry:GetText()
		pictureEntryText = self.pictureEntry:GetText()
	else
		columnTextEntryText = ""
		pictureEntryText = ""
	end

	if !self:GetParent():GetParent().editable then
		self:CreatePreviewPanel()
	end

	if parent.preview then
		parent.preview.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			if parent.master.editable then
				self:CreatePreviewPanel()
			else
				if !self.addColumn.removed then
					self.addColumn:SetVisible(true)
					self.addPicture:SetVisible(true)
				end

				parent.preview:SetText("ПРЕДПРОСМОТР")
				parent.preview:SizeToContents()

				if self.titlePanel then
					self.titlePanel:Remove()
					self.columnPanel:Remove()
					self.columnSubtitlePanel:Remove()
				end

				if self.columnTextEntry then
					self.columnTextEntry:SetEditable(true)
					self.columnTextEntry.Paint = function(self, w, h)
						textEntryPaint(self, w, h)
					end
				end

				-- false to true
				parent.master:SetEditable(true)
				parent.master.editable = true

				self.titleEntry:SetVisible(true)
				self.columnTitle:SetVisible(true)
				self.columnSubtitle:SetVisible(true)
			end
		end
	end

	if parent.print then
		parent.print.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			if !table.IsEmpty(savedText) then
				table.Empty(savedText)
			end

			table.insert(savedText,
				{
					["titleEntry"] = self.titleEntry:GetText(),
					["columnTitle"] = self.columnTitle:GetText(),
					["columnSubtitle"] = self.columnSubtitle:GetText(),
					["leftContent"] = self.leftContent:GetText(),
					["columnTextEntry"] = self.columnTextEntry:GetText(),
					["pictureEntry"] = self.pictureEntry:GetText(),
					["rightContent"] = self.rightColumn:GetText()
				}
			)

			local pictureEntryVisible = false
			local columnTextEntryVisible = false

			if self.pictureEntry then
				pictureEntryVisible = self.pictureEntry:IsVisible()
			end

			if self.columnTextEntry then
				columnTextEntryVisible = self.columnTextEntry:IsVisible()
			end

			if (parent.unionDatabase:GetChecked() and LocalPlayer():GetCharacter():GetGenericdata().permits == true) then
				PLUGIN.storedNewspapers[#PLUGIN.storedNewspapers + 1] = {pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture}

				netstream.Start("PrintNewsPaper", parent.entity, pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture, true)
				parent.master:Remove()
			else
				netstream.Start("PrintNewsPaper", parent.entity, pictureEntryVisible, columnTextEntryVisible, savedText, urlPicture, false)
				parent.master:Remove()
			end
		end
	end
end

function PANEL:CreatePreviewPanel()
	local parent = self:GetParent()

	if parent.preview then
		parent.preview:SetText("НАЗАД")
		parent.preview:SizeToContents()
	end

	parent.master:SetEditable(false)
	parent.master.editable = false

	if !self.addColumn.removed then
		self.addColumn:SetVisible(false)
		self.addPicture:SetVisible(false)
	end

	if self.columnTextEntry then
		self.columnTextEntry:SetEditable(false)
		self.columnTextEntry.Paint = function(self, w, h)
			self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
		end
	end

	self.titleEntry:SetVisible(false)
	self.columnTitle:SetVisible(false)
	self.columnSubtitle:SetVisible(false)

	self.titlePanel = parent:Add("Panel")
	self.titlePanel:SetSize(SScaleMin(607 / 3), SScaleMin(90 / 3))
	self.titlePanel:SetPos(SScaleMin(14 / 3), SScaleMin(11 / 3))

	local titleText = self.titlePanel:Add("DLabel")
	titleText:SetText(self.titleEntry:GetText() or "")
	titleText:SetContentAlignment(5)
	titleText:SetFont("NewspaperTitle")
	titleText:SizeToContents()
	titleText:Center()
	titleText:SetTextColor(Color(0, 0, 0, 255))

	self.columnPanel = parent:Add("Panel")
	self.columnPanel:SetSize(SScaleMin(170 / 3), SScaleMin(30 / 3))
	self.columnPanel:SetPos(SScaleMin(34 / 3), SScaleMin(203 / 3))

	local columnTitleText = self.columnPanel:Add("DLabel")
	columnTitleText:SetContentAlignment(5)
	columnTitleText:SetText(self.columnTitle:GetText() or "")
	columnTitleText:SetFont("NewspaperColumnTitle")
	columnTitleText:SizeToContents()
	columnTitleText:Center()
	columnTitleText:SetTextColor(Color(0, 0, 0, 255))

	local leftColumnX, leftColumnY = self.columnTitle:GetPos()
	self.columnSubtitlePanel = parent:Add("Panel")
	self.columnSubtitlePanel:SetSize(SScaleMin(170 / 3), SScaleMin(20 / 3))
	self.columnSubtitlePanel:SetPos(leftColumnX, leftColumnY + SScaleMin(72 / 3))

	local columnSubtitleText = self.columnSubtitlePanel:Add("DLabel")
	columnSubtitleText:SetContentAlignment(5)
	columnSubtitleText:SetText(self.columnSubtitle:GetText() or "")
	columnSubtitleText:SetFont("NewspaperColumnSubtitle")
	columnSubtitleText:SizeToContents()
	columnSubtitleText:Center()
	columnSubtitleText:SetTextColor(Color(0, 0, 0, 255))
	
	if parent.data and istable(parent.data) and !table.IsEmpty(parent.data) then
		self:Update(titleText, columnTitleText, columnSubtitleText, parent.data)
	end
end

function PANEL:Update(titleText, columnTitleText, columnSubtitleText, data)
	local titleEntry = self.titleEntry:GetText()
	local columnText = self.columnTitle:GetText()
	local subtitleText = self.columnSubtitle:GetText()
	local contentLeft = self.leftContent:GetText()
	local contentRight = self.rightColumn:GetText()
	local addedColumnText = self.columnTextEntry:GetText()
	local pictureText = self.pictureEntry:GetText()
	local pictureURL = ""
	
	if data and istable(data) and !table.IsEmpty(data) then
		local canRead = LocalPlayer():GetCharacter():GetCanread()
		titleEntry = canRead and data[1].titleEntry or Schema:ShuffleText(data[1].titleEntry)
		columnText = canRead and data[1].columnTitle or Schema:ShuffleText(data[1].columnTitle)
		subtitleText = canRead and data[1].columnSubtitle or Schema:ShuffleText(data[1].columnSubtitle)
		contentLeft = canRead and data[1].leftContent or Schema:ShuffleText(data[1].leftContent)
		contentRight = canRead and data[1].rightContent or Schema:ShuffleText(data[1].rightContent)
		addedColumnText = canRead and data[1].columnTextEntry or Schema:ShuffleText(data[1].columnTextEntry)
		pictureText = canRead and data[1].pictureEntry or Schema:ShuffleText(data[1].pictureEntry)

		if self.columnTextEntry and addedColumnText != "ТЕКСТ" then
			self.columnTextEntry:SetText(addedColumnText)
			self.columnTextEntry:SetVisible(true)
		end
		
		titleText:SetText(titleEntry or "")
		columnTitleText:SetText(columnText or "")
		columnSubtitleText:SetText(subtitleText or "")
		
		titleText:SizeToContents()
		columnTitleText:SizeToContents()
		columnSubtitleText:SizeToContents()
		
		titleText:Center()
		columnTitleText:Center()
		columnSubtitleText:Center()

		if data[1].pictureURL and self.picture then
			if data[1].pictureURL != "temp" then
				pictureURL = data[1].pictureURL
				self.picture:OpenURL( pictureURL )
				self.picture:SetVisible(true)
			end
		end

		if self.pictureEntry and data[1].pictureEntry != "ПОДЗАГОЛОВОК ИЗОБРАЖЕНИЯ" then
			self.pictureEntry:SetText(pictureText)
			self.pictureEntry:SetVisible(true)
		end
		
		if self.leftContent then
			self.leftContent:SetText(contentLeft)
		end

		if self.rightColumn then
			self.rightColumn:SetText(contentRight)
		end
	end
end

vgui.Register("NewspaperEditorPanel", PANEL, "EditablePanel")
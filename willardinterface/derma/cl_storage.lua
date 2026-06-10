
local PANEL = {}

AccessorFunc(PANEL, "money", "Money", FORCE_NUMBER)

function PANEL:Init()
	self:DockPadding(1, 1, 1, 1)
	self:SetTall(SScaleMin(64 / 3))

	local textPanel = self:Add("EditablePanel")
	textPanel:Dock(TOP)
	textPanel:SetTall(SScaleMin(18 / 3))

	self.moneyLabel = textPanel:Add("DLabel")
	self.moneyLabel:SetFont("MenuFontNoClamp")
	self.moneyLabel:SetText("")
	self.moneyLabel:SetTextInset(SScaleMin(2 / 3), 0)

	self.creditText = textPanel:Add("DLabel")
	self.creditText:Dock(LEFT)
	self.creditText:SetFont("MenuFontNoClamp")
	self.creditText:SetText(string.utf8upper(" Эдди"))
	self.creditText:SetTextInset(SScaleMin(2 / 3), 0)
	self.creditText:SizeToContents()

	local amountPanel = self:Add("EditablePanel")
	amountPanel:Dock(FILL)
	amountPanel.Paint = function(self, w, h)
		surface.SetDrawColor(35, 35, 35, 85)
		surface.DrawRect(1, 1, w - 2, h - 2)

		surface.SetDrawColor(80, 80, 80, 255)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end

	self.amountEntry = amountPanel:Add("DTextEntry")
	self.amountEntry:SetFont("MenuFontNoClamp")
	self.amountEntry:Dock(FILL)
	self.amountEntry:SetNumeric(true)
	self.amountEntry:SetValue("0")
	self.amountEntry.Paint = function(self, w, h)
		self:DrawTextEntryText( Color(255, 255, 255, 255), self:GetHighlightColor(), self:GetCursorColor() )
	end

	self.transferButton = amountPanel:Add("DButton")
	self.transferButton:SetFont("ixIconsMedium")
	self.transferButton:Dock(LEFT)
	self.transferButton:SetWide(SScaleMin(50 / 3))
	self:SetLeft(false)
	self.transferButton.DoClick = function()
		local amount = math.max(0, math.Round(tonumber(self.amountEntry:GetValue()) or 0))
		self.amountEntry:SetValue("0")

		if (amount != 0) then
			self:OnTransfer(amount)
		end
	end

	self.bNoBackgroundBlur = true
	self.transferButton.Paint = function(self, w, h) end
end

function PANEL:SetLeft(bValue)
	if (bValue) then
		self.transferButton:Dock(RIGHT)
		self.transferButton:SetText("t")
	else
		self.transferButton:Dock(LEFT)
		self.amountEntry:DockMargin(SScaleMin(10 / 3), 0, 0, 0)
		self.transferButton:SetText("s")
	end
end

function PANEL:SetMoney(money)
	self.money = math.max(math.Round(tonumber(money) or 0), 0)

	self.moneyLabel:SetText(money)
	self.moneyLabel:Dock(LEFT)
	self.moneyLabel:SizeToContents()
	self.moneyLabel:SetTextColor(Color(255, 204, 0, 255))
end

function PANEL:OnTransfer(amount)
end

vgui.Register("ixStorageMoney", PANEL, "EditablePanel")

DEFINE_BASECLASS("EditablePanel")
PANEL = {}

AccessorFunc(PANEL, "fadeTime", "FadeTime", FORCE_NUMBER)
AccessorFunc(PANEL, "frameMargin", "FrameMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "storageID", "StorageID", FORCE_NUMBER)

local dividerWidth = SScaleMin(1920 / 3)
local dividerHeight = SScaleMin(1080 / 3)
local halfWidth = dividerWidth * 0.5

function PANEL:Init()
	if (IsValid(ix.gui.openedStorage)) then
		ix.gui.openedStorage:Remove()
	end

	ix.gui.openedStorage = self

	self:SetSize(ScrW(), ScrH())
	self:SetFadeTime(0.25)
	self:SetFrameMargin(4)

	local background = self:Add("EditablePanel")
	background:SetSize(ScrW(), ScrH())
	background.Paint = function(self, w, h)
		surface.SetDrawColor(Color(90, 0, 0, 220))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end
	
	background:MakePopup()

	self.dividerPanel = background:Add("EditablePanel")
	self.dividerPanel:SetSize(dividerWidth, dividerHeight)
	self.dividerPanel:Center()

	local leftSide = self.dividerPanel:Add("EditablePanel")
	leftSide:Dock(LEFT)
	leftSide:SetSize(self.dividerPanel:GetWide() * 0.5, dividerHeight)
	leftSide.Paint = function(self, w, h)
		surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
		surface.DrawLine(w - 1, SScaleMin(50 / 3), w - 1, h)
	end

	local storageIcon = self.dividerPanel:Add("DImage")
	storageIcon:SetSize(SScaleMin(90 / 3), SScaleMin(90 / 3))
	storageIcon:SetImage("willardnetworks/storage/icon.png")
	storageIcon:Center()

	local topbar = background:Add("EditablePanel")
	topbar:SetSize(background:GetWide(), SScaleMin(50 / 3))
	topbar:Dock(TOP)
	topbar.Paint = function( self, w, h )
		surface.SetDrawColor(0, 0, 0, 130)
		surface.DrawRect(0, 0, w, h)
	end

	self.titleText = topbar:Add("DLabel")
	self.titleText:SetFont("CharCreationBoldTitleNoClamp")
	self.titleText:SetText("Хранилище")
	self.titleText:SetContentAlignment(5)
	self.titleText:SizeToContents()
	self.titleText:Center()

	local exit = topbar:Add("DImageButton")
	exit:SetImage("willardnetworks/tabmenu/navicons/exit.png")
	exit:SetSize(SScaleMin(20 / 3), SScaleMin(20 / 3))
	exit:DockMargin(0, SScaleMin(15 / 3), SScaleMin(20 / 3), SScaleMin(15 / 3))
	exit:Dock(RIGHT)
	exit.DoClick = function()
		self:Remove()
		surface.PlaySound("helix/ui/press.wav")
	end

	self.storageInventory = self.dividerPanel:Add("ixInventory")
	self.storageInventory.bNoBackgroundBlur = true
	self.storageInventory:MoveToBack()
	self.storageInventory.Close = function(this)
		net.Start("ixStorageClose")
		net.SendToServer()
		self:Remove()
	end

	self.storageMoney = self.dividerPanel:Add("ixStorageMoney")
	self.storageMoney:SetVisible(false)
	self.storageMoney.OnTransfer = function(_, amount)
		net.Start("ixStorageMoneyTake")
			net.WriteUInt(self.storageID, 32)
			net.WriteUInt(amount, 32)
		net.SendToServer()
	end

	if (self.storageMoney.creditText) then
		self.storageMoney.creditText:SetText(" ЭДДИ В ХРАНИЛИЩЕ")
		self.storageMoney.creditText:SizeToContents()
		self.storageMoney.creditText:Dock(LEFT)
	end

	ix.gui.inv1 = leftSide:Add("ixInventory")
	ix.gui.inv1.bNoBackgroundBlur = true
	ix.gui.inv1.Close = function(this)
		net.Start("ixStorageClose")
		net.SendToServer()
		self:Remove()
	end

	self.localMoney = ix.gui.inv1:Add("ixStorageMoney")
	self.localMoney:SetVisible(false)
	self.localMoney:SetLeft(true)
	self.localMoney.OnTransfer = function(_, amount)
		net.Start("ixStorageMoneyGive")
			net.WriteUInt(self.storageID, 32)
			net.WriteUInt(amount, 32)
		net.SendToServer()
	end

	self:SetAlpha(0)
	self:AlphaTo(255, self:GetFadeTime())
end

function PANEL:OnChildAdded(panel)
	panel:SetPaintedManually(true)
end

function PANEL:OnKeyCodePressed(key)
	if (key == KEY_TAB and IsValid(self)) then
		self:Remove()
	end
end

function PANEL:SetLocalInventory(inventory)
	if (IsValid(ix.gui.inv1) and !IsValid(ix.gui.menu)) then
		ix.gui.inv1:SetInventory(inventory)

		ix.gui.inv1:Center()

		local x, y = self.dividerPanel:GetPos()
		local x2, y2 = ix.gui.inv1:GetPos()

		self.localMoney:Dock(NODOCK)
		self.localMoney:SetWide(ix.gui.inv1:GetWide())
		self.localMoney:SetPos(0, ix.gui.inv1:GetTall() + SScaleMin(10 / 3))

		local padding = SScaleMin(10 / 3)

		local invTitleIcon = self.dividerPanel:Add("DImage")
		invTitleIcon:SetImage("willardnetworks/tabmenu/navicons/inventory.png")
		invTitleIcon:SetSize(SScaleMin(19 / 3), SScaleMin(17 / 3))
		invTitleIcon:SetPos(x2, y2 - invTitleIcon:GetTall() - padding)

		local invTitle = self.dividerPanel:Add("DLabel")
		invTitle:SetFont("TitlesFontNoClamp")
		invTitle:SetText("Инвентарь")
		invTitle:SizeToContents()
		invTitle:SetPos(x2 + SScaleMin(27 / 3), y2 - (invTitle:GetTall() * 0.8) - padding)

		ix.gui.inv1:MoveToBack()
	end
end

function PANEL:SetLocalMoney(money)
	if (!self.localMoney:IsVisible()) then
		self.localMoney:SetVisible(true)
		ix.gui.inv1:SetTall(ix.gui.inv1:GetTall() + self.localMoney:GetTall() + SScaleMin(10 / 3))
	end

	self.localMoney:SetMoney(money)
end

function PANEL:SetStorageTitle(title)
end

function PANEL:SetStorageInventory(inventory)
	self.storageInventory:SetInventory(inventory)
	self.storageInventory:SetPos(halfWidth + (halfWidth * 0.5) - self.storageInventory:GetWide() * 0.5, dividerHeight * 0.5 - self.storageInventory:GetTall() * 0.5)

	local x2, y2 = self.storageInventory:GetPos()
	self.storageMoney:Dock(NODOCK)
	self.storageMoney:SetWide(self.storageInventory:GetWide())
	self.storageMoney:SetPos(x2, y2 + self.storageInventory:GetTall() + SScaleMin(10 / 3))

	local x, y = self.storageInventory:GetPos()
	local padding = SScaleMin(10 / 3)

	local invTitleIcon = self.dividerPanel:Add("DImage")
	invTitleIcon:SetImage("willardnetworks/mainmenu/content.png")
	invTitleIcon:SetSize(SScaleMin(16 / 3), SScaleMin(16 / 3))
	invTitleIcon:SetPos(x, y - invTitleIcon:GetTall() - padding)

	local invTitle = self.dividerPanel:Add("DLabel")
	invTitle:SetFont("TitlesFontNoClamp")
	invTitle:SetText("Хранилище")
	invTitle:SizeToContents()
	invTitle:SetPos(x + SScaleMin(27 / 3), y - (invTitle:GetTall() * 0.8) - padding)

	ix.gui["inv" .. inventory:GetID()] = self.storageInventory
end

function PANEL:SetStorageMoney(money)
	if (!self.storageMoney:IsVisible()) then
		self.storageMoney:SetVisible(true)
		self.storageInventory:SetTall(self.storageInventory:GetTall() + self.storageMoney:GetTall() + SScaleMin(2 / 3))
	end

	self.storageMoney:SetMoney(money)
end

function PANEL:Paint(width, height)
	ix.util.DrawBlurAt(0, 0, width, height)

	for _, v in ipairs(self:GetChildren()) do
		v:PaintManual()
	end
end

function PANEL:Remove()
	self:SetAlpha(255)
	self:AlphaTo(0, self:GetFadeTime(), 0, function()
		BaseClass.Remove(self)
	end)
end

function PANEL:OnRemove()
	if (!IsValid(ix.gui.menu)) then
		self.storageInventory:Remove()
		ix.gui.inv1:Remove()

		net.Start("ixStorageClose")
		net.SendToServer()
	end
end

vgui.Register("ixStorageView", PANEL, "EditablePanel")

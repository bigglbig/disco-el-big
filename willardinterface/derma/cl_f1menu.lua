
local animationTime = 1

DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

function PANEL:Init()
	if IsValid(ix.gui.F1Menu) then
		ix.gui.F1Menu:Remove()
	end

	ix.gui.F1Menu = self

	-- properties
	self.noAnchor = CurTime() + 0.4
	self.anchorMode = true

	self.currentAlpha = 0
	self.currentBlur = 0

	gui.EnableScreenClicker( true )

	self:SetSize(ScrW(), ScrH())

	local function FramePaint( self, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 50))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(100, 100, 100, 150))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local mainFrame = self:Add("DPanel")
	mainFrame:SetSize( SScaleMin(1020 / 3), SScaleMin(372 / 3) )
	mainFrame:SetPos(ScrW() * 0.5 - mainFrame:GetWide() * 0.5, ScrH() * 0.5 - mainFrame:GetTall() * 0.5)
	mainFrame.Paint = function( self, w, h ) end

	-- Main frame (invisible)
	local rightFrame = vgui.Create( "DPanel", mainFrame )
	rightFrame:SetSize( SScaleMin(800 / 3), 0 )
	rightFrame:Dock(RIGHT)
	rightFrame.Paint = function( self, w, h ) end

	local leftFrame = vgui.Create( "DPanel", mainFrame)
	leftFrame:SetSize( SScaleMin(200 / 3), 0 )
	leftFrame:Dock(LEFT)
	leftFrame:DockMargin(0, SScaleMin(11 / 3), 0, 0)
	leftFrame.Paint = function( self, w, h )
		FramePaint(self, w, h)

		surface.SetDrawColor(Color(150, 150, 150, 20))
		surface.SetMaterial(Material("willardnetworks/tabmenu/crafting/box_pattern.png", "noclamp"))
		surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / SScaleMin(414 / 3), h / SScaleMin(677 / 3) )
	end

	-- Character model
	self.icon = vgui.Create( "ixModelPanel", leftFrame )
	self.icon:Dock(TOP)
	self.icon:SetTall(SScaleMin(372 / 3))
	self.icon:DockMargin(0, 0 - SScaleMin(20 / 3), 0, 0)
	self.icon:SetFOV(38)
	self.icon:SetModel( LocalPlayer():GetModel(), LocalPlayer():GetSkin(), true )

	local title = rightFrame:Add("DLabel")
	title:SetFont("WNSmallerMenuTitleNoClamp")
	title:SetTextColor(Color(255, 255, 255, 255))
	title:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	title:SetText(string.utf8upper("Информация о персонаже"))
	title:SizeToContents()
	title:Dock(TOP)

	-- Date, time
	local format = "%A, %B %d, %Y. %H:%M:%S"

	local timetext = rightFrame:Add("DLabel")
	timetext:SetFont("WNSmallerMenuTitleNoBoldNoClamp")
	timetext:SetTextColor(Color(255, 255, 255, 255))
	timetext:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	timetext:SetText(ix.date.GetFormatted(format))
	timetext:SizeToContents()
	timetext:Dock(TOP)
	timetext:DockMargin(0, 0, 0, SScaleMin(10 / 3))
	timetext.Think = function(this)
		if ((this.nextTime or 0) < CurTime()) then
			this:SetText(ix.date.GetFormatted(format))
			this.nextTime = CurTime() + 0.5
		end
	end

	local charInfoFrame = rightFrame:Add("DPanel")
	charInfoFrame:SetSize(rightFrame:GetWide(), SScaleMin(170 / 3))
	charInfoFrame:Dock(TOP)
	charInfoFrame:DockMargin(0, 0, 0, SScaleMin(20 / 3))
	charInfoFrame.Paint = function( self, w, h )
		FramePaint(self, w, h)

		surface.SetDrawColor(Color(150, 150, 150, 20))
		surface.SetMaterial(Material("willardnetworks/tabmenu/crafting/box_pattern.png", "noclamp"))
		surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / SScaleMin(414 / 3), h / SScaleMin(677 / 3) )
	end

	local function GetPartColor(name)
		if LocalPlayer():GetNetVar(name) and LocalPlayer():GetNetVar("fullHealth") == false then
			return Color(255, 129, 122, 255)
		else
			return Color(255, 255, 255, 255)
		end
	end

	local bodyParts = {
	{Image = "willardnetworks/f1menu/chest.png", Name = "ChestDamaged"},
	{Image = "willardnetworks/f1menu/head.png", Name = "HeadDamaged"},
	{Image = "willardnetworks/f1menu/larm.png", Name = "LArmDamaged"},
	{Image = "willardnetworks/f1menu/lleg.png", Name = "LLegDamaged"},
	{Image = "willardnetworks/f1menu/rarm.png", Name = "RArmDamaged"},
	{Image = "willardnetworks/f1menu/rleg.png", Name = "RLegDamaged"},
	{Image = "willardnetworks/f1menu/stomach.png", Name = "StomachDamaged"}
	}

	-- Body
	local bodyFrame = charInfoFrame:Add("DPanel")
	bodyFrame:SetWide( SScaleMin(100 / 3) )
	bodyFrame:Dock(LEFT)
	bodyFrame.Paint = function(self, w, h) end

	local body = bodyFrame:Add("DImage")
	local w, h = SScaleMin(64 / 3), SScaleMin(128 / 3)
	local x, y = bodyFrame:GetWide() * 0.5 - w * 0.5, charInfoFrame:GetTall() * 0.5 - h * 0.5

	body:SetSize( w, h )
	body:SetPos(x, y)
	body:SetImage( "willardnetworks/f1menu/body.png" )

	for k, v in pairs(bodyParts) do
		local bodypart = bodyFrame:Add("DImage")
		bodypart:SetSize( w, h )
		bodypart:SetPos(x, y)
		bodypart:SetImage( v.Image )
		bodypart:SetImageColor( GetPartColor(v.Name) )
	end

	local textFrame = charInfoFrame:Add("DPanel")
	textFrame:SetWide( SScaleMin( 500 / 3) )
	textFrame:Dock(LEFT)
	textFrame.Paint = function(self, w, h) end

	local name = textFrame:Add("DLabel")
	name:SetFont("TitlesFontNoClamp")
	name:SetTextColor(Color(254, 200, 0, 255))
	name:SetExpensiveShadow(1, Color(0, 0, 0, 50))
	name:SetText(LocalPlayer():Name())
	name:SizeToContents()
	name:Dock(TOP)
	name:DockMargin(0, SScaleMin(23 / 3), 0, 0)

	local faction = textFrame:Add("DLabel")
	local factionTable = ix.faction.Get(LocalPlayer():Team())
	faction:SetFont("TitlesFontNoClamp")
	faction:SetTextColor(Color(254, 200, 0, 255))
	faction:SetExpensiveShadow(1, Color(0, 0, 0, 50))
	faction:SetText(factionTable.name)
	faction:SizeToContents()
	faction:Dock(TOP)
	faction:DockMargin(0, SScaleMin(9 / 3), 0, 0)

	local citizenid = textFrame:Add("DLabel")
	local cidtext = LocalPlayer():GetCharacter():GetCid() or "Н/Д"
	citizenid:SetFont("TitlesFontNoClamp")
	citizenid:SetTextColor(Color(255, 255, 255, 255))
	citizenid:SetExpensiveShadow(1, Color(0, 0, 0, 50))
	citizenid:SetText("Гражданский ID: #"..cidtext or "Н/Д")
	citizenid:SizeToContents()
	citizenid:Dock(TOP)
	citizenid:DockMargin(0, SScaleMin(9 / 3), 0, 0)

	local tokens = textFrame:Add("DLabel")
	tokens:SetFont("TitlesFontNoClamp")
	tokens:SetTextColor(Color(255, 255, 255, 255))
	tokens:SetExpensiveShadow(1, Color(0, 0, 0, 50))
	tokens:SetText("Эдди: "..LocalPlayer():GetCharacter():GetMoney())
	tokens:SizeToContents()
	tokens:Dock(TOP)
	tokens:DockMargin(0, SScaleMin(9 / 3), 0, 0)

	local description = vgui.Create("DButton", rightFrame)
	description:SetFont("MenuFontNoClamp")
	description:SetText( "Описание" )
	description:Dock(TOP)
	description:DockMargin(0, 0, 0, 0 - SScaleMin(1 / 3))
	description:SetSize( rightFrame:GetWide(), SScaleMin(30 / 3) )

	description.Paint = function( self, w, h ) FramePaint(self, w, h) end

	description.DoClick = function ( btn )
		Derma_StringRequest(LocalPlayer():Name(), "Изменить ваше описание", LocalPlayer():GetCharacter():GetDescription(), function(desc)
			ix.command.Send("CharDesc", desc)
		end)
	end

	local detDesc = vgui.Create("DButton", rightFrame)
	detDesc:SetFont("MenuFontNoClamp")
	detDesc:SetText( "Анимации" )
	detDesc:Dock(TOP)
	detDesc:DockMargin(0, 0, 0, 0 - SScaleMin(1 / 3))
	detDesc:SetSize( rightFrame:GetWide(), SScaleMin(30 / 3) )
	detDesc.Paint = function( self, w, h ) FramePaint(self, w, h) end

	detDesc.DoClick = function ( btn )
		local MenuButtonOptions = DermaMenu() -- Creates the menu
		MenuButtonOptions:AddOption("Арест", function() ix.command.Send("actarrest") end ) -- Add options to the menu
		MenuButtonOptions:AddOption("Арест у стены", function() ix.command.Send("actarrestwall") end )
		MenuButtonOptions:AddOption("Ранен", function() ix.command.Send("actinjured") end )
		MenuButtonOptions:AddOption("Радость", function() ix.command.Send("actcheer") end )
		MenuButtonOptions:AddOption("Ранен", function() ix.command.Send("actinjured") end )
		MenuButtonOptions:AddOption("Облокотиться", function() ix.command.Send("actlean") end )
		MenuButtonOptions:AddOption("Наклониться", function() ix.command.Send("actpant") end )
		MenuButtonOptions:AddOption("Сесть", function() ix.command.Send("actsit") end )
		MenuButtonOptions:AddOption("Сесть у стены", function() ix.command.Send("actsitwall") end )
		MenuButtonOptions:AddOption("Стоять в стойке", function() ix.command.Send("actstand") end )
		MenuButtonOptions:AddOption("Помахать", function() ix.command.Send("actwave") end )
		MenuButtonOptions:AddOption("Посмотреть в окно", function() ix.command.Send("actwindow") end )		
		MenuButtonOptions:Open() -- Open the menu AFTER adding your options
		
		for _, v in pairs(MenuButtonOptions:GetChildren()[1]:GetChildren()) do
			if v:GetClassName() == "Label" then
				v:SetFont("MenuFontNoClamp")
			end
		end
	end

	local fallover = vgui.Create("DButton", rightFrame)
	fallover:SetFont("MenuFontNoClamp")
	fallover:SetText( "Упасть" )
	fallover:Dock(TOP)
	fallover:DockMargin(0, 0, 0, 0 - SScaleMin(1 / 3))
	fallover:SetSize( rightFrame:GetWide(), SScaleMin(30 / 3) )
	fallover.Paint = function( self, w, h ) FramePaint(self, w, h) end

	fallover.DoClick = function ( btn )
		ix.command.Send("CharFallover")
	end

	self:MakePopup()
	self:OnOpened()
end

function PANEL:OnOpened()
	self:SetAlpha(0)

	self:CreateAnimation(animationTime, {
		target = {currentAlpha = 255},
		easing = "outQuint",

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end
	})
end

function PANEL:OnKeyCodePressed(key)
	self.noAnchor = CurTime() + 0.5

	if (key == KEY_F1) then
		self:Remove()
	end
end

function PANEL:Think()
	if (self.bClosing) then
		return
	end

	local bF1Down = input.IsKeyDown(KEY_F1)

	if (bF1Down and (self.noAnchor or CurTime() + 0.4) < CurTime() and self.anchorMode) then
		self.anchorMode = false
	end

	if ((!self.anchorMode and !bF1Down) or gui.IsGameUIVisible()) then
		self:Remove()
	end
end

function PANEL:Paint(width, height)

	surface.SetDrawColor(Color(90, 0, 0, 220))
	surface.DrawRect(0, 0, width, height)

	Derma_DrawBackgroundBlur( self, 0 )

	BaseClass.Paint(self, width, height)
end

function PANEL:Remove()
	self.bClosing = true
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	if IsValid(self.icon) then
		self.icon:Remove()
	end

	CloseDermaMenus()
	gui.EnableScreenClicker(false)

	self:CreateAnimation(animationTime * 0.5, {
		index = 2,
		target = {currentBlur = 0},
		easing = "outQuint"
	})

	self:CreateAnimation(animationTime * 0.5, {
		target = {currentAlpha = 0},
		easing = "outQuint",

		-- we don't animate the blur because blurring doesn't draw things
		-- with amount < 1 very well, resulting in jarring transition
		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end,

		OnComplete = function(animation, panel)
			BaseClass.Remove(panel)
		end
	})
end

vgui.Register("ixF1Menu", PANEL, "ixSubpanelParent")

if (IsValid(ix.gui.F1Menu)) then
	ix.gui.F1Menu:Remove()
end

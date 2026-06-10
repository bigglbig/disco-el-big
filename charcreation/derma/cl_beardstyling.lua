local PANEL = {}
local padding = SScaleMin(10 / 3)

function PANEL:Init()	
	self:SetSize(ScrW(), ScrH())
	
	local background = self:Add("Panel")
	background:SetSize(self:GetSize())
	background.Paint = function(self, w, h)
		surface.SetDrawColor(Color(63, 58, 115, 220))
		surface.DrawRect(0, 0, w, h)

		Derma_DrawBackgroundBlur( self, 1 )
	end

	self.innerContent = background:Add("EditablePanel")
	self.innerContent:SetSize(SScaleMin(700 / 3), SScaleMin(600 / 3))
	self.innerContent:Center()
	self.innerContent:MakePopup()
	self.innerContent.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 130)
		surface.DrawRect(0, 0, w, h)
	end
	
	self:DrawTopBar()
	self:DrawModel()
	self:DrawLeftSide()
end

function PANEL:DrawTopBar()
	local topbar = self.innerContent:Add("Panel")
	topbar:SetSize(self.innerContent:GetWide(), SScaleMin(50 / 3))
	topbar:Dock(TOP)
	topbar.Paint = function( self, w, h )
		surface.SetDrawColor(0, 0, 0, 130)
		surface.DrawRect(0, 0, w, h)
	end

	local titleText = topbar:Add("DLabel")
	titleText:SetFont("CharCreationBoldTitleNoClamp")
	titleText:Dock(LEFT)
	titleText:SetText("Бритва")
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
end

function PANEL:DrawModel()
	local characterModelList = self.innerContent:Add("Panel")	
	characterModelList:Dock(RIGHT)
	characterModelList:SetWide(self.innerContent:GetWide() * 0.5)
	characterModelList.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 30));
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	
	local imgBackground = characterModelList:Add("DImage")
	imgBackground:SetImage("willardnetworks/tabmenu/inventory/char_bg.png")
	imgBackground:SetKeepAspect(true)
	imgBackground:Dock(FILL)
	imgBackground:DockMargin(1, 1, 1, 1)

	self.characterModel = imgBackground:Add("ixModelPanel")
	self.characterModel:Dock(FILL)
	
	self:SetCharacter()
	
	local eyepos = self.characterModel.Entity:GetBonePosition( self.characterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") )
	
	self.characterModel:SetLookAt(eyepos)
	self.characterModel:SetCamPos(eyepos-Vector(-12, -12, 0))	-- Move cam in front of eyes
	self.characterModel:SetFOV(45)
	self.characterModel.PaintModel = self.characterModel.Paint
end

function PANEL:SetCharacter()
	self.characterModel:SetModel(LocalPlayer():GetModel(), LocalPlayer():GetSkin(), true)
end

function PANEL:DrawLeftSide()
	self.leftSide = self.innerContent:Add("Panel")
	self.leftSide:Dock(LEFT)
	self.leftSide:SetWide(self.innerContent:GetWide() * 0.5)
	self.leftSide.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255, 10));
		surface.DrawRect(0, 0, w, h )
		
		surface.SetDrawColor(Color(255, 255, 255, 30));
		surface.DrawOutlinedRect(0, 0, w + 1, h)
	end
	
	local beardBodygroup = self.characterModel.Entity:GetBodygroup(10)
	if beardBodygroup == 5 or beardBodygroup == 8 then
		self:DrawBeardButtons()
	else
		local notEnoughPanel = self.leftSide:Add("Panel")
		notEnoughPanel:SetSize(self.leftSide:GetWide(), SScaleMin(50 / 3))
		notEnoughPanel:Dock(FILL)
		notEnoughPanel:DockMargin(0, self.innerContent:GetTall() * 0.5 - SScaleMin(100 / 3), 0, self.innerContent:GetTall() * 0.5 - SScaleMin(100 / 3))
		
		local notEnough = notEnoughPanel:Add("DLabel")
		notEnough:SetText("Моя борода слишком короткая...")
		notEnough:SetFont("MenuFontLargerBoldNoFix")
		notEnough:SetContentAlignment(5)
		notEnough:SizeToContents()
		notEnough:Center()
	end
	
	self:DrawShaveTrimButtons()
end

local function Paint(self, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(0, 0, w, h)
	
	surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:DrawBeardButtons()
	for i = 1, 6 do		
		local beardButton = self.leftSide:Add("DButton")
		local sideMargins = self.leftSide:GetWide() * 0.1
		beardButton:Dock(TOP)
		beardButton:SetTall(SScaleMin(50 / 3))
		beardButton:SetFont("MenuFontLargerBoldNoFix")
		beardButton:SetText("Стиль ")
		beardButton:DockMargin(sideMargins, padding * 3 - 1, sideMargins, 0)
		
		beardButton.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			if i == 5 then
				self.characterModel.Entity:SetBodygroup(10, 6)
			elseif i == 6 then
				self.characterModel.Entity:SetBodygroup(10, 7)
			else
				self.characterModel.Entity:SetBodygroup(10, i)
			end
		end
		
		beardButton.OnCursorEntered = function()
			surface.PlaySound("helix/ui/rollover.wav")
		end
		
		beardButton.Paint = function(self, w, h)
			Paint(self, w, h)
		end
	end
end

function PANEL:DrawShaveTrimButtons()	
	local buttonPanel = self.leftSide:Add("Panel")
	buttonPanel:Dock(BOTTOM)
	buttonPanel:SetTall(SScaleMin(50 / 3))
	
	local shaveButton = buttonPanel:Add("DButton")
	shaveButton:Dock(LEFT)
	shaveButton:SetText("Побриться")
	shaveButton:SetFont("MenuFontLargerBoldNoFix")
	shaveButton:SetWide(self.leftSide:GetWide() * 0.5)
	shaveButton.DoClick = function()		
		surface.PlaySound("willardnetworks/charactercreation/boop1.wav")
		self:CreateWarningPanel()
	end
	shaveButton.Paint = function(self, w, h)
		Paint(self, w, h)
	end
	
	local styleButton = buttonPanel:Add("DButton")
	styleButton:Dock(RIGHT)
	styleButton:SetFont("MenuFontLargerBoldNoFix")
	styleButton:SetText("Стиль")
	styleButton:SetWide(self.leftSide:GetWide() * 0.5)
	styleButton.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		if LocalPlayer():GetBodygroup(10) != self.characterModel.Entity:GetBodygroup(10) then
			netstream.Start("SetBeardBodygroup", self.characterModel.Entity:GetBodygroup(10))
			LocalPlayer():NotifyLocalized("Вы успешно поменяли стиль своей бороды!")
			self:Remove()
		else
			LocalPlayer():NotifyLocalized("Вы не можете выбрать тот же самый стиль бороды!")
		end
	end
	
	styleButton.Paint = function(self, w, h)
		Paint(self, w, h)
	end
	
	styleButton.OnCursorEntered = function()
		surface.PlaySound("helix/ui/rollover.wav")
	end
	
	shaveButton.OnCursorEntered = function()
		surface.PlaySound("helix/ui/rollover.wav")
	end
	
	local beardBodygroup = self.characterModel.Entity:GetBodygroup(10)
	if (beardBodygroup != 5 and beardBodygroup != 8) then
		styleButton:SetDisabled(true)
		styleButton.Paint = function(self, w, h)
			surface.SetDrawColor(255, 255, 255, 5) 
			surface.DrawRect(0, 0, w, h) 
		end
		
		styleButton.OnCursorEntered = function() end
	end
	
	if beardBodygroup == 0 then
		shaveButton:SetDisabled(true)
		shaveButton.Paint = function(self, w, h)
			surface.SetDrawColor(255, 255, 255, 5) 
			surface.DrawRect(0, 0, w, h) 
		end
		
		shaveButton.OnCursorEntered = function() end
	end
end

function PANEL:CreateWarningPanel()
	local warningPanel = vgui.Create("Panel")
	warningPanel:SetAlpha(0)
	warningPanel:MakePopup()
	warningPanel:SetSize(ScrW(), ScrH())
	warningPanel:AlphaTo(255, 0.5, 0)
	warningPanel.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 230)
		surface.DrawRect(0, 0, w, h)
	end
	
	local warningContent = warningPanel:Add("Panel")
	warningContent:SetSize(ScrW() * 0.4, SScaleMin(95 / 3))
	warningContent:Center()
	
	local label = warningContent:Add("DLabel")
	label:SetFont("CharCreationBoldTitleNoClamp")
	label:SetText("Это действие уберет вашу бороду, вы уверены?")
	label:SetContentAlignment(5)
	label:Dock(TOP)
	label:SizeToContents()
	
	local warningButtons = warningContent:Add("Panel")
	warningButtons:Dock(TOP)
	warningButtons:DockMargin(0, padding, 0, 0)
	warningButtons:SetTall(SScaleMin(50 / 3))
	
	local yes = warningButtons:Add("DButton")
	yes:Dock(LEFT)
	yes:SetWide(warningContent:GetWide() * 0.5)
	yes:SetText("ДА")
	yes:SetFont("CharCreationBoldTitleNoClamp")
	yes:SetContentAlignment(6)
	yes:SetTextColor(Color(200, 200, 200, 255))
	yes:SetTextInset(padding * 2, 0)
	yes.Paint = function(self, w, h) 
		if self:IsHovered() then
			self:SetTextColor(Color(255, 255, 255, 255))
		else
			self:SetTextColor(Color(200, 200, 200, 255))
		end
	end
	yes.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		surface.PlaySound("npc/antlion/idle1.wav")
		warningPanel:AlphaTo(0, 0.5, 0, function()
			warningPanel:Remove()
			self:Remove()

			netstream.Start("RemoveBeardBodygroup")
			self.characterModel.Entity:SetBodygroup(10, 0)
		end)
	end
	
	local no = warningButtons:Add("DButton")
	no:Dock(RIGHT)
	no:SetWide(warningContent:GetWide() * 0.5)
	no:SetText("НЕТ")
	no:SetFont("CharCreationBoldTitleNoClamp")
	no:SetTextColor(Color(200, 200, 200, 255))
	no:SetContentAlignment(4)
	no:SetTextInset(padding * 2, 0)
	no.Paint = function(self, w, h) 
		if self:IsHovered() then
			self:SetTextColor(Color(255, 255, 255, 255))
		else
			self:SetTextColor(Color(200, 200, 200, 255))
		end
	end
	no.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		warningPanel:AlphaTo(0, 0.5, 0, function()
			warningPanel:Remove()
		end)
	end
	
	yes.OnCursorEntered = function()
		surface.PlaySound("helix/ui/rollover.wav")
	end
	
	no.OnCursorEntered = function()
		surface.PlaySound("helix/ui/rollover.wav")
	end
end

vgui.Register("BeardStyling", PANEL, "EditablePanel")
local PANEL = {}

function PANEL:Init()
	local margin = SScaleMin(10 / 3)
	local iconSize = SScaleMin(20 / 3)
	local smallerIconSize = SScaleMin(16 / 3)
	local parent = self:GetParent()

	self:SetSize(parent:GetWide() * 0.5, parent:GetTall())
	self:Dock(LEFT)

	local imgBackground = self:Add("DImage")
	imgBackground:SetImage("aftermath/system/char_bg.png")
	imgBackground:SetKeepAspect(true)
	imgBackground:Dock(FILL)
	imgBackground:SetWide(self:GetWide() * 0.65)

	local statusArea = self:Add("Panel")
	statusArea:Dock(RIGHT)
	statusArea:SetWide(self:GetWide() * 0.35)
	statusArea.Paint = function( self, w, h )
		surface.SetDrawColor(Color(255, 255, 255, 10))
		surface.DrawRect(0, 0, w, h )
	end

	local innerStatus = statusArea:Add("Panel")
	innerStatus:SetSize(statusArea:GetWide() - (margin * 2), statusArea:GetTall())
	innerStatus:Dock(FILL)
	innerStatus:DockMargin(margin * 2, 0, margin * 2, 0)

	local function CreateTitle(parent, text)
		parent:Dock(TOP)
		parent:DockMargin(0, margin * 2 - (margin * 0.5), 0, margin * 0.5, 0)
		parent:SetText(text)
		parent:SetContentAlignment(4)
		parent:SetFont("MenuFontLargerNoClamp")
		parent:SizeToContents()
	end

	local function CreateSubBar(parent, iconImage, title, text, iconW, iconH)
		local SScaleMin25 = SScaleMin(25 / 3)
		parent:Dock(TOP)
		parent:DockMargin(0, margin * 0.5, 0, 0)
		parent:SetSize(innerStatus:GetWide(), SScaleMin25)

		local leftSideSub = parent:Add("Panel")
		leftSideSub:Dock(LEFT)
		leftSideSub:SetSize(parent:GetWide() * 0.65, SScaleMin25)

		local rightSideSub = parent:Add("Panel")
		rightSideSub:Dock(FILL)
		rightSideSub:SetSize(parent:GetWide() * 0.35, SScaleMin25)

		local iconPanel = leftSideSub:Add("Panel")
		iconPanel:Dock(LEFT)
		iconPanel:SetSize(iconW, parent:GetTall())

		local icon = iconPanel:Add("DImage")
		icon:SetSize(iconW, iconH)
		icon:SetImage(iconImage)
		icon:SetPos(0, iconPanel:GetTall() * 0.5 - icon:GetTall() * 0.5)

		local leftTitle = leftSideSub:Add("DLabel")
		leftTitle:SetFont("MenuFontLargerNoClamp")
		leftTitle:SetText(title or "")
		leftTitle:SetContentAlignment(4)
		leftTitle:Dock(LEFT)
		leftTitle:DockMargin(margin, 0, 0, 0)
		leftTitle:SizeToContents()

		local rightText = rightSideSub:Add("DLabel")
		rightText:SetFont("MenuFontLargerNoClamp")
		rightText:SetText(text or "")
		rightText:SetContentAlignment(6)
		rightText:Dock(RIGHT)
		rightText:SizeToContents()
	end

	local statusTitle = innerStatus:Add("DLabel")
	CreateTitle(statusTitle, "ПАРАМЕТРЫ")

	local hp = innerStatus:Add("Panel")
	CreateSubBar(hp, "willardnetworks/hud/cross.png", "Здоровье", LocalPlayer():Health(), smallerIconSize, smallerIconSize)

	local armor = innerStatus:Add("Panel")
	CreateSubBar(armor, "willardnetworks/hud/shield.png", "Броня", LocalPlayer():Armor(), smallerIconSize, smallerIconSize)

	local attributesTitle = innerStatus:Add("DLabel")
	CreateTitle(attributesTitle, "АТРИБУТЫ")

	for k, v in pairs(ix.special.list) do
		local attribute = innerStatus:Add("Panel")
		local character = LocalPlayer():GetCharacter()
		local special = character:GetSpecial(tostring(v.uniqueID))

		CreateSubBar(attribute, "willardnetworks/tabmenu/inventory/inv_"..v.uniqueID..".png", v.name, special.."/10", smallerIconSize, smallerIconSize)
	end

	local skills = LocalPlayer():GetCharacter():GetSkillExperience() or {}
	if !table.IsEmpty(skills) then
		local skillsTitle = innerStatus:Add("DLabel")
		CreateTitle(skillsTitle, "НАВЫКИ")
	end

	for k2, v2 in pairs(skills) do
		local skill = ix.skill:Find(k2)
		local skills = innerStatus:Add("Panel")
		
		if skill then
			local level = math.floor(v2 / 1000)
			CreateSubBar(skills, "willardnetworks/tabmenu/inventory/inv_"..skill.uniqueID..".png", skill.name, level.."/50", smallerIconSize, smallerIconSize)
		end
	end

	self.model = imgBackground:Add("ixModelPanel")
	self.model:Dock(FILL)
	self.model:SetFOV(ScrW() > 1920 and 50 or 40)
	self.model:SetModel(LocalPlayer():GetModel(), LocalPlayer():GetSkin(), true)

	-- Overrides the ixModelPanel's head following the cursor
	function self.model:LayoutEntity()
		local scrW, scrH = ScrW(), ScrH()
		local entity = self.Entity

		entity:SetAngles(Angle(0, 45, 0))
		entity:SetPos(Vector(0, 0, 4))

		entity:SetIK(false)

		if (self.copyLocalSequence) then
			entity:SetSequence(LocalPlayer():GetSequence())
			entity:SetPoseParameter("move_yaw", 360 * LocalPlayer():GetPoseParameter("move_yaw") - 180)
		end

		self:RunAnimation()

		local character = LocalPlayer():GetCharacter()
		if (character and character:IsVortigaunt()) then
			local headpos = entity:GetBonePosition(entity:LookupBone("ValveBiped.head"))
			entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
			return
		end

		for i = 2, 7 do
			entity:SetFlexWeight( i, 7 )
		end

		for i = 0, 1 do
			entity:SetFlexWeight( i, 1 )
		end
	end

	ix.gui.inventoryModel = self.model
end

function PANEL:Think()
	if !istable(ix.gui.inventoryModel) then
		ix.gui.inventoryModel = self.model
	end
end

vgui.Register("CharFrame", PANEL, "Panel")
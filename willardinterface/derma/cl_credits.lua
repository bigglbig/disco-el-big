
local CREDITS = {
	--[[{"Atle", "76561198002319944", {"creditManager", "Concept Art" }},
	{"Gr4ss", "76561197997384060", {"Primary Developer", "Lua Magician"}},
	{"Fruity", "76561198068753895", {"Lead UI Developer", "3D Modeling"}},
	{"Alexxx_07", "76561198050171407", {"Freelance Developer"}},
	{"M!NT", "76561198201768255", {"Sound Developer"}},--]]
}

local SPECIALS = {
	{
		--[[{"Imperator RAD-X", "76561197986444716"},
		{"Robert", "76561198032327315"},
		{"Mendelevius", "76561197967828719"}--]]


	},
	{
		--[[{"Bo Baker", "76561198037775178"},
		{"Kena", "76561198186266199"},
		{"DeNuke", "76561198009096978"}--]]
	}
}

local MISC = {
	{"Community Support", "Our deep gratitude and thanks for all the support from the WN community!"},
	{"Helix", "Copyright (c) 2015 Brian Hang, Kyu Yeon Lee\nCopyright (c) 2018 Alexander Grist-Hucker, Igor Radovanovic\nThis gamemode is build on top of Helix, available at https://github.com/NebulousCloud/helix, which is available under the MIT license.\nA full copy of the license can be acquired at https://github.com/NebulousCloud/helix/blob/master/LICENSE.txt."}
}

local url = "https://discord.gg/24hX9JuzU8"
local padding = SScaleMin(32 / 3)

-- logo
local PANEL = {}

function PANEL:Init()
	self:SetTall(SScaleMin(230 / 3))
	self:Dock(TOP)
	self:DockMargin(0, SScaleMin(30 / 3), 0, 0)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.SetMaterial(Material("aftermath/Am.png"))
	surface.DrawTexturedRect(width * 0.5 - SScaleMin(195 / 3) * 0.5, height * 0.5 - SScaleMin(196 / 3) * 0.5, SScaleMin(195 / 3), SScaleMin(196 / 3))
end

vgui.Register("ixCreditsLogo", PANEL, "Panel")

-- nametag
PANEL = {}

function PANEL:Init()
	self.name = self:Add("DLabel")
	self.name:SetFont("WNSmallerMenuTitleNoBoldNoClamp")

	self.avatar = self:Add("AvatarImage")
end

function PANEL:SetName(name)
	self.name:SetText(name)
end

function PANEL:SetAvatar(steamid)
	self.avatar:SetSteamID(steamid, SScaleMin(64 / 3))
end

function PANEL:PerformLayout(width, height)
	self.name:SetPos(width - self.name:GetWide(), 0)
	self.avatar:MoveLeftOf(self.name, padding * 0.5)
end

function PANEL:SizeToContents()
	self.name:SizeToContents()

	local tall = self.name:GetTall()
	self.avatar:SetSize(tall, tall)
	self:SetSize(self.name:GetWide() + self.avatar:GetWide() + padding * 0.5, self.name:GetTall())
end

vgui.Register("ixCreditsNametag", PANEL, "Panel")

-- name row
PANEL = {}

function PANEL:Init()
	self:DockMargin(0, padding, 0, 0)
	self:Dock(TOP)

	self.nametag = self:Add("ixCreditsNametag")

	self.tags = self:Add("DLabel")
	self.tags:SetFont("TitlesFontNoBoldNoClamp")

	self:SizeToContents()
end

function PANEL:SetName(name)
	self.nametag:SetName(name)
end

function PANEL:SetAvatar(steamid)
	self.nametag:SetAvatar(steamid)
end

function PANEL:SetTags(tags)
	for i = 1, #tags do
		tags[i] = L(tags[i])
	end

	self.tags:SetText(table.concat(tags, "\n"))
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(ix.config.Get("color"))
	surface.DrawRect(width * 0.5 - 1, 0, 1, height)
end

function PANEL:PerformLayout(width, height)
	self.nametag:SetPos(width * 0.5 - self.nametag:GetWide() - padding, 0)
	self.tags:SetPos(width * 0.5 + padding, 0)
end

function PANEL:SizeToContents()
	self.nametag:SizeToContents()
	self.tags:SizeToContents()

	self:SetTall(math.max(self.nametag:GetTall(), self.tags:GetTall()))
end

vgui.Register("ixCreditsRow", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
	self.left = {}
	self.right = {}
end

function PANEL:AddLeft(name, steamid)
	local nametag = self:Add("ixCreditsNametag")
	nametag:SetName(name)
	nametag:SetAvatar(steamid)
	nametag:SizeToContents()

	self.left[#self.left + 1] = nametag
end

function PANEL:AddRight(name, steamid)
	local nametag = self:Add("ixCreditsNametag")
	nametag:SetName(name)
	nametag:SetAvatar(steamid)
	nametag:SizeToContents()

	self.right[#self.right + 1] = nametag
end

function PANEL:PerformLayout(width, height)
	local y = 0

	for _, v in ipairs(self.left) do
		v:SetPos(width * 0.25 - v:GetWide() * 0.5, y)
		y = y + v:GetTall() + padding
	end

	y = 0

	for _, v in ipairs(self.right) do
		v:SetPos(width * 0.75 - v:GetWide() * 0.5, y)
		y = y + v:GetTall() + padding
	end

	if (IsValid(self.center)) then
		self.center:SetPos(width * 0.5 - self.center:GetWide() * 0.5, y)
	end
end

function PANEL:SizeToContents()
	local heightLeft, heightRight, centerHeight = 0, 0, 0

	if (#self.left > #self.right) then
		local center = self.left[#self.left]
		centerHeight = center:GetTall()

		self.center = center
		self.left[#self.left] = nil
	elseif (#self.right > #self.left) then
		local center = self.right[#self.right]
		centerHeight = center:GetTall()

		self.center = center
		self.right[#self.right] = nil
	end

	for _, v in ipairs(self.left) do
		heightLeft = heightLeft + v:GetTall() + padding
	end

	for _, v in ipairs(self.right) do
		heightRight = heightRight + v:GetTall() + padding
	end

	self:SetTall(math.max(heightLeft, heightRight) + centerHeight)
end

vgui.Register("ixCreditsSpecials", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
	self:Add("ixCreditsLogo")

	local link = self:Add("DLabel", self)
	link:SetFont("MenuFontNoClamp")
	link:SetTextColor(Color(200, 200, 200, 255))
	link:SetText(url)
	link:SetContentAlignment(5)
	link:Dock(TOP)
	link:SizeToContents()
	link:SetMouseInputEnabled(true)
	link:SetCursor("hand")
	link.OnMousePressed = function()
		gui.OpenURL(url)
	end

	for _, v in ipairs(CREDITS) do
		local row = self:Add("ixCreditsRow")
		row:SetName(v[1])
		row:SetAvatar(v[2])
		row:SetTags(v[3])
		row:SizeToContents()
	end

	local specials = self:Add("ixKLabel")
	specials:SetText(L("creditSpecial"):utf8upper())
	specials:SetTextColor(ix.config.Get("color"))
	specials:SetExpensiveShadow(1)
	specials:SetKerning(16)
	specials:SetCentered(true)
	specials:DockMargin(0, padding * 2, 0, padding)
	specials:Dock(TOP)
	specials:SetFont("WNSmallerMenuTitleNoBoldNoClamp")
	specials:SizeToContents()

	local specialList = self:Add("ixCreditsSpecials")
	specialList:DockMargin(0, padding, 0, 0)
	specialList:Dock(TOP)

	for _, v in ipairs(SPECIALS[1]) do
		specialList:AddLeft(v[1], v[2])
	end

	for _, v in ipairs(SPECIALS[2]) do
		specialList:AddRight(v[1], v[2])
	end

	specialList:SizeToContents()

	-- less more padding if there's a center column nametag
	if (IsValid(specialList.center)) then
		specialList:DockMargin(0, padding, 0, padding)
	end

	for _, v in ipairs(MISC) do
		local title = self:Add("DLabel")
		title:SetFont("WNSmallerMenuTitleNoBoldNoClamp")
		title:SetText(v[1])
		title:SetContentAlignment(5)
		title:SizeToContents()
		title:DockMargin(0, padding, 0, 0)
		title:Dock(TOP)

		local description = self:Add("DLabel")
		description:SetFont("TitlesFontNoBoldNoClamp")
		description:SetText(v[2])
		description:SetContentAlignment(5)
		description:SizeToContents()
		description:Dock(TOP)
	end

	self:Dock(TOP)
	self:SizeToContents()
end

function PANEL:SizeToContents()
	local height = padding

	for _, v in pairs(self:GetChildren()) do
		local _, top, _, bottom = v:GetDockMargin()
		height = height + v:GetTall() + top + bottom
	end

	self:SetTall(height)
end

vgui.Register("ixCredits", PANEL, "Panel")

hook.Add("PopulateHelpMenu", "ixCredits", function(tabs)
	tabs["авторы"] = function(container)
		container:Add("ixCredits")
	end
end)

-- Shared localization panel/hooks
local cameraActive = false
local combineOverlay = false
local cameraNumber = 1

local ButtonColor = Color(248, 248, 255)
local BackgroundColor = Color(0, 0, 0, 250)

local cameraLock = false

local cameras = {}
local cameraCount = #cameras

surface.CreateFont( "CameraFont", {
	font = "DebugFixed",
	size = 50,
	weight = 50,
	blursize = 0,
	scanlines = 50,
	extended = true,
} )

-- Console Panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(400, 300)
	self:Center()
	self:MakePopup()
	self.Paint = function(_, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, BackgroundColor )
	end

	self.topPanel = self:Add("Panel")
	self.topPanel:Dock(TOP)
	self.topPanel:SetTall(20)
	self.topPanel:DockMargin(10, 10, 10, 10)

	local line = self:Add("DShape")
	line:SetType("Rect")
	line:Dock(TOP)
	line:SetTall(1)
	line:SetColor(color_white)
	line:DockMargin(10, 0, 10, 10)

	self:GetAllCameras()
	self:CreateCloseButton()
	self:CreateTitle()
	self:CreateButtons()
end

function PANEL:CreateCloseButton()
	local close = self.topPanel:Add("DButton")
	close:Dock(RIGHT)
	close:SetWide(20)
	close:SetText("")
	close.Paint = function(_, w, h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("willardnetworks/tabmenu/navicons/exit-grey.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end

	close.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		self:TurnOff()
		self:Remove()
	end
end

function PANEL:CreateTitle()
	local combineText = self.topPanel:Add("DLabel")
	combineText:Dock(LEFT)
	combineText:SetFont("DebugFixed")
	combineText:SetText(">:: ")
	combineText:SetContentAlignment(4)
	combineText:SizeToContents()

	self.title = self.topPanel:Add("DLabel")
	self.title:Dock(LEFT)
	self.title:SetFont("DebugFixed")
	self.title:SetText("КОМАНДНАЯ КОНСОЛЬ")
	self.title:SetContentAlignment(4)
	self.title:SizeToContents()
end

function PANEL:CreateButtons()
	netstream.Start("GetLinkedUpdate")
	self.buttonlist = {}

	self.buttongrid = self:Add("DGrid")
	self.buttongrid:Dock(FILL)
	self.buttongrid:DockMargin(10, 0, 10, 0)
	self.buttongrid:SetCols(1)
	self.buttongrid:SetColWide(self:GetWide() - 20)
	self.buttongrid:SetRowHeight( 50 )

	local function CreateButton(parent, text, bAddToButtonList)
		parent:SetText(string.utf8upper(text))
		parent:SetSize(self:GetWide() - 20, 40)
		parent:SetTextColor(color_black)
		parent:SetFont("DebugFixed")
		parent.Paint = function(_, w, h)
			draw.RoundedBox( 8, 0, 0, w, h, ButtonColor )
		end

		if bAddToButtonList then
			self.buttongrid:AddItem(parent)
			self:AddToButtonList(parent)
		end
	end

	self.thirdperson = false

	local cameraButton = vgui.Create("DButton")
	CreateButton(cameraButton, "Камеры", true)
	cameraButton.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		if cameraCount >= 1 then
			cameraActive = true
			combineOverlay = true
			if ix.option.Get("thirdpersonEnabled") then
				self.thirdperson = true
				ix.option.Set("thirdpersonEnabled", false)
			end

			self:SetVisible(false)
			self:CreateCameraUI()
			self:AddPVS()
		end
	end

	local character = LocalPlayer():GetCharacter()
	local class = character:GetClass()
	if (class == CLASS_CP_RL or class == CLASS_CP_OVERSEER or class == CLASS_OW_SCANNER) then
		netstream.Start("GetConsoleUpdates", self.entity)

		local addLink = vgui.Create("DButton")
		CreateButton(addLink, "Обновление", true)
		addLink.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			local chooseUpdatePanel = vgui.Create("DFrame")
			chooseUpdatePanel:SetSize(300, 500)
			chooseUpdatePanel:MakePopup()
			chooseUpdatePanel:Center()
			chooseUpdatePanel:SetTitle("Выбрать обновления")

			local scrollPanel = chooseUpdatePanel:Add("DScrollPanel")
			scrollPanel:Dock(FILL)

			for _, v in pairs(self.updates) do
				local button = scrollPanel:Add("DButton")
				button:Dock(TOP)
				button:SetTall(50)
				button:SetText(string.utf8sub( v.update_text, 1, 20 ).."... - "..v.update_poster)
				button.Paint = function(_, w, h)
					surface.SetDrawColor(Color(0, 0, 0, 100))
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
					surface.DrawOutlinedRect(0, 0, w, h)
				end
				button.DoClick = function()
					surface.PlaySound("helix/ui/press.wav")
					netstream.Start("SetLinkedUpdate", self.entity, v.update_text)
					chooseUpdatePanel:Remove()
				end
			end
		end
	end

	local updates = vgui.Create("DButton")
	CreateButton(updates, "обновления", true)
	updates.DoClick = function()
		if !ix.data.Get("CameraConsoleLinkedUpdate") then
			LocalPlayer():NotifyLocalized("Нет назначенных обновлений")
			return
		end

		local updatePanel = vgui.Create("DFrame")
		updatePanel:SetSize(600, 700)
		updatePanel:Center()
		updatePanel:MakePopup()
		updatePanel:SetTitle("Текущее обновление")

		local htmlPanel = updatePanel:Add("HTML")
		htmlPanel:Dock(FILL)
		local string = "<p style='font-family: Open Sans; font-size: 13; color: rgb(41,243,229);'>"..tostring(ix.data.Get("CameraConsoleLinkedUpdate")).."</p>"
		if istable(ix.data.Get("CameraConsoleLinkedUpdate")) then
			if table.IsEmpty(ix.data.Get("CameraConsoleLinkedUpdate")) then
				string = "<p style='font-family: Open Sans; font-size: 13; color: rgb(41,243,229);'>No updates.</p>"
			end
		end

		local html = string.Replace(string, "\n", "<br>")
		htmlPanel:SetHTML(html)
		htmlPanel.Paint = function(_, w, h)
			surface.SetDrawColor(115, 40, 40, 75)
			surface.DrawRect(0, 0, w, h)
		end
	end
end

function PANEL:CreateCameraUI()
	local cameraPanel = vgui.Create( "Panel" )
	cameraPanel:SetPos( ScrW() / 2 + 350, ScrH() / 2 + 280)
	cameraPanel:SetSize( 200, 100 )
	cameraPanel:MakePopup()

	local CameraUI3 = vgui.Create( "Panel", cameraPanel )
	CameraUI3:SetPos( ScrW() / 2 + 350, ScrH() / 2 + 110)
	CameraUI3:SetSize( 200, 150 )

	local back = cameraPanel:Add("DButton")
	back:Dock(TOP)
	back:SetTextColor(color_black)
	back:SetTall(20)
	back:SetText("Назад")
	back.Paint = function(_, w, h)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(Material("willardnetworks/tabmenu/navicons/exit-grey.png"))
		surface.DrawTexturedRect(0, 0, w, h)
	end

	back.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		self:CameraOff()
		cameraPanel:Remove()
		self:SetVisible(true)
		if self.thirdperson then
			ix.option.Set("thirdpersonEnabled", true)
		end
	end

	local nextCamera = vgui.Create( "DButton", cameraPanel )
	nextCamera:SetText( "Следующая" )
	nextCamera:SetTextColor( Color(0, 0, 0, 255) )
	nextCamera:SetPos( 105, 30 )
	nextCamera:SetSize( 75, 25 )
	nextCamera.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		if cameraNumber < cameraCount then
			cameraNumber = cameraNumber + 1
			self:AddPVS()
		end
	end

	local previousCamera = vgui.Create( "DButton", cameraPanel )
	previousCamera:SetText( "Предыдушая" )
	previousCamera:SetTextColor( Color(0, 0, 0, 255) )
	previousCamera:SetPos( 20, 30 )
	previousCamera:SetSize( 75, 25 )
	previousCamera.DoClick = function()
		surface.PlaySound("helix/ui/press.wav")
		if cameraNumber > 1 then
			cameraNumber = cameraNumber - 1
			self:AddPVS()
		end
	end

	local LockCamera = vgui.Create( "DButton", cameraPanel )
		LockCamera:SetText( "Закрыть" )
		LockCamera:SetTextColor( Color(0, 0, 0, 255) )
		LockCamera:SetPos( 20, 60 )
		LockCamera:SetSize( 75, 25 )
		LockCamera.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			cameraLock = !cameraLock
		end

	local List = vgui.Create( "DPanelList", CameraUI3 )
	List:SetSize(190,120)
	List:SetSpacing( 5 )
	List:SetPos(5,15)
	List:EnableHorizontal( false )
	List:EnableVerticalScrollbar( true )
	for k, _ in pairs(cameras) do
		local Spawnd = vgui.Create("DButton",List)
		Spawnd:SetText("Камера "..k)
		Spawnd:SetTextColor( Color(0, 0, 0, 255) )
		Spawnd:SetSize( 75, 25 )
		Spawnd.DoClick = function()
			surface.PlaySound("helix/ui/press.wav")
			cameraNumber = k
			self:AddPVS()
		end
		Spawnd.Paint = function()
			draw.RoundedBox( 8, 0, 0, Spawnd:GetWide(), Spawnd:GetTall(), ButtonColor )
		end
		List:AddItem( Spawnd )
	end

	local Elements = { cameraPanel; CameraUI3; back; nextCamera; previousCamera; LockCamera}
	for k,v in pairs(Elements) do
		if k > 2 then
			v.Paint = function()
				draw.RoundedBox( 8, 0, 0, v:GetWide(), v:GetTall(), ButtonColor )
			end
		else
			v.Paint = function()
				draw.RoundedBox( 8, 0, 0, v:GetWide(), v:GetTall(), BackgroundColor )
			end
		end
	end
end

function PANEL:AddToButtonList(button)
	if button then
		if self.buttonlist then
			if istable(self.buttonlist) then
				table.insert(self.buttonlist, button)
			end
		end
	end
end

function PANEL:CameraOff()
	cameraActive = false
	combineOverlay = false
	cameraNumber = 1
	cameraLock = false
end

function PANEL:TurnOff()
	netstream.Start("CloseConsole", self.entity)
end

function PANEL:AddPVS()
	netstream.Start("SetConsoleCameraPos", self.entity, cameras[cameraNumber])
end

function PANEL:GetAllCameras()
	if !table.IsEmpty(cameras) then
		table.Empty(cameras)
	end

	for _, v in pairs(ents.GetAll()) do
		if (v:GetClass() == "npc_combine_camera" or v:GetClass() == "npc_turret_ceiling") then
			table.insert(cameras, v)
		end
	end
	cameraCount = #cameras
end


vgui.Register("ConsolePanel", PANEL, "Panel")

-- Hooks
local function DrawCombineOverlay()
	if combineOverlay then
		DrawMaterialOverlay( "effects/combine_binocoverlay.vmt", 0.1 )

		surface.SetTextColor( 255, 0, 0, 255 )
		surface.SetTextPos( 100, 75 )
		surface.SetFont("CameraFont")
		surface.DrawText( "Камера ".. cameraNumber )
	end
end

hook.Add( "RenderScreenspaceEffects", "ConsoleCameraOverlay", DrawCombineOverlay )

local function CalculateConsoleCameraView( client, pos, angles, fov )
	if cameraActive then
		if cameraCount >= 1 then
			if cameras[cameraNumber]:IsValid() then
				local BoneIndex = cameras[cameraNumber]:LookupAttachment("eyes")
				local Bone = cameras[cameraNumber]:GetAttachment( BoneIndex )

				local view = {}

				if cameraLock == false then
					view.origin = Bone.Pos + cameras[cameraNumber]:GetForward() * 6
					view.angles = Bone.Ang
					view.fov = fov
					view.vm_origin = LocalPlayer():GetForward() * -100
				else
					view.origin = cameras[cameraNumber]:GetPos() + cameras[cameraNumber]:GetUp() * -50 + cameras[cameraNumber]:GetForward() * 30
					view.angles = cameras[cameraNumber]:GetAngles() + Angle(10,0,0)
					view.fov = fov
					view.vm_origin = LocalPlayer():GetForward() * -100
				end

				return view
			end
		end
	end
end

hook.Add( "CalcView", "CalculateConsoleCameraView", CalculateConsoleCameraView )
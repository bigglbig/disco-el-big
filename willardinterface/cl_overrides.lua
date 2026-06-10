
local PLUGIN = PLUGIN

ix.hud.appendixColors = {
	["yellow"] = Color(255, 204, 0, 255),
	["red"] = Color(255, 78, 69, 255),
	["зелёные"] = Color(128, 200, 97, 255),
	["синие"] = Color(85, 194, 240, 255)
}

function ix.hud.PopulateItemTooltip(tooltip, item)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(item.GetName and item:GetName() or L(item.name))
	name:SetMaxWidth(math.max(name:GetMaxWidth(), ScrW() * 0.5))
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText(item:GetDescription() or "")
	description:SizeToContents()

	if item.invID then
		if (item.GetColorAppendix) or item.colorAppendix then
			if (isfunction(item.GetColorAppendix) and istable(item:GetColorAppendix()) and item:GetColorAppendix() != false) or istable(item.colorAppendix) then
				for color, text in pairs(item.GetColorAppendix and item:GetColorAppendix() or item.colorAppendix) do
					local appendix = tooltip:Add("DLabel")
					appendix:SetText(tostring(text) or "NOAPPENDIXTEXT")
					appendix:SetTextColor(ix.hud.appendixColors[color] or color_white)
					appendix:SetTextInset(15, 0)
					appendix:Dock(BOTTOM)
					appendix:DockMargin(0, 0, 0, 5)
					appendix:SetFont("ixSmallFont")
					appendix:SizeToContents()
					appendix:SetTall(appendix:GetTall() + 15)
				end
			end
		end
	end

	if (item.PopulateTooltip) then
		item:PopulateTooltip(tooltip)
	end

	hook.Run("PopulateItemTooltip", tooltip, item)
end

local function PerformLayoutWindow(self)
	local titlePush = 0

	if ( IsValid( self.imgIcon ) ) then

		self.imgIcon:SetPos( SScaleMin(5 / 3), SScaleMin(5 / 3) )
		self.imgIcon:SetSize( SScaleMin(16 / 3), SScaleMin(16 / 3) )
		titlePush = SScaleMin(16 / 3)
	end

	self.btnClose:SetPos( self:GetWide() - SScaleMin(31 / 3) - (0 - SScaleMin(4 / 3)), 0 )
	self.btnClose:SetSize( SScaleMin(31 / 3), SScaleMin(24 / 3) )

	self.btnMaxim:SetPos( self:GetWide() - SScaleMin(31 / 3) * 2 - (0 - SScaleMin(4 / 3)), 0 )
	self.btnMaxim:SetSize( SScaleMin(31 / 3), SScaleMin(24 / 3) )

	self.btnMinim:SetPos( self:GetWide() - SScaleMin(31 / 3) * 3 - (0 - SScaleMin(4 / 3)), 0 )
	self.btnMinim:SetSize( SScaleMin(31 / 3), SScaleMin(24 / 3) )

	self.lblTitle:SetPos( SScaleMin(8 / 3) + titlePush, SScaleMin(2 / 3) )
	self.lblTitle:SetSize( self:GetWide() - SScaleMin(25 / 3) - titlePush, SScaleMin(20 / 3) )
end

local function PaintWindow(self, w, h)
	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

	surface.SetDrawColor(Color(40, 40, 40, 100))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(Color(111, 111, 136, (255 / 100 * 30)))
	surface.DrawOutlinedRect(0, 0, w, h)
	
	surface.DrawRect(0, 0, w, self.lblTitle:GetTall() + SScaleMin(5 / 3))
	return true
end

function Derma_Query( strText, strTitle, ... )

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window.lblTitle:SetFont("MenuFontNoClamp")
	Window.lblTitle:SizeToContents()
	
	Window.PerformLayout = function(self)
		PerformLayoutWindow(self)
	end
	
	Window.Paint = function(self, w, h)
		PaintWindow(self, w, h)
	end

	local InnerPanel = vgui.Create( "DPanel", Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
	Text:SetFont("MenuFontNoClamp")
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( SScaleMin(30 / 3) )
	ButtonPanel:SetPaintBackground( false )

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 5

	for k=1, 8, 2 do

		local Text = select( k, ... )
		if Text == nil then break end

		local Func = select( k+1, ... ) or function() end

		local Button = vgui.Create( "DButton", ButtonPanel )
		Button:SetText( Text )
		Button:SetFont("MenuFontNoClamp")
		Button:SizeToContents()
		Button:SetTall( SScaleMin(25 / 3) )
		Button:SetWide( Button:GetWide() + SScaleMin(20 / 3) )
		Button.DoClick = function() Window:Close() Func() end
		Button:SetPos( x, SScaleMin(5 / 3) )

		x = x + Button:GetWide() + SScaleMin(5 / 3)

		ButtonPanel:SetWide( x )
		NumOptions = NumOptions + 1

	end

	local w, h = Text:GetSize()

	w = math.max( w, ButtonPanel:GetWide() )

	Window:SetSize( w + SScaleMin(50 / 3), h + SScaleMin(25 / 3) + SScaleMin(45 / 3) + SScaleMin(10 / 3) )
	Window:Center()

	InnerPanel:StretchToParent( SScaleMin(5 / 3), SScaleMin(25 / 3), SScaleMin(5 / 3), SScaleMin(45 / 3) )

	Text:StretchToParent( SScaleMin(5 / 3), SScaleMin(5 / 3), SScaleMin(5 / 3), SScaleMin(5 / 3) )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

	if ( NumOptions == 0 ) then

		Window:Close()
		Error( "Derma_Query: Created Query with no Options!?" )
		return nil

	end

	return Window

end

function Derma_StringRequest( strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window.lblTitle:SetFont("MenuFontNoClamp")
	Window.lblTitle:SizeToContents()
	
	Window.PerformLayout = function(self)
		PerformLayoutWindow(self)
	end
	
	Window.Paint = function(self, w, h)
		PaintWindow(self, w, h)
	end

	local InnerPanel = vgui.Create( "DPanel", Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
	Text:SetFont("MenuFontNoClamp")
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
	TextEntry:SetText( strDefaultText or "" )
	TextEntry:SetFont("MenuFontNoClamp")
	TextEntry.OnEnter = function() Window:Close() fnEnter( TextEntry:GetValue() ) end
	TextEntry:SetTall(Text:GetTall())

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( SScaleMin(30 / 3) )
	ButtonPanel:SetPaintBackground( false )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SetFont("MenuFontNoClamp")
	Button:SizeToContents()
	Button:SetTall( SScaleMin(25 / 3) )
	Button:SetWide( Button:GetWide() + SScaleMin(20 / 3) )
	Button:SetPos( SScaleMin(5 / 3), SScaleMin(5 / 3) )
	Button.DoClick = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( strButtonCancelText or "Cancel" )
	ButtonCancel:SetFont("MenuFontNoClamp")
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( SScaleMin(25 / 3) )
	ButtonCancel:SetWide( Button:GetWide() + SScaleMin(20 / 3) )
	ButtonCancel:SetPos( SScaleMin(5 / 3), SScaleMin(5 / 3) )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, SScaleMin(5 / 3) )

	ButtonPanel:SetWide( Button:GetWide() + SScaleMin(5 / 3) + ButtonCancel:GetWide() + SScaleMin(10 / 3) )

	local w, h = Text:GetSize()
	w = math.max( w, SScaleMin(400 / 3) )

	Window:SetSize( w + SScaleMin(50 / 3), h + SScaleMin(25 / 3) + SScaleMin(75 / 3) + SScaleMin(10 / 3) )
	Window:Center()

	InnerPanel:StretchToParent( SScaleMin(5 / 3), SScaleMin(25 / 3), SScaleMin(5 / 3), SScaleMin(45 / 3) )

	Text:StretchToParent( SScaleMin(5 / 3), SScaleMin(5 / 3), SScaleMin(5 / 3), SScaleMin(35 / 3) )

	TextEntry:StretchToParent( SScaleMin(5 / 3), nil, SScaleMin(5 / 3), nil )
	TextEntry:AlignBottom( 5 )

	TextEntry:RequestFocus()
	TextEntry:SelectAllText( true )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

	return Window

end
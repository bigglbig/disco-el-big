
local PLUGIN = PLUGIN

if (CLIENT) then
	local healthIcon = ix.util.GetMaterial("willardnetworks/hud/hp.png")
	local armorIcon = ix.util.GetMaterial("willardnetworks/hud/armor.png")
	local staminaIcon = ix.util.GetMaterial("willardnetworks/hud/stamina.png")
	local thirstIcon = ix.util.GetMaterial("willardnetworks/hud/thirst.png")
	local foodIcon = ix.util.GetMaterial("willardnetworks/hud/food.png")
	local toxicIcon = ix.util.GetMaterial("willardnetworks/hud/toxic.png")

	local yellow = Color(255, 255, 255)
	local fakeHealthColor = Color(145, 145, 145)
	local background = Color(0, 0, 0, 128)

	local paddingX, paddingY = SScaleMin(30 / 3), SScaleMin(30 / 3)
	local iconW, iconH = SScaleMin(14 / 3), SScaleMin(14 / 3)
	local iconRightPadding = SScaleMin(10 / 3)
	local iconBottomPadding = SScaleMin(10 / 3)
	local barWidth = SScaleMin(90 / 3)
	local barHeight = iconH / 2

	local function CreateRow(icon, value, yaw, bFakeHealth, bBleeding, bHealth)	
		local scale = ix.option.Get("HUDScalePercent")
		local bleedingRectH = SScaleMin(20 / 3)
		local x = paddingX + ((iconW / 100) * scale) + ((iconRightPadding / 100) * scale)
		local y = paddingY + ((yaw / 100) * scale) + (iconH / 2) - ((iconH / 2) - (barHeight / 2))
		local w = barWidth * math.Clamp(value, 0, 1)
		local h = barHeight
		local configpos = ix.option.Get("HUDPosition")
		local hudposX, hudposY = 0, 0
			
		if configpos == "Верхний правый" then
			hudposX = ScrW() - x - ((barWidth / 100) * scale) - paddingX
		elseif configpos == "Нижний правый" then
			hudposX = ScrW() - x - ((barWidth / 100) * scale) - paddingX
			hudposY = ScrH() - y - barHeight - paddingY - ((yaw / 100) * scale)
			
			if bBleeding then
				hudposY = ScrH() - y - bleedingRectH - paddingY - ((yaw / 100) * scale)
			end
		elseif configpos == "Нижний левый" then
			hudposY = ScrH() - y - barHeight - paddingY - ((yaw / 100) * scale)
			
			if bBleeding then
				hudposY = ScrH() - y - bleedingRectH - paddingY - ((yaw / 100) * scale)
			end
		end
		
		if !bBleeding then		
			-- Draw icon
			if !bFakeHealth then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(icon)
				surface.DrawTexturedRect(paddingX + hudposX, paddingY + ((yaw / 100) * scale) + hudposY, (iconW / 100) * scale, (iconH / 100) * scale)
			
				-- Bar background
				surface.SetDrawColor(background)
				surface.DrawRect(x + hudposX, y + hudposY, (barWidth / 100 * scale), (h / 100) * scale)
			end
			
			-- Actual info
			surface.SetDrawColor(bFakeHealth and fakeHealthColor or yellow)
			
			if bHealth and (LocalPlayer():GetCharacter():GetBleedout() > 0) then
				surface.SetDrawColor(Color(255, 78, 69, 255))
			end
			
			surface.DrawRect(x + hudposX, y + hudposY, (w / 100) * scale, (h / 100) * scale)
		end
		
		if bBleeding then		
			local newWidth = ((barWidth + iconRightPadding + iconW) / 100) * scale
			local newHeight = (bleedingRectH / 100) * scale
			draw.RoundedBox( 4, paddingX + hudposX, y + hudposY, newWidth, newHeight, Color(255, 78, 69, 255) )
			
			surface.SetFont( "HUDBleedingFontBold" )
			surface.SetTextColor( 255, 255, 255 )
			
			local textSizeW, textSizeY = surface.GetTextSize( "КРОВОТЕЧЕНИЕ" )
			surface.SetTextPos( paddingX + hudposX + (newWidth * 0.043), y + hudposY + (newHeight * 0.15))
			surface.DrawText( "КРОВОТЕЧЕНИЕ" )
		end
	end

	ix.option.Add("HUDMinimalShow", ix.type.bool, false, {
		category = "Внешность"
	})

	ix.option.Add("HUDScalePercent", ix.type.number, 100, {
		category = "Внешность", min = 0, max = 100, decimals = 0, OnChanged = function()
			surface.CreateFont( "HUDBleedingFontBold", {
				font = "Open Sans Bold",
				extended = false,
				size = (SScaleMin(15 / 3) / 100) * ix.option.Get("HUDScalePercent"),
				weight = 550,
				antialias = true,
			} )
		end
	})
	
	surface.CreateFont( "HUDBleedingFontBold", {
		font = "Open Sans Bold",
		extended = false,
		size = (SScaleMin(15 / 3) / 100) * ix.option.Get("HUDScalePercent"),
		weight = 550,
		antialias = true,
	} )
	
	ix.option.Add("HUDPosition", ix.type.array, "Верхний левый", {
		category = "Внешность",
		populate = function()
			local entries = {}

			for _, v in SortedPairs({"Верхний левый", "Верхний правый", "Нижний левый", "Нижний правый"}) do
				local name = v
				local name2 = v:utf8sub(1, 1):utf8upper() .. v:utf8sub(2)

				if (name) then
					name = name
				else
					name = name2
				end

				entries[v] = name
			end

			return entries
		end
	})

	ix.option.Add("HealthBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("ArmorBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("StaminaBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("HungerBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("ThirstBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("BleedingBarEnabled", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("BleedingEffects", ix.type.bool, true, {
		category = "Внешность"
	})
	
	ix.option.Add("gasPointsEnabled", ix.type.bool, true, {
		category = "Внешность"
	})

	function PLUGIN:HUDPaint()
		if (ix.option.Get("alwaysShowBars", false) or hook.Run("ShouldBarDraw", bar)) then
			local client = LocalPlayer()
			local character = client:GetCharacter()
			local yaw = 0
			
			if (!character) then return end
			
			if ix.option.Get("HealthBarEnabled", true) then
				if ix.option.Get("HUDMinimalShow") then
					if client:Health() < 100 then
						-- Health/Fake Health
						CreateRow(nil, (client:Health() - character:GetHealing("fakeHealth")) / client:GetMaxHealth(), 0, true)
						CreateRow(healthIcon, client:Health() / client:GetMaxHealth(), 0, false, false, true)
						
						yaw = yaw + iconH + iconBottomPadding
					end
				else
					CreateRow(nil, (client:Health() - character:GetHealing("fakeHealth")) / client:GetMaxHealth(), 0, true)
					CreateRow(healthIcon, client:Health() / client:GetMaxHealth(), 0, false, false, true)
					
					yaw = yaw + iconH + iconBottomPadding
				end
			end
			
			-- Armor
			if (client:Armor() > 0) and ix.option.Get("ArmorBarEnabled", true) then
				if ix.option.Get("HUDMinimalShow") then
					if client:Armor() < 100 then
						CreateRow(armorIcon, client:Armor() / 100, yaw)
						
						yaw = yaw + iconH + iconBottomPadding
					end
				else
					CreateRow(armorIcon, client:Armor() / 100, yaw)
						
					yaw = yaw + iconH + iconBottomPadding
				end
			end
			
			-- Stamina
			if client:GetLocalVar("stm", 0) < 100 and ix.option.Get("StaminaBarEnabled", true) then
				CreateRow(staminaIcon, client:GetLocalVar("stm", 0) / 100, yaw)
				
				yaw = yaw + iconH + iconBottomPadding
			end
			
			-- Hunger
			if character:GetHunger() <= 100 and ix.option.Get("HungerBarEnabled", true) then
				CreateRow(foodIcon, (100 - character:GetHunger()) / 100, yaw)
				
				yaw = yaw + iconH + iconBottomPadding
			end

			-- Cyberpsychosis (replaces Toxin)
			local cyberpsychosis = client:GetNetVar("ixCyberpsychosis", 0)
			if ix.option.Get("gasPointsEnabled", true) then
				CreateRow(toxicIcon, math.Clamp(cyberpsychosis, 0, 100) / 100, yaw)
				
				yaw = yaw + iconH + iconBottomPadding
			end
			
			-- Thirst
			if character:GetThirst() <= 100 and ix.option.Get("ThirstBarEnabled", true) then
				CreateRow(thirstIcon, (100 - character:GetThirst()) / 100, yaw)
				
				yaw = yaw + iconH + iconBottomPadding
			end
			
			if (character:GetBleedout() > 0) and ix.option.Get("BleedingBarEnabled", true) then
				CreateRow("", 0, yaw, nil, true)
				
				yaw = yaw + iconH + iconBottomPadding
			end
		end
		
		if (LocalPlayer():Health() < 100) and ix.option.Get("BleedingEffects", true) then
			surface.SetDrawColor(Color(255, 0, 0, 0))
			
			if LocalPlayer():Health() < 80 then
				surface.SetDrawColor(Color(255, 0, 0, 10))
			end
			
			if LocalPlayer():Health() < 60 then
				surface.SetDrawColor(Color(255, 0, 0, 20))
			end
			
			if LocalPlayer():Health() < 40 then
				surface.SetDrawColor(Color(255, 0, 0, 40))
			end
			
			if LocalPlayer():Health() < 20 then
				surface.SetDrawColor(Color(255, 0, 0, 60))
			end
		
			surface.SetMaterial(Material("willardnetworks/nlrbleedout/bleedout-background.png"))
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end
end
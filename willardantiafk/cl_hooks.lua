local PLUGIN = PLUGIN
PLUGIN.afk = false

local COLOR_BLACK_WHITE = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 0.9,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local player  = LocalPlayer()
local aimVector = nil
local posVector = nil

function PLUGIN:GetHookCallPriority(hook)
	if (hook == "GetInjuredText") then
		return 1100
	end
end

function PLUGIN:HUDPaint()
	if (PLUGIN.afk and player and player:GetAimVector()) then
		draw.SimpleText(
			"ВЫ ОТОШЛИ",
			"HUDFontExtraLarge",
			ScrW() * 0.5,
			ScrH() - 230,
			Color(255, 255, 255, 255),
			TEXT_ALIGN_CENTER
		)
		draw.SimpleText(
			"Счётчики голода, жажды, и рационов были приостановлены",
			"WNBleedingText",
			ScrW() * 0.5,
			ScrH() - 165,
			Color(255, 255, 255, 255),
			TEXT_ALIGN_CENTER
		)
		draw.SimpleText(
			"Вас могут исключить",
			"WNBleedingText",
			ScrW() * 0.5,
			ScrH() - 135,
			Color(255, 78, 69, 255),
			TEXT_ALIGN_CENTER
		)
	end
end

local afkColor = Color(255, 78, 69, 255)
function PLUGIN:GetInjuredText(client)
	local character = client:GetCharacter()
	if (character:GetBleedout() > 0) then
		return
	end

	if (client:GetNetVar("isAFK") == true) then
		return "playerIsAFK", afkColor
	end
end

net.Receive("ixPlayerIsAfk", function(len)
	local bAFK = net.ReadBool()
	if (bAFK) then
		timer.Create("WaitForSpawn", 0.1, 1, function()
			PLUGIN:UpdateVectors()
			PLUGIN.afk = true
		end)
	end
end)

function PLUGIN:UpdateVectors()
	aimVector = LocalPlayer():GetAimVector()
	posVector = LocalPlayer():GetPos()
	player = LocalPlayer()
end

function PLUGIN:RenderScreenspaceEffects()
	if (PLUGIN.afk and player and aimVector and player:GetAimVector()) then
		if aimVector ~= player:GetAimVector() or posVector ~= player:GetPos() then
			PLUGIN.afk = false

			print(aimVector, posVector, player:GetAimVector(), player:GetPos())
			net.Start("ixClientNotAfk")
			net.WriteBool(true)
			net.SendToServer()
			return
		else
			DrawColorModify(COLOR_BLACK_WHITE)
		end
	end
end

net.Receive("OnAFKPrintPlayers", function()
	local text = net.ReadString()
	chat.AddText(Color(255,255,255), text)
end)

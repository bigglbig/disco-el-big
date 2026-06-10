local PLUGIN = PLUGIN

util.AddNetworkString("OnAFKPrintPlayers")
util.AddNetworkString("ixPlayerIsAfk")
util.AddNetworkString("ixClientNotAfk")

net.Receive("ixClientNotAfk", function(len, client)
	local notAfk = net.ReadBool()
	local character = client:GetCharacter()

	if notAfk and character then
		client.isAFK = nil
		client:SetNetVar("isAFK", false)
	end
end)

do
	local CHAR = ix.meta.character

	function CHAR:GetPlayerIsAfk()
		return self:GetPlayer():GetNetVar("isAFK", false)
	end
end

function PLUGIN:UpdateAFK(client, character)
	local aimVector = client:GetAimVector()
	local posVector = client:GetPos()

	if (client.ixLastAimVector ~= aimVector or client.ixLastPosition ~= posVector) then
		client.ixLastAimVector = aimVector
		client.ixLastPosition = posVector
		client.isAFK = nil
	else
		local afkTime = ix.config.Get("afkTime")

		client.isAFK = client.isAFK or CurTime()

		local delta = CurTime() - client.isAFK

		if (delta > afkTime) then
			local d = delta - afkTime
			character.vars.playerIsAfk = d > 3600 and math.Round(d / 3600).." minutes" or (d > 60 and math.Round(d / 60).." minutes" or math.Round(d, 1).." seconds")
			client:SetNetVar("isAFK", true)

			net.Start("ixPlayerIsAfk")
				net.WriteBool(true)
			net.Send(client)
		end
	end
end
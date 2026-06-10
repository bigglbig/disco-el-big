local PLUGIN = PLUGIN

netstream.Hook("SetConsoleCameraPos", function(client, console, camera)
	if !IsValid(client.ixConsole) or !IsValid(console) or console != client.ixConsole then
		return
	end

	client.currentCamera = camera
end)

netstream.Hook("GetConsoleUpdates", function(client)
	if !IsValid(client.ixConsole) then
		return
	end

	PLUGIN:GetConsoleUpdates(client)

	timer.Simple(0.05, function()
		netstream.Start(client, "SetConsoleUpdates", PLUGIN.updatelist or {})
	end)
end)

netstream.Hook("GetLinkedUpdate", function(client)
	if !IsValid(client.ixConsole) then
		return
	end

	-- FIX ME, SYNC UPDATES
	local update = ix.data.Get("CameraConsoleLinkedUpdate", {})

	netstream.Start(client, "SetLinkedUpdateCL", update)
end)

netstream.Hook("SetLinkedUpdate", function(client, console, update)
	if !IsValid(client.ixConsole) then
		return
	end

	local character = client:GetCharacter()

	if !character then
		return
	end

	local class = character:GetClass()

	if class != CLASS_CP_RL and class != CLASS_CP_OVERSEER and class != CLASS_OW_SCANNER then
		return
	end

	ix.data.Set("CameraConsoleLinkedUpdate", update)

	for k, v in pairs(player.GetAll()) do
		if v.ixConsole and IsValid(v.ixConsole) then
			netstream.Start(v, "SetLinkedUpdateCL", update)
			continue
		end
	end
end)

netstream.Hook("CloseConsole", function(client, console)
	netstream.Start(client, "CloseConsole")

	if IsValid(client.ixConsole) then
		client.ixConsole = nil
	end

	if IsValid(console.user) and console.user == client then
		console.user = nil
	end
end)
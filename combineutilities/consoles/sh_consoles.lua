ix.util.IncludeDir("ixhl2rp/plugins/combineutilities/consoles/derma", true)

if (CLIENT) then
	netstream.Hook("SetLinkedUpdateCL", function(update)
		ix.data.Set("CameraConsoleLinkedUpdate", update)
	end)

	netstream.Hook("SetConsoleUpdates", function(updates)
		if (IsValid(ix.gui.consolePanel)) then
			ix.gui.consolePanel.updates = updates
		end
	end)

	netstream.Hook("CloseConsole", function(updates)
		if (IsValid(ix.gui.consolePanel)) then
			ix.gui.consolePanel:TurnOff()
			ix.gui.consolePanel:Remove()
		end
	end)
end

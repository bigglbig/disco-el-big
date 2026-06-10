
do
	local CLASS = {}
	CLASS.color = Color(200, 0, 0)
	CLASS.format = "Dispatch radios on command \"%s\""

	function CLASS:CanSay(speaker, text)
		if (!speaker:IsDispatch()) then
			speaker:NotifyLocalized("notAllowed")

			return false
		end
	end

	function CLASS:CanHear(speaker, listener)
		return listener:IsCombine()
	end

	function CLASS:OnChatAdd(speaker, text)
		if ix.option:Get("DispatchIconEnabled") then
			chat.AddText(Material("willardnetworks/chat/dispatch_icon.png"), self.color, string.format(self.format, text))
		else
			chat.AddText(self.color, string.format(self.format, text))
		end
	end

	ix.chat.Register("dispatch_radio", CLASS)
end

do
	local COMMAND = {}
	COMMAND.arguments = ix.type.text

	function COMMAND:OnRun(client, message)
		if (!client:IsRestricted()) then
			ix.chat.Send(client, "dispatch_radio", message)
		else
			return "@notNow"
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsDispatch()
	end

	ix.command.Add("C", COMMAND)
end

if (CLIENT) then
	ix.option.Add("DispatchIconEnabled", ix.type.bool, true, {
		category = "ChatIcons"
	})
end
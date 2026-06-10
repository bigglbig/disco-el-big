-- haha deez nuts, got 'em!
do
	local CLASS = {}

	function CLASS:CanSay(speaker, text)
		if (!speaker:IsDispatch()) then
			speaker:NotifyLocalized("notAllowed")

			return false
		end
	end

	function CLASS:CanHear(speaker, listener)
		return listener:IsDispatch()
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(Color(255, 200, 50, 255), "@dispatch ", Color(254, 39, 39, 255), speaker:Name().." ", Color(150, 200, 150, 255), text)
	end

	ix.chat.Register("dispatch_chat", CLASS)
end

do
	local COMMAND = {}
	COMMAND.arguments = ix.type.text

	function COMMAND:OnRun(client, message)
		if (!client:IsRestricted()) then
			ix.chat.Send(client, "dispatch_chat", message)
		else
			return "@notNow"
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsDispatch()
	end

	ix.command.Add("D", COMMAND)
end
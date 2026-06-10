local PLUGIN = PLUGIN

ITEM.name = "Газета"
ITEM.uniqueID = "newspaper"
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Газета."
ITEM.category = "Бумага"

function ITEM:GetDescription()
	local data = {}
	
	if self:GetData("data") then
		data = ix.data.Get(self:GetData("data")) or {}
		if table.IsEmpty(data) then
			netstream.Start("SetNewsPaperContentWithID", self:GetData("data"))
		end
	end
	
	local title = "Газета."
	if data[1] then
		title = "A newspaper with the title "..data[1].titleEntry or "Газета"
	end
	
	return title
end

function ITEM:GetName()
	-- Don't ask me why it's set up this way, but it breaks in the shipment if not
	local data = {}
	
	if self:GetData("data") then
		data = ix.data.Get(self:GetData("data")) or {}
		if table.IsEmpty(data) then
			netstream.Start("SetNewsPaperContentWithID", self:GetData("data"))
		end
	end
	
	local title = "Газета"
	
	if data[1] then
		title = data[1].titleEntry or "Газета"
	end
	
	return title
end

ITEM.functions.Read = {
	name = "Прочитать",
	tip = "Прочитать газету.",
	icon = "icon16/text_align_center.png",
	OnRun = function(item)
		local client = item.player
		local getdata = ix.data.Get(item:GetData("data"), {})
		if getdata then
			netstream.Start(client, "OpenNewspaperEditor", false, getdata)
		end
		
		client.ReadNewspaperCooldown = 2
		timer.Simple(2, function()
			if client then
				client.ReadNewspaperCooldown = 0
			end
		end)
		
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		if client.ReadNewspaperCooldown then
			if client.ReadNewspaperCooldown > 0 then
				client:NotifyLocalized("Вы пытаетесь прочитать это слишком быстро!")
				return false
			end
		end
		
		if (!item:GetData("data")) then
			client:NotifyLocalized("Эта газета пуста..")
			return false
		end
	end
}
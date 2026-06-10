local PLUGIN = PLUGIN

netstream.Hook("ixRequestLogs", function(client, searchData)
	if !CAMI.PlayerHasAccess(client, "Helix - Manage Logs", nil) then
		return
	end

	local curTime = CurTime()

	if client.nextLogSearch and client.nextLogSearch > curTime then
		netstream.Start(client, "ixSendLogs", math.ceil(client.nextLogSearch - curTime))
		return
	end

	local distance = tonumber(searchData.distance) or 0
	local perpage = searchData.logsPerPage
	local offset = perpage * (searchData.currentPage - 1)
	local time = os.time()

	local query = mysql:Select("ix_logs")
		query:Select("datetime")
		query:Select("steamid")
		query:Select("text")
		query:Select("logtype")
		query:Select("map")
		query:Select("pos_x")
		query:Select("pos_y")
		query:Select("pos_z")

		if searchData.map and #searchData.map > 0 then
			query:Where("map", searchData.map)
		end

		if searchData.steamid and #searchData.steamid > 0 then
			query:Where("steamid", searchData.steamid)
		end

		if searchData.logType and #searchData.logType > 0 and searchData.logType != "ALL" then
			query:Where("logType", searchData.logType)
		end

		local after = searchData.after
		local before = searchData.before

		if isnumber(searchData.before) and searchData.before > 0 then
			query:WhereGTE("datetime", time - before)
		end

		if isnumber(searchData.after) and searchData.after > 0 then
			query:WhereLTE("datetime", time - after)
		end

		if !searchData.desc then
			query:OrderByAsc("datetime")
		else
			query:OrderByDesc("datetime")
		end

		query:Callback(function(result)
			local logs = {}

			if istable(result) then
				local id = 0
				for k, v in ipairs(result) do
					if searchData.text and #searchData.text > 0 then
						if !string.find(v.text, searchData.text) then
							continue
						end
					end

					if v.pos_x and distance and distance > 0 then
						local pos = Vector(v.pos_x, v.pos_y, v.pos_z)

						if pos:Distance(client:GetPos()) > distance then
							continue
						end
					end

					id = id + 1

					if id <= offset then continue end
					if id > offset + perpage then break end

					v.id = id
					logs[#logs + 1] = v
				end
			end

			netstream.Start(client, "ixSendLogs", logs)
		end)
	query:Execute()

	client.nextLogSearch = curTime + 1
end)

netstream.Hook("ixRequestLogTypes", function(client)
	if !CAMI.PlayerHasAccess(client, "Helix - Manage Logs", nil) then
		return
	end

	local logtypes = {
		[1] = "ALL"
	}

	for logtype, v in pairs(ix.log.types) do
		logtypes[#logtypes + 1] = logtype
	end

	netstream.Start(client, "ixSendLogTypes", logtypes)
end)

netstream.Hook("ixLogTeleport", function(client, pos)
	if !CAMI.PlayerHasAccess(client, "Helix - Tp", nil) then
		return
	end

	if !client:Alive() or !client:GetCharacter() then
		return
	end

	client:SetPos(pos or client:GetPos())
end)

function PLUGIN:DatabaseConnected()
	local query = mysql:Create("ix_logs")
		query:Create("id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
		query:Create("datetime", "INT(11) UNSIGNED NOT NULL")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("text", "TEXT NOT NULL")
		query:Create("logtype", "TEXT NOT NULL")
		query:Create("map", "TEXT NOT NULL")
		query:Create("pos_x", "REAL DEFAULT NULL")
		query:Create("pos_y", "REAL DEFAULT NULL")
		query:Create("pos_z", "REAL DEFAULT NULL")
		query:PrimaryKey("id")
	query:Execute()
end

function ix.log.Add(client, logType, ...)
	local logString, logFlag = ix.log.Parse(client, logType, ...)
	if (logString == -1) then return end

	CAMI.GetPlayersWithAccess("Helix - Logs", function(receivers)
		ix.log.Send(receivers, logString, logFlag)
	end)

	Msg("[WILLARD LOG] ", logString .. "\n")

	ix.log.CallHandler("Write", client, logString, logFlag, logType, ...)

	local pos = client:GetPos()
	local query = mysql:Insert("ix_logs")
		query:Insert("datetime", os.time())
		query:Insert("steamid", client:SteamID()) --client:SteamID())
		query:Insert("text", logString)
		query:Insert("logtype", logType)
		query:Insert("map", game.GetMap())
		query:Insert("pos_x", pos.x)
		query:Insert("pos_y", pos.y)
		query:Insert("pos_z", pos.z)
	query:Execute()
end
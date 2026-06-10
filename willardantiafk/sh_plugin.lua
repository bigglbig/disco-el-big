local PLUGIN = PLUGIN

PLUGIN.name = "Anti-AFK"
PLUGIN.author = "Gr4Ss, M!NT"
PLUGIN.description = "Stops AFK players from earning wages and kicks when server is full."
PLUGIN.license = [[
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
For more information, please refer to <http://unlicense.org/>
]]
ix.afk = ix.afk or {}

ix.config.Add("afkTime", 300, "The amount of seconds it takes for someone to be flagged as AFK.", nil, {
	data = {min = 120, max = 3600},
	category = "antiafk"
})

ix.lang.AddTable("english", {
    playerIsAFK = "This player is AFK",
})

ix.command.Add("PrintAFKPlayers", {
	description = "Prints the currently AFK players into your chat.",
	privilege = "SeeAFKPlayers",
	adminOnly = true,
	OnRun = function(self, client)
        local msg        = "No one is currently AFK."
        local afkplayers = {}
        for _, ply in pairs(player.GetAll()) do
            local char = ply:GetCharacter()
            if (char) then
		if (char:GetPlayerIsAfk()) then
			table.insert(
				afkplayers,
				#afkplayers + 1,
				char
			)
		end
            end
        end
        if (#afkplayers > 0) then
            msg = "Current AFK players: "
            for _, char in pairs(afkplayers) do
                msg = msg..tostring(char:GetName()).." - "..tostring(char:GetPlayer()).." for "..tostring(char.vars.playerIsAfk).." "
            end
        end
        net.Start("OnAFKPrintPlayers")
            net.WriteString(msg)
        net.Send(client)
	end
})


ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

-- =======================
-- SHARED (sh_plugin.lua)
-- =======================

PLUGIN.name = "Big Neo"
PLUGIN.author = "Big Terminal Team"
PLUGIN.description = "Neo dodge system (Wesker + Matrix full)"
PLUGIN.uniqueID = "big_neo"

-- Инициализация таблиц
PLUGIN.neoModePlayers = {}
PLUGIN.invisModePlayers = {}
PLUGIN.dashCooldowns = {}

if SERVER then
    util.AddNetworkString("BigNeo_DodgeVisual")
end

-- Загрузка серверной и клиентской частей
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

-- =======================
-- КОМАНДА NEOMOD
-- =======================
ix.command.Add("neomod", {
    description = "Toggle Neo mode",
    OnRun = function(self, client)
        local plugin = ix.plugin.Get("big_neo")
        if not plugin then
            client:Notify("Ошибка: плагин не найден!")
            return
        end
        
        local id = client:SteamID()
        
        if id ~= "STEAM_0:1:217191793" then
            client:Notify("У вас нет доступа к этой команде!")
            return
        end
        
        if plugin.neoModePlayers[id] then
            plugin.neoModePlayers[id] = nil
            client:SetNWBool("BigNeoMode", false)
            client:Notify("Режим Нео выключен.")
            print("[Big Neo] " .. client:Name() .. " выключил режим Нео")
        else
            plugin.neoModePlayers[id] = true
            client:SetNWBool("BigNeoMode", true)
            client:Notify("Режим Нео включён! Вы уклоняетесь от ВСЕХ атак.")
            print("[Big Neo] " .. client:Name() .. " включил режим Нео")
        end
    end
})

-- =======================
-- КОМАНДА INVISFORPLAYER
-- =======================
ix.command.Add("invisforplayer", {
    description = "Стать невидимым для всех кроме указанного игрока",
    arguments = ix.type.string,
    OnRun = function(self, client, targetName)
        local plugin = ix.plugin.Get("big_neo")
        if not plugin then
            client:Notify("Ошибка: плагин не найден!")
            return
        end
        
        local steamID = client:SteamID()
        
        if steamID ~= "STEAM_0:1:217191793" then
            client:Notify("У вас нет доступа к этой команде!")
            return
        end
        
        local targetPly = nil
        local searchName = string.lower(targetName)
        
        for _, ply in ipairs(player.GetAll()) do
            local char = ply:GetCharacter()
            if char then
                local name = char:GetName()
                if string.lower(name) == searchName or string.find(string.lower(name), searchName, 1, true) then
                    targetPly = ply
                    break
                end
            end
        end
        
        if not IsValid(targetPly) then
            client:Notify("Персонаж '" .. targetName .. "' не найден!")
            return
        end
        
        local targetChar = targetPly:GetCharacter()
        if not targetChar then
            client:Notify("У цели нет персонажа!")
            return
        end
        
        plugin.invisModePlayers[steamID] = {
            targetCharID = targetChar:GetID(),
            targetPly = targetPly,
            targetName = targetChar:GetName()
        }
        
        client:SetNWBool("BigNeoInvisMode", true)
        client:SetNWEntity("BigNeoInvisTarget", targetPly)
        
        -- Убираем SetNoDraw и SetColor
        client:SetNotSolid(true)
        client:DrawShadow(false)
        
        client:Notify("Вы стали невидимым для всех кроме: " .. targetChar:GetName())
        targetPly:Notify(client:Name() .. " стал невидимым и наблюдает за вами!")
        
        print("[Big Neo] " .. client:Name() .. " включил невидимость для " .. targetChar:GetName())
    end
})

-- =======================
-- КОМАНДА INVISFORPLAYEROFF
-- =======================
ix.command.Add("invisforplayeroff", {
    description = "Выключить режим невидимости",
    OnRun = function(self, client)
        local plugin = ix.plugin.Get("big_neo")
        if not plugin then
            client:Notify("Ошибка: плагин не найден!")
            return
        end
        
        local steamID = client:SteamID()
        
        if steamID ~= "STEAM_0:1:217191793" then
            client:Notify("У вас нет доступа к этой команде!")
            return
        end
        
        if not plugin.invisModePlayers[steamID] then
            client:Notify("Вы не в режиме невидимости!")
            return
        end
        
        plugin.invisModePlayers[steamID] = nil
        client:SetNWBool("BigNeoInvisMode", false)
        client:SetNWEntity("BigNeoInvisTarget", NULL)
        
        client:SetNotSolid(false)
        client:DrawShadow(true)
        
        client:Notify("Вы снова видны для всех!")
        print("[Big Neo] " .. client:Name() .. " выключил невидимость")
    end
})

print("[Big Neo] sh_plugin.lua loaded!")
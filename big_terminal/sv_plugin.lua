local PLUGIN = PLUGIN

print("[BigTerminal] sv_plugin.lua loaded!")

-- ============================================================================
-- ЗАЩИТА ФРАКЦИЙ
-- ============================================================================

local PROTECTED_FACTIONS = {
    ["Администратор сервера"] = true,
    ["admin"] = true,
    ["superadmin"] = true,
    ["operator"] = true,
}

function PLUGIN:IsProtectedFaction(client)
    if not IsValid(client) then return false end
    local char = client:GetCharacter()
    if not char then return false end
    local faction = char:GetFaction()
    if faction and PROTECTED_FACTIONS[faction] then
        return true
    end
    local teamName = team.GetName(client:Team())
    if teamName and PROTECTED_FACTIONS[teamName] then
        return true
    end
    if client:IsSuperAdmin() then
        return true
    end
    return false
end

function PLUGIN:PunishHackAttempt(hacker, targetName)
    if not IsValid(hacker) then return end
    local output = {
        "═══════════════════════════════════════",
        "  [КРИТИЧЕСКАЯ ОШИБКА]",
        "═══════════════════════════════════════",
        "",
        "  Я очень сухой мальчик…",
        "  Я хочу пить…",
        "",
        "  [СИСТЕМА] ВЗЛОМ ЗАПРЕЩЁН",
        "  [СИСТЕМА] ПРИМЕНЕНО НАКАЗАНИЕ",
        "═══════════════════════════════════════",
    }
    net.Start("ixBigTerminalOutput")
        net.WriteTable(output)
    net.Send(hacker)
    local char = hacker:GetCharacter()
    if char then
        if char.SetHunger then char:SetHunger(0) end
        if char.SetThirst then char:SetThirst(0) end
        char:SetData("hunger", 0)
        char:SetData("thirst", 0)
    end
    local currentHealth = hacker:Health()
    local newHealth = math.floor(currentHealth * 0.5)
    hacker:SetHealth(newHealth)
    hacker:Notify("Вы попытались взломать защищённую цель!")
    hacker:EmitSound("buttons/button10.wav")
    hacker:ViewPunch(Angle(20, 0, 0))
end

-- ============================================================================
-- СИСТЕМА ОТЛАДКИ
-- ============================================================================

PLUGIN.debugMode = PLUGIN.debugMode or false

function PLUGIN:DebugPrint(...)
    if not self.debugMode then return end
    local args = {...}
    local msg = "[BigTerminal DEBUG] "
    for _, v in ipairs(args) do
        msg = msg .. tostring(v) .. " "
    end
    print(msg)
end

concommand.Add("bigterminal_debug", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[BigTerminal] Только суперадмины могут использовать эту команду!")
        return
    end
    PLUGIN.debugMode = not PLUGIN.debugMode
    local status = PLUGIN.debugMode and "ВКЛЮЧЁН" or "ВЫКЛЮЧЁН"
    local message = "[BigTerminal] Режим отладки " .. status
    print(message)
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, message)
    end
end, nil, "Включить/выключить режим отладки терминала")

concommand.Add("bigterminal_status", function(ply, cmd, args)
    local lines = {
        "═══════════════════════════════════════",
        "  BIG TERMINAL STATUS",
        "═══════════════════════════════════════",
        "",
        "  Debug mode: " .. (PLUGIN.debugMode and "ON" or "OFF"),
        "  Users loaded: " .. table.Count(PLUGIN.terminalUsers or {}),
        "  Forums loaded: " .. table.Count(PLUGIN.forums or {}),
        "  Viruses tracked: " .. table.Count(PLUGIN.viruses or {}),
        "  Antiviruses tracked: " .. table.Count(PLUGIN.antiviruses or {}),
        "  Active hacks: " .. table.Count(PLUGIN.activeHacks or {}),
        "  Terminals in world: " .. #ents.FindByClass("ix_big_terminal"),
        "  Access points in world: " .. #ents.FindByClass("ix_access_point"),
        "",
        "═══════════════════════════════════════"
    }
    for _, line in ipairs(lines) do
        print(line)
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, line)
        end
    end
end, nil, "Показать статус терминала")

--[[concommand.Add("bigterminal_test_save", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[BigTerminal] Только суперадмины могут использовать эту команду!")
        return
    end
    local data = PLUGIN:GetData()
    local terminals = 0
    local accessPoints = 0
    if data then
        for _, v in ipairs(data) do
            if v.class == "ix_big_terminal" then
                terminals = terminals + 1
            elseif v.class == "ix_access_point" then
                accessPoints = accessPoints + 1
            end
        end
    end
    local lines = {
        "═══════════════════════════════════════",
        "  BIG TERMINAL SAVE DATA",
        "═══════════════════════════════════════",
        "",
        "  Saved terminals: " .. terminals,
        "  Saved access points: " .. accessPoints,
        "",
        "  Terminals in world: " .. #ents.FindByClass("ix_big_terminal"),
        "  Access points in world: " .. #ents.FindByClass("ix_access_point"),
        "",
        "═══════════════════════════════════════"
    }
    for _, line in ipairs(lines) do
        print(line)
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTCONSOLE, line)
        end
    end
    -- Сохранение через штатный механизм Helix (принудительный дамп)
    ix.entity.SaveAll()
    print("[BigTerminal] Forced save via ix.entity.SaveAll()")
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[BigTerminal] Forced save via ix.entity.SaveAll()")
    end
end, nil, "Проверить сохранённые данные терминала")]]

concommand.Add("bigterminal_test", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[BigTerminal] Только суперадмины могут использовать эту команду!")
        return
    end
    if not IsValid(ply) then
        print("[BigTerminal] Эта команда только для игроков!")
        return
    end
    local testCmd = args[1] or "help"
    local testArgs = args[2] or ""
    print("[BigTerminal] Testing command: " .. testCmd .. " args: " .. testArgs)
    PLUGIN:ProcessTerminalCommand(ply, testCmd, testArgs, nil)
end, nil, "Тестировать команду терминала (bigterminal_test <cmd> [args])")

-- ============================================================================
-- СОХРАНЕНИЕ ОСТАЛЬНЫХ ДАННЫХ (форумы, пользователи, вирусы и т.д.)
-- ============================================================================

function PLUGIN:SaveForums() ix.data.Set("big_terminal_forums", self.forums) end
function PLUGIN:LoadForums() self.forums = ix.data.Get("big_terminal_forums") or {} end

function PLUGIN:SaveUsers() ix.data.Set("big_terminal_users", self.terminalUsers) end
function PLUGIN:LoadUsers() self.terminalUsers = ix.data.Get("big_terminal_users") or {} end

function PLUGIN:SaveViruses() ix.data.Set("big_terminal_viruses", self.viruses) end
function PLUGIN:LoadViruses() self.viruses = ix.data.Get("big_terminal_viruses") or {} end

function PLUGIN:SaveAntiviruses() ix.data.Set("big_terminal_antiviruses", self.antiviruses) end
function PLUGIN:LoadAntiviruses() self.antiviruses = ix.data.Get("big_terminal_antiviruses") or {} end

function PLUGIN:SaveAccessPointViruses() ix.data.Set("big_terminal_accesspoint_viruses", self.accessPointViruses) end
function PLUGIN:LoadAccessPointViruses() self.accessPointViruses = ix.data.Get("big_terminal_accesspoint_viruses") or {} end

function PLUGIN:SaveAccessPointAntiviruses() ix.data.Set("big_terminal_accesspoint_antiviruses", self.accessPointAntiviruses) end
function PLUGIN:LoadAccessPointAntiviruses() self.accessPointAntiviruses = ix.data.Get("big_terminal_accesspoint_antiviruses") or {} end

function PLUGIN:SavePlayerStats() ix.data.Set("big_terminal_player_stats", self.playerStats) end
function PLUGIN:LoadPlayerStats() self.playerStats = ix.data.Get("big_terminal_player_stats") or {} end

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ (без ручного сохранения энтити)
-- ============================================================================

function PLUGIN:InitPostEntity()
    self:DebugPrint("[InitPostEntity] Plugin initialized")
    -- Загрузка терминалов и точек доступа теперь выполняется автоматически Helix'ом
end

function PLUGIN:SaveData()
    local data = {}

    for _, entity in ipairs(ents.FindByClass("ix_big_terminal")) do
        local bodygroups = {}

        for _, v in ipairs(entity:GetBodyGroups() or {}) do
            bodygroups[v.id] = entity:GetBodygroup(v.id)
        end

        data[#data + 1] = {
            name = entity:GetDisplayName(),
            description = entity:GetDescription(),
            pos = entity:GetPos(),
            angles = entity:GetAngles(),
            model = entity:GetModel(),
            skin = entity:GetSkin(),
            bodygroups = bodygroups,
            owner = entity:GetOwnerID()
        }
    end

    -- Сохраняем в основной дата-ключ плагина
    self:SetData(data)
    
    -- Остальные сохранения
    self:SaveForums()
    self:SaveUsers()
    self:SaveViruses()
    self:SaveAntiviruses()
    self:SaveAccessPointViruses()
    self:SaveAccessPointAntiviruses()
    self:SavePlayerStats()
end

function PLUGIN:LoadData()
    -- Сначала загружаем терминалы
    for _, v in ipairs(self:GetData() or {}) do
        local entity = ents.Create("ix_big_terminal")
        entity:SetPos(v.pos)
        entity:SetAngles(v.angles)
        entity:Spawn()

        entity:SetModel(v.model)
        entity:SetSkin(v.skin or 0)
        entity:SetSolid(SOLID_BBOX)
        entity:PhysicsInit(SOLID_BBOX)

        local physObj = entity:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        entity:SetDisplayName(v.name)
        entity:SetDescription(v.description)

        for id, bodygroup in pairs(v.bodygroups or {}) do
            entity:SetBodygroup(id, bodygroup)
        end
        
        if v.owner then
            entity:SetNWInt("owner", v.owner)
        end
    end
    
    -- Остальные загрузки
    self:LoadForums()
    self:LoadUsers()
    self:LoadViruses()
    self:LoadAntiviruses()
    self:LoadAccessPointViruses()
    self:LoadAccessPointAntiviruses()
    self:LoadPlayerStats()
end

-- Хуки для автосохранения энтити больше не нужны, их можно удалить
-- function PLUGIN:OnEntityCreated(entity) ... end
-- function PLUGIN:EntityRemoved(entity) ... end

-- ============================================================================
-- ФОРУМЫ
-- ============================================================================

function PLUGIN:CreateForum(name, ownerCharID)
    local forumID = os.time() .. "_" .. ownerCharID
    self.forums[forumID] = {
        name = name,
        owner = ownerCharID,
        members = {ownerCharID},
        messages = {},
        created = os.date("%d/%m/%Y")
    }
    self:SaveForums()
    return forumID
end

function PLUGIN:JoinForum(forumID, charID)
    if not self.forums[forumID] then return false end
    if not table.HasValue(self.forums[forumID].members, charID) then
        table.insert(self.forums[forumID].members, charID)
        self:SaveForums()
    end
    return true
end

function PLUGIN:DeleteForum(forumID, ownerCharID)
    if not self.forums[forumID] then return false end
    if self.forums[forumID].owner == ownerCharID then
        self.forums[forumID] = nil
        self:SaveForums()
        return true
    end
    return false
end

function PLUGIN:AddForumMessage(forumID, charName, message)
    if not self.forums[forumID] then return false end
    table.insert(self.forums[forumID].messages, {
        author = charName,
        text = message,
        time = os.date("%H:%M:%S"),
        date = os.date("%d/%m/%Y")
    })
    self:SaveForums()
    return true
end

function PLUGIN:GetForumMessages(forumID, page)
    if not self.forums[forumID] then return {} end
    local messages = self.forums[forumID].messages
    local perPage = 25
    local startIdx = (page - 1) * perPage + 1
    local endIdx = math.min(startIdx + perPage - 1, #messages)
    local result = {}
    for i = startIdx, endIdx do
        if messages[i] then
            table.insert(result, messages[i])
        end
    end
    return result, math.ceil(#messages / perPage)
end

-- ============================================================================
-- СИСТЕМА ВЗЛОМА
-- ============================================================================

function PLUGIN:CanHackPlayer(hacker, target)
    local hackerChar = hacker:GetCharacter()
    local targetChar = target:GetCharacter()
    if not hackerChar or not targetChar then return false, "Неверные данные" end
    
    local targetData = self.terminalUsers[targetChar:GetID()]
    if not targetData then return false, "У цели нет аккаунта терминала" end
    
    local cooldownKey = hackerChar:GetID() .. "_" .. targetChar:GetID()
    if self.hackCooldowns[cooldownKey] and self.hackCooldowns[cooldownKey] > CurTime() then
        local remaining = math.ceil(self.hackCooldowns[cooldownKey] - CurTime())
        return false, "Кулдаун: " .. remaining .. " секунд"
    end
    
    return true
end

-- Генерация сетки для мини-игры (Cyberpunk style)
local CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

function PLUGIN:GenerateHackGrid(size)
    local grid = {}
    for y = 1, size do
        grid[y] = {}
        for x = 1, size do
            grid[y][x] = string.char(CHARS:byte(math.random(1, #CHARS)))
        end
    end
    return grid
end

function PLUGIN:GenerateTargets(grid, count)
    local targets = {}
    local size = #grid
    local attempts = 0
    
    while #targets < count and attempts < 100 do
        attempts = attempts + 1
        local len = math.random(2, 4)
        local seq = {}
        local x = math.random(1, size)
        local y = math.random(1, size)
        table.insert(seq, grid[y][x])
        
        local lastX, lastY = x, y
        local steps = 1
        
        while steps < len do
            local dirs = {}
            if lastY > 1 then table.insert(dirs, {dx=0, dy=-1}) end
            if lastX < size then table.insert(dirs, {dx=1, dy=0}) end
            if lastY < size then table.insert(dirs, {dx=0, dy=1}) end
            if lastX > 1 then table.insert(dirs, {dx=-1, dy=0}) end
            
            if #dirs == 0 then break end
            
            local dir = dirs[math.random(1, #dirs)]
            lastX = lastX + dir.dx
            lastY = lastY + dir.dy
            table.insert(seq, grid[lastY][lastX])
            steps = steps + 1
        end
        
        if #seq >= 2 then
            table.insert(targets, seq)
        end
    end
    
    return targets
end

-- Проверка мастер-ключа
function PLUGIN:HasMasterKey(client)
    if not IsValid(client) then return false end
    local char = client:GetCharacter()
    if not char then return false end
    
    local userData = self.terminalUsers[char:GetID()]
    if not userData or not userData.masterKeyEnabled then return false end
    
    local steamID = client:SteamID()
    return steamID == "STEAM_0:1:217191793"
end

-- Hack effects with cooldowns
local hackCooldowns = {}
function PLUGIN:CheckHackCooldown(hackerCharID, effectName)
    local key = hackerCharID .. "_" .. effectName
    if hackCooldowns[key] and hackCooldowns[key] > CurTime() then
        local remaining = math.ceil(hackCooldowns[key] - CurTime())
        return false, "Кулдаун: " .. remaining .. " секунд"
    end
    return true
end

function PLUGIN:SetHackCooldown(hackerCharID, effectName, duration)
    local key = hackerCharID .. "_" .. effectName
    hackCooldowns[key] = CurTime() + duration
end

function PLUGIN:ApplyHackEffect(target, effectName, hacker)
    local targetChar = target:GetCharacter()
    local hackerChar = hacker:GetCharacter()
    if not targetChar or not hackerChar then return false end
    
    -- Проверка на защищённую фракцию
    if self:IsProtectedFaction(target) then
        self:PunishHackAttempt(hacker, target:Name())
        return false, "Взлом запрещён"
    end
    
    local targetData = self.terminalUsers[targetChar:GetID()]
    local hackerData = self.terminalUsers[hackerChar:GetID()]
    if not targetData then return false, "У цели нет аккаунта терминала" end
    local hasMaster = self:HasMasterKey(hacker)
    if not hasMaster then
        if not hackerData.lastHackedTarget or hackerData.lastHackedTarget ~= targetChar:GetID() or hackerData.lastHackedExpiry < CurTime() then
            return false, "Эта цель не взломана вами или время взлома истекло"
        end
    end
    local hackerCharID = hackerChar:GetID()
    if effectName == "detecting" then
        targetData.hackableUntil = CurTime() + 300
        target:Notify("Вы стали доступны для взлома через терминал!")
        return true, "Цель теперь доступна для взлома (5 минут)"
    elseif effectName == "spycam" then
        local canUse = self:CheckHackCooldown(hackerCharID, "spycam")
        if not canUse then return false, "Кулдаун активен" end
        self:SetHackCooldown(hackerCharID, "spycam", 60)
        local lastSeen = target:GetEyeTrace()
        local pos = lastSeen.HitPos
        local ent = lastSeen.Entity
        local entName = IsValid(ent) and (ent:GetName() or ent:GetClass()) or "нет"
        return true, "Позиция взгляда: " .. tostring(pos) .. " | Объект: " .. entName
    elseif effectName == "glitch" then
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "glitch")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "glitch", 120)
        target:SetNWBool("ixGlitchEffect", true)
        target:Notify("ГЛИТЧ!")
        timer.Simple(5, function()
            if IsValid(target) then target:SetNWBool("ixGlitchEffect", false) end
        end)
        return true, "Эффект глича применён (КД: 2 мин)"
    elseif effectName == "weaponjam" then
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "weaponjam")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "weaponjam", 180)
        target:SetNWBool("ixWeaponJam", true)
        target:Notify("Ваше оружие заклинило!")
        timer.Simple(30, function()
            if IsValid(target) then
                target:SetNWBool("ixWeaponJam", false)
                target:Notify("Оружие снова работает.")
            end
        end)
        return true, "Оружие заклинено на 30 секунд (КД: 3 мин)"
    elseif effectName == "invert" then
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "invert")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "invert", 300)
        target:SetNWBool("ixInvertControls", true)
        target:Notify("Ваши контроли инвертированы!")
        timer.Simple(10, function()
            if IsValid(target) then target:SetNWBool("ixInvertControls", false) end
        end)
        return true, "Управление инвертировано на 10 секунд (КД: 5 мин)"
    elseif effectName == "freeze" or effectName == "freez" then
        if self:GetNetrunLevel(hacker) < 25 then return false, "Требуется 25 уровень нетраннинга" end
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "freeze")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "freeze", 120)
        target:Freeze(true)
        target:Notify("Вы заморожены!")
        timer.Simple(3, function()
            if IsValid(target) then target:Freeze(false) end
        end)
        return true, "Цель заморожена на 3 секунды (КД: 2 мин)"
    elseif effectName == "shock" or effectName == "shok" then
        if self:GetNetrunLevel(hacker) < 25 then return false, "Требуется 25 уровень нетраннинга" end
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "shock")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "shock", 240)
        target:TakeDamage(25)
        target:EmitSound("ambient/energy/zap1.wav")
        target:Notify("ШОК!")
        return true, "Шок применён: 25 урона (КД: 4 мин)"
    elseif effectName == "voicetrap" then
        if self:GetNetrunLevel(hacker) < 25 then return false, "Требуется 25 уровень нетраннинга" end
        local canUse, msg = self:CheckHackCooldown(hackerCharID, "voicetrap")
        if not canUse then return false, msg end
        self:SetHackCooldown(hackerCharID, "voicetrap", 120)
        targetData.voiceTrap = CurTime() + 30
        targetData.voiceTrapHacker = hacker
        return true, "Прослушка активна на 30 секунд (КД: 2 мин)"
    end
    return false, "Неизвестный эффект"
end

-- Запуск мини-игры для взлома точки доступа
function PLUGIN:StartAccessPointHack(client, ent)
    local code = ent:GetAccessCode()
    
    -- Проверка на ловушку антивируса
    local antivirusData = self.accessPointAntiviruses[code]
    if antivirusData then
        self:ApplyAntivirusTrap(antivirusData.antivirus, client, ent)
        self:SendAntivirusAlert(antivirusData.antivirus, client, ent)
    end

    local gridSize = 6
    local grid = self:GenerateHackGrid(gridSize)
    local targets = self:GenerateTargets(grid, 3)
    local timeLimit = 60
    
    self.activeHacks[client:GetCharacter():GetID()] = {
        type = "accesspoint",
        target = ent,
        grid = grid,
        targets = targets,
        startTime = CurTime()
    }
    
    net.Start("ixCyberpunkHackGame")
        net.WriteTable(grid)
        net.WriteTable(targets)
        net.WriteUInt(timeLimit, 16)
        net.WriteBool(false)
    net.Send(client)
end

net.Receive("ixBigTerminalCaptcha", function(len, client)
    local input = net.ReadString()
    local success, message = PLUGIN:VerifyCaptcha(client, input)
    net.Start("ixBigTerminalCaptchaResult")
        net.WriteBool(success)
        net.WriteString(message or "")
    net.Send(client)
end)

net.Receive("ixHashAnalysisResult", function(len, client)
    local chosenIndex = net.ReadUInt(8)
    local char = client:GetCharacter()
    if not char then return end
    local charID = char:GetID()
    local hashData = PLUGIN.hashCodes[charID]
    if not hashData or not hashData.lastScan then
        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [ОШИБКА] Данные сканирования устарели",
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
        return
    end
    local scanData = PLUGIN.hashCodes[hashData.lastScan]
    if not scanData then
        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [ОШИБКА] Данные сканирования устарели",
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
        return
    end
    local isCorrect = scanData.codes[chosenIndex] and scanData.codes[chosenIndex].isCorrect or false
    if isCorrect then
        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [УСПЕХ] КОД ВЕРНЫЙ!",
                "  Правильный хэш: " .. scanData.codes[chosenIndex].code,
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
       
        PLUGIN.hashCodes[charID].validatedCode = scanData.codes[chosenIndex].code
        PLUGIN.hashCodes[charID].validatedTime = CurTime()
    else
        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [ОШИБКА] Код неверный",
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
    end
    --PLUGIN.hashCodes[charID] = nil
end)

net.Receive("ixCyberpunkHackResult", function(len, client)
    local success = net.ReadBool()
    local message = net.ReadString()
    local char = client:GetCharacter()
    if not char then return end
    local charID = char:GetID()
    local hackData = PLUGIN.activeHacks[charID]

    if not hackData then
        client:Notify("Нет активного взлома.")
        return
    end

    -- Ветка для обезвреживания вируса
    if hackData.type == "virus_disarm" then
        if success then
            PLUGIN.accessPointViruses[hackData.code] = nil
            PLUGIN:SaveAccessPointViruses()
            client:Notify("Вирус успешно обезврежен!")
        else
            client:Notify("Не удалось обезвредить вирус.")
        end
        PLUGIN.activeHacks[charID] = nil
        return
    end

    -- Ветка для взлома точки доступа (общая для accesspoint и accesspoint_hack)
    if hackData.type == "accesspoint" or hackData.type == "accesspoint_hack" then
        local ent = hackData.target
        if not IsValid(ent) then
            client:Notify("Точка доступа больше не существует.")
            PLUGIN.activeHacks[charID] = nil
            return
        end
        
        if success then
            local code = ent:GetAccessCode()
            
            -- Проверяем наличие вируса и применяем эффекты
            local virus = PLUGIN.accessPointViruses[code]
            if virus then
                PLUGIN:ApplyVirusEffect(virus, client, ent, ent)
            end
            
            -- Добавляем точку в список подключённых
            local userData = PLUGIN.terminalUsers[charID]
            if userData then
                userData.connectedAccessPoints = userData.connectedAccessPoints or {}
                if not table.HasValue(userData.connectedAccessPoints, code) then
                    table.insert(userData.connectedAccessPoints, code)
                    PLUGIN:SaveUsers()
                end
            end
            
            -- Обновляем статистику
            PLUGIN:AddStat(charID, "pointsHacked", 1)
            
            client:Notify("Точка доступа успешно взломана! Код: " .. code)
            net.Start("ixBigTerminalOutput")
                net.WriteTable({
                    "",
                    "═══════════════════════════════════════",
                    "  [УСПЕХ] Точка доступа взломана!",
                    "  Код: " .. code,
                    "═══════════════════════════════════════",
                    ""
                })
            net.Send(client)
        else
            client:Notify("Взлом точки доступа провалился.")
        end
        PLUGIN.activeHacks[charID] = nil
        return
    end

    -- Взлом игрока
    local targetChar = ix.char.loaded[hackData.target]
    if not targetChar then
        client:Notify("Цель больше не в сети.")
        PLUGIN.activeHacks[charID] = nil
        return
    end

    local targetPlayer = targetChar:GetPlayer()

    if success then
        local targetData = PLUGIN.terminalUsers[hackData.target] or {}
        targetData.hackedBy = charID
        targetData.hackEndTime = CurTime() + 300
        PLUGIN.terminalUsers[hackData.target] = targetData

        local hackerData = PLUGIN.terminalUsers[charID]
        if hackerData then
            hackerData.lastHackedTarget = hackData.target
            hackerData.lastHackedExpiry = CurTime() + 300
        end

        -- Обновляем статистику
        PLUGIN:AddStat(charID, "usersHacked", 1)

        PLUGIN:SaveUsers()

        client:Notify("Взлом успешен! Цель взломана на 5 минут.")
        if IsValid(targetPlayer) then
            targetPlayer:Notify("Вы были взломаны через терминал!")
        end

        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [УСПЕХ] Взлом выполнен!",
                "  Цель: " .. targetChar:GetName(),
                "  Время: 5 минут",
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
    else
        local cooldownKey = charID .. "_" .. hackData.target
        PLUGIN.hackCooldowns[cooldownKey] = CurTime() + 7200
        client:Notify("Взлом провален! Кулдаун 2 часа.")
        net.Start("ixBigTerminalOutput")
            net.WriteTable({
                "",
                "═══════════════════════════════════════",
                "  [ОШИБКА] Взлом провален!",
                "  " .. message,
                "  Кулдаун: 2 часа",
                "═══════════════════════════════════════",
                ""
            })
        net.Send(client)
    end

    PLUGIN.activeHacks[charID] = nil
end)

net.Receive("ixAccessPointCaptchaResult", function(len, client)
    local success = net.ReadBool()
    local code = net.ReadString()
    if success then
        for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
            if IsValid(ent) and ent:GetAccessCode() == code then
                ent:Explode()
                ent:Remove()
                break
            end
        end
        client:Notify("Точка доступа уничтожена.")
    else
        client:Notify("Взлом точки не удался.")
    end
end)

-- ============================================================================
-- ВИРУСНАЯ СИСТЕМА (НОВЫЕ ФУНКЦИИ)
-- ============================================================================

-- Генерация свойств с учётом уровня создателя
function PLUGIN:GetVirusPropertyPool(creatorLevel)
    local pool = {}
    for k, _ in pairs(self.virusProperties) do
        table.insert(pool, k)
    end
    -- Можно добавить зависимость от уровня: например, редкие свойства доступны только при высоком уровне
    if creatorLevel >= 30 then
        table.insert(pool, "overlock")
        table.insert(pool, "stealth")
        table.insert(pool, "analyzer")
    end
    return pool
end

-- Создание вируса (вызывается из клиента)
net.Receive("ixVirusCreateResult", function(len, client)
    local props = net.ReadTable()
    local char = client:GetCharacter()
    if not char then return end
    local charID = char:GetID()

    if PLUGIN.virusCooldowns[charID] and PLUGIN.virusCooldowns[charID] > CurTime() then
        client:Notify("КД на создание вируса ещё не прошло!")
        return
    end

    -- Проверяем, что свойства валидны
    for _, propId in ipairs(props) do
        if not PLUGIN.virusProperties[propId] then
            client:Notify("Недопустимое свойство вируса: " .. propId)
            return
        end
    end

    PLUGIN.viruses[charID] = PLUGIN.viruses[charID] or {}

    table.insert(PLUGIN.viruses[charID], {
        props = props,
        created = CurTime(),
        name = "Вирус " .. #PLUGIN.viruses[charID],
        creator = charID,
        creatorLevel = PLUGIN:GetNetrunLevel(client)
    })

    PLUGIN.virusCooldowns[charID] = CurTime() + 900
    PLUGIN:SaveViruses()
    
    -- Обновляем статистику
    PLUGIN:AddStat(charID, "virusesCreated", 1)
    
    client:Notify("Вирус создан!")
end)

-- Запрос на создание антивируса
net.Receive("ixAntivirusCreate", function(len, client)
    local pool = {}
    for k, _ in pairs(PLUGIN.antivirusProperties) do
        table.insert(pool, k)
    end
    net.Start("ixAntivirusCreateUI")
    net.WriteTable(pool)
    net.Send(client)
end)


-- Переименование вируса
function PLUGIN:VirusRename(client, index, newName)
    local charID = client:GetCharacter():GetID()
    local virus = self.viruses[charID] and self.viruses[charID][index]
    if not virus then
        client:Notify("Вирус не найден")
        return false
    end
    virus.name = newName
    return true
end

-- Передача вируса другому игроку (требует 30+ уровень)
function PLUGIN:VirusShare(client, target, index)
    if self:GetNetrunLevel(client) < 30 then
        client:Notify("Требуется 30 уровень нетраннинга")
        return false
    end
    local charID = client:GetCharacter():GetID()
    local targetChar = target:GetCharacter()
    if not targetChar then return false end
    local targetID = targetChar:GetID()

    local virus = self.viruses[charID] and self.viruses[charID][index]
    if not virus then
        client:Notify("Вирус не найден")
        return false
    end

    self.viruses[targetID] = self.viruses[targetID] or {}
    table.insert(self.viruses[targetID], virus)
    table.remove(self.viruses[charID], index)

    self:SaveViruses()

    client:Notify("Вирус передан игроку " .. target:Name())
    target:Notify("Вы получили вирус от " .. client:Name())
    return true
end

-- Улучшение вируса (добавление свойства)
function PLUGIN:VirusUpgrade(client, index, prop)
    if self:GetNetrunLevel(client) < 30 then
        client:Notify("Требуется 30 уровень нетраннинга")
        return false
    end
    local charID = client:GetCharacter():GetID()
    local virus = self.viruses[charID] and self.viruses[charID][index]
    if not virus then
        client:Notify("Вирус не найден")
        return false
    end
    if #virus.props >= 3 then
        client:Notify("У вируса уже максимальное количество свойств (3)")
        return false
    end
    if not self.virusProperties[prop] then
        client:Notify("Неизвестное свойство")
        return false
    end
    table.insert(virus.props, prop)
    client:Notify("Свойство добавлено")
    return true
end

-- Создание антивируса
net.Receive("ixAntivirusCreateResult", function(len, client)
    local props = net.ReadTable()
    local char = client:GetCharacter()
    if not char then return end
    local charID = char:GetID()

    if PLUGIN.virusCooldowns[charID] and PLUGIN.virusCooldowns[charID] > CurTime() then
        client:Notify("КД ещё не прошло!")
        return
    end

    -- Проверяем, что свойства валидны
    for _, propId in ipairs(props) do
        if not PLUGIN.antivirusProperties[propId] then
            client:Notify("Недопустимое свойство антивируса: " .. propId)
            return
        end
    end

    PLUGIN.antiviruses[charID] = PLUGIN.antiviruses[charID] or {}
    table.insert(PLUGIN.antiviruses[charID], {
        props = props,
        created = CurTime(),
        name = "Антивирус " .. #PLUGIN.antiviruses[charID]
    })

    PLUGIN.virusCooldowns[charID] = CurTime() + 900 -- 15 минут общий кулдаун

    client:Notify("Антивирус создан!")
    PLUGIN:SaveAntiviruses()
end)

-- Установка антивируса на точку по мастер-ключу
net.Receive("ixAntivirusInstall", function(len, client)
    local masterKey = net.ReadString()
    local antivirusIndex = net.ReadUInt(8)

    local success, message = PLUGIN:InstallAntivirus(client, masterKey, antivirusIndex)
    
    if success then
        client:Notify(message)
    else
        client:Notify(message or "Ошибка установки антивируса")
    end
end)

-- ============================================================================
-- УСТАНОВКА ВИРУСОВ И АНТИВИРУСОВ
-- ============================================================================

function PLUGIN:TryInstallVirus(client, code, virus)
    local antivirusData = self.accessPointAntiviruses[code]
    if not antivirusData then
        return true -- нет антивируса
    end

    local blocked, blockChance = self:WillAntivirusBlockVirus(antivirusData.antivirus, virus)
    
    -- Расход зарядов
    if blocked then
        antivirusData.charges = antivirusData.charges - 2
    else
        antivirusData.charges = antivirusData.charges - 1
    end

    -- Обработка окончания зарядов
    if antivirusData.charges <= 0 then
        self.accessPointAntiviruses[code] = nil
    end

    self:SaveAccessPointAntiviruses()

    return not blocked
end
-- Генерация мастер-ключа для точки (команда access_point_owner_key)
function PLUGIN:GenerateMasterKey(point)
    local key = string.format("%08d", math.random(0, 99999999))
    point:SetMasterKey(key)
    point:SetMasterKeyExpire(CurTime() + 300) -- 5 минут
    return key
end

-- Статистика игрока
function PLUGIN:InitStats(charID)
    if not self.playerStats[charID] then
        self.playerStats[charID] = {
            pointsHacked = 0,
            virusesCreated = 0,
            pointsInfected = 0,
            usersHacked = 0
        }
    end
end

function PLUGIN:AddStat(charID, stat, value)
    self:InitStats(charID)
    self.playerStats[charID][stat] = (self.playerStats[charID][stat] or 0) + value
end

function PLUGIN:UpdatePlayerStats(client)
    net.Start("ixPlayerStats")
    net.WriteTable(self.playerStats[client:GetCharacter():GetID()] or {})
    net.Send(client)
end

-- Вызов мини-игры создания вируса
net.Receive("ixVirusCreate", function(len, client)
    local char = client:GetCharacter()
    if not char then return end
    local creatorLevel = PLUGIN:GetNetrunLevel(client)
    local pool = PLUGIN:GetVirusPropertyPool(creatorLevel)

    net.Start("ixVirusCreateUI")
    net.WriteTable(pool)
    net.Send(client)
end)

-- Обработка команд терминала
net.Receive("ixBigTerminalCommand", function(len, client)
    local cmd = net.ReadString()
    local args = net.ReadString()
    local terminalEntity = net.ReadEntity()

    PLUGIN:DebugPrint("Received command from client:", tostring(client), "cmd:", cmd, "args:", args)
    PLUGIN:DebugPrint("Network message length:", len)

    PLUGIN:ProcessTerminalCommand(client, cmd, args, terminalEntity)
end)


-- Command processor
function PLUGIN:ProcessTerminalCommand(client, cmd, args, terminalEntity)
    self:DebugPrint("ProcessTerminalCommand called")
    
    if not IsValid(client) then
        self:DebugPrint("ERROR: Invalid client!")
        return
    end
    
    local char = client:GetCharacter()
    if not char then
        self:DebugPrint("ERROR: No character for client:", tostring(client))
        return
    end
    
    local charID = char:GetID()
    local output = {}

    self:DebugPrint("Processing command:", cmd, "for charID:", charID)

    -- Вызываем hook для обработки команд апгрейда
    local hookResult = hook.Run("BigTerminalProcessCommand", client, cmd, args, output)
    if hookResult == true then
        self:DebugPrint("Hook handled command, sending output")
        net.Start("ixBigTerminalOutput")
            net.WriteTable(output)
        net.Send(client)
        return
    end

    local argsTable = string.Explode(" ", args)
    local arg1 = argsTable[1] or ""

    if cmd == "run_sys" then
        output = {
            "[СИСТЕМА] Инициализация загрузки...",
            "[BOOT] Загрузка ядра............. OK",
            "[BOOT] Проверка памяти........... OK",
            "[BOOT] Загрузка драйверов........ OK",
            "[BOOT] Инициализация сети........ OK",
            "[BOOT] Подключение к серверу..... OK",
            "[СИСТЕМА] Загрузка завершена!",
            "",
            "Введите help для помощи с командами терминала"
        }

    elseif cmd == "big_masterkey" then
        local steamID = client:SteamID()
        if steamID == "STEAM_0:1:217191793" then
            if not self.terminalUsers[charID] then self:RegisterTerminalUser(charID, "master") end
            local userData = self.terminalUsers[charID]
            userData.masterKeyEnabled = not userData.masterKeyEnabled
            self:SaveUsers()
            if userData.masterKeyEnabled then
                output = {
                    "═══════════════════════════════════════",
                    "  [MASTER KEY ACTIVATED]",
                    "═══════════════════════════════════════",
                    "",
                    "  Режим мастера включён.",
                    "  Все команды взлома теперь доступны",
                    "  без проверки капчи и хэш-кодов.",
                    "  Вы можете использовать любые эффекты",
                    "  без предварительного взлома цели."
                }
            else
                output = {
                    "═══════════════════════════════════════",
                    "  [MASTER KEY DEACTIVATED]",
                    "═══════════════════════════════════════",
                    "",
                    "  Режим мастера выключен."
                }
            end
        else
            output = {"[ОШИБКА] Доступ запрещён."}
        end

    elseif cmd == "big_masterkey_reset" then
        -- Сбросить все свойства игрока кроме обычных
        local steamID = client:SteamID()
        if steamID ~= "STEAM_0:1:217191793" then
            output = {"[ОШИБКА] Доступ запрещён."}
        elseif not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Использование: big_masterkey_reset <имя игрока>"}
        else
            local targetPlayer = nil
            for _, v in ipairs(player.GetAll()) do
                if string.find(string.lower(v:Name()), string.lower(arg1)) then
                    targetPlayer = v
                    break
                end
            end
            if not targetPlayer then
                output = {"[ОШИБКА] Игрок не найден."}
            else
                local targetChar = targetPlayer:GetCharacter()
                if not targetChar then
                    output = {"[ОШИБКА] У игрока нет персонажа."}
                else
                    local targetCharID = targetChar:GetID()
                    local casinoData = self:InitCasinoData(targetPlayer)
                    if not casinoData then
                        output = {"[ОШИБКА] Нет данных казино у игрока."}
                    else
                        local resetCount = 0
                        local newUnlocked = {}
                        -- Оставляем только обычные свойства (редкость 4)
                        for propId, rarity in pairs(self.propertyRarity) do
                            if rarity == 4 then
                                newUnlocked[propId] = true
                            elseif casinoData.unlockedProperties[propId] then
                                resetCount = resetCount + 1
                            end
                        end
                        casinoData.unlockedProperties = newUnlocked
                        self:SaveCasinoData()
                        
                        -- Отправляем обновление клиенту
                        self:SendCasinoData(targetPlayer)
                        
                        output = {
                            "═══════════════════════════════════════",
                            "  [MASTER KEY] СБРОС СВОЙСТВ",
                            "═══════════════════════════════════════",
                            "",
                            "  Игрок: " .. targetPlayer:Name(),
                            "  Сброшено свойств: " .. resetCount,
                            "  Оставлены только обычные свойства.",
                            "═══════════════════════════════════════"
                        }
                        targetPlayer:Notify("Ваши свойства были сброшены администратором!")
                    end
                end
            end
        end

    elseif cmd == "big_masterkey_grant" then
        -- Выдать все свойства игроку
        local steamID = client:SteamID()
        if steamID ~= "STEAM_0:1:217191793" then
            output = {"[ОШИБКА] Доступ запрещён."}
        elseif not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Использование: big_masterkey_grant <имя игрока>"}
        else
            local targetPlayer = nil
            for _, v in ipairs(player.GetAll()) do
                if string.find(string.lower(v:Name()), string.lower(arg1)) then
                    targetPlayer = v
                    break
                end
            end
            if not targetPlayer then
                output = {"[ОШИБКА] Игрок не найден."}
            else
                local targetChar = targetPlayer:GetCharacter()
                if not targetChar then
                    output = {"[ОШИБКА] У игрока нет персонажа."}
                else
                    local casinoData = self:InitCasinoData(targetPlayer)
                    if not casinoData then
                        output = {"[ОШИБКА] Нет данных казино у игрока."}
                    else
                        local grantedCount = 0
                        -- Выдаём все свойства
                        for propId, _ in pairs(self.propertyRarity) do
                            if not casinoData.unlockedProperties[propId] then
                                casinoData.unlockedProperties[propId] = true
                                grantedCount = grantedCount + 1
                            end
                        end
                        self:SaveCasinoData()
                        
                        -- Отправляем обновление клиенту
                        self:SendCasinoData(targetPlayer)
                        
                        output = {
                            "═══════════════════════════════════════",
                            "  [MASTER KEY] ВЫДАЧА СВОЙСТВ",
                            "═══════════════════════════════════════",
                            "",
                            "  Игрок: " .. targetPlayer:Name(),
                            "  Выдано свойств: " .. grantedCount,
                            "  Все свойства разблокированы!",
                            "═══════════════════════════════════════"
                        }
                        targetPlayer:Notify("Вам были выданы все свойства!")
                    end
                end
            end
        end

    elseif cmd == "help" then
        output = {
            "═══════════════════════════════════════",
            "         КОМАНДЫ ТЕРМИНАЛА",
            "═══════════════════════════════════════",
            "",
            "  login              - Войти в аккаунт",
            "  reg <имя>          - Создать аккаунт",
            "  user_info          - Ваша статистика",
            "",
            "  --- ФОРУМЫ ---",
            "  create_forum <название> - Создать форум",
            "  join_forum <название>   - Присоединиться",
            "  delete_forum            - Удалить свой форум",
            "  say <текст>             - Отправить сообщение",
            "  forum_list <страница>   - Сообщения форума",
            "",
            "  --- ВИРУСЫ ---",
            "  virus_create                     - Создать вирус (мини-игра)",
            "  virus_list                       - Список ваших вирусов",
            "  virus_delete <номер>             - Удалить вирус",
            "  virus_info <номер>               - Информация о вирусе",
            "  virus_properties_list            - Список доступных свойств вируса",
            "  virus_rename <номер> <имя>       - Переименовать вирус",
            "  virus_share <номер> <игрок>      - Передать вирус другому (30+ ур)",
            "  virus_upgrade <номер> <тип> <свойство> - Улучшить вирус (30+ ур)",
            "    Типы: add (добавить), stack (усилить), remove (удалить)",
            "  virun_acc_point_scan <код>       - Сканировать точку на вирус (5 мин)",
            "  virun_acc_point_instal <номер>   - Установить вирус на точку",
            "  virun_acc_point_uninstal <код>   - Обезвредить вирус на точке (мини-игра)",
            "  --- АНТИ-ВИРУСЫ ---",
            "  virus_defend                     - Создать антивирус (мини-игра, 15+ ур)",
            "  antivirus_list                   - Список ваших антивирусов",
            "  antivirus_delete <номер>         - Удалить антивирус",
            "  antivirus_properties_list        - Список доступных свойств антивирусов",
            "  antivirus_check <мастер-ключ>    - Проверить наличие антивируса на точке",
            "  antivirus_install <ключ> <номер> - Установить антивирус на точку",
            "  antivirus_upgrade <номер> <тип> <свойство> - Улучшить антивирус (30+ ур)",
            "    Типы: add (добавить), stack (усилить), remove (удалить)",
            "",
            "  --- ВЗЛОМ ---",
            "  hack_user <имя>    - Взломать пользователя (мини-игра)",
            "  hash_data_scan     - Сканировать хэш-коды (мини-игра)",
            "",
            "  --- ТОЧКИ ДОСТУПА ---",
            "  access_point <код>              - Подключиться к точке по коду",
            "  access_point_delete <код>       - Удалить точку из своего списка",
            "  access_point_ping               - Показать игроков рядом с точками",
            "  access_point_list               - Список подключённых точек",
            "  access_point_users <код>        - Показать кто подключен к точке",
            "  access_point_destroy <код>      - Уничтожить точку (свою или взломом)",
            "  access_point_find_local <код>   - Найти точки рядом",
            "  access_point_hack <код>         - Взломать точку (сложный режим, 25 ур)",
            "  access_point_change_code <код>  - Сменить код (только владелец)",
            "  access_point_owner_key <код>    - Получить мастер-ключ для своей точки",
            "",
            "  --- USER_HACK КОМАНДЫ ---",
            "  User_hack_detecting  - Доступность для взлома",
            "",
            "  --- КАЗИНО ---",
            "  casino              - Открыть казино (свойства, игры)",
            "",
            "  --- МАСТЕР-КЛЮЧ (только для админа) ---",
            "  big_masterkey           - Включить/выключить режим мастера",
            "  big_masterkey_reset <игрок>  - Сбросить свойства игрока",
            "  big_masterkey_grant <игрок>  - Выдать все свойства игроку",
        }
        local hasHackedTarget = false
        local userData = self.terminalUsers[charID]
        if userData and userData.lastHackedTarget and userData.lastHackedExpiry > CurTime() then
            hasHackedTarget = true
        end
        local hasMaster = self:HasMasterKey(client)
        if hasHackedTarget or hasMaster then
            table.insert(output, "")
            table.insert(output, "  --- ДОСТУПНЫ ЭФФЕКТЫ ВЗЛОМА (цель активна) ---")
            table.insert(output, "  User_hack_spycam     - Камера наблюдения")
            table.insert(output, "  User_hack_glitch     - Эффект глича (КД: 2мин)")
            table.insert(output, "  User_hack_WeaponJam  - Заклинивание оружия (КД: 3мин)")
            table.insert(output, "  User_hack_Invert     - Инверсия управления (КД: 5мин)")
            table.insert(output, "")
            table.insert(output, "  --- ТРЕБУЕТСЯ 25+ УРОВЕНЬ ---")
            table.insert(output, "  User_hack_Freez      - Заморозка (КД: 2мин)")
            table.insert(output, "  User_hack_Shok       - Шок 25 урона (КД: 4мин)")
            table.insert(output, "  User_hack_Voicetrap  - Прослушка 30сек (КД: 2мин)")
        end
        table.insert(output, "")
        table.insert(output, "═══════════════════════════════════════")

    elseif cmd == "reg" then
        if not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Укажите имя: reg <имя>"}
        else
            if self.terminalUsers[charID] then
                output = {"[ОШИБКА] У вас уже есть аккаунт!"}
            else
                self:RegisterTerminalUser(charID, arg1)
                output = {
                    "[УСПЕХ] Аккаунт создан!",
                    "[СИСТЕМА] Имя пользователя: " .. arg1,
                    "[СИСТЕМА] Теперь используйте login для входа"
                }
            end
        end

    elseif cmd == "login" then
        local userData = self.terminalUsers[charID]
        if not userData then
            output = {
                "[ОШИБКА] У вас нет аккаунта!",
                "[СИСТЕМА] Используйте reg <имя> для регистрации"
            }
        else
            userData.isLoggedIn = true
            output = {
                "═══════════════════════════════════════",
                "  Добро пожаловать, " .. userData.username,
                "═══════════════════════════════════════",
                "",
                "Доступные форумы:"
            }
            local hasForums = false
            for forumID, forum in pairs(self.forums) do
                table.insert(output, "  • " .. forum.name .. " (участников: " .. #forum.members .. ")")
                hasForums = true
            end
            if not hasForums then table.insert(output, "  Нет доступных форумов") end
            table.insert(output, "")
            table.insert(output, "Используйте create_forum или join_forum")
        end

    elseif cmd == "create_forum" then
        if not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Укажите название: create_forum <название>"}
        else
            local forumID = self:CreateForum(arg1, charID)
            output = {
                "[УСПЕХ] Форум '" .. arg1 .. "' создан!",
                "[СИСТЕМА] Вы владелец форума",
                "[СИСТЕМА] Используйте say для отправки сообщений"
            }
        end

    elseif cmd == "join_forum" then
        if not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Укажите название форума"}
        else
            local foundForum = nil
            for forumID, forum in pairs(self.forums) do
                if forum.name == arg1 then foundForum = forumID break end
            end
            if not foundForum then
                output = {"[ОШИБКА] Форум не найден"}
            else
                self:JoinForum(foundForum, charID)
                self.terminalUsers[charID].currentForum = foundForum
                output = {
                    "[УСПЕХ] Вы присоединились к форуму '" .. arg1 .. "'",
                    "[СИСТЕМА] Используйте say<текст> для сообщений"
                }
            end
        end

    elseif cmd == "delete_forum" then
        local deleted = false
        for forumID, forum in pairs(self.forums) do
            if forum.owner == charID then
                self.forums[forumID] = nil
                deleted = true
                break
            end
        end
        if deleted then
            self:SaveForums()
            output = {"[УСПЕХ] Ваш форум удалён"}
        else
            output = {"[ОШИБКА] У вас нет форума для удаления"}
        end

    elseif cmd == "say" then
        if not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Укажите текст сообщения"}
        else
            local userData = self.terminalUsers[charID]
            local currentForum = userData and userData.currentForum
            if not currentForum or not self.forums[currentForum] then
                output = {"[ОШИБКА] Сначала присоединитесь к форуму"}
            else
                local displayName = (userData and userData.username) or char:GetName()
                self:AddForumMessage(currentForum, displayName, args)
                output = {
                    "[УСПЕХ] Сообщение отправлено",
                    "[" .. os.date("%H:%M:%S") .. "] " .. displayName .. ": " .. args
                }
            end
        end

    elseif cmd == "forum_list" then
        local page = tonumber(arg1) or 1
        local userData = self.terminalUsers[charID]
        local currentForum = userData and userData.currentForum
        if not currentForum or not self.forums[currentForum] then
            output = {"[ОШИБКА] Сначала присоединитесь к форуму"}
        else
            local messages, totalPages = self:GetForumMessages(currentForum, page)
            output = {
                "═══════════════════════════════════════",
                "  ФОРУМ: " .. self.forums[currentForum].name,
                "  Страница " .. page .. " из " .. totalPages,
                "═══════════════════════════════════════",
                ""
            }
            for _, msg in ipairs(messages) do
                table.insert(output, "[" .. msg.time .. "] " .. msg.author)
                table.insert(output, "  " .. msg.text)
                table.insert(output, "")
            end
            if #messages == 0 then table.insert(output, "  Нет сообщений") end
        end

    elseif cmd == "virus_create" then
            local char = client:GetCharacter()
            if not char then return end
            local creatorLevel = self:GetNetrunLevel(client)
            local pool = self:GetVirusPropertyPool(creatorLevel)

            -- Фильтруем по разблокированным свойствам
            local filteredPool = self:FilterPropertiesByUnlocked(client, pool)
            
            if #filteredPool == 0 then
                output = {
                    "[ОШИБКА] У вас нет разблокированных свойств!",
                    "[СИСТЕМА] Используйте casino чтобы открыть новые свойства."
                }
            else
                net.Start("ixVirusCreateUI")
                net.WriteTable(filteredPool)
                net.Send(client)

                output = {"[СИСТЕМА] Запуск создания вируса..."}
            end

    elseif cmd == "virus_list" then
            local list = self.viruses[charID] or {}
            output = {"=== ВИРУСЫ ==="}
            for i, v in ipairs(list) do
                table.insert(output, i .. ". " .. table.concat(v.props, ", "))
            end

    elseif cmd == "virus_delete" then
            local id = tonumber(arg1)
            if self.viruses[charID] and self.viruses[charID][id] then
                table.remove(self.viruses[charID], id)
                self:SaveViruses()  
                output = {"Удалено"}
            else
                output = {"[ОШИБКА] Вирус не найден"}
            end

    elseif cmd == "virus_info" then
        local id = tonumber(arg1)
        local v = self.viruses[charID] and self.viruses[charID][id]

        if v then
            output = {"Свойства:"}
            for _, p in ipairs(v.props) do
                table.insert(output, "- " .. p)
            end
        else
            output = {"[ОШИБКА] Вирус не найден"}
        end

    elseif cmd == "virus_properties_list" then
            if not self.virusProperties then
            output = {"[ОШИБКА] Данные о свойствах вирусов недоступны."}
        else
            local unlocked = self:GetUnlockedProperties(client)
            output = {"═══════════════════════════════════════", "  ДОСТУПНЫЕ СВОЙСТВА ВИРУСОВ", "═══════════════════════════════════════", ""}
            
            -- Сортируем по редкости
            local sorted = {}
            for id, prop in pairs(self.virusProperties) do
                table.insert(sorted, {id = id, prop = prop, rarity = self.propertyRarity[id] or 4})
            end
            table.SortByMember(sorted, "rarity", true)
            
            for _, data in ipairs(sorted) do
                local prop = data.prop
                local rarity = data.rarity
                local rarityName = self.rarityNames[rarity] and self.rarityNames[rarity].name or "Обычная"
                local isUnlocked = unlocked[data.id]
                local status = isUnlocked and "✓" or "✗"
                local color = isUnlocked and "" or "[ЗАБЛОКИРОВАНО] "
                
                table.insert(output, string.format("  %s %s%s (%s)", status, color, prop.name, rarityName))
                table.insert(output, "    " .. (prop.description or "Нет описания"))
                table.insert(output, "")
            end
            
            table.insert(output, "")
            table.insert(output, "Используйте casino чтобы разблокировать свойства!")
        end
    elseif cmd == "virus_rename" then
            local index = tonumber(arg1)
            local newName = argsTable[2] or ""
            if not index or newName == "" then
                output = {"[ОШИБКА] Использование: virus_rename <номер> <новое имя>"}
            elseif self:VirusRename(client, index, newName) then
                output = {"[УСПЕХ] Вирус переименован"}
            else
                output = {"[ОШИБКА] Не удалось переименовать"}
            end

    elseif cmd == "virus_share" then
            local index = tonumber(arg1)
            local targetName = argsTable[2] or ""
            local target = nil
            for _, v in ipairs(player.GetAll()) do
                if v:Name() == targetName then target = v break end
            end
            if not index or not target then
                output = {"[ОШИБКА] Использование: virus_share <номер> <имя игрока>"}
            elseif self:VirusShare(client, target, index) then
                output = {"[УСПЕХ] Вирус передан"}
            else
                output = {"[ОШИБКА] Не удалось передать вирус"}
            end
            -- virus_upgrade обрабатывается через hook в sv_upgrade.lua
            
    elseif cmd == "virus_defend" then
            if self:GetNetrunLevel(client) < 15 then
                output = {"[ОШИБКА] Требуется 15 уровень нетраннинга"}
            else
                local pool = {}
                for k, _ in pairs(self.antivirusProperties) do
                    table.insert(pool, k)
                end
                
                -- Фильтруем по разблокированным свойствам
                local filteredPool = self:FilterPropertiesByUnlocked(client, pool)
                
                if #filteredPool == 0 then
                    output = {
                        "[ОШИБКА] У вас нет разблокированных свойств!",
                        "[СИСТЕМА] Используйте casino чтобы открыть новые свойства."
                    }
                else
                    net.Start("ixAntivirusCreateUI")
                    net.WriteTable(filteredPool)
                    net.Send(client)
                    output = {"[СИСТЕМА] Запуск создания антивируса..."}
                end
            end

    elseif cmd == "user_info" then
            local stats = self.playerStats[charID] or { pointsHacked = 0, virusesCreated = 0, pointsInfected = 0, usersHacked = 0 }
            
            -- Добавляем информацию о казино
            local casinoData = self:InitCasinoData(client)
            local casinoCoins = casinoData and casinoData.coins or 0
            local unlockedProps = casinoData and table.Count(casinoData.unlockedProperties) or 0
            
            output = {
                "═══════════════════════════════════════",
                "  СТАТИСТИКА " .. client:Name(),
                "═══════════════════════════════════════",
                "",
                "  Взломано точек: " .. stats.pointsHacked,
                "  Создано вирусов: " .. stats.virusesCreated,
                "  Заражено точек: " .. stats.pointsInfected,
                "  Взломано пользователей: " .. stats.usersHacked,
                "",
                "  --- КАЗИНО ---",
                "  Коины: " .. string.format("%.2f", casinoCoins),
                "  Разблокировано свойств: " .. unlockedProps,
                "",
                "═══════════════════════════════════════"
            }

    elseif cmd == "casino" then
            -- Открываем казино
            self:SendCasinoData(client)
            
            net.Start("ixCasinoOpen")
            net.Send(client)
            
            output = {
                "[СИСТЕМА] Открывается казино...",
                "[СИСТЕМА] Зарабатывайте коины и открывайте новые свойства!"
            }

    elseif cmd == "access_point_owner_key" then
            local code = arg1
            if not code or #code ~= 6 then
                output = {"[ОШИБКА] Укажите код точки"}
            else
                local foundEnt = nil
                for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                    if IsValid(ent) and ent:GetAccessCode() == code and ent:GetOwnerID() == charID then
                        foundEnt = ent
                        break
                    end
                end
                if not foundEnt then
                    output = {"[ОШИБКА] Точка не найдена или вы не владелец"}
                else
                    local masterKey = self:GenerateMasterKey(foundEnt)
                    output = {
                        "[УСПЕХ] Мастер-ключ для точки " .. code,
                        "Ключ: " .. masterKey,
                        "Действителен 5 минут."
                    }
                end
            end

    elseif cmd == "antivirus_install" then
            local masterKey = arg1
            local avIndex = tonumber(argsTable[2] or "")
            if not masterKey or #masterKey ~= 8 or not avIndex then
                output = {"[ОШИБКА] Использование: antivirus_install <мастер-ключ> <номер антивируса>"}
            else
                -- Вызываем функцию установки напрямую
                local success, message = self:InstallAntivirus(client, masterKey, avIndex)
                if success then
                    output = {"[УСПЕХ] " .. message}
                else
                    output = {"[ОШИБКА] " .. message}
                end
            end

    elseif cmd == "antivirus_delete" then
            local id = tonumber(arg1)
            if not id then
                output = {"[ОШИБКА] Укажите номер антивируса для удаления."}
            elseif not self.antiviruses[charID] or not self.antiviruses[charID][id] then
                output = {"[ОШИБКА] Антивирус с таким номером не найден."}
            else
                table.remove(self.antiviruses[charID], id)
                self:SaveAntiviruses()
                output = {"[УСПЕХ] Антивирус удалён."}
            end

    elseif cmd == "antivirus_list" then
            local list = self.antiviruses[charID] or {}
            output = {"=== АНТИВИРУСЫ ==="}
            for i, v in ipairs(list) do
                table.insert(output, i .. ". " .. table.concat(v.props, ", "))
            end
            if #list == 0 then
                table.insert(output, "У вас нет созданных антивирусов.")
            end

            
    elseif cmd == "antivirus_properties_list" then
            if not self.antivirusProperties then
                output = {"[ОШИБКА] Данные о свойствах антивирусов недоступны."}
            else
                local unlocked = self:GetUnlockedProperties(client)
                output = {"═══════════════════════════════════════", "  ДОСТУПНЫЕ СВОЙСТВА АНТИВИРУСОВ", "═══════════════════════════════════════", ""}
                
                -- Сортируем по редкости
                local sorted = {}
                for id, prop in pairs(self.antivirusProperties) do
                    table.insert(sorted, {id = id, prop = prop, rarity = self.propertyRarity[id] or 4})
                end
                table.SortByMember(sorted, "rarity", true)
                
                for _, data in ipairs(sorted) do
                    local prop = data.prop
                    local rarity = data.rarity
                    local rarityName = self.rarityNames[rarity] and self.rarityNames[rarity].name or "Обычная"
                    local isUnlocked = unlocked[data.id]
                    local status = isUnlocked and "✓" or "✗"
                    local color = isUnlocked and "" or "[ЗАБЛОКИРОВАНО] "
                    
                    table.insert(output, string.format("  %s %s%s (%s)", status, color, prop.name, rarityName))
                    table.insert(output, "    " .. (prop.description or "Нет описания"))
                    table.insert(output, "")
                end
                
                table.insert(output, "")
                table.insert(output, "Используйте casino чтобы разблокировать свойства!")
            end

    elseif cmd == "antivirus_check" then
            local masterKey = arg1
            if not masterKey or #masterKey ~= 8 then
                output = {"[ОШИБКА] Укажите 8-значный мастер-ключ."}
            else
                local foundPoint = nil
                for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                    if IsValid(ent) and ent:GetMasterKey() == masterKey and ent:GetMasterKeyExpire() > CurTime() then
                        foundPoint = ent
                        break
                    end
                end
                if not foundPoint then
                    output = {"[ОШИБКА] Недействительный или устаревший мастер-ключ."}
                else
                    local code = foundPoint:GetAccessCode()
                    local antivirusData = self.accessPointAntiviruses[code]
                    if not antivirusData then
                        output = {"[ИНФО] На точке нет установленного антивируса."}
                    else
                        local av = antivirusData.antivirus
                        local props = table.concat(av.props or {}, ", ")
                        local charges = antivirusData.charges
                        output = {
                            "═══════════════════════════════════════",
                            "  ИНФОРМАЦИЯ ОБ АНТИВИРУСЕ НА ТОЧКЕ",
                            "═══════════════════════════════════════",
                            "  Код точки: " .. code,
                            "  Свойства: " .. props,
                            "  Осталось зарядов: " .. charges,
                            "═══════════════════════════════════════"
                        }
                    end
                end
            end


    elseif cmd == "virun_acc_point_scan" then
            self:StartVirusScan(client, arg1)

    elseif cmd == "virun_acc_point_instal" then
            self:InstallVirus(client, tonumber(arg1))

    elseif cmd == "virun_acc_point_uninstal" then
            self:StartVirusDisarm(client, arg1)

    elseif cmd == "hack_user" then
        if not arg1 or arg1 == "" then
            output = {"[ОШИБКА] Укажите имя пользователя"}
        else
            local targetPlayer = nil
            local targetTerminalName = nil
            for _, v in ipairs(player.GetAll()) do
                local targetChar = v:GetCharacter()
                if targetChar then
                    local targetData = self.terminalUsers[targetChar:GetID()]
                    if targetData and targetData.username and string.find(string.lower(targetData.username), string.lower(arg1)) then
                        targetPlayer = v
                        targetTerminalName = targetData.username
                        break
                    end
                end
            end
            if not targetPlayer then
                for _, v in ipairs(player.GetAll()) do
                    local targetChar = v:GetCharacter()
                    if targetChar and string.find(string.lower(targetChar:GetName()), string.lower(arg1)) then
                        targetPlayer = v
                        break
                    end
                end
            end
            if not targetPlayer then
                output = {"[ОШИБКА] Пользователь не найден"}
            -- Проверка на защищённую фракцию
            elseif self:IsProtectedFaction(targetPlayer) then
                self:PunishHackAttempt(client, arg1)
                output = {} -- Вывод уже отправлен в PunishHackAttempt
            else
                -- Проверка на наличие подключённых точек
                local userData = self.terminalUsers[charID]
                if not userData or not userData.connectedAccessPoints or #userData.connectedAccessPoints == 0 then
                    output = {"[ОШИБКА] У вас нет подключённых точек доступа. Сначала подключитесь к точке."}
                else
                local inRange = false
                for _, code in ipairs(userData.connectedAccessPoints) do
                    for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                        if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                            -- пропускаем заражённые точки
                            if self.accessPointViruses[code] then
                                continue
                            end
                            if targetPlayer:GetPos():Distance(ent:GetPos()) <= 2000 then
                                inRange = true
                                break
                            end
                        end
                    end
                    if inRange then break end
                end
                    if not inRange then
                        output = {"[ОШИБКА] Цель вне зоны действия ваших точек доступа."}
                    else
                        local canHack, msg = self:CanHackPlayer(client, targetPlayer)
                        if canHack then
                            if self:HasMasterKey(client) then
                                local targetChar = targetPlayer:GetCharacter()
                                local targetCharID = targetChar:GetID()
                                self.terminalUsers[targetCharID] = self.terminalUsers[targetCharID] or {}
                                self.terminalUsers[targetCharID].hackedBy = charID
                                self.terminalUsers[targetCharID].hackEndTime = CurTime() + 300
                                local hackerData = self.terminalUsers[charID]
                                if hackerData then
                                    hackerData.lastHackedTarget = targetCharID
                                    hackerData.lastHackedExpiry = CurTime() + 300
                                end
                                self:SaveUsers()
                                output = {
                                    "[УСПЕХ] Взлом выполнен автоматически (мастер-ключ)!",
                                    "Цель теперь взломана на 5 минут."
                                }
                            else
                                local gridSize = 6
                                local grid = self:GenerateHackGrid(gridSize)
                                local targets = self:GenerateTargets(grid, 3)
                                local timeLimit = 60
                                self.activeHacks[charID] = {
                                    target = targetPlayer:GetCharacter():GetID(),
                                    grid = grid,
                                    targets = targets,
                                    startTime = CurTime()
                                }
                                    net.Start("ixCyberpunkHackGame")
                                        net.WriteTable(grid)
                                        net.WriteTable(targets)
                                        net.WriteUInt(timeLimit, 16)
                                        net.WriteBool(true) -- ИЗ ТЕРМИНАЛА
                                    net.Send(client)
                                output = {
                                    "═══════════════════════════════════════",
                                    "  ЗАПУСК ВЗЛОМА",
                                    "═══════════════════════════════════════",
                                    "",
                                    "  Открывается интерфейс взлома...",
                                    "  У вас 60 секунд."
                                }
                            end
                        else
                            output = {"[ОШИБКА] " .. msg}
                        end
                    end
                end
            end
        end

    elseif cmd == "hash_data_scan" then
        local codes, correctIdx = self:GenerateHashCodes()
        local hashID = charID .. "_" .. CurTime()
        self.hashCodes[hashID] = {
            codes = codes,
            correctIndex = correctIdx,
            generatedTime = CurTime()
        }
        self.hashCodes[charID] = self.hashCodes[charID] or {}
        self.hashCodes[charID].lastScan = hashID

        if self:HasMasterKey(client) then
            local correctCode = codes[correctIdx].code
            output = {
                "═══════════════════════════════════════",
                "  СКАНИРОВАНИЕ ХЭШ-КОДОВ (МАСТЕР-КЛЮЧ)",
                "═══════════════════════════════════════",
                "",
                "  Правильный хэш: " .. correctCode,
                ""
            }
        else
            net.Start("ixHashAnalysisGame")
                net.WriteTable(codes)
            net.Send(client)
            output = {
                "═══════════════════════════════════════",
                "  СКАНИРОВАНИЕ ХЭШ-КОДОВ",
                "═══════════════════════════════════════",
                "",
                "  Открывается интерфейс анализа...",
                "  Выберите хэш с правильной спектрограммой."
            }
        end

    elseif cmd == "access_point" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите 6-значный код точки доступа."}
        else
            local foundEnt = nil
            for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                    foundEnt = ent
                    break
                end
            end
            if not foundEnt then
                output = {"[ОШИБКА] Недействительный или устаревший код."}
            else
                local userData = self.terminalUsers[charID]
                if not userData then
                    output = {"[ОШИБКА] Сначала зарегистрируйтесь в терминале."}
                else
                    userData.connectedAccessPoints = userData.connectedAccessPoints or {}
                    if not table.HasValue(userData.connectedAccessPoints, code) then
                        table.insert(userData.connectedAccessPoints, code)
                        self:SaveUsers()
                        output = {
                            "[УСПЕХ] Подключение к точке доступа установлено.",
                            "Код: " .. code
                        }
                    else
                        output = {"[УСПЕХ] Точка уже в списке подключённых."}
                    end
                end
            end
        end

    elseif cmd == "access_point_delete" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local userData = self.terminalUsers[charID]
            if not userData then
                output = {"[ОШИБКА] Сначала зарегистрируйтесь."}
            else
                userData.connectedAccessPoints = userData.connectedAccessPoints or {}
                local newList = {}
                for _, c in ipairs(userData.connectedAccessPoints) do
                    if c ~= code then
                        table.insert(newList, c)
                    end
                end
                userData.connectedAccessPoints = newList
                self:SaveUsers()
                output = {"[УСПЕХ] Точка удалена из списка."}
            end
        end

    elseif cmd == "access_point_ping" then
        local userData = self.terminalUsers[charID]
        if not userData or not userData.connectedAccessPoints or #userData.connectedAccessPoints == 0 then
            output = {"[ОШИБКА] У вас нет подключённых точек доступа."}
        else
            output = {"═══════════════════════════════════════", "  ПИНГ ТОЧЕК ДОСТУПА", "═══════════════════════════════════════", ""}
            for _, code in ipairs(userData.connectedAccessPoints) do
                local foundEnt = nil
                for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                    if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                        foundEnt = ent
                        break
                    end
                end
                if not foundEnt then
                    table.insert(output, "Точка " .. code .. ": (недоступна или устарела)")
                else
                    local pos = foundEnt:GetPos()
                    local players = {}
                    for _, ply in ipairs(player.GetAll()) do
                        if ply ~= client and ply:Alive() then
                            local dist = ply:GetPos():Distance(pos)
                            if dist <= 2000 then
                                table.insert(players, {name = ply:Name(), dist = math.floor(dist)})
                            end
                        end
                    end
                    table.insert(output, "Точка " .. code .. ":")
                    if #players == 0 then
                        table.insert(output, "  Никого нет в радиусе.")
                    else
                        for _, p in ipairs(players) do
                            table.insert(output, string.format("  %s (%d м)", p.name, p.dist))
                        end
                    end
                end
                table.insert(output, "")
            end
        end

    elseif cmd == "access_point_list" then
        local userData = self.terminalUsers[charID]
        if not userData or not userData.connectedAccessPoints or #userData.connectedAccessPoints == 0 then
            output = {"[ОШИБКА] У вас нет подключённых точек доступа."}
        else
            output = {"═══════════════════════════════════════", "  ПОДКЛЮЧЁННЫЕ ТОЧКИ", "═══════════════════════════════════════", ""}
            for _, code in ipairs(userData.connectedAccessPoints) do
                table.insert(output, "  Код: " .. code)
            end
        end

    elseif cmd == "access_point_users" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local foundEnt = nil
            for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                    foundEnt = ent
                    break
                end
            end
            if not foundEnt then
                output = {"[ОШИБКА] Точка не найдена или код устарел."}
            else
                local users = {}
                for cid, data in pairs(self.terminalUsers) do
                    if data.connectedAccessPoints then
                        for _, c in ipairs(data.connectedAccessPoints) do
                            if c == code then
                                local targetChar = ix.char.loaded[cid]
                                if targetChar then
                                    local name = data.username or targetChar:GetName()
                                    table.insert(users, name)
                                end
                                break
                            end
                        end
                    end
                end
                output = {"═══════════════════════════════════════", "  ПОЛЬЗОВАТЕЛИ ТОЧКИ " .. code, "═══════════════════════════════════════", ""}
                if #users == 0 then
                    table.insert(output, "  Никто не подключён.")
                else
                    for _, name in ipairs(users) do
                        table.insert(output, "  " .. name)
                    end
                end
            end
        end

    elseif cmd == "access_point_destroy" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local foundEnt = nil
            for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                    foundEnt = ent
                    break
                end
            end
            if not foundEnt then
                output = {"[ОШИБКА] Точка не найдена или код устарел."}
            else
                local owner = foundEnt:GetOwnerID()
                if owner == charID then
                    foundEnt:Explode()
                    foundEnt:Remove()
                    output = {"[УСПЕХ] Ваша точка доступа уничтожена."}
                else
                    local level = self:GetNetrunLevel(client)
                    if level < 25 then
                        output = {"[ОШИБКА] Требуется 25 уровень нетраннинга для уничтожения чужих точек."}
                    else
                        local captcha = self:GenerateCaptcha(10)
                        net.Start("ixAccessPointCaptcha")
                            net.WriteString(captcha)
                            net.WriteString(code)
                        net.Send(client)
                        output = {
                            "═══════════════════════════════════════",
                            "  УНИЧТОЖЕНИЕ ТОЧКИ ДОСТУПА",
                            "═══════════════════════════════════════",
                            "",
                            "  Введите капчу для подтверждения:",
                            "  (капча отправлена в отдельное окно)"
                        }
                    end
                end
            end
        end

    elseif cmd == "access_point_find_local" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local srcEnt = nil
            for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                    srcEnt = ent
                    break
                end
            end
            if not srcEnt then
                output = {"[ОШИБКА] Исходная точка не найдена."}
            else
                local pos = srcEnt:GetPos()
                local found = {}
                for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                    if IsValid(ent) and ent ~= srcEnt and ent:GetCodeExpireTime() > CurTime() then
                        local dist = ent:GetPos():Distance(pos)
                        if dist <= 500 then
                            table.insert(found, {code = ent:GetAccessCode(), dist = math.floor(dist)})
                        end
                    end
                end
                output = {"═══════════════════════════════════════", "  ТОЧКИ РЯДОМ С " .. code, "═══════════════════════════════════════", ""}
                if #found == 0 then
                    table.insert(output, "  Рядом нет других точек.")
                else
                    for _, info in ipairs(found) do
                        table.insert(output, string.format("  Код: %s (расстояние %d м)", info.code, info.dist))
                    end
                end
                table.insert(output, "")
                table.insert(output, "Используйте access_point_hack <код> для взлома.")
            end
        end

    elseif cmd == "access_point_hack" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local level = self:GetNetrunLevel(client)
            if level < 25 then
                output = {"[ОШИБКА] Требуется 25 уровень нетраннинга."}
            else
                local targetEnt = nil
                for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                    if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                        targetEnt = ent
                        break
                    end
                end
                if not targetEnt then
                    output = {"[ОШИБКА] Точка не найдена или код устарел."}
                else
                    local gridSize = 6
                    local grid = self:GenerateHackGrid(gridSize)
                    local targets = self:GenerateTargets(grid, 5)
                    local timeLimit = 90
                    self.activeHacks[charID] = {
                        type = "accesspoint_hack",
                        target = targetEnt,
                        grid = grid,
                        targets = targets,
                        startTime = CurTime()
                    }
                    net.Start("ixCyberpunkHackGame")
                        net.WriteTable(grid)
                        net.WriteTable(targets)
                        net.WriteUInt(timeLimit, 16)
                    net.Send(client)
                    output = {
                        "═══════════════════════════════════════",
                        "  ВЗЛОМ ТОЧКИ ДОСТУПА (СЛОЖНЫЙ)",
                        "═══════════════════════════════════════",
                        "",
                        "  Открывается интерфейс взлома...",
                        "  У вас 90 секунд."
                    }
                end
            end
        end

    elseif cmd == "access_point_change_code" then
        local code = arg1
        if not code or #code ~= 6 then
            output = {"[ОШИБКА] Укажите код точки."}
        else
            local foundEnt = nil
            for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
                if IsValid(ent) and ent:GetAccessCode() == code and ent:GetCodeExpireTime() > CurTime() then
                    foundEnt = ent
                    break
                end
            end
            if not foundEnt then
                output = {"[ОШИБКА] Точка не найдена."}
            else
                if foundEnt:GetOwnerID() ~= charID then
                    output = {"[ОШИБКА] Вы не владелец этой точки."}
                else
                    local newCode = foundEnt:GenerateNewCode()
                    -- self:SaveTerminalsAndAccessPoints()
                    output = {
                        "[УСПЕХ] Код точки изменён.",
                        "Новый код: " .. newCode
                    }
                end
            end
        end

    elseif string.sub(cmd, 1, 10) == "User_hack_" then
        local effectName = string.lower(string.sub(cmd, 11))
        local userData = self.terminalUsers[charID]
        if not userData or not userData.isLoggedIn then
            output = {"[ОШИБКА] Сначала выполните login"}
        else
            -- Эффект detecting не требует хэш-кода
            if effectName == "detecting" then
                local targetCharID = userData.lastHackedTarget
                if not targetCharID or userData.lastHackedExpiry < CurTime() then
                    output = {"[ОШИБКА] Нет активной взломанной цели"}
                else
                    local targetChar = ix.char.loaded[targetCharID]
                    local targetPlayer = targetChar and targetChar:GetPlayer()
                    if not IsValid(targetPlayer) then
                        output = {"[ОШИБКА] Цель не найдена"}
                    else
                        local success, msg = self:ApplyHackEffect(targetPlayer, effectName, client)
                        if success then
                            output = {
                                "[УСПЕХ] Эффект применён!",
                                "[СИСТЕМА] " .. (type(msg) == "string" and msg or "Выполнено")
                            }
                        else
                            output = {"[ОШИБКА] " .. (msg or "Не удалось применить эффект")}
                        end
                    end
                end
            else
                -- Для остальных эффектов требуется хэш-код
                local hashInput = arg1
                if not hashInput or #hashInput ~= 16 then
                    output = {
                        "[ОШИБКА] Требуется 16-значный код!",
                        "Используйте hash_data_scan для получения кодов"
                    }
                else
                    local hashData = self.hashCodes[charID]
                    local lastScan = hashData and hashData.lastScan and self.hashCodes[hashData.lastScan]
                    local validCode = false
                    if lastScan and CurTime() - lastScan.generatedTime < 300 then -- 5 минут на использование
                        for _, codeData in ipairs(lastScan.codes) do
                            if codeData.code == hashInput and codeData.isCorrect then
                                validCode = true
                                break
                            end
                        end
                    end
                    if not validCode then
                        output = {"[ОШИБКА] Неверный или устаревший код подтверждения"}
                    else
                        local targetCharID = userData.lastHackedTarget
                        if not targetCharID or userData.lastHackedExpiry < CurTime() then
                            output = {"[ОШИБКА] Нет активной взломанной цели"}
                        else
                            local targetChar = ix.char.loaded[targetCharID]
                            local targetPlayer = targetChar and targetChar:GetPlayer()
                            if not IsValid(targetPlayer) then
                                output = {"[ОШИБКА] Цель не найдена"}
                            else
                                local success, msg = self:ApplyHackEffect(targetPlayer, effectName, client)
                                if success then
                                    output = {
                                        "[УСПЕХ] Эффект применён!",
                                        "[СИСТЕМА] " .. (type(msg) == "string" and msg or "Выполнено")
                                    }
                                else
                                    output = {"[ОШИБКА] " .. (msg or "Не удалось применить эффект")}
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        output = {
            "[ОШИБКА] Неизвестная команда: " .. cmd,
            "[СИСТЕМА] Введите help для списка команд"
        }
    end

    self:DebugPrint("Command processed, output lines:", #output)
    
    net.Start("ixBigTerminalOutput")
        net.WriteTable(output)
    net.Send(client)
    
    self:DebugPrint("Output sent to client:", tostring(client))
end

-- Voice trap hooks
hook.Add("PlayerSay", "ixBigTerminalVoiceTrap", function(ply, text, teamChat)
    local charID = ply:GetCharacter() and ply:GetCharacter():GetID()
    local PLUGIN = ix.plugin.Get("big_terminal")
    if PLUGIN and charID then
        local userData = PLUGIN.terminalUsers[charID]
        if userData and userData.voiceTrap and userData.voiceTrap > CurTime() then
            local hacker = userData.voiceTrapHacker
            if IsValid(hacker) then
                net.Start("ixBigTerminalOutput")
                    net.WriteTable({
                        "",
                        "═══════════════════════════════════════",
                        "  VOICE TRAP [CHAT]",
                        "═══════════════════════════════════════",
                        "",
                        "  [НЕИЗВЕСТНО]: " .. text,
                        ""
                    })
                net.Send(hacker)
            end
        end
    end
end)

hook.Add("PlayerCanHearPlayersVoice", "ixBigTerminalVoiceTrapVoice", function(listener, talker)
    local talkerCharID = talker:GetCharacter() and talker:GetCharacter():GetID()
    local PLUGIN = ix.plugin.Get("big_terminal")
    if PLUGIN and talkerCharID then
        local userData = PLUGIN.terminalUsers[talkerCharID]
        if userData and userData.voiceTrap and userData.voiceTrap > CurTime() then
            local hacker = userData.voiceTrapHacker
            if IsValid(hacker) and listener == hacker then
                net.Start("ixBigTerminalOutput")
                    net.WriteTable({
                        "",
                        "  [VOICE TRAP] НЕИЗВЕСТНО говорит...",
                        ""
                    })
                net.Send(hacker)
            end
        end
    end
end)

-- ============================================================================
-- СТАТИСТИКА ИГРОКА
-- ============================================================================

function PLUGIN:InitStats(charID)
    if not self.playerStats[charID] then
        self.playerStats[charID] = {
            pointsHacked = 0,
            virusesCreated = 0,
            pointsInfected = 0,
            usersHacked = 0
        }
    end
end

function PLUGIN:AddStat(charID, stat, value)
    self:InitStats(charID)
    self.playerStats[charID][stat] = (self.playerStats[charID][stat] or 0) + value
    self:SavePlayerStats()
end

function PLUGIN:UpdatePlayerStats(client)
    local char = client:GetCharacter()
    if not char then return end
    net.Start("ixPlayerStats")
    net.WriteTable(self.playerStats[char:GetID()] or {})
    net.Send(client)
end

-- ============================================================================
-- СКАНИРОВАНИЕ И УСТАНОВКА ВИРУСОВ
-- ============================================================================

function PLUGIN:StartVirusScan(client, code)
    if not code or #code ~= 6 then
        client:Notify("Укажите корректный код точки.")
        return
    end

    -- Проверяем, есть ли антивирус на точке
    local antivirusData = self.accessPointAntiviruses[code]
    local scanTime = 300 -- 5 минут по умолчанию
    
    if antivirusData then
        scanTime = self:GetAntivirusScanTime(antivirusData.antivirus, scanTime)
    end

    client:Notify("Сканирование началось (" .. scanTime/60 .. " минут)...")

    timer.Simple(scanTime, function()
        if not IsValid(client) then return end
        
        local virus = self.accessPointViruses[code]
        if not virus then
            client:Notify("Вирус не обнаружен.")
            return
        end

        -- Проверяем, будет ли вирус обнаружен
        if self:WillVirusBeDetected(virus, virus.creatorLevel or 0) then
            client:Notify("Вирус найден! Используйте virun_acc_point_uninstal для обезвреживания.")
            client.foundVirusCode = code
        else
            client:Notify("Вирус не удалось обнаружить.")
        end
    end)
end

function PLUGIN:InstallVirus(client, index)
    local char = client:GetCharacter()
    if not char then return end

    local charID = char:GetID()
    local userData = self.terminalUsers[charID]

    if not userData or not userData.connectedAccessPoints or #userData.connectedAccessPoints == 0 then
        client:Notify("Нет подключённых точек доступа.")
        return
    end

    -- Берём первую подключённую точку
    local code = userData.connectedAccessPoints[1]
    local virus = self.viruses[charID] and self.viruses[charID][index]

    if not virus then
        client:Notify("Вирус не найден.")
        return
    end

    -- Проверяем антивирус
    local success = self:TryInstallVirus(client, code, virus)
    if not success then
        client:Notify("Антивирус заблокировал установку вируса!")
        return
    end

    self.accessPointViruses[code] = virus
    table.remove(self.viruses[charID], index)

    self:SaveViruses()
    self:SaveAccessPointViruses()
    
    -- Обновляем статистику
    self:AddStat(charID, "pointsInfected", 1)

    client:Notify("Вирус установлен на точку!")
end

-- Установка антивируса на точку (вызывается из команды и net.Receive)
function PLUGIN:InstallAntivirus(client, masterKey, antivirusIndex)
    local char = client:GetCharacter()
    if not char then
        return false, "Персонаж не найден"
    end
    local charID = char:GetID()

    -- Ищем точку с таким мастер-ключом
    local foundEnt = nil
    for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
        if IsValid(ent) and ent:GetMasterKey() == masterKey and ent:GetMasterKeyExpire() > CurTime() then
            foundEnt = ent
            break
        end
    end

    if not foundEnt then
        return false, "Точка не найдена или ключ устарел"
    end

    local antivirus = self.antiviruses[charID] and self.antiviruses[charID][antivirusIndex]
    if not antivirus then
        return false, "Антивирус не найден"
    end

    local code = foundEnt:GetAccessCode()
    self.accessPointAntiviruses[code] = {
        antivirus = antivirus,
        charges = 5,
        installedBy = charID,
        installedTime = CurTime()
    }

    table.remove(self.antiviruses[charID], antivirusIndex)
    self:SaveAntiviruses()
    self:SaveAccessPointAntiviruses()

    return true, "Антивирус установлен на точку " .. code
end

-- Voice trap hooks
hook.Add("PlayerSay", "ixBigTerminalVoiceTrap", function(ply, text, teamChat)
    local charID = ply:GetCharacter() and ply:GetCharacter():GetID()
    local PLUGIN = ix.plugin.Get("big_terminal")
    if PLUGIN and charID then
        local userData = PLUGIN.terminalUsers[charID]
        if userData and userData.voiceTrap and userData.voiceTrap > CurTime() then
            local hacker = userData.voiceTrapHacker
            if IsValid(hacker) then
                net.Start("ixBigTerminalOutput")
                    net.WriteTable({
                        "",
                        "═══════════════════════════════════════",
                        "  VOICE TRAP [CHAT]",
                        "═══════════════════════════════════════",
                        "",
                        "  [НЕИЗВЕСТНО]: " .. text,
                        ""
                    })
                net.Send(hacker)
            end
        end
    end
end)

hook.Add("PlayerCanHearPlayersVoice", "ixBigTerminalVoiceTrapVoice", function(listener, talker)
    local talkerCharID = talker:GetCharacter() and talker:GetCharacter():GetID()
    local PLUGIN = ix.plugin.Get("big_terminal")
    if PLUGIN and talkerCharID then
        local userData = PLUGIN.terminalUsers[talkerCharID]
        if userData and userData.voiceTrap and userData.voiceTrap > CurTime() then
            local hacker = userData.voiceTrapHacker
            if IsValid(hacker) and listener == hacker then
                net.Start("ixBigTerminalOutput")
                    net.WriteTable({
                        "",
                        "  [VOICE TRAP] НЕИЗВЕСТНО говорит...",
                        ""
                    })
                net.Send(hacker)
            end
        end
    end
end)

print("[BigTerminal] sv_plugin.lua fully loaded!") 
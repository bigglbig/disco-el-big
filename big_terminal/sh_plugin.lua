local PLUGIN = PLUGIN

print("[BigTerminal] sh_plugin.lua loading...")

PLUGIN.name = "Big Terminal"
PLUGIN.author = "Big.txt"
PLUGIN.description = "Плагин добавляет хакерский терминал с возможностью взлома и форумами."

-- ============================================================================
-- СИСТЕМА ОТЛАДКИ (shared)
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

-- ============================================================================
-- СЕТЕВЫЕ СТРОКИ (должны быть зарегистрированы до использования)
-- ============================================================================

if SERVER then
    util.AddNetworkString("ixBigTerminalOpen")
    util.AddNetworkString("ixBigTerminalClose")
    util.AddNetworkString("ixBigTerminalCommand")
    util.AddNetworkString("ixBigTerminalOutput")
    util.AddNetworkString("ixBigTerminalCaptcha")
    util.AddNetworkString("ixBigTerminalCaptchaResult")
    util.AddNetworkString("ixBigTerminalHashCode")
    util.AddNetworkString("ixBigTerminalHashCodeAnalysis")
    util.AddNetworkString("ixCyberpunkHackGame")
    util.AddNetworkString("ixCyberpunkHackResult")
    util.AddNetworkString("ixHashAnalysisGame")
    util.AddNetworkString("ixHashAnalysisResult")
    util.AddNetworkString("ixAccessPointCaptcha")
    util.AddNetworkString("ixAccessPointCaptchaResult")
    util.AddNetworkString("ixVirusCreate")
    util.AddNetworkString("ixVirusCreateResult")
    util.AddNetworkString("ixVirusDisarmGame")
    util.AddNetworkString("ixVirusDisarmResult")
    util.AddNetworkString("ixAntivirusCreate")
    util.AddNetworkString("ixAntivirusCreateResult")
    util.AddNetworkString("ixAccessPointOwnerKey")
    util.AddNetworkString("ixAntivirusInstall")
    util.AddNetworkString("ixVirusCreateUI")
    util.AddNetworkString("ixAntivirusCreateUI")
    util.AddNetworkString("ixPlayerStats")
    util.AddNetworkString("ixVirusUpgradeUI")
    util.AddNetworkString("ixVirusUpgradeResult")
    util.AddNetworkString("ixAntivirusUpgradeUI")
    util.AddNetworkString("ixAntivirusUpgradeResult")
    util.AddNetworkString("ixMazeUpgradeGame")
    util.AddNetworkString("ixMazeUpgradeResult")
    -- Casino
    util.AddNetworkString("ixCasinoOpen")
    util.AddNetworkString("ixCasinoData")
    util.AddNetworkString("ixCasinoClick")
    util.AddNetworkString("ixCasinoUpgradeClick")
    util.AddNetworkString("ixCasinoUpgradePassive")
    util.AddNetworkString("ixCasinoCollectPassive")
    util.AddNetworkString("ixCasinoCrashStart")
    util.AddNetworkString("ixCasinoCrashCashout")
    util.AddNetworkString("ixCasinoCrashUpdate")
    util.AddNetworkString("ixCasinoCrashResult")
    util.AddNetworkString("ixCasinoRoulette")
    util.AddNetworkString("ixCasinoSlots")
    util.AddNetworkString("ixCasinoPropertyRoulette")
    util.AddNetworkString("ixCasinoPropertyRouletteConfirm")
    util.AddNetworkString("ixCasinoPropertyRouletteResult")
end

-- Подключаем файлы свойств (должны быть загружены до остального кода)
ix.util.Include("properties/sh_virus_properties.lua", "shared")
ix.util.Include("properties/sh_antivirus_properties.lua", "shared")

-- Подключаем основные файлы (sv_casino.lua ДО sv_plugin.lua!)
ix.util.Include("sv_plugin.lua", "server")
ix.util.Include("sv_casino.lua", "server")
ix.util.Include("sv_upgrade.lua", "server")
ix.util.Include("cl_plugin.lua", "client")
ix.util.Include("derma/cl_casino.lua", "client")

print("[BigTerminal] All files included!")
PLUGIN:DebugPrint("Plugin initialization complete")

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ ХРАНИЛИЩ ДАННЫХ
-- ============================================================================

-- Terminal data storage
PLUGIN.terminalUsers = PLUGIN.terminalUsers or {}
PLUGIN.forums = PLUGIN.forums or {}
PLUGIN.hackCooldowns = PLUGIN.hackCooldowns or {}
PLUGIN.activeHacks = PLUGIN.activeHacks or {}
PLUGIN.hashCodes = PLUGIN.hashCodes or {}

-- Virus system
PLUGIN.viruses = PLUGIN.viruses or {}
PLUGIN.virusCooldowns = PLUGIN.virusCooldowns or {}
PLUGIN.accessPointViruses = PLUGIN.accessPointViruses or {}
PLUGIN.virusScanInProgress = PLUGIN.virusScanInProgress or {}
PLUGIN.antiviruses = PLUGIN.antiviruses or {}
PLUGIN.accessPointAntiviruses = PLUGIN.accessPointAntiviruses or {}

-- Player statistics
PLUGIN.playerStats = PLUGIN.playerStats or {}

-- 3D Text offset configuration
PLUGIN.textOffsetX = 0
PLUGIN.textOffsetY = 0
PLUGIN.textOffsetZ = 0
PLUGIN.textAnglePitch = 0
PLUGIN.textAngleYaw = 0
PLUGIN.textAngleRoll = 0
PLUGIN.textScale = 0.1

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (SHARED)
-- ============================================================================

-- Получить уровень нетраннинга игрока
function PLUGIN:GetNetrunLevel(client)
    if not IsValid(client) then return 0 end
    local char = client:GetCharacter()
    if not char then return 0 end

    -- Пытаемся получить уровень через стандартный метод Helix
    if char.GetSkillLevel then
        return char:GetSkillLevel("netrunning") or 0
    elseif char.GetSkill then
        return char:GetSkill("netrunning") or 0
    else
        -- Fallback на старый способ
        local skills = char:GetData("skills", {})
        return skills["netrunning"] or skills["нетраннинг"] or 0
    end
end

-- Генерация случайной капчи
function PLUGIN:GenerateCaptcha(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    local captcha = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        captcha = captcha .. string.sub(chars, rand, rand)
    end
    return captcha
end

-- Генерация хэш-кодов для мини-игры
function PLUGIN:GenerateHashCodes()
    local codes = {}
    local correctIndex = math.random(1, 10)

    for i = 1, 10 do
        local code = ""
        for j = 1, 16 do
            local charType = math.random(1, 2)
            if charType == 1 then
                code = code .. string.char(math.random(48, 57))
            else
                code = code .. string.char(math.random(65, 90))
            end
        end
        codes[i] = {
            code = code,
            isCorrect = i == correctIndex
        }
    end

    return codes, correctIndex
end

-- ============================================================================
-- РЕГИСТРАЦИЯ ПЕРЕМЕННЫХ ПЕРСОНАЖА
-- ============================================================================

ix.char.RegisterVar("terminalAccount", {
    default = nil,
    field = "terminal_account",
    fieldType = ix.type.string,
    bNoDisplay = true,
})

ix.char.RegisterVar("terminalForums", {
    default = {},
    field = "terminal_forums",
    fieldType = ix.type.text,
    bNoDisplay = true,
})

-- ============================================================================
-- ФУНКЦИИ РАБОТЫ С ПОЛЬЗОВАТЕЛЯМИ
-- ============================================================================

-- Регистрация нового пользователя терминала
function PLUGIN:RegisterTerminalUser(charID, username)
    if not charID or not username then return false end
    
    self.terminalUsers[charID] = {
        username = username,
        registered = os.date("%d/%m/%Y"),
        hackedPlayers = {},
        isHacked = false,
        hackableUntil = 0,
        lastHackedTarget = nil,
        lastHackedExpiry = 0,
        masterKeyEnabled = false,
        connectedAccessPoints = {},
    }
    
    -- Инициализируем статистику
    self.playerStats[charID] = {
        pointsHacked = 0,
        virusesCreated = 0,
        pointsInfected = 0,
        usersHacked = 0
    }
    
    self:SaveUsers()
    self:SavePlayerStats()
    return true
end

-- Получить данные пользователя
function PLUGIN:GetTerminalUser(charID)
    return self.terminalUsers[charID]
end
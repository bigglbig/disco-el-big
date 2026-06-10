local PLUGIN = PLUGIN

-- ============================================================================
-- СИСТЕМА КАЗИНО ДЛЯ ОТКРЫТИЯ СВОЙСТВ
-- ============================================================================

-- Редкость свойств: 1 = легендарная, 2 = эпическая, 3 = редкая, 4 = обычная
PLUGIN.propertyRarity = {}

-- Определяем редкость для свойств вирусов
local virusRarity = {
    -- Обычные (4) - открыты по умолчанию
    ransomware = 4,
    glitch = 4,
    spy = 4,
    noise = 4,
    silent = 4,
    shock = 4,
    informant = 4,
    slow = 4,
    blind = 4,
    
    -- Редкие (3)
    stamina_drain = 3,
    bleed = 3,
    hallucination = 3,
    hunger_accel = 3,
    radio_jammer = 3,
    mirror = 3,
    
    -- Эпические (2)
    neural_disruptor = 2,
    synapse_burn = 2,
    medical_suppress = 2,
    cyberpsychosis = 2,
    
    -- Легендарные (1)
    overlock = 1,
    stealth = 1,
    analyzer = 1,
    parasite = 1,
    polymorph = 1,
    logic_bomb = 1,
    symbiote = 1
}

-- Редкость для антивирусов
local antivirusRarity = {
    -- Обычные (4) - открыты по умолчанию
    scanner = 4,
    cleaner = 4,
    blocker = 4,
    trap = 4,
    durable = 4,
    alert = 4,
    
    -- Редкие (3)
    regen = 3,
    ice_wall = 3,
    feedback = 3,
    auto_repair = 3,
    blood_shield = 3,
    neural_firewall = 3,
    stamina_boost = 3,
    
    -- Эпические (2)
    memory_shield = 2,
    quarantine = 2,
    purifier = 2,
    
    -- Легендарные (1)
    overwatch = 1,
    black_ice = 1,
    synthesis = 1,
    entropy = 1
}

-- Сохраняем редкость в PLUGIN
for propId, rarity in pairs(virusRarity) do
    PLUGIN.propertyRarity[propId] = rarity
end

for propId, rarity in pairs(antivirusRarity) do
    PLUGIN.propertyRarity[propId] = rarity
end

-- Названия редкости
PLUGIN.rarityNames = {
    [1] = {name = "Легендарная", color = Color(255, 215, 0), chance = 0.01},
    [2] = {name = "Эпическая", color = Color(163, 53, 238), chance = 0.05},
    [3] = {name = "Редкая", color = Color(0, 112, 221), chance = 0.15},
    [4] = {name = "Обычная", color = Color(128, 128, 128), chance = 0.79}
}

-- Стоимость рулетки свойств
PLUGIN.rouletteCosts = {
    all = 100,      -- Рулетка со всеми свойствами
    [1] = 500,      -- Легендарная рулетка
    [2] = 300,      -- Эпическая рулетка
    [3] = 150,      -- Редкая рулетка
    [4] = 50        -- Обычная рулетка
}

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ ДАННЫХ КАЗИНО
-- ============================================================================

PLUGIN.casinoData = PLUGIN.casinoData or {}

function PLUGIN:InitCasinoData(client)
    local char = client:GetCharacter()
    if not char then return nil end
    
    local charID = char:GetID()
    
    if not self.casinoData[charID] then
        self.casinoData[charID] = {
            coins = 0,                          -- Коины
            clickPower = 0.1,                   -- Сила клика
            passiveIncome = 0,                  -- Пассивный доход в секунду
            clickLevel = 1,                     -- Уровень кнопки
            passiveLevel = 1,                   -- Уровень пассивного дохода
            unlockedProperties = {},            -- Разблокированные свойства
            lastPassiveCollect = CurTime()      -- Последний сбор пассивного дохода
        }
        
        -- Открываем обычные свойства по умолчанию
        for propId, rarity in pairs(self.propertyRarity) do
            if rarity == 4 then
                self.casinoData[charID].unlockedProperties[propId] = true
            end
        end
        
        self:SaveCasinoData()
    end
    
    return self.casinoData[charID]
end

-- ============================================================================
-- СОХРАНЕНИЕ И ЗАГРУЗКА
-- ============================================================================

function PLUGIN:SaveCasinoData()
    local data = util.TableToJSON(self.casinoData or {})
    if not data then return end
    
    local compressed = util.Compress(data)
    if not compressed then return end
    
    file.CreateDir("ixhl2rp/big_terminal")
    file.Write("ixhl2rp/big_terminal/casino_data.txt", compressed)
end

function PLUGIN:LoadCasinoData()
    local path = "ixhl2rp/big_terminal/casino_data.txt"
    if not file.Exists(path, "DATA") then return end
    
    local compressed = file.Read(path, "DATA")
    if not compressed then return end
    
    local data = util.Decompress(compressed)
    if not data then return end
    
    self.casinoData = util.JSONToTable(data) or {}
end

-- ============================================================================
-- ФУНКЦИИ КАЗИНО
-- ============================================================================

-- Получить коины
function PLUGIN:GetCoins(client)
    local data = self:InitCasinoData(client)
    return data and data.coins or 0
end

-- Добавить коины
function PLUGIN:AddCoins(client, amount)
    local data = self:InitCasinoData(client)
    if not data then return false end
    
    data.coins = data.coins + amount
    self:SaveCasinoData()
    return true
end

-- Снять коины
function PLUGIN:TakeCoins(client, amount)
    local data = self:InitCasinoData(client)
    if not data or data.coins < amount then return false end
    
    data.coins = data.coins - amount
    self:SaveCasinoData()
    return true
end

-- Клик по кнопке
function PLUGIN:CasinoClick(client)
    local data = self:InitCasinoData(client)
    if not data then 
        self:DebugPrint("CasinoClick: No data for client")
        return 0 
    end
    
    local earned = data.clickPower
    data.coins = data.coins + earned
    self:SaveCasinoData()
    
    self:DebugPrint("CasinoClick: earned", earned, "total coins", data.coins)
    
    return earned
end

-- Собрать пассивный доход
function PLUGIN:CollectPassiveIncome(client)
    local data = self:InitCasinoData(client)
    if not data then return 0 end
    
    local timePassed = CurTime() - (data.lastPassiveCollect or CurTime())
    local earned = data.passiveIncome * timePassed
    
    data.coins = data.coins + earned
    data.lastPassiveCollect = CurTime()
    self:SaveCasinoData()
    
    return earned
end

-- Апгрейд кнопки
function PLUGIN:UpgradeClickButton(client)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    local cost = self:GetClickUpgradeCost(data.clickLevel)
    if data.coins < cost then
        return false, "Недостаточно коинов: " .. cost
    end
    
    data.coins = data.coins - cost
    data.clickLevel = data.clickLevel + 1
    data.clickPower = 0.1 * (1 + data.clickLevel * 0.5)
    self:SaveCasinoData()
    
    return true, data.clickLevel
end

-- Апгрейд пассивного дохода
function PLUGIN:UpgradePassiveIncome(client)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    local cost = self:GetPassiveUpgradeCost(data.passiveLevel)
    if data.coins < cost then
        return false, "Недостаточно коинов: " .. cost
    end
    
    data.coins = data.coins - cost
    data.passiveLevel = data.passiveLevel + 1
    data.passiveIncome = 0.01 * data.passiveLevel
    self:SaveCasinoData()
    
    return true, data.passiveLevel
end

-- Стоимость апгрейда кнопки
function PLUGIN:GetClickUpgradeCost(level)
    return math.floor(10 * math.pow(1.5, level))
end

-- Стоимость апгрейда пассивного дохода
function PLUGIN:GetPassiveUpgradeCost(level)
    return math.floor(50 * math.pow(2, level))
end

-- ============================================================================
-- ИГРЫ КАЗИНО
-- ============================================================================

-- Crash (Ракетка)
function PLUGIN:PlayCrash(client, bet)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    if bet <= 0 or bet > data.coins then
        return false, "Неверная ставка"
    end
    
    -- Генерируем случайный множитель (алгоритм Crash)
    -- Чем выше множитель, тем меньше шанс
    local crashPoint = 1.0
    local random = math.random()
    
    -- Формула: crash = 1 / (1 - random) * 0.01
    -- Но ограничиваем максимум 10x
    if random < 0.99 then
        crashPoint = math.min(1 / (1 - random) * 0.99, 10)
    else
        crashPoint = 1.0 -- Мгновенный краш
    end
    
    -- Снимаем ставку
    data.coins = data.coins - bet
    self:SaveCasinoData()
    
    -- Сохраняем игру
    local charID = client:GetCharacter():GetID()
    self.activeCrashGames = self.activeCrashGames or {}
    self.activeCrashGames[charID] = {
        bet = bet,
        crashPoint = crashPoint,
        currentMultiplier = 1.0,
        startTime = CurTime(),
        isActive = true,
        client = client
    }
    
    return true, {bet = bet, crashPoint = crashPoint}
end

-- Забрать выигрыш в Crash
function PLUGIN:CashoutCrash(client)
    local charID = client:GetCharacter():GetID()
    local game = self.activeCrashGames and self.activeCrashGames[charID]
    
    if not game or not game.isActive then
        return false, "Нет активной игры"
    end
    
    game.isActive = false
    
    local data = self:InitCasinoData(client)
    local winnings = game.bet * game.currentMultiplier
    
    data.coins = data.coins + winnings
    self:SaveCasinoData()
    
    self.activeCrashGames[charID] = nil
    
    return true, winnings
end

-- Обновление Crash (вызывается каждые 0.1 секунды для плавной анимации)
function PLUGIN:UpdateCrashGames()
    if not self.activeCrashGames then return end
    
    for charID, game in pairs(self.activeCrashGames) do
        if game.isActive then
            -- Увеличиваем множитель (скорость роста зависит от времени)
            local elapsed = CurTime() - game.startTime
            local growthRate = 0.05 + (elapsed * 0.01) -- Ускоряется со временем
            game.currentMultiplier = game.currentMultiplier + growthRate
            
            if game.currentMultiplier >= game.crashPoint then
                game.isActive = false
                
                -- Находим игрока по charID
                local client = nil
                local targetChar = ix.char.loaded[charID]
                if targetChar then
                    client = targetChar:GetPlayer()
                end
                
                if IsValid(client) then
                    client:Notify("CRASH! Вы проиграли ставку!")
                    net.Start("ixCasinoCrashResult")
                        net.WriteBool(false)
                        net.WriteFloat(game.crashPoint)
                    net.Send(client)
                    -- Отправляем обновлённые данные после краша
                    self:SendCasinoData(client)
                end
                
                self.activeCrashGames[charID] = nil
            else
                -- Отправляем обновление клиенту каждый тик
                local client = nil
                local targetChar = ix.char.loaded[charID]
                if targetChar then
                    client = targetChar:GetPlayer()
                end
                
                if IsValid(client) then
                    net.Start("ixCasinoCrashUpdate")
                        net.WriteFloat(game.currentMultiplier)
                    net.Send(client)
                end
            end
        end
    end
end

-- Рулетка
function PLUGIN:PlayRoulette(client, bet, betType, betValue)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    if bet <= 0 or bet > data.coins then
        return false, "Неверная ставка"
    end
    
    -- Снимаем ставку
    data.coins = data.coins - bet
    
    -- Крутим рулетку (0-36)
    local result = math.random(0, 36)
    local redNumbers = {1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36}
    local isRed = table.HasValue(redNumbers, result)
    local isBlack = result > 0 and not isRed
    local isZero = result == 0
    
    local won = false
    local multiplier = 0
    
    if betType == "red" and isRed then
        won = true
        multiplier = 2
    elseif betType == "black" and isBlack then
        won = true
        multiplier = 2
    elseif betType == "number" and result == betValue then
        won = true
        multiplier = 36
    elseif betType == "dozen" then
        -- 1-12, 13-24, 25-36
        local dozen = math.ceil(result / 12)
        if result > 0 and dozen == betValue then
            won = true
            multiplier = 3
        end
    elseif betType == "half" then
        -- 1: 1-18, 2: 19-36
        local half = result <= 18 and 1 or 2
        if result > 0 and half == betValue then
            won = true
            multiplier = 2
        end
    end
    
    local winnings = 0
    if won then
        winnings = bet * multiplier
        data.coins = data.coins + winnings
    end
    
    self:SaveCasinoData()
    
    return true, {
        result = result,
        isRed = isRed,
        won = won,
        winnings = winnings,
        multiplier = multiplier
    }
end

-- Слот-машина
function PLUGIN:PlaySlots(client, bet)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    if bet <= 0 or bet > data.coins then
        return false, "Неверная ставка"
    end
    
    -- Снимаем ставку
    data.coins = data.coins - bet
    
    -- Символы слот-машины (все по 4 символа)
    local symbols = {"7777", "BARS", "CHRY", "LMON", "BELL", "STAR", "GEMS"}
    -- Веса: 7777 очень редкий, остальные более частые
    local weights = {1, 10, 15, 15, 15, 12, 8}
    
    -- Функция взвешенного случайного выбора
    local function getRandomSymbol()
        local totalWeight = 0
        for _, w in ipairs(weights) do
            totalWeight = totalWeight + w
        end
        
        local random = math.random() * totalWeight
        local current = 0
        
        for i, w in ipairs(weights) do
            current = current + w
            if random <= current then
                return symbols[i]
            end
        end
        
        return symbols[#symbols]
    end
    
    -- Крутим 3 барабана
    local reels = {}
    for i = 1, 3 do
        reels[i] = getRandomSymbol()
    end
    
    -- Проверяем комбинации (уменьшенные шансы на выигрыш)
    local multiplier = 0
    
    -- Три одинаковых (очень редкий выигрыш)
    if reels[1] == reels[2] and reels[2] == reels[3] then
        if reels[1] == "7777" then
            multiplier = 10  -- Джекпот x10 (было x100)
        elseif reels[1] == "GEMS" then
            multiplier = 8
        elseif reels[1] == "STAR" then
            multiplier = 6
        elseif reels[1] == "BELL" then
            multiplier = 5
        elseif reels[1] == "BARS" then
            multiplier = 4
        else
            multiplier = 3
        end
    -- Два одинаковых (редкий выигрыш - только 10% шанс)
    elseif (reels[1] == reels[2] or reels[2] == reels[3] or reels[1] == reels[3]) then
        -- Только 10% шанс получить x2 за два одинаковых
        if math.random(1, 10) == 1 then
            multiplier = 2
        end
    -- Вишенки (маленький выигрыш - только 20% шанс)
    elseif reels[1] == "CHRY" or reels[2] == "CHRY" or reels[3] == "CHRY" then
        -- Только 20% шанс получить x1.5 за вишенку
        if math.random(1, 5) == 1 then
            multiplier = 1.5
        end
    end
    
    local winnings = 0
    if multiplier > 0 then
        winnings = bet * multiplier
        data.coins = data.coins + winnings
    end
    
    self:SaveCasinoData()
    
    return true, {
        reels = reels,
        multiplier = multiplier,
        winnings = winnings
    }
end

-- ============================================================================
-- РУЛЕТКА СВОЙСТВ
-- ============================================================================

function PLUGIN:PlayPropertyRoulette(client, rouletteType)
    local data = self:InitCasinoData(client)
    if not data then return false, "Нет данных" end
    
    -- Преобразуем строку в число для ключа таблицы, если это не "all"
    local costKey = rouletteType
    if rouletteType ~= "all" then
        costKey = tonumber(rouletteType) or 4
    end
    
    local cost = self.rouletteCosts[costKey] or 100
    
    if data.coins < cost then
        return false, "Недостаточно коинов: " .. cost
    end
    
    -- Снимаем стоимость
    data.coins = data.coins - cost
    
    -- Получаем список свойств для рулетки
    local availableProps = {}
    
    if rouletteType == "all" then
        -- Все свойства
        for propId, rarity in pairs(self.propertyRarity) do
            if not data.unlockedProperties[propId] then
                table.insert(availableProps, {id = propId, rarity = rarity})
            end
        end
    else
        -- Определённая редкость (преобразуем строку в число)
        local targetRarity = tonumber(rouletteType)
        
        print("[PropertyRoulette] Looking for rarity: " .. tostring(rouletteType) .. " (converted: " .. tostring(targetRarity) .. ")")
        
        for propId, rarity in pairs(self.propertyRarity) do
            print("[PropertyRoulette] Checking prop: " .. propId .. " rarity: " .. tostring(rarity) .. " (type: " .. type(rarity) .. ")")
            
            if rarity == targetRarity and not data.unlockedProperties[propId] then
                table.insert(availableProps, {id = propId, rarity = rarity})
                print("[PropertyRoulette] Added prop: " .. propId)
            end
        end
    end
    
    print("[PropertyRoulette] Available props count: " .. #availableProps)
    
    -- Если нет доступных свойств
    if #availableProps == 0 then
        data.coins = data.coins + cost -- Возвращаем коины
        return false, "Все свойства этой редкости уже открыты!"
    end
    
    -- Выбираем случайное свойство с учётом редкости
    local function getPropertyByRarity()
        if rouletteType == "all" then
            -- Случайный выбор с весами редкости
            local roll = math.random()
            local cumulative = 0
            
            for rarity = 1, 4 do
                cumulative = cumulative + self.rarityNames[rarity].chance
                if roll <= cumulative then
                    -- Ищем свойство этой редкости
                    local propsOfRarity = {}
                    for _, prop in ipairs(availableProps) do
                        if prop.rarity == rarity then
                            table.insert(propsOfRarity, prop)
                        end
                    end
                    
                    if #propsOfRarity > 0 then
                        return propsOfRarity[math.random(1, #propsOfRarity)]
                    end
                end
            end
            
            -- Fallback на случайное
            return availableProps[math.random(1, #availableProps)]
        else
            -- Конкретная редкость
            return availableProps[math.random(1, #availableProps)]
        end
    end
    
    local selectedProp = getPropertyByRarity()
    
    -- Сохраняем результат для анимации
    local charID = client:GetCharacter():GetID()
    self.propertyRouletteResults = self.propertyRouletteResults or {}
    self.propertyRouletteResults[charID] = {
        finalProp = selectedProp.id,
        rarity = selectedProp.rarity,
        allProps = availableProps,
        startTime = CurTime()
    }
    
    -- Разблокируем свойство после анимации (клиент запросит)
    self:SaveCasinoData()
    
    return true, {
        cost = cost,
        availableCount = #availableProps,
        rouletteType = rouletteType
    }
end

-- Подтверждение получения свойства (после анимации)
function PLUGIN:ConfirmPropertyRoulette(client)
    local charID = client:GetCharacter():GetID()
    local result = self.propertyRouletteResults and self.propertyRouletteResults[charID]
    
    if not result then
        return false, "Нет результата рулетки"
    end
    
    local data = self:InitCasinoData(client)
    data.unlockedProperties[result.finalProp] = true
    self:SaveCasinoData()
    
    self.propertyRouletteResults[charID] = nil
    
    return true, result.finalProp
end

-- Проверка разблокировки свойства
function PLUGIN:IsPropertyUnlocked(client, propId)
    local data = self:InitCasinoData(client)
    return data and data.unlockedProperties[propId]
end

-- Получить список разблокированных свойств
function PLUGIN:GetUnlockedProperties(client)
    local data = self:InitCasinoData(client)
    return data and data.unlockedProperties or {}
end

-- Фильтровать пул свойств по разблокированным
function PLUGIN:FilterPropertiesByUnlocked(client, pool)
    local unlocked = self:GetUnlockedProperties(client)
    local filtered = {}
    
    for _, propId in ipairs(pool) do
        if unlocked[propId] then
            table.insert(filtered, propId)
        end
    end
    
    return filtered
end

-- ============================================================================
-- СЕТЕВЫЕ СООБЩЕНИЯ (строки уже зарегистрированы в sh_plugin.lua)
-- ============================================================================

-- Отправить данные казино клиенту
function PLUGIN:SendCasinoData(client)
    local data = self:InitCasinoData(client)
    if not data then 
        self:DebugPrint("SendCasinoData: No data for client")
        return 
    end
    
    self:DebugPrint("SendCasinoData: coins", data.coins, "clickPower", data.clickPower)
    
    net.Start("ixCasinoData")
        net.WriteFloat(data.coins)
        net.WriteFloat(data.clickPower)
        net.WriteFloat(data.passiveIncome)
        net.WriteUInt(data.clickLevel, 16)
        net.WriteUInt(data.passiveLevel, 16)
        net.WriteTable(data.unlockedProperties)
    net.Send(client)
end
    
-- Обработчики сетевых сообщений
net.Receive("ixCasinoClick", function(len, client)
    if not PLUGIN then 
        print("[BigTerminal Casino] ERROR: PLUGIN is nil in ixCasinoClick")
        return
    end
    
    print("[BigTerminal Casino] ixCasinoClick received from " .. tostring(client))
    
    local earned = PLUGIN:CasinoClick(client)
    PLUGIN:DebugPrint("CasinoClick earned:", earned)
    PLUGIN:SendCasinoData(client)
    
    print("[BigTerminal Casino] Click processed, earned: " .. tostring(earned))
end)

net.Receive("ixCasinoUpgradeClick", function(len, client)
    if not PLUGIN then return end
    local data = PLUGIN:InitCasinoData(client)
    if not data then 
        client:Notify("Ошибка данных!")
        return 
    end
    
    local cost = PLUGIN:GetClickUpgradeCost(data.clickLevel)
    if data.coins < cost then
        client:Notify("Недостаточно коинов! Нужно: " .. cost)
        PLUGIN:SendCasinoData(client)
        return
    end
    
    local success, result = PLUGIN:UpgradeClickButton(client)
    client:Notify(success and "Кнопка улучшена до уровня " .. result or result)
    PLUGIN:SendCasinoData(client)
end)

net.Receive("ixCasinoUpgradePassive", function(len, client)
    if not PLUGIN then return end
    local data = PLUGIN:InitCasinoData(client)
    if not data then 
        client:Notify("Ошибка данных!")
        return
    end
    
    local cost = PLUGIN:GetPassiveUpgradeCost(data.passiveLevel)
    if data.coins < cost then
        client:Notify("Недостаточно коинов! Нужно: " .. cost)
        PLUGIN:SendCasinoData(client)
        return
    end
    
    local success, result = PLUGIN:UpgradePassiveIncome(client)
    client:Notify(success and "Пассивный доход улучшен до уровня " .. result or result)
    PLUGIN:SendCasinoData(client)
end)

net.Receive("ixCasinoCollectPassive", function(len, client)
    if not PLUGIN then return end
    local earned = PLUGIN:CollectPassiveIncome(client)
    
    -- Сначала отправляем обновлённые данные
    PLUGIN:SendCasinoData(client)
    
    -- Потом показываем уведомление
    if earned > 0 then
        client:Notify("Собрано " .. string.format("%.2f", earned) .. " коинов")
    else
        client:Notify("Нечего собирать!")
    end
end)

net.Receive("ixCasinoCrashStart", function(len, client)
    if not PLUGIN then return end
    local bet = net.ReadFloat()
    
    if bet <= 0 then
        client:Notify("Введите корректную ставку!")
        return
    end
    
    local success, result = PLUGIN:PlayCrash(client, bet)
    
    if success then
        net.Start("ixCasinoCrashStart")
            net.WriteFloat(result.bet)
            net.WriteFloat(result.crashPoint)
        net.Send(client)
    else
        client:Notify(result)
    end
end)

net.Receive("ixCasinoCrashCashout", function(len, client)
    if not PLUGIN then return end
    local success, winnings = PLUGIN:CashoutCrash(client)
    
    net.Start("ixCasinoCrashResult")
        net.WriteBool(success)
        net.WriteFloat(winnings or 0)
    net.Send(client)
    
    -- Отправляем обновлённые данные казино
    PLUGIN:SendCasinoData(client)
    
    if success then
        client:Notify("Вы выиграли " .. string.format("%.2f", winnings) .. " коинов!")
    else
        client:Notify(winnings or "Нет активной игры!")
    end
end)

net.Receive("ixCasinoRoulette", function(len, client)
    if not PLUGIN then return end
    local bet = net.ReadFloat()
    local betType = net.ReadString()
    local betValue = net.ReadUInt(8)
    
    if bet <= 0 then
        client:Notify("Введите корректную ставку!")
        return
    end
    
    local success, result = PLUGIN:PlayRoulette(client, bet, betType, betValue)
    
    if success then
        net.Start("ixCasinoRoulette")
            net.WriteUInt(result.result, 8)
            net.WriteBool(result.isRed)
            net.WriteBool(result.won)
            net.WriteFloat(result.winnings)
            net.WriteFloat(result.multiplier)
        net.Send(client)
        
        PLUGIN:SendCasinoData(client)
    else
        client:Notify(result)
    end
end)

net.Receive("ixCasinoSlots", function(len, client)
    if not PLUGIN then return end
    local bet = net.ReadFloat()
    
    if bet <= 0 then
        client:Notify("Введите корректную ставку!")
        return
    end
    
    local success, result = PLUGIN:PlaySlots(client, bet)
    
    if success then
        net.Start("ixCasinoSlots")
            net.WriteTable(result.reels)
            net.WriteFloat(result.multiplier)
            net.WriteFloat(result.winnings)
        net.Send(client)
        
        PLUGIN:SendCasinoData(client)
    else
        client:Notify(result)
    end
end)

net.Receive("ixCasinoPropertyRoulette", function(len, client)
    if not PLUGIN then return end
    local rouletteType = net.ReadString()
    local success, result = PLUGIN:PlayPropertyRoulette(client, rouletteType)
    
    if success then
        local charID = client:GetCharacter():GetID()
        local rouletteResult = PLUGIN.propertyRouletteResults[charID]
        
        -- Отправляем обновлённые данные СРАЗУ после снятия денег
        PLUGIN:SendCasinoData(client)
        
        net.Start("ixCasinoPropertyRouletteResult")
            net.WriteBool(true)
            net.WriteString(rouletteType)
            net.WriteTable(rouletteResult.allProps)
            net.WriteString(rouletteResult.finalProp)
            net.WriteUInt(rouletteResult.rarity, 8)
        net.Send(client)
    else
        net.Start("ixCasinoPropertyRouletteResult")
            net.WriteBool(false)
            net.WriteString(result)
        net.Send(client)
    end
end)

net.Receive("ixCasinoPropertyRouletteConfirm", function(len, client)
    if not PLUGIN then return end
    local success, propId = PLUGIN:ConfirmPropertyRoulette(client)
    
    if success then
        local propData = PLUGIN.virusProperties[propId] or PLUGIN.antivirusProperties[propId]
        local rarity = PLUGIN.propertyRarity[propId]
        local rarityName = PLUGIN.rarityNames[rarity] and PLUGIN.rarityNames[rarity].name or "Неизвестно"
        
        client:Notify("Вы открыли " .. (propData and propData.name or propId) .. " (" .. rarityName .. ")!")
        PLUGIN:SendCasinoData(client)
    end
end)

-- ============================================================================
-- ТАЙМЕР ДЛЯ ПАССИВНОГО ДОХОДА И CRASH
-- ============================================================================

-- Таймер для Crash игр (0.1 сек для плавной анимации)
timer.Create("ixCasinoCrashUpdate", 0.1, 0, function()
    if not PLUGIN then return end
    PLUGIN:UpdateCrashGames()
end)

-- Таймер для пассивного дохода (1 сек)
timer.Create("ixCasinoPassiveIncome", 1, 0, function()
    if not PLUGIN then return end
    -- Пассивный доход можно добавить здесь
end)

-- Загрузка данных при старте
PLUGIN:LoadCasinoData()

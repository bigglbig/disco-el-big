-- ============================================================================
-- СИСТЕМА АПГРЕЙДА ВИРУСОВ И АНТИВИРУСОВ
-- ============================================================================

local PLUGIN = PLUGIN

-- Константы апгрейда
PLUGIN.UPGRADE_COSTS = {
    add = 500,      -- Добавить свойство
    stack = 300,    -- Усилить стак
    remove = 200    -- Удалить свойство
}

PLUGIN.UPGRADE_COOLDOWN = 3600  -- 1 час
PLUGIN.UPGRADE_MAX = 3          -- Максимум апгрейдов

-- Свойства, которые нельзя добавить через апгрейд
PLUGIN.UPGRADE_BLACKLIST = {
    "overlock", "stealth", "analyzer", "polymorph", "parasite", "logic_bomb"
}

-- ============================================================================
-- ПРОВЕРКИ
-- ============================================================================

function PLUGIN:CanUpgradeVirus(client, index, upgradeType, prop)
    local char = client:GetCharacter()
    if not char then return false, "Персонаж не найден" end
    
    local charID = char:GetID()
    local level = self:GetNetrunLevel(client)
    
    -- Проверка уровня
    if level < 30 then
        return false, "Требуется 30 уровень нетраннинга"
    end
    
    -- Проверка существования вируса
    local virus = self.viruses[charID] and self.viruses[charID][index]
    if not virus then
        return false, "Вирус не найден"
    end
    
    -- Проверка кулдауна
    local lastUpgrade = virus.lastUpgradeTime or 0
    if CurTime() - lastUpgrade < self.UPGRADE_COOLDOWN then
        local remaining = math.ceil(self.UPGRADE_COOLDOWN - (CurTime() - lastUpgrade))
        return false, "Кулдаун: " .. remaining .. " секунд"
    end
    
    -- Проверка количества апгрейдов
    virus.upgradesUsed = virus.upgradesUsed or 0
    if virus.upgradesUsed >= self.UPGRADE_MAX then
        return false, "Достигнут максимум апгрейдов (" .. self.UPGRADE_MAX .. ")"
    end
    
    -- Проверка типа апгрейда
    if upgradeType == "add" then
        -- Проверка количества свойств
        if #virus.props >= 3 then
            return false, "У вируса уже максимум свойств (3)"
        end
        
        -- Проверка наличия свойства
        if table.HasValue(virus.props, prop) then
            return false, "Свойство уже есть. Используйте 'stack' для усиления"
        end
        
        -- Проверка blacklist
        if table.HasValue(self.UPGRADE_BLACKLIST, prop) then
            return false, "Это свойство нельзя добавить через апгрейд"
        end
        
        -- Проверка существования свойства
        if not self.virusProperties[prop] then
            return false, "Неизвестное свойство: " .. prop
        end
        
        -- Проверка уровня для свойства
        local propData = self.virusProperties[prop]
        if level < (propData.minLevel or 0) then
            return false, "Требуется " .. propData.minLevel .. " уровень для этого свойства"
        end
        
    elseif upgradeType == "stack" then
        -- Проверка наличия свойства
        if not table.HasValue(virus.props, prop) then
            return false, "У вируса нет этого свойства"
        end
        
        -- Проверка стаков
        local propData = self.virusProperties[prop]
        if not propData.stackable then
            return false, "Это свойство нельзя стакать"
        end
        
        local stacks = 0
        for _, p in ipairs(virus.props) do
            if p == prop then stacks = stacks + 1 end
        end
        
        if stacks >= (propData.maxStacks or 5) then
            return false, "Достигнут максимум стаков для этого свойства"
        end
        
    elseif upgradeType == "remove" then
        -- Проверка наличия свойства
        if not table.HasValue(virus.props, prop) then
            return false, "У вируса нет этого свойства"
        end
        
        -- Проверка минимального количества свойств
        if #virus.props <= 1 then
            return false, "Нельзя удалить последнее свойство"
        end
    else
        return false, "Неизвестный тип апгрейда: " .. upgradeType
    end
    
    -- Проверка денег
    local cost = self.UPGRADE_COSTS[upgradeType] or 500
    local money = char:GetMoney()
    if money < cost then
        return false, "Недостаточно денег: нужно " .. cost .. ", есть " .. money
    end
    
    return true, cost
end

function PLUGIN:CanUpgradeAntivirus(client, index, upgradeType, prop)
    local char = client:GetCharacter()
    if not char then return false, "Персонаж не найден" end
    
    local charID = char:GetID()
    local level = self:GetNetrunLevel(client)
    
    -- Проверка уровня
    if level < 30 then
        return false, "Требуется 30 уровень нетраннинга"
    end
    
    -- Проверка существования антивируса
    local antivirus = self.antiviruses[charID] and self.antiviruses[charID][index]
    if not antivirus then
        return false, "Антивирус не найден"
    end
    
    -- Проверка кулдауна
    local lastUpgrade = antivirus.lastUpgradeTime or 0
    if CurTime() - lastUpgrade < self.UPGRADE_COOLDOWN then
        local remaining = math.ceil(self.UPGRADE_COOLDOWN - (CurTime() - lastUpgrade))
        return false, "Кулдаун: " .. remaining .. " секунд"
    end
    
    -- Проверка количества апгрейдов
    antivirus.upgradesUsed = antivirus.upgradesUsed or 0
    if antivirus.upgradesUsed >= self.UPGRADE_MAX then
        return false, "Достигнут максимум апгрейдов (" .. self.UPGRADE_MAX .. ")"
    end
    
    -- Проверка типа апгрейда
    if upgradeType == "add" then
        if #antivirus.props >= 3 then
            return false, "У антивируса уже максимум свойств (3)"
        end
        
        if table.HasValue(antivirus.props, prop) then
            return false, "Свойство уже есть. Используйте 'stack' для усиления"
        end
        
        if not self.antivirusProperties[prop] then
            return false, "Неизвестное свойство: " .. prop
        end
        
        local propData = self.antivirusProperties[prop]
        if level < (propData.minLevel or 0) then
            return false, "Требуется " .. propData.minLevel .. " уровень для этого свойства"
        end
        
    elseif upgradeType == "stack" then
        if not table.HasValue(antivirus.props, prop) then
            return false, "У антивируса нет этого свойства"
        end
        
        local propData = self.antivirusProperties[prop]
        if not propData.stackable then
            return false, "Это свойство нельзя стакать"
        end
        
        local stacks = 0
        for _, p in ipairs(antivirus.props) do
            if p == prop then stacks = stacks + 1 end
        end
        
        if stacks >= (propData.maxStacks or 5) then
            return false, "Достигнут максимум стаков для этого свойства"
        end
        
    elseif upgradeType == "remove" then
        if not table.HasValue(antivirus.props, prop) then
            return false, "У антивируса нет этого свойства"
        end
        
        if #antivirus.props <= 1 then
            return false, "Нельзя удалить последнее свойство"
        end
    else
        return false, "Неизвестный тип апгрейда: " .. upgradeType
    end
    
    -- Проверка денег
    local cost = self.UPGRADE_COSTS[upgradeType] or 500
    local money = char:GetMoney()
    if money < cost then
        return false, "Недостаточно денег: нужно " .. cost .. ", есть " .. money
    end
    
    return true, cost
end

-- ============================================================================
-- ЗАПУСК АПГРЕЙДА
-- ============================================================================

function PLUGIN:StartVirusUpgrade(client, index, upgradeType, prop)
    local canUpgrade, costOrError = self:CanUpgradeVirus(client, index, upgradeType, prop)
    
    if not canUpgrade then
        return false, costOrError
    end
    
    local char = client:GetCharacter()
    local charID = char:GetID()
    local virus = self.viruses[charID][index]
    
    -- Генерируем лабиринт
    local maze = self:GenerateMaze(20, 20)
    
    -- Сохраняем данные апгрейда
    self.activeHacks[charID] = {
        type = "virus_upgrade",
        index = index,
        upgradeType = upgradeType,
        prop = prop,
        cost = costOrError,
        maze = maze,
        startTime = CurTime()
    }
    
    -- Отправляем клиенту
    net.Start("ixMazeUpgradeGame")
        net.WriteUInt(index, 8)
        net.WriteString(upgradeType)
        net.WriteString(prop)
        net.WriteUInt(costOrError, 16)
        net.WriteTable(maze)
    net.Send(client)
    
    return true
end

function PLUGIN:StartAntivirusUpgrade(client, index, upgradeType, prop)
    local canUpgrade, costOrError = self:CanUpgradeAntivirus(client, index, upgradeType, prop)
    
    if not canUpgrade then
        return false, costOrError
    end
    
    local char = client:GetCharacter()
    local charID = char:GetID()
    local antivirus = self.antiviruses[charID][index]
    
    -- Генерируем лабиринт
    local maze = self:GenerateMaze(20, 20)
    
    -- Сохраняем данные апгрейда
    self.activeHacks[charID] = {
        type = "antivirus_upgrade",
        index = index,
        upgradeType = upgradeType,
        prop = prop,
        cost = costOrError,
        maze = maze,
        startTime = CurTime()
    }
    
    -- Отправляем клиенту
    net.Start("ixMazeUpgradeGame")
        net.WriteUInt(index, 8)
        net.WriteString(upgradeType)
        net.WriteString(prop)
        net.WriteUInt(costOrError, 16)
        net.WriteTable(maze)
    net.Send(client)
    
    return true
end

-- ============================================================================
-- ПРИМЕНЕНИЕ АПГРЕЙДА
-- ============================================================================

function PLUGIN:ApplyVirusUpgrade(client, success)
    local char = client:GetCharacter()
    if not char then return end
    
    local charID = char:GetID()
    local upgradeData = self.activeHacks[charID]
    
    if not upgradeData or upgradeData.type ~= "virus_upgrade" then
        return
    end
    
    if not success then
        client:Notify("Апгрейд провален!")
        self.activeHacks[charID] = nil
        return
    end
    
    local virus = self.viruses[charID] and self.viruses[charID][upgradeData.index]
    if not virus then
        client:Notify("Вирус не найден!")
        self.activeHacks[charID] = nil
        return
    end
    
    -- Списываем деньги
    char:TakeMoney(upgradeData.cost)
    
    -- Применяем апгрейд
    local upgradeType = upgradeData.upgradeType
    local prop = upgradeData.prop
    
    if upgradeType == "add" then
        table.insert(virus.props, prop)
        client:Notify("Свойство '" .. prop .. "' добавлено!")
        
    elseif upgradeType == "stack" then
        table.insert(virus.props, prop)
        client:Notify("Стак свойства '" .. prop .. "' увеличен!")
        
    elseif upgradeType == "remove" then
        local newProps = {}
        local removed = false
        for _, p in ipairs(virus.props) do
            if p == prop and not removed then
                removed = true
            else
                table.insert(newProps, p)
            end
        end
        virus.props = newProps
        client:Notify("Свойство '" .. prop .. "' удалено!")
    end
    
    -- Обновляем метаданные
    virus.lastUpgradeTime = CurTime()
    virus.upgradesUsed = (virus.upgradesUsed or 0) + 1
    
    self:SaveViruses()
    self.activeHacks[charID] = nil
end

function PLUGIN:ApplyAntivirusUpgrade(client, success)
    local char = client:GetCharacter()
    if not char then return end
    
    local charID = char:GetID()
    local upgradeData = self.activeHacks[charID]
    
    if not upgradeData or upgradeData.type ~= "antivirus_upgrade" then
        return
    end
    
    if not success then
        client:Notify("Апгрейд провален!")
        self.activeHacks[charID] = nil
        return
    end
    
    local antivirus = self.antiviruses[charID] and self.antiviruses[charID][upgradeData.index]
    if not antivirus then
        client:Notify("Антивирус не найден!")
        self.activeHacks[charID] = nil
        return
    end
    
    -- Списываем деньги
    char:TakeMoney(upgradeData.cost)
    
    -- Применяем апгрейд
    local upgradeType = upgradeData.upgradeType
    local prop = upgradeData.prop
    
    if upgradeType == "add" then
        table.insert(antivirus.props, prop)
        client:Notify("Свойство '" .. prop .. "' добавлено!")
        
    elseif upgradeType == "stack" then
        table.insert(antivirus.props, prop)
        client:Notify("Стак свойства '" .. prop .. "' увеличен!")
        
    elseif upgradeType == "remove" then
        local newProps = {}
        local removed = false
        for _, p in ipairs(antivirus.props) do
            if p == prop and not removed then
                removed = true
            else
                table.insert(newProps, p)
            end
        end
        antivirus.props = newProps
        client:Notify("Свойство '" .. prop .. "' удалено!")
    end
    
    -- Обновляем метаданные
    antivirus.lastUpgradeTime = CurTime()
    antivirus.upgradesUsed = (antivirus.upgradesUsed or 0) + 1
    
    self:SaveAntiviruses()
    self.activeHacks[charID] = nil
end

-- ============================================================================
-- ГЕНЕРАЦИЯ ЛАБИРИНТА
-- ============================================================================

function PLUGIN:GenerateMaze(width, height)
    -- Алгоритм Recursive Backtracking
    local maze = {}
    
    -- Инициализация: все стены
    for y = 1, height do
        maze[y] = {}
        for x = 1, width do
            maze[y][x] = 1 -- 1 = стена, 0 = проход
        end
    end
    
    -- Рекурсивная функция для вырезания проходов
    local function carve(x, y)
        maze[y][x] = 0
        
        local directions = {
            {0, -2}, -- вверх
            {0, 2},  -- вниз
            {-2, 0}, -- влево
            {2, 0}   -- вправо
        }
        
        -- Перемешиваем направления
        for i = #directions, 2, -1 do
            local j = math.random(1, i)
            directions[i], directions[j] = directions[j], directions[i]
        end
        
        for _, dir in ipairs(directions) do
            local nx, ny = x + dir[1], y + dir[2]
            
            if nx > 1 and nx < width and ny > 1 and ny < height and maze[ny][nx] == 1 then
                maze[y + dir[2] / 2][x + dir[1] / 2] = 0 -- Убираем стену между
                carve(nx, ny)
            end
        end
    end
    
    -- Начинаем с (2, 2)
    carve(2, 2)
    
    -- Устанавливаем старт и финиш
    maze[2][2] = 2 -- 2 = старт
    maze[height - 1][width - 1] = 3 -- 3 = финиш
    
    -- Убеждаемся, что финиш доступен
    maze[height - 2][width - 1] = 0
    maze[height - 1][width - 2] = 0
    
    return maze
end

-- ============================================================================
-- СЕТЕВЫЕ СООБЩЕНИЯ
-- ============================================================================

net.Receive("ixMazeUpgradeResult", function(len, client)
    local success = net.ReadBool()
    local char = client:GetCharacter()
    if not char then return end
    
    local charID = char:GetID()
    local upgradeData = PLUGIN.activeHacks[charID]
    
    if not upgradeData then
        client:Notify("Нет активного апгрейда")
        return
    end
    
    if upgradeData.type == "virus_upgrade" then
        PLUGIN:ApplyVirusUpgrade(client, success)
    elseif upgradeData.type == "antivirus_upgrade" then
        PLUGIN:ApplyAntivirusUpgrade(client, success)
    end
end)

-- Запрос на апгрейд вируса
net.Receive("ixVirusUpgradeUI", function(len, client)
    local index = net.ReadUInt(8)
    local upgradeType = net.ReadString()
    local prop = net.ReadString()
    
    local success, msg = PLUGIN:StartVirusUpgrade(client, index, upgradeType, prop)
    
    if not success then
        client:Notify(msg)
    end
end)

-- Запрос на апгрейд антивируса
net.Receive("ixAntivirusUpgradeUI", function(len, client)
    local index = net.ReadUInt(8)
    local upgradeType = net.ReadString()
    local prop = net.ReadString()
    
    local success, msg = PLUGIN:StartAntivirusUpgrade(client, index, upgradeType, prop)
    
    if not success then
        client:Notify(msg)
    end
end)

-- ============================================================================
-- КОМАНДЫ ТЕРМИНАЛА
-- ============================================================================

-- Добавляем hook для обработки команд апгрейда
hook.Add("BigTerminalProcessCommand", "UpgradeCommands", function(client, cmd, args, output)
    -- Используем PLUGIN напрямую, т.к. файл подключается к плагину
    if not PLUGIN then 
        print("[UpgradeCommands] PLUGIN not found!")
        return false 
    end
    
    print("[UpgradeCommands] Processing command: " .. cmd)
    
    local char = client:GetCharacter()
    if not char then return false end
    local charID = char:GetID()
    
    local argsTable = string.Explode(" ", args)
    local arg1 = argsTable[1] or ""
    local arg2 = argsTable[2] or ""
    local arg3 = argsTable[3] or ""
    
    if cmd == "virus_upgrade" then
        print("[UpgradeCommands] virus_upgrade detected")
        local index = tonumber(arg1)
        local upgradeType = arg2
        local prop = arg3
        
        if not index or not upgradeType or not prop then
            table.insert(output, "[ОШИБКА] Использование: virus_upgrade <номер> <тип> <свойство>")
            table.insert(output, "Типы: add (добавить), stack (усилить), remove (удалить)")
            return true
        end
        
        local success, msg = PLUGIN:StartVirusUpgrade(client, index, upgradeType, prop)
        
        if success then
            table.insert(output, "[СИСТЕМА] Запуск мини-игры апгрейда...")
            table.insert(output, "Стоимость: " .. msg .. " кредитов")
        else
            table.insert(output, "[ОШИБКА] " .. msg)
        end
        return true
        
    elseif cmd == "antivirus_upgrade" then
        print("[UpgradeCommands] antivirus_upgrade detected")
        local index = tonumber(arg1)
        local upgradeType = arg2
        local prop = arg3
        
        if not index or not upgradeType or not prop then
            table.insert(output, "[ОШИБКА] Использование: antivirus_upgrade <номер> <тип> <свойство>")
            table.insert(output, "Типы: add (добавить), stack (усилить), remove (удалить)")
            return true
        end
        
        local success, msg = PLUGIN:StartAntivirusUpgrade(client, index, upgradeType, prop)
        
        if success then
            table.insert(output, "[СИСТЕМА] Запуск мини-игры апгрейда...")
            table.insert(output, "Стоимость: " .. msg .. " кредитов")
        else
            table.insert(output, "[ОШИБКА] " .. msg)
        end
        return true
    end
    
    return false
end)

-- ============================================================================
-- СВОЙСТВА АНТИВИРУСОВ
-- Каждый антивирус может иметь до 3 свойств
-- Свойства стакаются и взаимодействуют друг с другом
-- ============================================================================

local PLUGIN = PLUGIN

-- Таблица свойств антивирусов
PLUGIN.antivirusProperties = PLUGIN.antivirusProperties or {}

-- ============================================================================
-- БАЗОВЫЕ СВОЙСТВА (уровень 15+)
-- ============================================================================

PLUGIN.antivirusProperties.scanner = {
    id = "scanner",
    name = "Сканер",
    description = "Автоматически обнаруживает вирусы на точке (сокращает время скана на 30%).",
    effect = "scanner",
    stackable = true,
    maxStacks = 3,
    minLevel = 15,
    category = "detection",
    scanReduction = 0.3
}

PLUGIN.antivirusProperties.cleaner = {
    id = "cleaner",
    name = "Очиститель",
    description = "Удаляет вирусы с точки при установке (шанс 50% за стак).",
    effect = "cleaner",
    stackable = true,
    maxStacks = 3,
    minLevel = 15,
    category = "removal",
    cleanChance = 0.5
}

PLUGIN.antivirusProperties.blocker = {
    id = "blocker",
    name = "Блокировщик",
    description = "Затрудняет установку вирусов на точку (+30% к сложности за стак).",
    effect = "blocker",
    stackable = true,
    maxStacks = 3,
    minLevel = 15,
    category = "protection",
    blockChance = 0.3
}

PLUGIN.antivirusProperties.trap = {
    id = "trap",
    name = "Ловушка",
    description = "При попытке взлома точки наносит урон (10) взломщику.",
    effect = "trap",
    stackable = true,
    maxStacks = 5,
    minLevel = 15,
    category = "counter",
    damage = 10
}

PLUGIN.antivirusProperties.durable = {
    id = "durable",
    name = "Прочный",
    description = "Увеличивает долговечность антивируса на 1 заряд.",
    effect = "durable",
    stackable = true,
    maxStacks = 5,
    minLevel = 15,
    category = "utility",
    extraCharges = 1
}

PLUGIN.antivirusProperties.regen = {
    id = "regen",
    name = "Регенерация",
    description = "Восстанавливает 1 заряд каждые 2 часа (максимум 3 заряда).",
    effect = "regen",
    stackable = false,
    minLevel = 25,
    category = "utility",
    regenInterval = 7200, -- 2 часа
    maxRegenCharges = 3
}

PLUGIN.antivirusProperties.alert = {
    id = "alert",
    name = "Оповещение",
    description = "Отправляет владельцу уведомление при попытке взлома.",
    effect = "alert",
    stackable = false,
    minLevel = 15,
    category = "utility"
}

-- ============================================================================
-- СРЕДНИЕ СВОЙСТВА (уровень 20+)
-- ============================================================================

PLUGIN.antivirusProperties.ice_wall = {
    id = "ice_wall",
    name = "Лёд-стена",
    description = "Защищает от скриптов нетраннинга (ICE) - +40% к блоку скриптов.",
    effect = "ice_wall",
    stackable = true,
    maxStacks = 3,
    minLevel = 20,
    category = "protection",
    iceBlockBonus = 0.4
}

PLUGIN.antivirusProperties.feedback = {
    id = "feedback",
    name = "Обратная связь",
    description = "Отражает 30% урона ловушки обратно атакующему.",
    effect = "feedback",
    stackable = true,
    maxStacks = 3,
    minLevel = 20,
    category = "counter",
    reflectPercent = 0.3
}

PLUGIN.antivirusProperties.auto_repair = {
    id = "auto_repair",
    name = "Авто-ремонт",
    description = "Восстанавливает 1 HP точки каждые 30 секунд.",
    effect = "auto_repair",
    stackable = false,
    minLevel = 20,
    category = "utility",
    healInterval = 30,
    healAmount = 1
}

PLUGIN.antivirusProperties.blood_shield = {
    id = "blood_shield",
    name = "Кровяной щит",
    description = "Защищает от эффекта кровотечения (иммунитет).",
    effect = "blood_shield",
    stackable = false,
    minLevel = 20,
    category = "immunity"
}

PLUGIN.antivirusProperties.neural_firewall = {
    id = "neural_firewall",
    name = "Нейрощит",
    description = "Защищает навыки от снижения вирусами на 60 секунд.",
    effect = "neural_firewall",
    stackable = false,
    minLevel = 20,
    category = "protection",
    duration = 60
}

PLUGIN.antivirusProperties.stamina_boost = {
    id = "stamina_boost",
    name = "Энергощит",
    description = "Компенсирует истощение выносливости (+20% к максимуму).",
    effect = "stamina_boost",
    stackable = true,
    maxStacks = 3,
    minLevel = 20,
    category = "buff",
    staminaBonus = 0.2
}

-- ============================================================================
-- ПРОДВИНУТЫЕ СВОЙСТВА (уровень 25+)
-- ============================================================================

PLUGIN.antivirusProperties.memory_shield = {
    id = "memory_shield",
    name = "Щит памяти",
    description = "Полная защита от прослушки (spy virus).",
    effect = "memory_shield",
    stackable = false,
    minLevel = 25,
    category = "immunity"
}

-- heal_aura УДАЛЁН

PLUGIN.antivirusProperties.quarantine = {
    id = "quarantine",
    name = "Карантин",
    description = "Изолирует заражённые файлы - вирус не активируется 30 сек.",
    effect = "quarantine",
    stackable = false,
    minLevel = 25,
    category = "protection",
    delayTime = 30
}

PLUGIN.antivirusProperties.purifier = {
    id = "purifier",
    name = "Очиститель",
    description = "Удаляет 1 негативный эффект с владельца при установке.",
    effect = "purifier",
    stackable = true,
    maxStacks = 3,
    minLevel = 25,
    category = "removal",
    removeCount = 1
}

-- immunizer УДАЛЁН

-- ============================================================================
-- ЭКСПЕРТНЫЕ СВОЙСТВА (уровень 30+)
-- ============================================================================

PLUGIN.antivirusProperties.overwatch = {
    id = "overwatch",
    name = "Перехват",
    description = "Копирует вирус и отправляет его создателю (шанс 20%).",
    effect = "overwatch",
    stackable = false,
    minLevel = 30,
    category = "counter",
    stealChance = 0.2
}

PLUGIN.antivirusProperties.black_ice = {
    id = "black_ice",
    name = "Чёрный лёд",
    description = "При обнаружении взломщика - наносит 50 урона и поджигает.",
    effect = "black_ice",
    stackable = false,
    minLevel = 30,
    category = "counter",
    damage = 50,
    burnDuration = 4
}

PLUGIN.antivirusProperties.synthesis = {
    id = "synthesis",
    name = "Синтез",
    description = "Превращает вирус в антивирус (шанс 10%).",
    effect = "synthesis",
    stackable = false,
    minLevel = 30,
    category = "conversion",
    convertChance = 0.1
}

-- multicore УДАЛЁН

PLUGIN.antivirusProperties.entropy = {
    id = "entropy",
    name = "Энтропия",
    description = "Вирусы теряют 1 стак каждый раз при активации.",
    effect = "entropy",
    stackable = false,
    minLevel = 30,
    category = "debuff"
}

-- ============================================================================
-- ФУНКЦИИ ОБРАБОТКИ СВОЙСТВ АНТИВИРУСОВ
-- ============================================================================

-- Получить список доступных свойств для уровня
function PLUGIN:GetAntivirusPropertyPool(creatorLevel)
    local pool = {}
    for id, prop in pairs(self.antivirusProperties) do
        if creatorLevel >= (prop.minLevel or 0) then
            table.insert(pool, id)
        end
    end
    return pool
end

-- Проверить, есть ли свойство у антивируса
function PLUGIN:AntivirusHasProperty(antivirus, propId)
    if not antivirus or not antivirus.props then return false end
    for _, p in ipairs(antivirus.props) do
        if p == propId then return true end
    end
    return false
end

-- Получить количество стаков свойства
function PLUGIN:GetAntivirusPropertyStacks(antivirus, propId)
    if not antivirus or not antivirus.props then return 0 end
    local count = 0
    for _, p in ipairs(antivirus.props) do
        if p == propId then
            count = count + 1
        end
    end
    return count
end

-- Вычислить базовые заряды антивируса
function PLUGIN:CalculateAntivirusCharges(antivirus)
    local baseCharges = 3
    local durableStacks = self:GetAntivirusPropertyStacks(antivirus, "durable")
    return baseCharges + durableStacks
end

-- Проверить, блокирует ли антивирус вирус
function PLUGIN:WillAntivirusBlockVirus(antivirus, virus)
    if not antivirus or not antivirus.props then return false, 0 end
    
    local blockChance = 0
    local blockerStacks = self:GetAntivirusPropertyStacks(antivirus, "blocker")
    if blockerStacks > 0 then
        local prop = self.antivirusProperties.blocker
        blockChance = blockChance + (prop.blockChance * blockerStacks)
    end
    
    -- Scanner увеличивает шанс блокировки
    local scannerStacks = self:GetAntivirusPropertyStacks(antivirus, "scanner")
    if scannerStacks > 0 then
        blockChance = blockChance + (0.1 * scannerStacks)
    end
    
    -- ICE Wall увеличивает защиту от скриптов
    local iceStacks = self:GetAntivirusPropertyStacks(antivirus, "ice_wall")
    if iceStacks > 0 then
        local prop = self.antivirusProperties.ice_wall
        blockChance = blockChance + (prop.iceBlockBonus * iceStacks)
    end
    
    return math.random() < blockChance, blockChance
end

-- Проверить, удаляет ли антивирус вирус
function PLUGIN:WillAntivirusCleanVirus(antivirus)
    if not antivirus or not antivirus.props then return false end
    
    local cleanerStacks = self:GetAntivirusPropertyStacks(antivirus, "cleaner")
    if cleanerStacks == 0 then return false end
    
    local prop = self.antivirusProperties.cleaner
    local cleanChance = prop.cleanChance * cleanerStacks
    
    return math.random() < cleanChance
end

-- Проверить иммунитет к эффекту
function PLUGIN:HasAntivirusImmunity(antivirus, effectId)
    if not antivirus or not antivirus.props then return false end
    
    -- Базовые иммунитеты
    if effectId == "bleed" and self:AntivirusHasProperty(antivirus, "blood_shield") then
        return true
    end
    
    if (effectId == "memory_corrupt" or effectId == "spy") and self:AntivirusHasProperty(antivirus, "memory_shield") then
        return true
    end
    
    -- Иммунизатор даёт временный иммунитет ко всему
    if self:AntivirusHasProperty(antivirus, "immunizer") then
        local data = self.accessPointAntiviruses[antivirus.code]
        if data and data.immunityEnd and CurTime() < data.immunityEnd then
            return true
        end
    end
    
    return false
end

-- Проверить, активирует ли антивирус карантин
function PLUGIN:WillAntivirusQuarantineVirus(antivirus)
    if not antivirus then return false, 0 end
    
    if not self:AntivirusHasProperty(antivirus, "quarantine") then return false, 0 end
    
    local prop = self.antivirusProperties.quarantine
    return true, prop.delayTime
end

-- Проверить синтез вируса
function PLUGIN:WillAntivirusSynthesize(antivirus)
    if not antivirus then return false end
    
    if not self:AntivirusHasProperty(antivirus, "synthesis") then return false end
    
    local prop = self.antivirusProperties.synthesis
    return math.random() < prop.convertChance
end

-- Проверить перехват вируса
function PLUGIN:WillAntivirusOverwatch(antivirus)
    if not antivirus then return false end
    
    if not self:AntivirusHasProperty(antivirus, "overwatch") then return false end
    
    local prop = self.antivirusProperties.overwatch
    return math.random() < prop.stealChance
end

-- Применить эффект ловушки
function PLUGIN:ApplyAntivirusTrap(antivirus, attacker, accessPoint)
    if not antivirus or not antivirus.props then return end
    
    local trapStacks = self:GetAntivirusPropertyStacks(antivirus, "trap")
    if trapStacks == 0 then return end
    
    local prop = self.antivirusProperties.trap
    local damage = prop.damage * trapStacks
    
    -- Проверяем обратную связь
    local feedbackStacks = self:GetAntivirusPropertyStacks(antivirus, "feedback")
    local reflectedDamage = 0
    if feedbackStacks > 0 then
        local feedbackProp = self.antivirusProperties.feedback
        reflectedDamage = damage * feedbackProp.reflectPercent * feedbackStacks
    end
    
    if IsValid(attacker) then
        attacker:TakeDamage(damage, accessPoint, accessPoint)
        attacker:Notify("Ловушка антивируса нанесла вам " .. damage .. " урона!")
        
        -- Отражённый урон
        if reflectedDamage > 0 then
            local owner = accessPoint:GetOwner()
            if IsValid(owner) then
                owner:TakeDamage(reflectedDamage, attacker, attacker)
                attacker:Notify("Обратная связь нанесла " .. math.floor(reflectedDamage) .. " урона владельцу!")
            end
        end
    end
end

-- Применить чёрный лёд
function PLUGIN:ApplyBlackIce(antivirus, attacker, accessPoint)
    if not antivirus then return end
    
    if not self:AntivirusHasProperty(antivirus, "black_ice") then return end
    
    local prop = self.antivirusProperties.black_ice
    
    if IsValid(attacker) then
        attacker:TakeDamage(prop.damage, accessPoint, accessPoint)
        attacker:Ignite(prop.burnDuration, 0)
        attacker:EmitSound("ambient/energy/zap1.wav")
        attacker:Notify("ЧЁРНЫЙ ЛЁД! Вы получили " .. prop.damage .. " урона и горите!")
    end
end

-- Применить эффект очистителя
function PLUGIN:ApplyPurifierEffect(antivirus, target)
    if not antivirus or not IsValid(target) then return end
    
    local purifierStacks = self:GetAntivirusPropertyStacks(antivirus, "purifier")
    if purifierStacks == 0 then return end
    
    local prop = self.antivirusProperties.purifier
    local removeCount = prop.removeCount * purifierStacks
    
    -- Удаляем негативные эффекты
    local removed = 0
    
    if target.ixStaminaDrain and removed < removeCount then
        target.ixStaminaDrain = nil
        removed = removed + 1
        target:Notify("Истощение снято!")
    end
    
    if target.ixHallucination and removed < removeCount then
        target.ixHallucination = nil
        target:SetNWBool("ixHallucination", false)
        removed = removed + 1
        target:Notify("Галлюцинации сняты!")
    end
    
    if target.ixHungerAccelerate and removed < removeCount then
        target.ixHungerAccelerate = nil
        removed = removed + 1
        target:Notify("Метаболизм нормализован!")
    end
    
    if target.ixRadioJammed and CurTime() < target.ixRadioJammed and removed < removeCount then
        target.ixRadioJammed = nil
        removed = removed + 1
        target:Notify("Радио разблокировано!")
    end
    
    if target.ixNeuralDisrupt and removed < removeCount then
        target.ixNeuralDisrupt = nil
        removed = removed + 1
        target:Notify("Нейронные связи восстановлены!")
    end
    
    if target.ixMedicalSuppressed and CurTime() < target.ixMedicalSuppressed and removed < removeCount then
        target.ixMedicalSuppressed = nil
        removed = removed + 1
        target:Notify("Регенерация разблокирована!")
    end
    
    if target.ixCyberpsychosis and removed < removeCount then
        target.ixCyberpsychosis = nil
        target:SetNWBool("ixCyberpsychosis", false)
        removed = removed + 1
        target:Notify("Киберпсихоз подавлен!")
    end
end

-- Применить эффект энергощита
function PLUGIN:ApplyStaminaBoost(antivirus, target)
    if not antivirus or not IsValid(target) then return end
    
    local stacks = self:GetAntivirusPropertyStacks(antivirus, "stamina_boost")
    if stacks == 0 then return end
    
    local prop = self.antivirusProperties.stamina_boost
    local bonus = prop.staminaBonus * stacks
    
    target.ixStaminaBoost = bonus
    target:Notify("Выносливость усилена на " .. math.floor(bonus * 100) .. "%!")
end

-- Применить эффект лечащего поля
function PLUGIN:ProcessHealAura(antivirus, owner)
    if not antivirus or not IsValid(owner) then return end
    
    if not self:AntivirusHasProperty(antivirus, "heal_aura") then return end
    
    local stacks = self:GetAntivirusPropertyStacks(antivirus, "heal_aura")
    local prop = self.antivirusProperties.heal_aura
    
    local healAmount = prop.healAmount * stacks
    local currentHealth = owner:Health()
    local maxHealth = owner:GetMaxHealth()
    local newHealth = math.min(currentHealth + healAmount, maxHealth)
    
    owner:SetHealth(newHealth)
    owner:Notify("Лечащее поле восстановило " .. healAmount .. " HP")
end

-- Применить энтропию к вирусу
function PLUGIN:ApplyEntropyToVirus(antivirus, virus)
    if not antivirus or not virus then return virus end
    
    if not self:AntivirusHasProperty(antivirus, "entropy") then return virus end
    
    -- Удаляем 1 стак с каждого свойства
    if virus.props and #virus.props > 0 then
        local newProps = {}
        local removed = {}
        
        for _, propId in ipairs(virus.props) do
            if not removed[propId] then
                removed[propId] = true
                -- Пропускаем первое вхождение (удаляем 1 стак)
            else
                table.insert(newProps, propId)
            end
        end
        
        virus.props = newProps
    end
    
    return virus
end

-- Отправить оповещение владельцу
function PLUGIN:SendAntivirusAlert(antivirus, attacker, accessPoint)
    if not antivirus then return end
    
    if not self:AntivirusHasProperty(antivirus, "alert") then return end
    
    local ownerId = accessPoint:GetOwnerID()
    local ownerChar = ix.char.loaded[ownerId]
    
    if ownerChar then
        local owner = ownerChar:GetPlayer()
        if IsValid(owner) then
            local attackerName = IsValid(attacker) and attacker:Name() or "Неизвестный"
            owner:Notify("Взлом вашей точки доступа! Злоумышленник: " .. attackerName)
        end
    end
end

-- Получить время сканирования с учётом антивируса
function PLUGIN:GetAntivirusScanTime(antivirus, baseTime)
    if not antivirus then return baseTime end
    
    local scannerStacks = self:GetAntivirusPropertyStacks(antivirus, "scanner")
    if scannerStacks == 0 then return baseTime end
    
    local prop = self.antivirusProperties.scanner
    local reduction = prop.scanReduction * scannerStacks
    
    return baseTime * (1 - reduction)
end

-- Обработка регенерации зарядов
function PLUGIN:ProcessAntivirusRegen(antivirus, code)
    if not antivirus or not antivirus.props then return end
    
    if not self:AntivirusHasProperty(antivirus, "regen") then return end
    
    local data = self.accessPointAntiviruses[code]
    if not data then return end
    
    local prop = self.antivirusProperties.regen
    local maxCharges = self:CalculateAntivirusCharges(antivirus)
    
    -- Проверяем, прошло ли время регенерации
    data.lastRegen = data.lastRegen or CurTime()
    
    -- Проверяем, не превышен ли максимум регенерированных зарядов
    data.regenCharges = data.regenCharges or 0
    
    if CurTime() - data.lastRegen >= prop.regenInterval then
        if data.charges < maxCharges and data.regenCharges < prop.maxRegenCharges then
            data.charges = data.charges + 1
            data.regenCharges = data.regenCharges + 1
            data.lastRegen = CurTime()
            self:SaveAccessPointAntiviruses()
        end
    end
end

-- Обработка авто-ремонта точки
function PLUGIN:ProcessAutoRepair(antivirus, accessPoint)
    if not antivirus or not IsValid(accessPoint) then return end
    
    if not self:AntivirusHasProperty(antivirus, "auto_repair") then return end
    
    local prop = self.antivirusProperties.auto_repair
    local data = self.accessPointAntiviruses[accessPoint:GetAccessCode()]
    
    if not data then return end
    
    data.lastRepair = data.lastRepair or CurTime()
    
    if CurTime() - data.lastRepair >= prop.healInterval then
        local currentHealth = accessPoint:GetNWInt("health", 100)
        local maxHealth = 100
        local newHealth = math.min(currentHealth + prop.healAmount, maxHealth)
        accessPoint:SetNWInt("health", newHealth)
        data.lastRepair = CurTime()
    end
end

-- Активировать имунизатор
function PLUGIN:ActivateImmunizer(antivirus, code)
    if not antivirus then return end
    
    if not self:AntivirusHasProperty(antivirus, "immunizer") then return end
    
    local prop = self.antivirusProperties.immunizer
    local data = self.accessPointAntiviruses[code]
    
    if data then
        data.immunityEnd = CurTime() + prop.immunityDuration
    end
end

-- Применить мультиядро (распространить эффекты на всех подключённых)
function PLUGIN:ApplyMulticoreEffect(antivirus, accessPoint, effectFunc)
    if not antivirus or not IsValid(accessPoint) then return end
    
    if not self:AntivirusHasProperty(antivirus, "multicore") then return end
    
    -- Получаем всех подключённых к точке
    local connected = accessPoint:GetConnectedPlayers() or {}
    
    for _, client in ipairs(connected) do
        if IsValid(client) and client:IsPlayer() then
            effectFunc(client)
        end
    end
end

-- Получить описание антивируса с учётом стаков
function PLUGIN:GetAntivirusDescription(antivirus)
    if not antivirus or not antivirus.props then return "Нет свойств" end
    
    local desc = {}
    local processedProps = {}
    
    for _, propId in ipairs(antivirus.props) do
        if not processedProps[propId] then
            local prop = self.antivirusProperties[propId]
            if prop then
                local stacks = self:GetAntivirusPropertyStacks(antivirus, propId)
                local stackText = stacks > 1 and string.format(" (x%d)", stacks) or ""
                table.insert(desc, prop.name .. stackText .. ": " .. prop.description)
                processedProps[propId] = true
            end
        end
    end
    
    local charges = self:CalculateAntivirusCharges(antivirus)
    table.insert(desc, "Зарядов: " .. charges)
    
    return table.concat(desc, "\n")
end

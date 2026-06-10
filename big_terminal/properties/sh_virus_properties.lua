-- ============================================================================
-- СВОЙСТВА ВИРУСОВ
-- Каждый вирус может иметь до 3 свойств
-- Свойства стакаются и взаимодействуют друг с другом
-- ============================================================================

local PLUGIN = PLUGIN

-- Таблица свойств вирусов
PLUGIN.virusProperties = PLUGIN.virusProperties or {}

-- ============================================================================
-- БАЗОВЫЕ СВОЙСТВА (доступны всем, уровень 0+)
-- ============================================================================

PLUGIN.virusProperties.ransomware = {
    id = "ransomware",
    name = "Вымогатель",
    description = "Отнимает у жертвы 2% денег при активации.",
    effect = "ransomware",
    stackable = true,
    maxStacks = 3,
    minLevel = 0,
    category = "basic"
}

PLUGIN.virusProperties.glitch = {
    id = "glitch",
    name = "Глич",
    description = "Накладывает 3 случайных эффекта из User_hack на жертву.",
    effect = "glitch",
    stackable = false,
    minLevel = 0,
    category = "basic"
}

PLUGIN.virusProperties.spy = {
    id = "spy",
    name = "Прослушка",
    description = "Дублирует сообщения жертвы в терминал хакера (10 сек).",
    effect = "spy",
    stackable = true,
    maxStacks = 3,
    minLevel = 0,
    category = "basic",
    duration = 10
}

PLUGIN.virusProperties.noise = {
    id = "noise",
    name = "Шум",
    description = "Упрощает обнаружение (-30 сек к скану), но усиливает другие свойства в 2 раза.",
    effect = "noise",
    stackable = false,
    minLevel = 0,
    category = "modifier",
    scanPenalty = 30,
    damageMultiplier = 2.0
}

PLUGIN.virusProperties.silent = {
    id = "silent",
    name = "Тишина",
    description = "Затрудняет обнаружение (20% шанс не обнаружить), но ослабляет другие свойства в 2 раза.",
    effect = "silent",
    stackable = true,
    maxStacks = 5,
    minLevel = 0,
    category = "modifier",
    stealthChance = 0.2,
    damageMultiplier = 0.5
}

PLUGIN.virusProperties.shock = {
    id = "shock",
    name = "Замыкание",
    description = "Наносит 10 урона шоком при активации.",
    effect = "shock",
    stackable = true,
    maxStacks = 5,
    minLevel = 0,
    category = "damage",
    baseDamage = 10
}

PLUGIN.virusProperties.informant = {
    id = "informant",
    name = "Информатор",
    description = "Показывает расстояние до ближайших точек доступа (радиус 1000).",
    effect = "informant",
    stackable = false,
    minLevel = 0,
    category = "utility",
    radius = 1000
}

PLUGIN.virusProperties.slow = {
    id = "slow",
    name = "Замедление",
    description = "Замедляет скорость передвижения жертвы на 20% на 10 секунд.",
    effect = "slow",
    stackable = true,
    maxStacks = 5,
    minLevel = 0,
    category = "debuff",
    slowPercent = 0.2,
    duration = 10
}

PLUGIN.virusProperties.blind = {
    id = "blind",
    name = "Ослепление",
    description = "Накладывает эффект reboot optics (слепота) на 5 секунд.",
    effect = "blind",
    stackable = true,
    maxStacks = 3,
    minLevel = 0,
    category = "debuff",
    duration = 5
}

-- ============================================================================
-- СРЕДНИЕ СВОЙСТВА (требуют уровень 15+)
-- ============================================================================

PLUGIN.virusProperties.stamina_drain = {
    id = "stamina_drain",
    name = "Истощение",
    description = "Снижает максимальную выносливость жертвы на 30% на 30 секунд.",
    effect = "stamina_drain",
    stackable = true,
    maxStacks = 3,
    minLevel = 15,
    category = "debuff",
    drainPercent = 0.3,
    duration = 30
}

PLUGIN.virusProperties.bleed = {
    id = "bleed",
    name = "Кровотечение",
    description = "Вызывает кровотечение у жертвы (1 урон каждые 3 сек, 15 сек).",
    effect = "bleed",
    stackable = true,
    maxStacks = 3,
    minLevel = 15,
    category = "damage",
    damagePerTick = 1,
    tickInterval = 3,
    duration = 15
}

PLUGIN.virusProperties.hallucination = {
    id = "hallucination",
    name = "Галлюцинации",
    description = "Вызывает визуальные искажения у жертвы на 20 секунд.",
    effect = "hallucination",
    stackable = false,
    minLevel = 15,
    category = "debuff",
    duration = 20
}

PLUGIN.virusProperties.hunger_accel = {
    id = "hunger_accel",
    name = "Метаболизм",
    description = "Ускоряет голод и жажду жертвы в 3 раза на 60 секунд.",
    effect = "hunger_accel",
    stackable = false,
    minLevel = 15,
    category = "debuff",
    multiplier = 3,
    duration = 60
}

PLUGIN.virusProperties.radio_jammer = {
    id = "radio_jammer",
    name = "Глушитель",
    description = "Блокирует радио связь жертвы на 30 секунд.",
    effect = "radio_jammer",
    stackable = false,
    minLevel = 15,
    category = "debuff",
    duration = 30
}

PLUGIN.virusProperties.mirror = {
    id = "mirror",
    name = "Зеркало",
    description = "Отражает 25% урона обратно атакующему в течение 30 секунд.",
    effect = "mirror",
    stackable = true,
    maxStacks = 4,
    minLevel = 15,
    category = "counter",
    reflectPercent = 0.25,
    duration = 30
}

-- ============================================================================
-- ПРОДВИНУТЫЕ СВОЙСТВА (требуют уровень 25+)
-- ============================================================================

PLUGIN.virusProperties.neural_disruptor = {
    id = "neural_disruptor",
    name = "Нейронарушитель",
    description = "Временно снижает случайный навык жертвы на 2 уровня (60 сек).",
    effect = "neural_disruptor",
    stackable = true,
    maxStacks = 3,
    minLevel = 25,
    category = "debuff",
    skillReduction = 2,
    duration = 60
}

PLUGIN.virusProperties.synapse_burn = {
    id = "synapse_burn",
    name = "Синаптический ожог",
    description = "Наносит 30 урона и поджигает жертву на 4 секунды.",
    effect = "synapse_burn",
    stackable = true,
    maxStacks = 3,
    minLevel = 25,
    category = "damage",
    baseDamage = 30,
    burnDuration = 4
}

PLUGIN.virusProperties.medical_suppress = {
    id = "medical_suppress",
    name = "Блокада",
    description = "Блокирует регенерацию здоровья и лечение на 60 секунд.",
    effect = "medical_suppress",
    stackable = false,
    minLevel = 25,
    category = "debuff",
    duration = 60
}

PLUGIN.virusProperties.cyberpsychosis = {
    id = "cyberpsychosis",
    name = "Киберпсихоз",
    description = "Накладывает 20 единиц киберпсихоза на жертву.",
    effect = "cyberpsychosis",
    stackable = true,
    maxStacks = 3,
    minLevel = 25,
    category = "special",
    psychosisAmount = 20
}

-- memory_corrupt УДАЛЁН

-- ============================================================================
-- ЭКСПЕРТНЫЕ СВОЙСТВА (требуют уровень 30+)
-- ============================================================================

PLUGIN.virusProperties.overlock = {
    id = "overlock",
    name = "Перегрузка",
    description = "Увеличивает силу всех эффектов на 20% за каждые 10 уровня создателя (макс 100%).",
    effect = "overlock",
    stackable = false,
    minLevel = 30,
    category = "modifier",
    bonusPerLevels = 10,
    bonusPercent = 0.2,
    maxBonus = 1.0
}

PLUGIN.virusProperties.stealth = {
    id = "stealth",
    name = "Стелс",
    description = "Увеличивает шанс необнаружения на 2% за каждый уровень создателя.",
    effect = "stealth",
    stackable = false,
    minLevel = 30,
    category = "modifier",
    stealthPerLevel = 0.02
}

PLUGIN.virusProperties.analyzer = {
    id = "analyzer",
    name = "Анализатор",
    description = "При активации показывает уровень нетраннинга жертвы и имя хакера (создателя).",
    effect = "analyzer",
    stackable = false,
    minLevel = 30,
    category = "utility"
}

PLUGIN.virusProperties.parasite = {
    id = "parasite",
    name = "Паразит",
    description = "Передаётся на всех, кто подключается к той же точке доступа.",
    effect = "parasite",
    stackable = false,
    minLevel = 30,
    category = "special"
}

PLUGIN.virusProperties.polymorph = {
    id = "polymorph",
    name = "Полиморф",
    description = "Каждый скан показывает разные свойства (обман антивируса).",
    effect = "polymorph",
    stackable = false,
    minLevel = 30,
    category = "stealth"
}

PLUGIN.virusProperties.logic_bomb = {
    id = "logic_bomb",
    name = "Логическая бомба",
    description = "Активируется через 5 минут после установки, нанося 50 урона всем в радиусе 200.",
    effect = "logic_bomb",
    stackable = false,
    minLevel = 30,
    category = "damage",
    delay = 300,
    damage = 50,
    radius = 200
}

PLUGIN.virusProperties.symbiote = {
    id = "symbiote",
    name = "Симбионт",
    description = "Восстанавливает создателю 5 HP каждый раз, когда вирус наносит урон.",
    effect = "symbiote",
    stackable = false,
    minLevel = 30,
    category = "utility",
    healPercent = 0.05
}

-- ============================================================================
-- ФУНКЦИИ ОБРАБОТКИ СВОЙСТВ ВИРУСОВ
-- ============================================================================

-- Получить список доступных свойств для уровня
function PLUGIN:GetVirusPropertyPool(creatorLevel)
    local pool = {}
    for id, prop in pairs(self.virusProperties) do
        if creatorLevel >= (prop.minLevel or 0) then
            table.insert(pool, id)
        end
    end
    return pool
end

-- Проверить, есть ли свойство у вируса
function PLUGIN:VirusHasProperty(virus, propId)
    if not virus or not virus.props then return false end
    for _, p in ipairs(virus.props) do
        if p == propId then return true end
    end
    return false
end

-- Получить количество стаков свойства
function PLUGIN:GetVirusPropertyStacks(virus, propId)
    if not virus or not virus.props then return 0 end
    local count = 0
    for _, p in ipairs(virus.props) do
        if p == propId then
            count = count + 1
        end
    end
    return count
end

-- Вычислить множители эффекта на основе свойств
function PLUGIN:CalculateVirusMultipliers(virus, creatorLevel)
    local multipliers = {
        damage = 1.0,
        duration = 1.0,
        stealth = 0.0,
        scanPenalty = 0
    }
    
    if not virus or not virus.props then return multipliers end
    
    -- Noise: усиливает эффекты, но добавляет штраф к скану
    if self:VirusHasProperty(virus, "noise") then
        multipliers.damage = multipliers.damage * 2.0
        multipliers.scanPenalty = multipliers.scanPenalty + 30
    end
    
    -- Silent: ослабляет эффекты, но добавляет стелс
    local silentStacks = self:GetVirusPropertyStacks(virus, "silent")
    if silentStacks > 0 then
        multipliers.damage = multipliers.damage * 0.5
        multipliers.stealth = multipliers.stealth + (0.2 * silentStacks)
    end
    
    -- Overlock: усиливает эффекты на основе уровня создателя
    if self:VirusHasProperty(virus, "overlock") and creatorLevel then
        local prop = self.virusProperties.overlock
        local bonus = math.floor(creatorLevel / prop.bonusPerLevels) * prop.bonusPercent
        bonus = math.min(bonus, prop.maxBonus)
        multipliers.damage = multipliers.damage * (1.0 + bonus)
        multipliers.duration = multipliers.duration * (1.0 + bonus)
    end
    
    -- Stealth: добавляет шанс необнаружения на основе уровня
    if self:VirusHasProperty(virus, "stealth") and creatorLevel then
        local prop = self.virusProperties.stealth
        multipliers.stealth = multipliers.stealth + (creatorLevel * prop.stealthPerLevel)
    end
    
    return multipliers
end

-- Проверить, будет ли вирус обнаружен
function PLUGIN:WillVirusBeDetected(virus, creatorLevel)
    local multipliers = self:CalculateVirusMultipliers(virus, creatorLevel)
    
    -- Шанс обнаружения = 100% - шанс стелса
    local detectChance = 1.0 - math.min(multipliers.stealth, 0.95) -- максимум 95% стелса
    return math.random() < detectChance
end

-- Получить время сканирования с учётом свойств
function PLUGIN:GetVirusScanTime(virus, baseTime)
    if not virus then return baseTime end
    local multipliers = self:CalculateVirusMultipliers(virus)
    return math.max(baseTime - multipliers.scanPenalty, 30) -- минимум 30 секунд
end

-- Применить эффект вируса к цели
function PLUGIN:ApplyVirusEffect(virus, target, attacker, accessPoint)
    if not virus or not virus.props then return end
    
    local creatorLevel = virus.creatorLevel or 0
    local multipliers = self:CalculateVirusMultipliers(virus, creatorLevel)
    
    for _, propId in ipairs(virus.props) do
        local prop = self.virusProperties[propId]
        if not prop then continue end
        
        -- Применяем эффект в зависимости от типа
        self:ApplySingleVirusEffect(prop, target, attacker, accessPoint, multipliers, virus)
    end
end

-- Применить отдельный эффект вируса
function PLUGIN:ApplySingleVirusEffect(prop, target, attacker, accessPoint, multipliers, virus)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    local effect = prop.effect
    
    -- ========== БАЗОВЫЕ ЭФФЕКТЫ ==========
    
    if effect == "ransomware" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local percent = 0.02 * stacks * multipliers.damage
        local char = target:GetCharacter()
        if char then
            local money = char:GetMoney()
            local stolen = math.floor(money * percent)
            if stolen > 0 then
                char:TakeMoney(stolen)
                if IsValid(attacker) and attacker:GetCharacter() then
                    attacker:GetCharacter():GiveMoney(stolen)
                end
                target:Notify("Вирус вымогатель украл " .. stolen .. " кредитов!")
            end
        end
        
    elseif effect == "glitch" then
        local hackEffects = {"glitch", "weaponjam", "invert", "freeze", "shock", "blind", "slow"}
        for i = 1, 3 do
            local randomEffect = hackEffects[math.random(1, #hackEffects)]
            self:ApplyHackEffect(target, randomEffect, attacker)
        end
        target:Notify("Вирус Глич активирован!")
        
    elseif effect == "spy" then
        local duration = (prop.duration or 10) * multipliers.duration
        target.ixSpyVirus = {
            hacker = attacker,
            endTime = CurTime() + duration
        }
        target:Notify("Ваш терминал прослушивается!")
        
    elseif effect == "shock" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local damage = (prop.baseDamage or 10) * stacks * multipliers.damage
        target:TakeDamage(damage, attacker, accessPoint or attacker)
        target:EmitSound("ambient/energy/zap1.wav")
        target:Notify("Электрический разряд!")
        self:ApplySymbioteHeal(virus, attacker, damage)
        
    elseif effect == "informant" then
        local radius = prop.radius or 1000
        local points = {}
        for _, ent in ipairs(ents.FindByClass("ix_access_point")) do
            if IsValid(ent) then
                local dist = target:GetPos():Distance(ent:GetPos())
                if dist <= radius then
                    table.insert(points, {code = ent:GetAccessCode(), dist = math.floor(dist)})
                end
            end
        end
        if IsValid(attacker) then
            attacker:Notify("Найдено точек доступа: " .. #points)
            for _, p in ipairs(points) do
                attacker:Notify(string.format("  Код: %s (%d м)", p.code, p.dist))
            end
        end
        
    elseif effect == "slow" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local slowPercent = (prop.slowPercent or 0.2) * stacks
        local duration = (prop.duration or 10) * multipliers.duration
        local oldWalk = target:GetWalkSpeed()
        local oldRun = target:GetRunSpeed()
        target:SetWalkSpeed(oldWalk * (1 - slowPercent))
        target:SetRunSpeed(oldRun * (1 - slowPercent))
        timer.Simple(duration, function()
            if IsValid(target) then
                target:SetWalkSpeed(oldWalk)
                target:SetRunSpeed(oldRun)
            end
        end)
        target:Notify("Ваша скорость снижена!")
        
    elseif effect == "blind" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local duration = (prop.duration or 5) * stacks * multipliers.duration
        target:SetNWBool("ixGlitchEffect", true)
        timer.Simple(duration, function()
            if IsValid(target) then
                target:SetNWBool("ixGlitchEffect", false)
            end
        end)
        target:Notify("Оптика перезагружается!")
        
    -- ========== СРЕДНИЕ ЭФФЕКТЫ (15+) ==========
    
    elseif effect == "stamina_drain" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local drainPercent = (prop.drainPercent or 0.3) * stacks
        local duration = (prop.duration or 30) * multipliers.duration
        target.ixStaminaDrain = {
            endTime = CurTime() + duration,
            drainPercent = drainPercent
        }
        target:Notify("Вы чувствуете усталость!")
        
    elseif effect == "bleed" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local damagePerTick = (prop.damagePerTick or 1) * stacks * multipliers.damage
        local duration = prop.duration or 15
        local ticks = math.floor(duration / (prop.tickInterval or 3))
        
        target:SetNWBool("ixBleeding", true)
        target:Notify("У вас открылось кровотечение!")
        
        for i = 1, ticks do
            timer.Simple(i * (prop.tickInterval or 3), function()
                if IsValid(target) and target:Alive() then
                    target:TakeDamage(damagePerTick, attacker, accessPoint or attacker)
                    self:ApplySymbioteHeal(virus, attacker, damagePerTick)
                end
            end)
        end
        
        timer.Simple(duration, function()
            if IsValid(target) then
                target:SetNWBool("ixBleeding", false)
                target:Notify("Кровотечение остановлено.")
            end
        end)
        
    elseif effect == "hallucination" then
        local duration = (prop.duration or 20) * multipliers.duration
        target.ixHallucination = CurTime() + duration
        target:SetNWBool("ixHallucination", true)
        target:Notify("Ваше зрение искажается!")
        
        timer.Simple(duration, function()
            if IsValid(target) then
                target:SetNWBool("ixHallucination", false)
                target:Notify("Зрение восстановлено.")
            end
        end)
        
    elseif effect == "hunger_accel" then
        local duration = (prop.duration or 60) * multipliers.duration
        local multiplier = prop.multiplier or 3
        target.ixHungerAccelerate = {
            endTime = CurTime() + duration,
            multiplier = multiplier
        }
        target:Notify("Вы чувствуете сильный голод и жажду!")
        
    elseif effect == "radio_jammer" then
        local duration = (prop.duration or 30) * multipliers.duration
        target.ixRadioJammed = CurTime() + duration
        target:Notify("Ваше радио заглушено!")
        
        timer.Simple(duration, function()
            if IsValid(target) then
                target:Notify("Радио снова работает.")
            end
        end)
        
    elseif effect == "mirror" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local reflectPercent = (prop.reflectPercent or 0.25) * stacks
        local duration = (prop.duration or 30) * multipliers.duration
        target.ixMirrorDamage = {
            endTime = CurTime() + duration,
            reflectPercent = reflectPercent,
            attacker = attacker
        }
        target:Notify("Зеркальный щит активирован!")
        
    -- ========== ПРОДВИНУТЫЕ ЭФФЕКТЫ (25+) ==========
    
    elseif effect == "neural_disruptor" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local reduction = (prop.skillReduction or 2) * stacks
        local duration = (prop.duration or 60) * multipliers.duration
        
        local char = target:GetCharacter()
        if char then
            local skills = {"guns", "melee", "medicine", "engineering", "netrunning"}
            local affectedSkills = {}
            
            for i = 1, math.min(stacks, 3) do
                local skill = skills[math.random(1, #skills)]
                affectedSkills[skill] = reduction
            end
            
            target.ixNeuralDisrupt = {
                endTime = CurTime() + duration,
                skills = affectedSkills
            }
            
            target:Notify("Ваши нейронные связи повреждены!")
        end
        
    elseif effect == "synapse_burn" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local damage = (prop.baseDamage or 30) * stacks * multipliers.damage
        local burnDuration = (prop.burnDuration or 4) * multipliers.duration
        
        target:TakeDamage(damage, attacker, accessPoint or attacker)
        target:Ignite(burnDuration, 0)
        target:EmitSound("ambient/energy/weld2.wav")
        target:Notify("Ваш мозг горит!")
        self:ApplySymbioteHeal(virus, attacker, damage)
        
    elseif effect == "medical_suppress" then
        local duration = (prop.duration or 60) * multipliers.duration
        target.ixMedicalSuppressed = CurTime() + duration
        target:Notify("Регенерация заблокирована!")
        
    elseif effect == "cyberpsychosis" then
        local stacks = self:GetVirusPropertyStacks(virus, prop.id)
        local psychosisAmount = (prop.psychosisAmount or 20) * stacks * multipliers.damage
        
        -- Добавляем киберпсихоз через implant_sys
        local char = target:GetCharacter()
        if char then
            local currentPsychosis = char:GetData("cyberpsychosis", 0)
            local newPsychosis = math.min(currentPsychosis + psychosisAmount, 100)
            char:SetData("cyberpsychosis", newPsychosis)
            target:Notify("Киберпсихоз увеличен на " .. psychosisAmount .. "!")
        end
        
    elseif effect == "memory_corrupt" then
        target.ixMemoryCorrupted = CurTime()
        target:Notify("Вы не помните последние несколько минут...")
        
    -- ========== ЭКСПЕРТНЫЕ ЭФФЕКТЫ (30+) ==========
    
    elseif effect == "analyzer" then
        if IsValid(attacker) then
            local targetLevel = self:GetNetrunLevel(target)
            local creatorName = "Неизвестно"
            if virus.creator then
                local creatorChar = ix.char.loaded[virus.creator]
                if creatorChar then
                    creatorName = creatorChar:GetName()
                end
            end
            attacker:Notify(string.format("Анализ цели: уровень нетраннинга %d, создатель: %s", targetLevel, creatorName))
        end
        
    elseif effect == "parasite" then
        target.ixParasiteVirus = virus
        target:Notify("Вирус-паразит внедрён в вашу систему!")
        
    elseif effect == "polymorph" then
        -- Эффект применяется при сканировании
        target.ixPolymorphVirus = true
        target:Notify("Вирус мутирует!")
        
    elseif effect == "logic_bomb" then
        local delay = prop.delay or 300
        local damage = (prop.damage or 50) * multipliers.damage
        local radius = prop.radius or 200
        
        target:Notify("Обнаружена логическая бомба! Время до детонации: " .. delay .. " секунд.")
        
        timer.Simple(delay, function()
            if not IsValid(target) then return end
            
            local pos = target:GetPos()
            local explosion = EffectData()
            explosion:SetOrigin(pos)
            explosion:SetMagnitude(10)
            util.Effect("Explosion", explosion, true, true)
            target:EmitSound("ambient/explosions/explode_4.wav")
            
            for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
                if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
                    ent:TakeDamage(damage, attacker, accessPoint or attacker)
                    self:ApplySymbioteHeal(virus, attacker, damage)
                end
            end
            
            target:Notify("Логическая бомба взорвалась!")
        end)
    end
end

-- Вспомогательная функция для симбионта
function PLUGIN:ApplySymbioteHeal(virus, attacker, damage)
    if not virus then return end
    if not self:VirusHasProperty(virus, "symbiote") then return end
    if not IsValid(attacker) then return end
    
    local prop = self.virusProperties.symbiote
    local healAmount = damage * (prop.healPercent or 0.05)
    
    local attackerChar = attacker:GetCharacter()
    if attackerChar then
        local currentHealth = attacker:Health()
        local maxHealth = attacker:GetMaxHealth()
        local newHealth = math.min(currentHealth + healAmount, maxHealth)
        attacker:SetHealth(newHealth)
        attacker:Notify("Симбионт восстановил вам " .. math.floor(healAmount) .. " HP")
    end
end

-- Получить описание вируса с учётом стаков
function PLUGIN:GetVirusDescription(virus)
    if not virus or not virus.props then return "Нет свойств" end
    
    local desc = {}
    local processedProps = {}
    
    for _, propId in ipairs(virus.props) do
        if not processedProps[propId] then
            local prop = self.virusProperties[propId]
            if prop then
                local stacks = self:GetVirusPropertyStacks(virus, propId)
                local stackText = stacks > 1 and string.format(" (x%d)", stacks) or ""
                table.insert(desc, prop.name .. stackText .. ": " .. prop.description)
                processedProps[propId] = true
            end
        end
    end
    
    return table.concat(desc, "\n")
end

-- ============================================================================
-- КЛИЕНТСКИЙ ИНТЕРФЕЙС КАЗИНО
-- ============================================================================

local CASINO_PANEL = {}

-- Цвета редкости
local RARITY_COLORS = {
    [1] = Color(255, 215, 0),   -- Легендарная (золотой)
    [2] = Color(163, 53, 238),  -- Эпическая (фиолетовый)
    [3] = Color(0, 112, 221),   -- Редкая (синий)
    [4] = Color(128, 128, 128)  -- Обычная (серый)
}

local RARITY_NAMES = {
    [1] = "Легендарная",
    [2] = "Эпическая",
    [3] = "Редкая",
    [4] = "Обычная"
}

function CASINO_PANEL:Init()
    -- DPanel не имеет SetTitle, ShowCloseButton, SetDraggable - убираем эти вызовы
    
    self.coins = 0
    self.clickPower = 0.1
    self.passiveIncome = 0
    self.clickLevel = 1
    self.passiveLevel = 1
    self.unlockedProperties = {}
    
    self.currentTab = "main"
    
    -- Crash переменные
    self.crashMultiplier = 1.0
    self.crashActive = false
    self.crashBet = 0
    
    -- Roulette переменные
    self.rouletteResult = nil
    self.rouletteBetType = "red"
    
    -- Slots переменные
    self.slotsReels = {"?", "?", "?"}
    self.slotsSpinning = false
    
    self:UpdateContent()
end

function CASINO_PANEL:UpdateData(data)
    self.coins = data.coins or 0
    self.clickPower = data.clickPower or 0.1
    self.passiveIncome = data.passiveIncome or 0
    self.clickLevel = data.clickLevel or 1
    self.passiveLevel = data.passiveLevel or 1
    self.unlockedProperties = data.unlockedProperties or {}
    
    if self.contentPanel then
        self:UpdateContent()
    end
end

function CASINO_PANEL:UpdateContent()
    -- Очищаем контент
    if not self.contentPanel then
        -- Создаём основной layout
        self.titlePanel = self:Add("DPanel")
        self.titlePanel:Dock(TOP)
        self.titlePanel:SetHeight(30)
        self.titlePanel.Paint = function(s, w, h)
            surface.SetDrawColor(0, 50, 0, 200)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("🎰 CASINO", "DermaDefaultBold", w/2, h/2, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Панель коинов
        self.coinsPanel = self:Add("DPanel")
        self.coinsPanel:Dock(TOP)
        self.coinsPanel:SetHeight(25)
        self.coinsPanel.Paint = function(s, w, h)
            surface.SetDrawColor(0, 30, 0, 200)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(string.format("💰 %.2f | Пассив: %.3f/сек", self.coins, self.passiveIncome), "DermaDefault", 10, h/2, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        -- Табы
        self.tabPanel = self:Add("DPanel")
        self.tabPanel:Dock(TOP)
        self.tabPanel:SetHeight(30)
        self.tabPanel.Paint = nil
        
        self.tabs = {}
        local tabNames = {
            {id = "main", name = "Главная"},
            {id = "crash", name = "Ракетка"},
            {id = "roulette", name = "Рулетка"},
            {id = "slots", name = "Слоты"},
            {id = "properties", name = "Свойства"}
        }
        
        for i, tab in ipairs(tabNames) do
            local btn = self.tabPanel:Add("DButton")
            btn:Dock(LEFT)
            btn:SetWide(90)
            btn:SetText(tab.name)
            btn:SetTextColor(Color(0, 255, 0))
            btn.tabId = tab.id
            btn.Paint = function(s, w, h)
                surface.SetDrawColor(s:IsHovered() and Color(0, 80, 0, 200) or (self.currentTab == tab.id and Color(0, 60, 0, 200) or Color(0, 30, 0, 200)))
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(0, 255, 0, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            btn.DoClick = function()
                self.currentTab = tab.id
                self:UpdateContent()
            end
            table.insert(self.tabs, btn)
        end
        
        -- Контент панель
        self.contentPanel = self:Add("DPanel")
        self.contentPanel:Dock(FILL)
        self.contentPanel.Paint = function(s, w, h)
            surface.SetDrawColor(0, 20, 0, 200)
            surface.DrawRect(0, 0, w, h)
        end
    end
    
    -- Очищаем только контент панель
    for _, child in pairs(self.contentPanel:GetChildren()) do
        child:Remove()
    end
    
    if self.currentTab == "main" then
        self:CreateMainTab()
    elseif self.currentTab == "crash" then
        self:CreateCrashTab()
    elseif self.currentTab == "roulette" then
        self:CreateRouletteTab()
    elseif self.currentTab == "slots" then
        self:CreateSlotsTab()
    elseif self.currentTab == "properties" then
        self:CreatePropertiesTab()
    end
end

-- ============================================================================
-- ГЛАВНАЯ ВКЛАДКА
-- ============================================================================

function CASINO_PANEL:CreateMainTab()
    local scroll = self.contentPanel:Add("DScrollPanel")
    scroll:Dock(FILL)
    
    -- Кнопка клика
    local clickPanel = scroll:Add("DPanel")
    clickPanel:Dock(TOP)
    clickPanel:SetHeight(100)
    clickPanel:DockMargin(10, 10, 10, 10)
    clickPanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("Уровень кнопки: " .. self.clickLevel, "DermaDefault", 10, 10, Color(0, 255, 0))
        draw.SimpleText(string.format("Сила клика: %.2f коинов", self.clickPower), "DermaDefault", 10, 30, Color(0, 255, 0))
    end
    
    local clickBtn = clickPanel:Add("DButton")
    clickBtn:SetPos(10, 50)
    clickBtn:SetSize(200, 40)
    clickBtn:SetText("💰 КЛИК!")
    clickBtn:SetTextColor(Color(0, 255, 0))
    clickBtn:SetFont("DermaDefaultBold")
    clickBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(0, 100, 0, 255) or Color(0, 60, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    clickBtn.DoClick = function()
        net.Start("ixCasinoClick")
        net.SendToServer()
        surface.PlaySound("buttons/button15.wav")
    end
    
    local upgradeClickBtn = clickPanel:Add("DButton")
    upgradeClickBtn:SetPos(220, 50)
    upgradeClickBtn:SetSize(150, 40)
    upgradeClickBtn:SetText("⬆️ Улучшить")
    upgradeClickBtn:SetTextColor(Color(255, 255, 0))
    upgradeClickBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(80, 80, 0, 255) or Color(50, 50, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    upgradeClickBtn.DoClick = function()
        net.Start("ixCasinoUpgradeClick")
        net.SendToServer()
    end
    
    -- Пассивный доход
    local passivePanel = scroll:Add("DPanel")
    passivePanel:Dock(TOP)
    passivePanel:SetHeight(100)
    passivePanel:DockMargin(10, 10, 10, 10)
    passivePanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("Уровень пассивного дохода: " .. self.passiveLevel, "DermaDefault", 10, 10, Color(0, 255, 0))
        draw.SimpleText(string.format("Доход: %.3f коинов/сек", self.passiveIncome), "DermaDefault", 10, 30, Color(0, 255, 0))
    end
    
    local collectBtn = passivePanel:Add("DButton")
    collectBtn:SetPos(10, 50)
    collectBtn:SetSize(200, 40)
    collectBtn:SetText("📥 Собрать пассивный доход")
    collectBtn:SetTextColor(Color(0, 255, 0))
    collectBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(0, 100, 0, 255) or Color(0, 60, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    collectBtn.DoClick = function()
        net.Start("ixCasinoCollectPassive")
        net.SendToServer()
    end
    
    local upgradePassiveBtn = passivePanel:Add("DButton")
    upgradePassiveBtn:SetPos(220, 50)
    upgradePassiveBtn:SetSize(150, 40)
    upgradePassiveBtn:SetText("⬆️ Улучшить")
    upgradePassiveBtn:SetTextColor(Color(255, 255, 0))
    upgradePassiveBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(80, 80, 0, 255) or Color(50, 50, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    upgradePassiveBtn.DoClick = function()
        net.Start("ixCasinoUpgradePassive")
        net.SendToServer()
    end
    
    -- Информация о свойствах
    local infoPanel = scroll:Add("DPanel")
    infoPanel:Dock(TOP)
    infoPanel:SetHeight(60)
    infoPanel:DockMargin(10, 10, 10, 10)
    infoPanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("Разблокировано свойств: " .. table.Count(self.unlockedProperties), "DermaDefaultBold", 10, 10, Color(0, 255, 0))
        draw.SimpleText("Перейдите во вкладку 'Свойства' чтобы открыть новые!", "DermaDefault", 10, 30, Color(255, 255, 0))
    end
end

-- ============================================================================
-- CRASH (РАКЕТКА)
-- ============================================================================

function CASINO_PANEL:CreateCrashTab()
    local panel = self.contentPanel:Add("DPanel")
    panel:Dock(FILL)
    panel.Paint = nil
    
    -- Ставка
    local betPanel = panel:Add("DPanel")
    betPanel:Dock(TOP)
    betPanel:SetHeight(50)
    betPanel:DockMargin(10, 10, 10, 10)
    betPanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Ставка:", "DermaDefault", 10, h/2, Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    self.crashBetEntry = betPanel:Add("DTextEntry")
    self.crashBetEntry:SetPos(70, 10)
    self.crashBetEntry:SetSize(150, 30)
    self.crashBetEntry:SetValue("10")
    self.crashBetEntry:SetNumeric(true)
    
    -- Дисплей множителя
    self.crashDisplay = panel:Add("DPanel")
    self.crashDisplay:Dock(TOP)
    self.crashDisplay:SetHeight(120)
    self.crashDisplay:DockMargin(10, 10, 10, 10)
    self.crashDisplay.Paint = function(s, w, h)
        surface.SetDrawColor(0, 20, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        
        local color = self.crashActive and Color(0, 255, 0) or Color(255, 255, 255)
        draw.SimpleText(string.format("%.2fx", self.crashMultiplier), "DermaLarge", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self.crashActive then
            draw.SimpleText("🚀 ЛЕТИМ!", "DermaDefaultBold", w/2, 20, Color(0, 255, 0), TEXT_ALIGN_CENTER)
        elseif self.crashMultiplier > 1 then
            draw.SimpleText("CRASH!", "DermaDefaultBold", w/2, 20, Color(255, 0, 0), TEXT_ALIGN_CENTER)
        end
    end
    
    -- Кнопки
    local btnPanel = panel:Add("DPanel")
    btnPanel:Dock(TOP)
    btnPanel:SetHeight(50)
    btnPanel:DockMargin(10, 10, 10, 10)
    btnPanel.Paint = nil
    
    self.crashStartBtn = btnPanel:Add("DButton")
    self.crashStartBtn:SetPos(0, 0)
    self.crashStartBtn:SetSize(150, 40)
    self.crashStartBtn:SetText("🚀 ЗАПУСК")
    self.crashStartBtn:SetTextColor(Color(0, 255, 0))
    self.crashStartBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(0, 100, 0, 255) or Color(0, 60, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    self.crashStartBtn.DoClick = function()
        local bet = tonumber(self.crashBetEntry:GetValue()) or 0
        if bet <= 0 then
            LocalPlayer():Notify("Введите ставку!")
            return
        end
        net.Start("ixCasinoCrashStart")
            net.WriteFloat(bet)
        net.SendToServer()
        self.crashStartBtn:SetEnabled(false)
    end
    
    self.crashCashoutBtn = btnPanel:Add("DButton")
    self.crashCashoutBtn:SetPos(170, 0)
    self.crashCashoutBtn:SetSize(150, 40)
    self.crashCashoutBtn:SetText("💰 ЗАБРАТЬ")
    self.crashCashoutBtn:SetTextColor(Color(255, 255, 0))
    self.crashCashoutBtn:SetEnabled(false)
    self.crashCashoutBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(80, 80, 0, 255) or Color(50, 50, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    self.crashCashoutBtn.DoClick = function()
        net.Start("ixCasinoCrashCashout")
        net.SendToServer()
    end
    
    -- Инструкция
    local info = panel:Add("DLabel")
    info:Dock(TOP)
    info:DockMargin(10, 10, 10, 10)
    info:SetText("Нажмите ЗАПУСК чтобы начать. Множитель будет расти.\nНажмите ЗАБРАТЬ чтобы получить ставку * множитель.\nЕсли ракета упадёт - вы потеряете ставку!")
    info:SetTextColor(Color(0, 255, 0))
    info:SetWrap(true)
    info:SetAutoStretchVertical(true)
end

-- ============================================================================
-- РУЛЕТКА
-- ============================================================================

function CASINO_PANEL:CreateRouletteTab()
    local panel = self.contentPanel:Add("DPanel")
    panel:Dock(FILL)
    panel.Paint = nil
    
    -- Ставка
    local betPanel = panel:Add("DPanel")
    betPanel:Dock(TOP)
    betPanel:SetHeight(50)
    betPanel:DockMargin(10, 10, 10, 10)
    betPanel.Paint = function(s, w, h)
        draw.SimpleText("Ставка:", "DermaDefault", 10, h/2, Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    self.rouletteBetEntry = betPanel:Add("DTextEntry")
    self.rouletteBetEntry:SetPos(70, 10)
    self.rouletteBetEntry:SetSize(100, 30)
    self.rouletteBetEntry:SetValue("10")
    self.rouletteBetEntry:SetNumeric(true)
    
    -- Тип ставки
    local typePanel = panel:Add("DPanel")
    typePanel:Dock(TOP)
    typePanel:SetHeight(80)
    typePanel:DockMargin(10, 10, 10, 10)
    typePanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Выберите тип ставки:", "DermaDefault", 10, 10, Color(0, 255, 0))
    end
    
    -- Кнопки выбора
    local redBtn = typePanel:Add("DButton")
    redBtn:SetPos(10, 35)
    redBtn:SetSize(100, 35)
    redBtn:SetText("🔴 Красное")
    redBtn:SetTextColor(Color(255, 100, 100))
    redBtn.Paint = function(s, w, h)
        local isSelected = self.rouletteBetType == "red"
        surface.SetDrawColor(isSelected and Color(150, 0, 0, 255) or (s:IsHovered() and Color(100, 0, 0, 255) or Color(50, 0, 0, 255)))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 0, 0, isSelected and 255 or 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    redBtn.DoClick = function()
        self.rouletteBetType = "red"
        surface.PlaySound("buttons/button15.wav")
    end
    
    local blackBtn = typePanel:Add("DButton")
    blackBtn:SetPos(120, 35)
    blackBtn:SetSize(100, 35)
    blackBtn:SetText("⚫ Чёрное")
    blackBtn:SetTextColor(Color(200, 200, 200))
    blackBtn.Paint = function(s, w, h)
        local isSelected = self.rouletteBetType == "black"
        surface.SetDrawColor(isSelected and Color(80, 80, 80, 255) or (s:IsHovered() and Color(60, 60, 60, 255) or Color(30, 30, 30, 255)))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, isSelected and 255 or 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    blackBtn.DoClick = function()
        self.rouletteBetType = "black"
        surface.PlaySound("buttons/button15.wav")
    end
    
    -- Отображение текущего выбора
    local choiceLabel = typePanel:Add("DLabel")
    choiceLabel:SetPos(230, 35)
    choiceLabel:SetSize(150, 35)
    choiceLabel:SetTextColor(Color(0, 255, 0))
    choiceLabel:SetFont("DermaDefaultBold")
    choiceLabel.Think = function(s)
        local betType = self.rouletteBetType or "red"
        s:SetText("Выбрано: " .. (betType == "red" and "Красное" or "Чёрное"))
    end
    
    -- Дисплей результата
    self.rouletteDisplay = panel:Add("DPanel")
    self.rouletteDisplay:Dock(TOP)
    self.rouletteDisplay:SetHeight(100)
    self.rouletteDisplay:DockMargin(10, 10, 10, 10)
    self.rouletteDisplay.Paint = function(s, w, h)
        surface.SetDrawColor(0, 20, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        
        if self.rouletteResult then
            local color = self.rouletteResult.isRed and Color(255, 0, 0) or (self.rouletteResult.result == 0 and Color(0, 255, 0) or Color(50, 50, 50))
            draw.SimpleText(tostring(self.rouletteResult.result), "DermaLarge", w/2, h/2 - 20, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            if self.rouletteResult.won then
                draw.SimpleText(string.format("ВЫИГРЫШ: %.2f коинов!", self.rouletteResult.winnings), "DermaDefaultBold", w/2, h/2 + 20, Color(0, 255, 0), TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("ПРОИГРЫШ", "DermaDefaultBold", w/2, h/2 + 20, Color(255, 0, 0), TEXT_ALIGN_CENTER)
            end
        else
            draw.SimpleText("Выберите ставку и нажмите КРУТИТЬ", "DermaDefault", w/2, h/2, Color(0, 255, 0), TEXT_ALIGN_CENTER)
        end
    end
    
    -- Кнопка крутить
    local spinBtn = panel:Add("DButton")
    spinBtn:Dock(TOP)
    spinBtn:SetHeight(50)
    spinBtn:DockMargin(10, 10, 10, 10)
    spinBtn:SetText("🎰 КРУТИТЬ")
    spinBtn:SetTextColor(Color(0, 255, 0))
    spinBtn:SetFont("DermaDefaultBold")
    spinBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(0, 100, 0, 255) or Color(0, 60, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    spinBtn.DoClick = function()
        local bet = tonumber(self.rouletteBetEntry:GetValue()) or 0
        if bet <= 0 then
            LocalPlayer():Notify("Введите ставку!")
            return
        end
        
        net.Start("ixCasinoRoulette")
            net.WriteFloat(bet)
            net.WriteString(self.rouletteBetType)
            net.WriteUInt(0, 8)
        net.SendToServer()
    end
end

-- ============================================================================
-- СЛОТ-МАШИНА
-- ============================================================================

function CASINO_PANEL:CreateSlotsTab()
    local panel = self.contentPanel:Add("DPanel")
    panel:Dock(FILL)
    panel.Paint = nil
    
    -- Ставка
    local betPanel = panel:Add("DPanel")
    betPanel:Dock(TOP)
    betPanel:SetHeight(50)
    betPanel:DockMargin(10, 10, 10, 10)
    betPanel.Paint = function(s, w, h)
        draw.SimpleText("Ставка:", "DermaDefault", 10, h/2, Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    self.slotsBetEntry = betPanel:Add("DTextEntry")
    self.slotsBetEntry:SetPos(70, 10)
    self.slotsBetEntry:SetSize(100, 30)
    self.slotsBetEntry:SetValue("10")
    self.slotsBetEntry:SetNumeric(true)
    
    -- Дисплей слотов
    self.slotsDisplay = panel:Add("DPanel")
    self.slotsDisplay:Dock(TOP)
    self.slotsDisplay:SetHeight(120)
    self.slotsDisplay:DockMargin(10, 10, 10, 10)
    self.slotsDisplay.Paint = function(s, w, h)
        surface.SetDrawColor(0, 20, 0, 200)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        
        local cellW = 70
        local startX = w/2 - cellW * 1.5
        
        for i, symbol in ipairs(self.slotsReels) do
            local x = startX + (i - 1) * (cellW + 10)
            surface.SetDrawColor(0, 40, 0, 255)
            surface.DrawRect(x, 20, cellW, 80)
            surface.SetDrawColor(0, 255, 0, 200)
            surface.DrawOutlinedRect(x, 20, cellW, 80)
            
            draw.SimpleText(symbol, "DermaLarge", x + cellW/2, 60, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Результат
    self.slotsResultLabel = panel:Add("DLabel")
    self.slotsResultLabel:Dock(TOP)
    self.slotsResultLabel:DockMargin(10, 5, 10, 5)
    self.slotsResultLabel:SetText("")
    self.slotsResultLabel:SetTextColor(Color(0, 255, 0))
    self.slotsResultLabel:SetContentAlignment(5)
    
    -- Кнопка крутить
    self.slotsSpinBtn = panel:Add("DButton")
    self.slotsSpinBtn:Dock(TOP)
    self.slotsSpinBtn:SetHeight(50)
    self.slotsSpinBtn:DockMargin(10, 10, 10, 10)
    self.slotsSpinBtn:SetText("🎰 КРУТИТЬ")
    self.slotsSpinBtn:SetTextColor(Color(0, 255, 0))
    self.slotsSpinBtn:SetFont("DermaDefaultBold")
    self.slotsSpinBtn.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(0, 100, 0, 255) or Color(0, 60, 0, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    self.slotsSpinBtn.DoClick = function()
        if self.slotsSpinning then return end
        
        local bet = tonumber(self.slotsBetEntry:GetValue()) or 0
        if bet <= 0 then
            LocalPlayer():Notify("Введите ставку!")
            return
        end
        
        net.Start("ixCasinoSlots")
            net.WriteFloat(bet)
        net.SendToServer()
        
        self.slotsSpinning = true
        self.slotsSpinBtn:SetEnabled(false)
        self.slotsResultLabel:SetText("Крутим...")
    end
end

-- ============================================================================
-- РУЛЕТКА СВОЙСТВ
-- ============================================================================

function CASINO_PANEL:CreatePropertiesTab()
    local scroll = self.contentPanel:Add("DScrollPanel")
    scroll:Dock(FILL)
    
    -- Информация
    local infoPanel = scroll:Add("DPanel")
    infoPanel:Dock(TOP)
    infoPanel:SetHeight(50)
    infoPanel:DockMargin(10, 10, 10, 10)
    infoPanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Разблокировано свойств: " .. table.Count(self.unlockedProperties), "DermaDefaultBold", 10, 15, Color(0, 255, 0))
        draw.SimpleText("Крутите рулетку чтобы открыть новые!", "DermaDefault", 10, 32, Color(255, 255, 0))
    end
    
    -- Рулетки
    local roulettePanel = scroll:Add("DPanel")
    roulettePanel:Dock(TOP)
    roulettePanel:SetHeight(160)
    roulettePanel:DockMargin(10, 10, 10, 10)
    roulettePanel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 40, 0, 200)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("🎰 РУЛЕТКИ СВОЙСТВ", "DermaDefaultBold", w/2, 12, Color(0, 255, 0), TEXT_ALIGN_CENTER)
    end
    
    local rouletteTypes = {
        {id = "all", name = "Все", cost = 100, rarity = 4},
        {id = "4", name = "Обычная", cost = 50, rarity = 4},
        {id = "3", name = "Редкая", cost = 150, rarity = 3},
        {id = "2", name = "Эпическая", cost = 300, rarity = 2},
        {id = "1", name = "Легенда", cost = 500, rarity = 1}
    }
    
    for i, r in ipairs(rouletteTypes) do
        local btn = roulettePanel:Add("DButton")
        btn:SetPos(10 + ((i-1) % 3) * 135, 35 + math.floor((i-1) / 3) * 55)
        btn:SetSize(125, 50)
        btn:SetText(r.name .. "\n" .. r.cost .. " коинов")
        btn:SetTextColor(RARITY_COLORS[r.rarity])
        btn.Paint = function(s, w, h)
            surface.SetDrawColor(s:IsHovered() and Color(0, 80, 0, 255) or Color(0, 40, 0, 255))
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(RARITY_COLORS[r.rarity])
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        btn.DoClick = function()
            net.Start("ixCasinoPropertyRoulette")
                net.WriteString(r.id)
            net.SendToServer()
        end
    end
end

vgui.Register("CasinoFrame", CASINO_PANEL, "DPanel")

-- ============================================================================
-- СЕТЕВЫЕ СООБЩЕНИЯ И АНИМАЦИИ
-- ============================================================================

-- Переменные для анимаций
local crashTimer = nil
local slotsAnimTimer = nil

net.Receive("ixCasinoData", function()
    local data = {
        coins = net.ReadFloat(),
        clickPower = net.ReadFloat(),
        passiveIncome = net.ReadFloat(),
        clickLevel = net.ReadUInt(16),
        passiveLevel = net.ReadUInt(16),
        unlockedProperties = net.ReadTable()
    }
    
    print("[BigTerminal Casino] Received data: coins=" .. tostring(data.coins) .. " clickPower=" .. tostring(data.clickPower))
    
    if IsValid(ix.gui.Casino) then
        ix.gui.Casino:UpdateData(data)
        print("[BigTerminal Casino] Updated existing casino panel")
    else
        print("[BigTerminal Casino] No casino panel to update")
    end
    
    -- Также обновляем данные в терминале, если казино открыто там
    if IsValid(ix.gui.BigTerminal) and IsValid(ix.gui.BigTerminal.currentGame) then
        if ix.gui.BigTerminal.currentGame.UpdateData then
            ix.gui.BigTerminal.currentGame:UpdateData(data)
            print("[BigTerminal Casino] Updated casino in terminal")
        end
    end
end)

net.Receive("ixCasinoCrashStart", function()
    local bet = net.ReadFloat()
    local crashPoint = net.ReadFloat()
    
    if IsValid(ix.gui.Casino) then
        ix.gui.Casino.crashActive = true
        ix.gui.Casino.crashMultiplier = 1.0
        ix.gui.Casino.crashBet = bet
        ix.gui.Casino.crashCashoutBtn:SetEnabled(true)
        -- Сохраняем crashPoint для отображения
        ix.gui.Casino.crashPoint = crashPoint
    end
end)

net.Receive("ixCasinoCrashUpdate", function()
    local multiplier = net.ReadFloat()
    
    if IsValid(ix.gui.Casino) then
        ix.gui.Casino.crashMultiplier = multiplier
    end
end)

net.Receive("ixCasinoCrashResult", function()
    local success = net.ReadBool()
    local winnings = net.ReadFloat()
    
    if IsValid(ix.gui.Casino) then
        ix.gui.Casino.crashActive = false
        ix.gui.Casino.crashCashoutBtn:SetEnabled(false)
        ix.gui.Casino.crashStartBtn:SetEnabled(true)
        
        if success then
            ix.gui.Casino.crashMultiplier = winnings / (ix.gui.Casino.crashBet or 1)
            ix.gui.Casino.slotsResultLabel = ix.gui.Casino.slotsResultLabel or {}
        end
    end
end)

net.Receive("ixCasinoRoulette", function()
    local result = net.ReadUInt(8)
    local isRed = net.ReadBool()
    local won = net.ReadBool()
    local winnings = net.ReadFloat()
    local multiplier = net.ReadFloat()
    
    if IsValid(ix.gui.Casino) then
        ix.gui.Casino.rouletteResult = {
            result = result,
            isRed = isRed,
            won = won,
            winnings = winnings,
            multiplier = multiplier
        }
    end
end)

net.Receive("ixCasinoSlots", function()
    local reels = net.ReadTable()
    local multiplier = net.ReadFloat()
    local winnings = net.ReadFloat()
    
    if not IsValid(ix.gui.Casino) then return end
    
    -- Анимация вращения
    local symbols = {"7", "BAR", "🍒", "🍋", "🔔", "⭐", "💎"}
    local spinDuration = 2
    local startTime = CurTime()
    
    -- Останавливаем барабаны по очереди
    local function animateReel(reelIndex, delay)
        timer.Simple(delay, function()
            if not IsValid(ix.gui.Casino) then return end
            
            local spinSpeed = 0.05
            local spinTime = 0
            
            timer.Create("ixSlotsReel" .. reelIndex, spinSpeed, 0, function()
                if not IsValid(ix.gui.Casino) then
                    timer.Remove("ixSlotsReel" .. reelIndex)
                    return
                end
                
                spinTime = spinTime + spinSpeed
                
                if spinTime >= 0.5 then
                    -- Останавливаем на финальном символе
                    ix.gui.Casino.slotsReels[reelIndex] = reels[reelIndex]
                    timer.Remove("ixSlotsReel" .. reelIndex)
                    
                    -- Когда все барабаны остановлены
                    if reelIndex == 3 then
                        ix.gui.Casino.slotsSpinning = false
                        ix.gui.Casino.slotsSpinBtn:SetEnabled(true)
                        
                        if multiplier > 0 then
                            ix.gui.Casino.slotsResultLabel:SetText(string.format("ВЫИГРЫШ: %.2f коинов! (x%.1f)", winnings, multiplier))
                            ix.gui.Casino.slotsResultLabel:SetTextColor(Color(0, 255, 0))
                        else
                            ix.gui.Casino.slotsResultLabel:SetText("Не повезло...")
                            ix.gui.Casino.slotsResultLabel:SetTextColor(Color(255, 100, 100))
                        end
                    end
                else
                    -- Вращаем
                    ix.gui.Casino.slotsReels[reelIndex] = symbols[math.random(1, #symbols)]
                end
            end)
        end)
    end
    
    -- Запускаем анимацию для каждого барабана
    for i = 1, 3 do
        animateReel(i, 0.5 * (i - 1))
    end
end)

net.Receive("ixCasinoPropertyRouletteResult", function()
    local success = net.ReadBool()
    
    if not success then
        local msg = net.ReadString()
        LocalPlayer():Notify(msg)
        return
    end
    
    local rouletteType = net.ReadString()
    local allProps = net.ReadTable()
    local finalProp = net.ReadString()
    local rarity = net.ReadUInt(8)
    
    -- Создаём панель рулетки свойств
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 350)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:MakePopup()
    
    frame.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(RARITY_COLORS[rarity])
        surface.DrawOutlinedRect(0, 0, w, h)
        
        draw.SimpleText("🎰 РУЛЕТКА СВОЙСТВ", "DermaDefaultBold", w/2, 20, Color(0, 255, 0), TEXT_ALIGN_CENTER)
    end
    
    -- Анимация рулетки
    local currentIndex = 1
    local spinSpeed = 0.05
    local spinDuration = 3
    local startTime = CurTime()
    
    local displayLabel = frame:Add("DLabel")
    displayLabel:SetPos(0, 130)
    displayLabel:SetSize(400, 50)
    displayLabel:SetContentAlignment(5)
    displayLabel:SetFont("DermaLarge")
    
    local function getPropertyName(propId)
        local plugin = ix.plugin.Get("big_terminal")
        local propData = plugin and plugin.virusProperties and plugin.virusProperties[propId]
        if not propData then
            propData = plugin and plugin.antivirusProperties and plugin.antivirusProperties[propId]
        end
        return propData and propData.name or propId
    end
    
    local animTimer = nil
    
    frame.Think = function(s)
        local elapsed = CurTime() - startTime
        
        if elapsed < spinDuration then
            -- Замедление
            if elapsed > spinDuration * 0.7 then
                spinSpeed = math.min(spinSpeed + 0.003, 0.2)
            end
            
            if not s.lastSpin or CurTime() - s.lastSpin > spinSpeed then
                s.lastSpin = CurTime()
                currentIndex = currentIndex + 1
                if currentIndex > #allProps then currentIndex = 1 end
                
                local prop = allProps[currentIndex]
                displayLabel:SetText(getPropertyName(prop.id))
                displayLabel:SetTextColor(RARITY_COLORS[prop.rarity])
            end
        else
            -- Показываем финальный результат
            displayLabel:SetText(getPropertyName(finalProp))
            displayLabel:SetTextColor(RARITY_COLORS[rarity])
            
            -- Кнопка подтверждения
            if not s.confirmed then
                local confirmBtn = s:Add("DButton")
                confirmBtn:SetPos(100, 250)
                confirmBtn:SetSize(200, 40)
                confirmBtn:SetText("✅ ЗАБРАТЬ!")
                confirmBtn:SetTextColor(Color(0, 255, 0))
                confirmBtn:SetFont("DermaDefaultBold")
                confirmBtn.Paint = function(btn, w, h)
                    surface.SetDrawColor(0, 80, 0, 255)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(0, 255, 0, 200)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
                confirmBtn.DoClick = function()
                    net.Start("ixCasinoPropertyRouletteConfirm")
                    net.SendToServer()
                    frame:Remove()
                end
                s.confirmed = true
            end
        end
    end
end)

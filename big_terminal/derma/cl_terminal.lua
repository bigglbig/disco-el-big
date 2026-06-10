local PANEL = {}

-- ASCII Art for hacker style
local ASCII_LOGO = [[
_________ $$$$$$$$$$$$$$$$$$$$$$$
________$$$$___$$$$$$$$$$$$$$$$$$$$$
______$$$$______$$$$$$$$$$$$$$$$$$$$$$
____$$$$$________$$$$$$$$$$$$$$$$$$$$$$$
___$$$$$__________$$$$$$$$$$$$$$$$$$$$$$$
__$$$$$____________$$$$$$$$$$$$$$$$$$$$$$$
_$$$$$$____________$$$$$$$$$$$$$$$$$$$$$$$$
_$$$$$$___________$$$$$$$$$___________$$$$$$
_$$…$$$$$_________$$$_$$$_$$$_________$$$$$
_$$$$$$$$______$$$$___$___$$$$______$$$$$$$$
_$$$$$$$$$$$$$$$$$___$$$___$$$$$$$$$$$$$$$$$
_$$$_$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$_o$$
_$$$__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$__$$$
__$$$__$’$$$$$$$$$$$$$$$$$$$$$$$$$$$$$__o$$$
__’$$o__$$__$$’$$$$$$$$$$$$$$’$$__$$_____o$$
____$$o$____$$__’$$’$$’$$’__$$______$___o$$
_____$$$o$__$____$$___$$___$$_____$$__o$
______’$$$$O$____$$____$$___$$ ____o$$$
_________’$$o$$___$$___$$___$$___o$$$
___________’$$$$$o$o$o$o$o$o$o$$$$
]]

-- Время жизни сохранённого состояния терминала (в секундах)
local TERMINAL_MEMORY_TTL = 300 -- 5 минут
local terminalMemory = {} -- хранилище для разных игроков (по SteamID64)

-- ============================================================================
-- МЕТОДЫ ПАНЕЛИ (определены до Init)
-- ============================================================================

function PANEL:RestoreFromMemory(memory)
    if IsValid(self.outputText) and memory.output then
        self.outputText:SetText(memory.output)
        self:ScrollToBottom()
    end
    if IsValid(self.inputEntry) and memory.history then
        for _, entry in ipairs(memory.history) do
            self.inputEntry:AddHistory(entry)
            table.insert(self.commandHistory, entry)
        end
    end
    if IsValid(self.inputEntry) and memory.currentInput then
        self.inputEntry:SetText(memory.currentInput)
    end
end

function PANEL:SaveToMemory()
    local ply = LocalPlayer()
    if not ply or not IsValid(self.outputText) or not IsValid(self.inputEntry) then return end
    local steamID = ply:SteamID64()
    terminalMemory[steamID] = {
        timestamp = CurTime(),
        output = self.outputText:GetText(),
        history = self.commandHistory,
        currentInput = self.inputEntry:GetText()
    }
end

function PANEL:AddOutput(lines)
    if not IsValid(self.outputText) then return end

    local currentText = self.outputText:GetText() or ""
    local newText = currentText

    for _, line in ipairs(lines) do
        newText = newText .. line .. "\n"
    end

    self.outputText:SetText(newText)
    
    -- Устанавливаем курсор в конец (помогает с прокруткой)
    self.outputText:SetCaretPos(#newText)
    
    -- Прокручиваем вниз
    self:ScrollToBottom()
    
    -- Сохраняем в память без повторной прокрутки
    local ply = LocalPlayer()
    if not ply then return end
    local steamID = ply:SteamID64()
    terminalMemory[steamID] = {
        timestamp = CurTime(),
        output = newText,
        history = self.commandHistory,
        currentInput = IsValid(self.inputEntry) and self.inputEntry:GetText() or ""
    }
end

-- Прокрутка вниз для DTextEntry
function PANEL:ScrollToBottom()
    if not IsValid(self.outputText) then return end

    -- Используем таймер для задержки, т.к. DTextEntry обновляется асинхронно
    timer.Simple(0.01, function()
        if not IsValid(self) or not IsValid(self.outputText) then return end
        
        -- Метод 1: GotoTextEnd (если доступен)
        if self.outputText.GotoTextEnd then
            pcall(function() self.outputText:GotoTextEnd() end)
        end
        
        -- Метод 2: Через внутренний элемент (DTextEntry имеет внутреннюю структуру)
        local inner = self.outputText:GetChild(0)
        if IsValid(inner) then
            local vbar = inner.GetVBar and inner:GetVBar()
            if IsValid(vbar) then
                vbar:SetScroll(999999)
            end
        end
        
        -- Метод 3: Установка курсора в конец
        local text = self.outputText:GetText()
        if text and self.outputText.SetCaretPos then
            self.outputText:SetCaretPos(#text)
        end
    end)
end

function PANEL:ShowGame(panelClass, ...)
    if not IsValid(self.gamePanel) then return end
    -- Очищаем предыдущую игру
    if IsValid(self.currentGame) then
        self.currentGame:Remove()
    end
    -- Пристыковываем gamePanel и делаем её видимой
    self.gamePanel:SetVisible(true)
    self.gamePanel:Dock(FILL) -- занимает всё оставшееся место справа
    -- Создаём игру как дочернюю панель
    self.currentGame = self.gamePanel:Add(panelClass)
    self.currentGame:Dock(FILL)
    -- Передаём данные
    if IsValid(self.currentGame) then
        if self.currentGame.SetGameData then
            self.currentGame:SetGameData(...)
        elseif self.currentGame.SetHashData then
            self.currentGame:SetHashData(...)
        elseif self.currentGame.SetPool then
            self.currentGame:SetPool(...)
        elseif self.currentGame.SetMazeData then
            self.currentGame:SetMazeData(...)
        end
    end
    self:InvalidateLayout()
    return self.currentGame
end

function PANEL:HideGame()
    if IsValid(self.currentGame) then
        self.currentGame:Remove()
        self.currentGame = nil
    end
    if IsValid(self.gamePanel) then
        -- Отстыковываем gamePanel и скрываем
        self.gamePanel:Dock(0)
        self.gamePanel:SetVisible(false)
    end
    self:InvalidateLayout()
end

function PANEL:ShowProgressBar(title, duration, callback)
    local progressPanel = self:Add("DPanel")
    progressPanel:SetSize(400, 80)
    progressPanel:Center()
    progressPanel:SetZPos(100)

    progressPanel.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 30, 0, 250))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 200))
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText(title, "DermaDefaultBold", w / 2, 20, Color(0, 255, 0), TEXT_ALIGN_CENTER)
    end
    
    local progressBar = progressPanel:Add("DPanel")
    progressBar:SetPos(20, 40)
    progressBar:SetSize(360, 20)

    local progress = 0
    local startTime = CurTime()

    progressBar.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 50, 0, 200))
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(Color(0, 255, 0, 200))
        surface.DrawRect(0, 0, w * progress, h)

        surface.SetDrawColor(Color(0, 255, 0, 255))
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText(math.floor(progress * 100) .. "%", "DermaDefaultBold", w / 2, h / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    timer.Create("ixBigTerminalProgress", 0.05, 0, function()
        if not IsValid(progressPanel) then return end

        local elapsed = CurTime() - startTime
        progress = math.min(elapsed / duration, 1)

        if progress >= 1 then
            progressPanel:Remove()
            timer.Remove("ixBigTerminalProgress")
            if callback then callback() end
        end
    end)
end

function PANEL:SubmitCommand()
    if not IsValid(self.inputEntry) then return end
    local input = self.inputEntry:GetText()
    if input == "" then return end

    self.inputEntry:AddHistory(input)
    table.insert(self.commandHistory, input)

    self:AddOutput({"> " .. input})

    local args = string.Explode(" ", input)
    local cmd = args[1] or ""
    local argString = #args > 1 and table.concat(args, " ", 2) or ""

    self.inputEntry:SetText("")
    surface.PlaySound("buttons/button15.wav")

    if PLUGIN and PLUGIN.debugMode then
        print("[BigTerminal DEBUG] Sending command: " .. cmd .. " args: " .. argString)
    end

    net.Start("ixBigTerminalCommand")
        net.WriteString(cmd)
        net.WriteString(argString)
        net.WriteEntity(LocalPlayer().activeTerminal or Entity(0))
    net.SendToServer()
    
    self:SaveToMemory()
end

function PANEL:Think()
    if not IsValid(self) then return end
    if IsValid(self.inputEntry) and not self.inputEntry:HasFocus() and not vgui.GetKeyboardFocus() then
        self.inputEntry:RequestFocus()
    end
end

function PANEL:OnRemove()
    self:SaveToMemory()
end

-- ============================================================================
-- ИНИЦИАЛИЗАЦИЯ ПАНЕЛИ
-- ============================================================================

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)
    self:MakePopup()

    -- Клик по фону терминала возвращает фокус в поле ввода
    self.OnMousePressed = function()
        if IsValid(self.inputEntry) then
            self.inputEntry:RequestFocus()
        end
    end

    -- Store reference for network receive
    ix.gui.BigTerminal = self

    self.Paint = function(self, w, h)
        -- Black background with slight transparency
        surface.SetDrawColor(Color(0, 0, 0, 250))
        surface.DrawRect(0, 0, w, h)

        -- Scanlines effect
        surface.SetDrawColor(Color(0, 255, 0, 5))
        for y = 0, h, 3 do
            surface.DrawRect(0, y, w, 1)
        end

        -- Moving scan line
        local scanY = (CurTime() * 100) % h
        surface.SetDrawColor(Color(0, 255, 0, 30))
        surface.DrawRect(0, scanY - 50, w, 100)
    end

    -- Main terminal panel
    self.terminalPanel = self:Add("DFrame")
    self.terminalPanel:SetSize(ScrW() * 0.8, ScrH() * 0.85)
    self.terminalPanel:Center()
    self.terminalPanel:SetTitle("")
    self.terminalPanel:ShowCloseButton(false)
    self.terminalPanel:SetDraggable(false)

    self.terminalPanel.Paint = function(self, w, h)
        -- Border glow
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

        -- Background
        surface.SetDrawColor(Color(5, 15, 5, 250))
        surface.DrawRect(2, 2, w - 4, h - 4)

        -- Title bar
        surface.SetDrawColor(Color(0, 50, 0, 200))
        surface.DrawRect(2, 2, w - 4, 35)

        -- Title text
        draw.SimpleText("BIG_TERMINAL v2.0.47 [SECURE CONNECTION]", "DermaDefaultBold", w / 2, 18, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Close button
    self.closeBtn = self.terminalPanel:Add("DButton")
    self.closeBtn:SetSize(80, 28)
    self.closeBtn:SetPos(self.terminalPanel:GetWide() - 90, 5)
    self.closeBtn:SetText("[X]")
    self.closeBtn:SetTextColor(Color(0, 255, 0))
    self.closeBtn:SetFont("DermaDefaultBold")

    self.closeBtn.Paint = function(self, w, h)
        surface.SetDrawColor(self:IsHovered() and Color(100, 0, 0, 200) or Color(50, 0, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.closeBtn.DoClick = function()
        surface.PlaySound("buttons/button4.wav")
        self:SaveToMemory()
        net.Start("ixBigTerminalClose")
        net.SendToServer()
        ix.gui.BigTerminal = nil
        self:Remove()
    end

    -- Главный контейнер с двумя колонками
    self.mainContainer = self.terminalPanel:Add("DPanel")
    self.mainContainer:SetPos(10, 45)
    self.mainContainer:SetSize(self.terminalPanel:GetWide() - 20, self.terminalPanel:GetTall() - 100)
    self.mainContainer.Paint = nil

    -- Левая колонка (текстовый вывод)
    self.outputPanel = self.mainContainer:Add("DPanel")
    self.outputPanel:Dock(LEFT)
    self.outputPanel:SetWide(600)
    self.outputPanel:DockMargin(0, 0, 10, 0)

    self.outputPanel.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 20, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 50))
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Output text
    self.outputText = self.outputPanel:Add("DTextEntry")
    self.outputText:Dock(FILL)
    self.outputText:DockMargin(5, 5, 5, 5)
    self.outputText:SetMultiline(true)
    self.outputText:SetVerticalScrollbarEnabled(true)
    self.outputText:SetEnabled(false)
    self.outputText:SetTextColor(Color(0, 255, 0))
    self.outputText:SetCursorColor(Color(0, 255, 0))
    self.outputText:SetFont("DermaDefault")

    self.outputText.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 10, 0, 200))
        surface.DrawRect(0, 0, w, h)
        self:DrawTextEntryText(Color(0, 255, 0), Color(0, 100, 0), Color(0, 255, 0))
    end

    -- Правая колонка (игровая панель)
    self.gamePanel = self.mainContainer:Add("DPanel")
    self.gamePanel:SetVisible(false)
    self.gamePanel:Dock(0)
    self.gamePanel.Paint = function(s, w, h)
        surface.SetDrawColor(Color(0, 20, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 50))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    -- Input panel (внизу, вне mainContainer)
    self.inputPanel = self.terminalPanel:Add("DPanel")
    self.inputPanel:SetPos(10, self.terminalPanel:GetTall() - 55)
    self.inputPanel:SetSize(self.terminalPanel:GetWide() - 20, 45)

    self.inputPanel.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 30, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    -- Prompt label
    self.promptLabel = self.inputPanel:Add("DLabel")
    self.promptLabel:SetPos(10, 12)
    self.promptLabel:SetSize(30, 25)
    self.promptLabel:SetText(">")
    self.promptLabel:SetTextColor(Color(0, 255, 0))
    self.promptLabel:SetFont("DermaDefaultBold")

    -- Input entry
    self.inputEntry = self.inputPanel:Add("DTextEntry")
    self.inputEntry:SetPos(30, 8)
    self.inputEntry:SetSize(self.inputPanel:GetWide() - 120, 30)
    self.inputEntry:SetTextColor(Color(0, 255, 0))
    self.inputEntry:SetFont("DermaDefault")
    self.inputEntry:SetCursorColor(Color(0, 255, 0))
    self.inputEntry:SetPlaceholderText("")
    self.inputEntry:SetHistoryEnabled(true)

    self.inputEntry.Paint = function(self, w, h)
        self:DrawTextEntryText(Color(0, 255, 0), Color(0, 100, 0), Color(0, 255, 0))
    end

    self.inputEntry.OnEnter = function()
        self:SubmitCommand()
    end

    -- Submit button
    self.submitBtn = self.inputPanel:Add("DButton")
    self.submitBtn:SetPos(self.inputPanel:GetWide() - 80, 8)
    self.submitBtn:SetSize(70, 30)
    self.submitBtn:SetText("ENTER")
    self.submitBtn:SetTextColor(Color(0, 255, 0))
    self.submitBtn:SetFont("DermaDefaultBold")

    self.submitBtn.Paint = function(self, w, h)
        surface.SetDrawColor(self:IsHovered() and Color(0, 80, 0, 200) or Color(0, 40, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.submitBtn.DoClick = function()
        self:SubmitCommand()
    end

    -- История команд
    self.commandHistory = {}

    -- Initialize output
    self:AddOutput({
        ASCII_LOGO,
        "═══════════════════════════════════════════════════════════════════════",
        "  BIG TERMINAL v2.0.47 - SECURE HACKING SYSTEM",
        "═══════════════════════════════════════════════════════════════════════",
        "",
        "  [СИСТЕМА] Терминал инициализиран",
        "  [СИСТЕМА] Введите run_sys для запуска системы",
        ""
    })

    -- Пытаемся восстановить сохранённое состояние
    local ply = LocalPlayer()
    if ply then
        local steamID = ply:SteamID64()
        local memory = terminalMemory[steamID]
        if memory and memory.timestamp and CurTime() - memory.timestamp < TERMINAL_MEMORY_TTL then
            self:RestoreFromMemory(memory)
        end
    end

    -- Focus input
    if IsValid(self.inputEntry) then
        self.inputEntry:RequestFocus()
    end
end

vgui.Register("BigTerminalFrame", PANEL, "EditablePanel")

-- ============================================================================
-- СЕТЕВЫЕ СООБЩЕНИЯ И МИНИ-ИГРЫ (без изменений, оставляем как есть)
-- ============================================================================

net.Receive("ixBigTerminalOutput", function()
    local output = net.ReadTable()
    
    if PLUGIN and PLUGIN.debugMode then
        print("[BigTerminal DEBUG] Received output from server, lines:", #output)
    end
    
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:AddOutput(output)
    else
        if PLUGIN and PLUGIN.debugMode then
            print("[BigTerminal DEBUG] ERROR: BigTerminal GUI not valid!")
        end
    end
end)

-- ============================================================================
-- Новая мини-игра для анализа хэш-кодов (спектральный анализ)
-- ============================================================================
local HASH_PANEL = {}

function HASH_PANEL:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetKeyboardInputEnabled(true)

    self.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 5)
        for y = 0, h, 4 do
            surface.DrawRect(0, y, w, 1)
        end
    end

    -- Заголовок
    local title = self:Add("DLabel")
    title:Dock(TOP)
    title:SetHeight(30)
    title:DockMargin(5, 5, 5, 0)
    title:SetText("СПЕКТРАЛЬНЫЙ АНАЛИЗ ХЭШ-КОДОВ")
    title:SetTextColor(Color(0, 255, 0))
    title:SetFont("DermaDefaultBold")
    title:SetContentAlignment(5)

    -- Инструкция
    local instr = self:Add("DLabel")
    instr:Dock(TOP)
    instr:SetHeight(20)
    instr:DockMargin(5, 0, 5, 5)
    instr:SetText("Выберите код со стабильной спектрограммой")
    instr:SetTextColor(Color(0, 255, 0, 200))
    instr:SetFont("DermaDefault")
    instr:SetContentAlignment(5)

    -- Скроллируемый список кодов
    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(5, 5, 5, 5)

    self.hashButtons = {}
    self.animPhases = {}
    self.correctIndex = nil
end

function HASH_PANEL:SetHashData(codes)
    self.codes = codes
    self.correctIndex = nil

    for i, codeData in ipairs(codes) do
        local btn = self.scroll:Add("DButton")
        btn:Dock(TOP)
        btn:SetHeight(40)
        btn:DockMargin(0, 2, 0, 2)
        btn:SetText("")
        btn.codeData = codeData
        btn.index = i

        self.animPhases[i] = {
            base = math.random(0, 360),
            speed = math.random(5, 15) / 10,
            amp = math.random(3, 8),
            correct = codeData.isCorrect
        }
        if codeData.isCorrect then
            self.animPhases[i].speed = 0.5
            self.animPhases[i].amp = 2
            self.correctIndex = i
        end

        btn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(0, 40, 0, 200) or Color(0, 20, 0, 200)
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(0, 255, 0, 50)
            surface.DrawOutlinedRect(0, 0, w, h)

            draw.SimpleText(s.codeData.code, "DermaDefault", 10, h/2, Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local phase = self.animPhases[s.index]
            local offset = math.sin(CurTime() * phase.speed + phase.base) * phase.amp
            local barY = h/2 - 5 + offset
            surface.SetDrawColor(0, 255, 0, 200)
            surface.DrawRect(w - 100, barY, 80, 10)
        end

        btn.DoClick = function()
            net.Start("ixHashAnalysisResult")
                net.WriteUInt(i, 8)
            net.SendToServer()
            if IsValid(ix.gui.BigTerminal) then
                ix.gui.BigTerminal:HideGame()
            else
                self:Remove()
            end
        end

        table.insert(self.hashButtons, btn)
    end
end

vgui.Register("HashAnalysisFrame", HASH_PANEL, "DFrame")

net.Receive("ixHashAnalysisGame", function()
    local codes = net.ReadTable()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:ShowGame("HashAnalysisFrame", codes)
    else
        local frame = vgui.Create("HashAnalysisFrame")
        frame:SetHashData(codes)
    end
end)

-- ============================================================================
-- Cyberpunk 2077 hacking minigame
-- ============================================================================
local HACK_PANEL = {}

function HACK_PANEL:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)
    self:SetKeyboardInputEnabled(true)

    self.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 0, 5)
        for y = 0, h, 4 do
            surface.DrawRect(0, y, w, 1)
        end
    end

    function HACK_PANEL:OnKeyCodePressed(key)
        if key == KEY_ESCAPE then
            self:Remove()
        end
    end

    -- Главный контейнер с двумя колонками (сетка и цели)
    local main = self:Add("DPanel")
    main:Dock(FILL)
    main:DockMargin(5, 5, 5, 5)
    main.Paint = nil

    -- Левая колонка (сетка + буфер + таймер)
    local left = main:Add("DPanel")
    left:Dock(LEFT)
    left:SetWide(300)
    left.Paint = nil

    -- Сетка
    self.gridPanel = left:Add("DPanel")
    self.gridPanel:Dock(TOP)
    self.gridPanel:SetHeight(300)
    self.gridPanel:DockMargin(0, 0, 0, 5)
    self.gridPanel.Paint = function(s2, w2, h2)
        if not self.gridData then return end
        local cellSize = w2 / self.gridSize

        surface.SetDrawColor(10, 20, 10, 255)
        surface.DrawRect(0, 0, w2, h2)

        for y = 1, self.gridSize do
            for x = 1, self.gridSize do
                local sym = self.gridData[y][x]
                local cx = (x - 1) * cellSize
                local cy = (y - 1) * cellSize

                surface.SetDrawColor(0, 255, 0, 80)
                surface.DrawOutlinedRect(cx, cy, cellSize, cellSize)

                draw.SimpleText(sym, "DermaDefault", cx + cellSize/2, cy + cellSize/2,
                    Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if self.selectedX and self.selectedY then
            surface.SetDrawColor(0, 255, 0, 60)
            local cx = (self.selectedX - 1) * cellSize
            local cy = (self.selectedY - 1) * cellSize
            surface.DrawRect(cx, cy, cellSize, cellSize)
        end

        if self.path and #self.path > 1 then
            surface.SetDrawColor(0, 255, 0, 150)
            for i = 2, #self.path do
                local prev = self.path[i-1]
                local curr = self.path[i]
                local x1 = (prev.x - 0.5) * cellSize
                local y1 = (prev.y - 0.5) * cellSize
                local x2 = (curr.x - 0.5) * cellSize
                local y2 = (curr.y - 0.5) * cellSize
                surface.DrawLine(x1, y1, x2, y2)
            end
        end
    end

    self.gridPanel.OnMousePressed = function(s2, code)
        if code ~= MOUSE_LEFT then return end
        local mx, my = s2:CursorPos()
        local cellSize = s2:GetWide() / self.gridSize
        local x = math.floor(mx / cellSize) + 1
        local y = math.floor(my / cellSize) + 1
        if x < 1 or x > self.gridSize or y < 1 or y > self.gridSize then return end
        self:SelectCell(x, y)
    end

    -- Буфер
    self.bufferPanel = left:Add("DPanel")
    self.bufferPanel:Dock(TOP)
    self.bufferPanel:SetHeight(30)
    self.bufferPanel:DockMargin(0, 5, 0, 5)
    self.bufferPanel.Paint = function(s2, w2, h2)
        surface.SetDrawColor(0, 30, 0, 200)
        surface.DrawRect(0, 0, w2, h2)
        draw.SimpleText("BUFFER: " .. table.concat(self.buffer or {}, " "),
            "DermaDefaultBold", 5, 15, Color(0, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Таймер и кнопка Abort
    local bottomLeft = left:Add("DPanel")
    bottomLeft:Dock(TOP)
    bottomLeft:SetHeight(30)
    bottomLeft.Paint = nil

    self.timerLabel = bottomLeft:Add("DLabel")
    self.timerLabel:Dock(LEFT)
    self.timerLabel:SetWide(100)
    self.timerLabel:SetText("TIME: --")
    self.timerLabel:SetTextColor(Color(0, 255, 0))
    self.timerLabel:SetFont("DermaDefaultBold")
    self.timerLabel:SetContentAlignment(4)

    self.abortBtn = bottomLeft:Add("DButton")
    self.abortBtn:Dock(RIGHT)
    self.abortBtn:SetWide(80)
    self.abortBtn:SetText("ABORT")
    self.abortBtn:SetTextColor(Color(255, 0, 0))
    self.abortBtn:SetFont("DermaDefaultBold")
    self.abortBtn.Paint = function(s2, w2, h2)
        surface.SetDrawColor(s2:IsHovered() and Color(100, 0, 0, 200) or Color(50, 0, 0, 200))
        surface.DrawRect(0, 0, w2, h2)
        surface.SetDrawColor(Color(255, 0, 0, 100))
        surface.DrawOutlinedRect(0, 0, w2, h2)
    end
    self.abortBtn.DoClick = function()
        self:Fail("Hack aborted by user")
    end

    -- Правая колонка (цели)
    self.targetsPanel = main:Add("DPanel")
    self.targetsPanel:Dock(FILL)
    self.targetsPanel:DockMargin(5, 0, 0, 0)
    self.targetsPanel.Paint = function(s2, w2, h2)
        surface.SetDrawColor(0, 20, 0, 200)
        surface.DrawRect(0, 0, w2, h2)
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w2, h2)

        draw.SimpleText("TARGET SEQUENCES", "DermaDefaultBold", w2/2, 10,
            Color(0, 255, 0), TEXT_ALIGN_CENTER)

        if self.targets then
            local y = 30
            for i, target in ipairs(self.targets) do
                local color = target.completed and Color(0, 100, 0) or Color(0, 255, 0)
                local text = string.format("%d. %s", i, table.concat(target.sequence, " "))
                draw.SimpleText(text, "DermaDefault", 5, y, color)
                y = y + 20
            end
        end
    end

    -- Initialize variables
    self.buffer = {}
    self.path = {}
    self.selectedX, self.selectedY = nil, nil
    self.timerStarted = false
    self.startTime = nil
end

function HACK_PANEL:SetGameData(grid, targets, timeLimit)
    self.gridData = grid
    self.gridSize = #grid

    self.targets = {}
    for _, t in ipairs(targets or {}) do
        if t.sequence then
            table.insert(self.targets, t)
        else
            table.insert(self.targets, {
                sequence = t,
                completed = false
            })
        end
    end

    self.buffer = {}
    self.path = {}
    self.startTime = CurTime()
    self.timeLimit = timeLimit
end

function HACK_PANEL:StartTimer()
    timer.Create("CyberpunkHackTimer", 1, self.timeLimit, function()
        if not IsValid(self) then timer.Remove("CyberpunkHackTimer") return end
        local elapsed = CurTime() - self.startTime
        local remaining = math.max(0, self.timeLimit - math.floor(elapsed))
        self.timerLabel:SetText(string.format("TIME: %d", remaining))
        if remaining <= 0 then
            self:Fail("Time limit exceeded")
        end
    end)
end

function HACK_PANEL:SelectCell(x, y)
    if not self.timerStarted then
        self.startTime = CurTime()
        self.timerStarted = true
        self:StartTimer()
    end

    if self.selectedX and self.selectedY then
        if x ~= self.selectedX and y ~= self.selectedY then
            surface.PlaySound("buttons/button8.wav")
            return
        end
    end

    local sym = self.gridData[y][x]
    table.insert(self.buffer, sym)
    table.insert(self.path, {x = x, y = y})
    self.selectedX, self.selectedY = x, y
    surface.PlaySound("buttons/button15.wav")

    local bufferStr = table.concat(self.buffer)
    for _, target in ipairs(self.targets) do
        if not target.completed then
            local targetStr = table.concat(target.sequence)
            if bufferStr == targetStr then
                target.completed = true
                self.buffer = {}
                self.path = {}
                self.selectedX, self.selectedY = nil, nil
                surface.PlaySound("buttons/button9.wav")

                local allCompleted = true
                for _, t in ipairs(self.targets) do
                    if not t.completed then allCompleted = false break end
                end
                if allCompleted then
                    self:Win("Hack successful!")
                end
                break
            end
        end
    end
end

function HACK_PANEL:Win(msg)
    timer.Remove("CyberpunkHackTimer")
    net.Start("ixCyberpunkHackResult")
        net.WriteBool(true)
        net.WriteString(msg)
    net.SendToServer()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:HideGame()
    else
        self:Remove()
    end
end

function HACK_PANEL:Fail(msg)
    timer.Remove("CyberpunkHackTimer")
    net.Start("ixCyberpunkHackResult")
        net.WriteBool(false)
        net.WriteString(msg)
    net.SendToServer()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:HideGame()
    else
        self:Remove()
    end
end

vgui.Register("CyberpunkHackFrame", HACK_PANEL, "DFrame")

net.Receive("ixCyberpunkHackGame", function()
    local grid = net.ReadTable()
    local targets = net.ReadTable()
    local timeLimit = net.ReadUInt(16)
    local isTerminal = net.ReadBool()

    if isTerminal and IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:ShowGame("CyberpunkHackFrame", grid, targets, timeLimit)
        return
    end

    local frame = vgui.Create("CyberpunkHackFrame")
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.6)
    frame:Center()
    frame:MakePopup()
    frame:SetGameData(grid, targets, timeLimit)
end)

-- ============================================================================
-- Капча для уничтожения точки доступа
-- ============================================================================
net.Receive("ixAccessPointCaptcha", function()
    local captcha = net.ReadString()
    local code = net.ReadString()

    local captchaFrame = vgui.Create("DFrame")
    captchaFrame:SetSize(700, 250)
    captchaFrame:Center()
    captchaFrame:SetTitle("")
    captchaFrame:ShowCloseButton(false)
    captchaFrame:SetDraggable(false)
    captchaFrame:MakePopup()

    captchaFrame.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 20, 0, 250))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(255, 0, 0, 200))
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText("DESTROY ACCESS POINT", "DermaDefaultBold", w / 2, 25, Color(255, 0, 0), TEXT_ALIGN_CENTER)
        draw.SimpleText("Введите код для уничтожения точки:", "DermaDefault", w / 2, 55, Color(0, 255, 0), TEXT_ALIGN_CENTER)
    end

    local captchaLabel = captchaFrame:Add("DLabel")
    captchaLabel:SetPos(10, 80)
    captchaLabel:SetSize(680, 50)
    captchaLabel:SetText(captcha)
    captchaLabel:SetTextColor(Color(0, 255, 0))
    captchaLabel:SetFont("DermaDefaultBold")
    captchaLabel:SetContentAlignment(5)

    local captchaEntry = captchaFrame:Add("DTextEntry")
    captchaEntry:SetPos(10, 150)
    captchaEntry:SetSize(570, 35)
    captchaEntry:SetTextColor(Color(0, 255, 0))
    captchaEntry:SetFont("DermaDefault")
    captchaEntry:SetCursorColor(Color(0, 255, 0))

    captchaEntry.Paint = function(self, w, h)
        surface.SetDrawColor(Color(0, 30, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
        self:DrawTextEntryText(Color(0, 255, 0), Color(0, 100, 0), Color(0, 255, 0))
    end

    local submitBtn = captchaFrame:Add("DButton")
    submitBtn:SetPos(590, 150)
    submitBtn:SetSize(100, 35)
    submitBtn:SetText("SUBMIT")
    submitBtn:SetTextColor(Color(0, 255, 0))
    submitBtn:SetFont("DermaDefaultBold")

    submitBtn.Paint = function(self, w, h)
        surface.SetDrawColor(self:IsHovered() and Color(0, 80, 0, 200) or Color(0, 40, 0, 200))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 255, 0, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local function submit()
        net.Start("ixAccessPointCaptchaResult")
            net.WriteBool(captchaEntry:GetText() == captcha)
            net.WriteString(code)
        net.SendToServer()
        captchaFrame:Remove()
    end

    submitBtn.DoClick = submit
    captchaEntry.OnEnter = submit
    captchaEntry:RequestFocus()
end)

net.Receive("ixBigTerminalCaptchaResult", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:AddOutput({
            "",
            "═══════════════════════════════════════",
            success and "  [УСПЕХ] " .. message or "  [ОШИБКА] " .. message,
            "═══════════════════════════════════════",
            ""
        })
    end
end)

-- ============================================================================
-- Virus Creation Minigame (исправлена независимость)
-- ============================================================================
local VIRUS_PANEL = {}

function VIRUS_PANEL:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)

    self.blocks = {}
    self.selected = {}
    self.currentResult = nil
    self.currentIndex = nil
    self.opened = 0
    self.maxOpen = 6
    self.maxSelect = 3
    self.decoding = nil
    self.decodingStart = 0
    self.decodingDuration = 10

    -- Получаем список свойств (будет передан через SetPool)
    self.pool = {}

    -- Создаём 12 блоков (заполнятся позже)
    for i = 1, 12 do
        self.blocks[i] = {
            encrypted = "0x" .. math.random(1000, 9999),
            decoded = false,
            used = false,
            result = "unknown"
        }
    end

    -- Нижняя панель
    self.bottomPanel = self:Add("DPanel")
    self.bottomPanel:Dock(BOTTOM)
    self.bottomPanel:SetHeight(120)
    self.bottomPanel:DockMargin(10, 10, 10, 10)
    self.bottomPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 30, 0, 200))
        surface.SetDrawColor(0, 255, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        draw.SimpleText("ВЫБРАННЫЕ СВОЙСТВА:", "DermaDefaultBold", 10, 5, Color(0,255,0))
        local x = 10
        local plugin = ix.plugin.Get("big_terminal")
        for i, prop in ipairs(self.selected) do
            local propName = (plugin and plugin.virusProperties and plugin.virusProperties[prop] and plugin.virusProperties[prop].name) or prop
            draw.SimpleText(propName .. " (" .. i .. ")", "DermaDefault", x, 25, Color(0,255,0))
            x = x + 150
        end
    end

    -- Кнопки
    self.btnAdd = self.bottomPanel:Add("DButton")
    self.btnAdd:SetText("ДОБАВИТЬ")
    self.btnAdd:SetTextColor(Color(0,255,0))
    self.btnAdd:SetVisible(false)
    self.btnAdd.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(0,80,0,200) or Color(0,50,0,200))
        surface.SetDrawColor(0,255,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnAdd.DoClick = function()
        if self.currentResult and #self.selected < self.maxSelect then
            table.insert(self.selected, self.currentResult)
            if self.currentIndex then
                self.blocks[self.currentIndex].used = true
            end
            self.currentResult = nil
            self.currentIndex = nil
            self.btnAdd:SetVisible(false)
            self.btnReject:SetVisible(false)
            self:InvalidateLayout()
        end
    end

    self.btnReject = self.bottomPanel:Add("DButton")
    self.btnReject:SetText("ОТКЛОНИТЬ")
    self.btnReject:SetTextColor(Color(255,100,100))
    self.btnReject:SetVisible(false)
    self.btnReject.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(100,0,0,200) or Color(50,0,0,200))
        surface.SetDrawColor(255,0,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnReject.DoClick = function()
        if self.currentIndex then
            self.blocks[self.currentIndex].used = true
        end
        self.currentResult = nil
        self.currentIndex = nil
        self.btnAdd:SetVisible(false)
        self.btnReject:SetVisible(false)
        self:InvalidateLayout()
    end

    self.btnFinish = self.bottomPanel:Add("DButton")
    self.btnFinish:SetText("СОЗДАТЬ ВИРУС")
    self.btnFinish:SetTextColor(Color(0,255,0))
    self.btnFinish:SetVisible(false)
    self.btnFinish.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(0,100,0,200) or Color(0,70,0,200))
        surface.SetDrawColor(0,255,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnFinish.DoClick = function()
        self:Finish()
    end

    self.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,Color(0,0,0,240))
        draw.SimpleText("VIRUS DECRYPTION", "DermaDefaultBold", w/2, 10, Color(0,255,0), TEXT_ALIGN_CENTER)
    end
end

function VIRUS_PANEL:PerformLayout(w, h)
    local padding = 20
    local cols = 4
    local size = (w - padding * 2) / cols
    local startY = 40
    local bottomHeight = 120

    for i, block in ipairs(self.blocks) do
        if not IsValid(block.btn) then
            block.btn = self:Add("DButton")
            block.btn:SetText("")
            block.btn.DoClick = function() self:OnBlockClick(i) end
        end
        local x = ((i-1) % cols) * size + padding
        local y = math.floor((i-1) / cols) * size + startY
        block.btn:SetPos(x, y)
        block.btn:SetSize(size - 5, size - 5)

        block.btn.Paint = function(s, w2, h2)
            if block.used then
                surface.SetDrawColor(20, 20, 20, 200)
            elseif self.decoding == i then
                local elapsed = CurTime() - self.decodingStart
                local progress = math.Clamp(elapsed / self.decodingDuration, 0, 1)

                -- Фон с изменяющимся оттенком
                surface.SetDrawColor(0, 50 + 150 * progress, 0, 200)
                surface.DrawRect(0, 0, w2, h2)

                -- Прогресс-бар снизу
                surface.SetDrawColor(0, 255, 0, 200)
                surface.DrawRect(0, h2 - 5, w2 * progress, 5)

                -- Вращающийся спиннер (| / - \)
                local frames = {"|", "/", "-", "\\"}
                local frame = math.floor(elapsed * 4) % 4 + 1
                local spinner = frames[frame]

                -- Пульсирующая надпись "DECODING"
                local alpha = 150 + 105 * math.sin(elapsed * 5)
                draw.SimpleText("DECODING " .. spinner, "DermaDefault", w2/2, h2/2 - 10,
                    Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Процент выполнения
                draw.SimpleText(math.floor(progress * 100) .. "%", "DermaDefault", w2/2, h2/2 + 10,
                    Color(200, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Мигающая рамка
                surface.SetDrawColor(0, 255, 0, 100 + 155 * math.sin(elapsed * 8))
                surface.DrawOutlinedRect(0, 0, w2, h2)
            elseif block.decoded then
                if self.currentIndex == i then
                    surface.SetDrawColor(0, 100, 0, 200)
                else
                    surface.SetDrawColor(0, 60, 0, 200)
                end
            else
                surface.SetDrawColor(0, 30, 0, 200)
            end
            surface.DrawRect(0, 0, w2, h2)
            surface.SetDrawColor(0, 255, 0, 100)
            surface.DrawOutlinedRect(0, 0, w2, h2)

            local text
            if block.used then
                text = "x"
            elseif block.decoded then
                local plugin = ix.plugin.Get("big_terminal")
                local propName = (plugin and plugin.virusProperties and plugin.virusProperties[block.result] and plugin.virusProperties[block.result].name) or block.result
                text = propName
            else
                text = block.encrypted
            end
            draw.SimpleText(text, "DermaDefault", w2/2, h2/2, Color(0,255,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local panel = self.bottomPanel
    panel:SetPos(padding, h - bottomHeight - 10)
    panel:SetSize(w - padding * 2, bottomHeight)

    local btnW = 120
    local btnH = 30
    local btnY = panel:GetTall() - btnH - 10
    self.btnAdd:SetPos(10, btnY)
    self.btnAdd:SetSize(btnW, btnH)
    self.btnReject:SetPos(10 + btnW + 10, btnY)
    self.btnReject:SetSize(btnW, btnH)
    self.btnFinish:SetPos(panel:GetWide() - btnW - 10, btnY)
    self.btnFinish:SetSize(btnW, btnH)

    self.btnAdd:SetVisible(self.currentResult ~= nil and #self.selected < self.maxSelect)
    self.btnReject:SetVisible(self.currentResult ~= nil)
    self.btnFinish:SetVisible(#self.selected > 0)
end

function VIRUS_PANEL:SetPool(pool)
    self.pool = pool or {}
    if #self.pool == 0 then
        print("[VIRUS ERROR] pool пуст")
        return
    end
    for i = 1, 12 do
        local block = self.blocks[i]
        block.encrypted = "0x" .. math.random(1000, 9999)
        block.decoded = false
        block.used = false
        block.result = self.pool[math.random(#self.pool)]
        if IsValid(block.btn) then
            block.btn:SetText(block.encrypted)
        end
    end
    self:InvalidateLayout()
end

function VIRUS_PANEL:OnBlockClick(index)
    local block = self.blocks[index]
    if block.used then return end
    if self.decoding then return end
    if block.decoded then
        self.currentResult = block.result
        self.currentIndex = index
        self:InvalidateLayout()
        return
    end
    if self.opened >= self.maxOpen then return end

    self.decoding = index
    self.decodingStart = CurTime()
    timer.Create("VirusDecode" .. index, self.decodingDuration, 1, function()
        if not IsValid(self) then return end
        block.decoded = true
        self.opened = self.opened + 1
        self.decoding = nil
        self.currentResult = block.result
        self.currentIndex = index
        surface.PlaySound("buttons/button15.wav")
        self:InvalidateLayout()
    end)
    self:InvalidateLayout()
end

function VIRUS_PANEL:Finish()
    if #self.selected == 0 then return end
    net.Start("ixVirusCreateResult")
    net.WriteTable(self.selected)
    net.SendToServer()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:HideGame()
    else
        self:Remove()
    end
end

vgui.Register("VirusCreateFrame", VIRUS_PANEL, "DFrame")

-- ============================================================================
-- Полноценная панель создания антивируса (исправлена)
-- ============================================================================
local ANTIVIRUS_PANEL = {}

function ANTIVIRUS_PANEL:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)

    self.blocks = {}
    self.selected = {}
    self.currentResult = nil
    self.currentIndex = nil
    self.opened = 0
    self.maxOpen = 6
    self.maxSelect = 3
    self.decoding = nil
    self.decodingStart = 0
    self.decodingDuration = 8

    self.pool = {}

    for i = 1, 12 do
        self.blocks[i] = {
            encrypted = "0x" .. math.random(1000, 9999),
            decoded = false,
            used = false,
            result = "unknown"
        }
    end

    self.bottomPanel = self:Add("DPanel")
    self.bottomPanel:Dock(BOTTOM)
    self.bottomPanel:SetHeight(120)
    self.bottomPanel:DockMargin(10, 10, 10, 10)
    self.bottomPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0,30,0,200))
        surface.SetDrawColor(0,255,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
        draw.SimpleText("ВЫБРАННЫЕ СВОЙСТВА АНТИВИРУСА:", "DermaDefaultBold", 10, 5, Color(0,255,0))
        local x = 10
        local plugin = ix.plugin.Get("big_terminal")
        for i, prop in ipairs(self.selected) do
            local propName = (plugin and plugin.antivirusProperties and plugin.antivirusProperties[prop] and plugin.antivirusProperties[prop].name) or prop
            draw.SimpleText(propName .. " (" .. i .. ")", "DermaDefault", x, 25, Color(0,255,0))
            x = x + 150
        end
    end

    self.btnAdd = self.bottomPanel:Add("DButton")
    self.btnAdd:SetText("ДОБАВИТЬ")
    self.btnAdd:SetTextColor(Color(0,255,0))
    self.btnAdd:SetVisible(false)
    self.btnAdd.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(0,80,0,200) or Color(0,50,0,200))
        surface.SetDrawColor(0,255,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnAdd.DoClick = function()
        if self.currentResult and #self.selected < self.maxSelect then
            table.insert(self.selected, self.currentResult)
            if self.currentIndex then
                self.blocks[self.currentIndex].used = true
            end
            self.currentResult = nil
            self.currentIndex = nil
            self.btnAdd:SetVisible(false)
            self.btnReject:SetVisible(false)
            self:InvalidateLayout()
        end
    end

    self.btnReject = self.bottomPanel:Add("DButton")
    self.btnReject:SetText("ОТКЛОНИТЬ")
    self.btnReject:SetTextColor(Color(255,100,100))
    self.btnReject:SetVisible(false)
    self.btnReject.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(100,0,0,200) or Color(50,0,0,200))
        surface.SetDrawColor(255,0,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnReject.DoClick = function()
        if self.currentIndex then
            self.blocks[self.currentIndex].used = true
        end
        self.currentResult = nil
        self.currentIndex = nil
        self.btnAdd:SetVisible(false)
        self.btnReject:SetVisible(false)
        self:InvalidateLayout()
    end

    self.btnFinish = self.bottomPanel:Add("DButton")
    self.btnFinish:SetText("СОЗДАТЬ АНТИВИРУС")
    self.btnFinish:SetTextColor(Color(0,255,0))
    self.btnFinish:SetVisible(false)
    self.btnFinish.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,s:IsHovered() and Color(0,100,0,200) or Color(0,70,0,200))
        surface.SetDrawColor(0,255,0,100)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    self.btnFinish.DoClick = function()
        if #self.selected == 0 then return end
        net.Start("ixAntivirusCreateResult")
        net.WriteTable(self.selected)
        net.SendToServer()
        if IsValid(ix.gui.BigTerminal) then
            ix.gui.BigTerminal:HideGame()
        else
            self:Remove()
        end
    end

    self.Paint = function(s,w,h)
        draw.RoundedBox(4,0,0,w,h,Color(0,0,0,240))
        draw.SimpleText("АНТИВИРУС: ДЕКОДИРОВАНИЕ", "DermaDefaultBold", w/2, 10, Color(0,255,0), TEXT_ALIGN_CENTER)
    end
end

function ANTIVIRUS_PANEL:PerformLayout(w, h)
    local padding = 20
    local cols = 4
    local size = (w - padding * 2) / cols
    local startY = 40
    local bottomHeight = 120

    for i, block in ipairs(self.blocks) do
        if not IsValid(block.btn) then
            block.btn = self:Add("DButton")
            block.btn:SetText("")
            block.btn.DoClick = function() self:OnBlockClick(i) end
        end
        local x = ((i-1) % cols) * size + padding
        local y = math.floor((i-1) / cols) * size + startY
        block.btn:SetPos(x, y)
        block.btn:SetSize(size - 5, size - 5)

        block.btn.Paint = function(s, w2, h2)
            if block.used then
                surface.SetDrawColor(20, 20, 20, 200)
            elseif self.decoding == i then
                local elapsed = CurTime() - self.decodingStart
                local progress = math.Clamp(elapsed / self.decodingDuration, 0, 1)

                -- Фон с изменяющимся оттенком
                surface.SetDrawColor(0, 50 + 150 * progress, 0, 200)
                surface.DrawRect(0, 0, w2, h2)

                -- Прогресс-бар снизу
                surface.SetDrawColor(0, 255, 0, 200)
                surface.DrawRect(0, h2 - 5, w2 * progress, 5)

                -- Вращающийся спиннер (| / - \)
                local frames = {"|", "/", "-", "\\"}
                local frame = math.floor(elapsed * 4) % 4 + 1
                local spinner = frames[frame]

                -- Пульсирующая надпись "DECODING"
                local alpha = 150 + 105 * math.sin(elapsed * 5)
                draw.SimpleText("DECODING " .. spinner, "DermaDefault", w2/2, h2/2 - 10,
                    Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Процент выполнения
                draw.SimpleText(math.floor(progress * 100) .. "%", "DermaDefault", w2/2, h2/2 + 10,
                    Color(200, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Мигающая рамка
                surface.SetDrawColor(0, 255, 0, 100 + 155 * math.sin(elapsed * 8))
                surface.DrawOutlinedRect(0, 0, w2, h2)
            elseif block.decoded then
                if self.currentIndex == i then
                    surface.SetDrawColor(0, 100, 0, 200)
                else
                    surface.SetDrawColor(0, 60, 0, 200)
                end
            else
                surface.SetDrawColor(0, 30, 0, 200)
            end
            surface.DrawRect(0, 0, w2, h2)
            surface.SetDrawColor(0, 255, 0, 100)
            surface.DrawOutlinedRect(0, 0, w2, h2)

            local text
            if block.used then
                text = "x"
            elseif block.decoded then
                local plugin = ix.plugin.Get("big_terminal")
                local propName = (plugin and plugin.antivirusProperties and plugin.antivirusProperties[block.result] and plugin.antivirusProperties[block.result].name) or block.result
                text = propName
            else
                text = block.encrypted
            end
            draw.SimpleText(text, "DermaDefault", w2/2, h2/2, Color(0,255,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local panel = self.bottomPanel
    panel:SetPos(padding, h - bottomHeight - 10)
    panel:SetSize(w - padding * 2, bottomHeight)

    local btnW = 120
    local btnH = 30
    local btnY = panel:GetTall() - btnH - 10
    self.btnAdd:SetPos(10, btnY)
    self.btnAdd:SetSize(btnW, btnH)
    self.btnReject:SetPos(10 + btnW + 10, btnY)
    self.btnReject:SetSize(btnW, btnH)
    self.btnFinish:SetPos(panel:GetWide() - btnW - 10, btnY)
    self.btnFinish:SetSize(btnW, btnH)

    self.btnAdd:SetVisible(self.currentResult ~= nil and #self.selected < self.maxSelect)
    self.btnReject:SetVisible(self.currentResult ~= nil)
    self.btnFinish:SetVisible(#self.selected > 0)
end

function ANTIVIRUS_PANEL:SetPool(pool)
    self.pool = pool or {}
    if #self.pool == 0 then
        print("[ANTIVIRUS ERROR] pool пуст")
        return
    end
    for i = 1, 12 do
        local block = self.blocks[i]
        block.encrypted = "0x" .. math.random(1000, 9999)
        block.decoded = false
        block.used = false
        block.result = self.pool[math.random(#self.pool)]
        if IsValid(block.btn) then
            block.btn:SetText(block.encrypted)
        end
    end
    self:InvalidateLayout()
end

function ANTIVIRUS_PANEL:OnBlockClick(index)
    local block = self.blocks[index]
    if block.used then return end
    if self.decoding then return end
    if block.decoded then
        self.currentResult = block.result
        self.currentIndex = index
        self:InvalidateLayout()
        return
    end
    if self.opened >= self.maxOpen then return end

    self.decoding = index
    self.decodingStart = CurTime()
    timer.Create("AntivirusDecode" .. index, self.decodingDuration, 1, function()
        if not IsValid(self) then return end
        block.decoded = true
        self.opened = self.opened + 1
        self.decoding = nil
        self.currentResult = block.result
        self.currentIndex = index
        surface.PlaySound("buttons/button15.wav")
        self:InvalidateLayout()
    end)
    self:InvalidateLayout()
end

vgui.Register("AntivirusCreateFrame", ANTIVIRUS_PANEL, "DFrame")

-- ============================================================================
-- Обработчики вызова мини-игр
-- ============================================================================

net.Receive("ixVirusCreateUI", function()
    local pool = net.ReadTable()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:ShowGame("VirusCreateFrame", pool)
    else
        local frame = vgui.Create("VirusCreateFrame")
        frame:SetPool(pool)
        frame:SetSize(ScrW() * 0.4, ScrH() * 0.6)
        frame:Center()
        frame:MakePopup()
    end
end)

net.Receive("ixAntivirusCreateUI", function()
    local pool = net.ReadTable()
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:ShowGame("AntivirusCreateFrame", pool)
    else
        local frame = vgui.Create("AntivirusCreateFrame")
        frame:SetPool(pool)
        frame:SetSize(ScrW() * 0.4, ScrH() * 0.6)
        frame:Center()
        frame:MakePopup()
    end
end)

net.Receive("ixPlayerStats", function()
    local stats = net.ReadTable()
    LocalPlayer().terminalStats = stats
end)

-- ============================================================================
-- Мини-игра лабиринта для апгрейда
-- ============================================================================
local MAZE_PANEL = {}

function MAZE_PANEL:Init()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(false)
    
    self.maze = nil
    self.cellSize = 20
    self.playerX = 2
    self.playerY = 2
    self.mazeWidth = 20
    self.mazeHeight = 20
    self.upgradeIndex = 0
    self.upgradeType = ""
    self.upgradeProp = ""
    self.cost = 0
    self.path = {{x = 2, y = 2}}
    self.offsetX = 0
    self.offsetY = 70
    
    self.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 240))
        draw.SimpleText("UPGRADE MAZE", "DermaDefaultBold", w/2, 15, Color(0, 255, 0), TEXT_ALIGN_CENTER)
        draw.SimpleText("Кликайте на ячейки чтобы построить путь от S до E", "DermaDefault", w/2, 35, Color(0, 255, 0, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("Стоимость: " .. self.cost .. " кредитов", "DermaDefault", w/2, 50, Color(255, 255, 0), TEXT_ALIGN_CENTER)
    end
    
    -- Кнопка отмены
    self.btnCancel = self:Add("DButton")
    self.btnCancel:SetText("ОТМЕНА")
    self.btnCancel:SetTextColor(Color(255, 100, 100))
    self.btnCancel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and Color(100, 0, 0, 200) or Color(50, 0, 0, 200))
        surface.SetDrawColor(255, 0, 0, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    self.btnCancel.DoClick = function()
        net.Start("ixMazeUpgradeResult")
            net.WriteBool(false)
        net.SendToServer()
        if IsValid(ix.gui.BigTerminal) then
            ix.gui.BigTerminal:HideGame()
        else
            self:Remove()
        end
    end
end

function MAZE_PANEL:PerformLayout(w, h)
    self.btnCancel:SetPos(w - 100, h - 40)
    self.btnCancel:SetSize(90, 30)
end

function MAZE_PANEL:SetMazeData(index, upgradeType, prop, cost, maze)
    self.upgradeIndex = index
    self.upgradeType = upgradeType
    self.upgradeProp = prop
    self.cost = cost
    self.maze = maze
    self.mazeWidth = #maze[1]
    self.mazeHeight = #maze
    self.playerX = 2
    self.playerY = 2
    self.path = {{x = 2, y = 2}}
    
    -- Размер ячейки
    local maxCellW = (self:GetWide() - 40) / self.mazeWidth
    local maxCellH = (self:GetTall() - 120) / self.mazeHeight
    self.cellSize = math.min(maxCellW, maxCellH, 25)
    
    -- Запрашиваем фокус после установки данных
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:RequestFocus()
        end
    end)
end

function MAZE_PANEL:PaintOver(w, h)
    if not self.maze then return end
    
    local offsetX = (w - self.mazeWidth * self.cellSize) / 2
    local offsetY = 70
    
    -- Рисуем лабиринт
    for y = 1, self.mazeHeight do
        for x = 1, self.mazeWidth do
            local cell = self.maze[y][x]
            local px = offsetX + (x - 1) * self.cellSize
            local py = offsetY + (y - 1) * self.cellSize
            
            if cell == 1 then
                -- Стена
                surface.SetDrawColor(30, 30, 30, 255)
                surface.DrawRect(px, py, self.cellSize, self.cellSize)
                surface.SetDrawColor(0, 100, 0, 100)
                surface.DrawOutlinedRect(px, py, self.cellSize, self.cellSize)
            elseif cell == 0 then
                -- Проход
                surface.SetDrawColor(10, 20, 10, 255)
                surface.DrawRect(px, py, self.cellSize, self.cellSize)
            elseif cell == 2 then
                -- Старт
                surface.SetDrawColor(0, 150, 0, 255)
                surface.DrawRect(px, py, self.cellSize, self.cellSize)
                draw.SimpleText("S", "DermaDefaultBold", px + self.cellSize/2, py + self.cellSize/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            elseif cell == 3 then
                -- Финиш
                surface.SetDrawColor(150, 0, 0, 255)
                surface.DrawRect(px, py, self.cellSize, self.cellSize)
                draw.SimpleText("E", "DermaDefaultBold", px + self.cellSize/2, py + self.cellSize/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
    
    -- Рисуем путь
    if self.path and #self.path > 1 then
        surface.SetDrawColor(0, 255, 0, 200)
        for i = 2, #self.path do
            local prev = self.path[i-1]
            local curr = self.path[i]
            local x1 = offsetX + (prev.x - 0.5) * self.cellSize
            local y1 = offsetY + (prev.y - 0.5) * self.cellSize
            local x2 = offsetX + (curr.x - 0.5) * self.cellSize
            local y2 = offsetY + (curr.y - 0.5) * self.cellSize
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
    
    -- Рисуем игрока
    local playerPx = offsetX + (self.playerX - 0.5) * self.cellSize
    local playerPy = offsetY + (self.playerY - 0.5) * self.cellSize
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawCircle(playerPx, playerPy, self.cellSize / 3, Color(0, 255, 0))
end

function MAZE_PANEL:OnKeyCodePressed(key)
    if not self.maze then return end
    
    local newX, newY = self.playerX, self.playerY
    
    if key == KEY_UP or key == KEY_W then
        newY = self.playerY - 1
    elseif key == KEY_DOWN or key == KEY_S then
        newY = self.playerY + 1
    elseif key == KEY_LEFT or key == KEY_A then
        newX = self.playerX - 1
    elseif key == KEY_RIGHT or key == KEY_D then
        newX = self.playerX + 1
    end
    
    -- Проверка границ
    if newX < 1 or newX > self.mazeWidth or newY < 1 or newY > self.mazeHeight then
        return
    end
    
    -- Проверка стены
    if self.maze[newY][newX] == 1 then
        surface.PlaySound("buttons/button8.wav")
        return
    end
    
    -- Проверка на возврат назад
    if #self.path > 1 and self.path[#self.path].x == newX and self.path[#self.path].y == newY then
        -- Возвращаемся назад
        table.remove(self.path)
        self.playerX = newX
        self.playerY = newY
        surface.PlaySound("buttons/button15.wav")
        return
    end
    
    -- Проверка на пересечение пути
    for i, p in ipairs(self.path) do
        if p.x == newX and p.y == newY then
            surface.PlaySound("buttons/button8.wav")
            return
        end
    end
    
    -- Двигаемся
    self.playerX = newX
    self.playerY = newY
    table.insert(self.path, {x = newX, y = newY})
    surface.PlaySound("buttons/button15.wav")
    
    -- Проверка финиша
    if self.maze[newY][newX] == 3 then
        self:OnWin()
    end
end

function MAZE_PANEL:OnWin()
    surface.PlaySound("buttons/button9.wav")
    
    net.Start("ixMazeUpgradeResult")
        net.WriteBool(true)
    net.SendToServer()
    
    if IsValid(ix.gui.BigTerminal) then
        ix.gui.BigTerminal:HideGame()
    else
        self:Remove()
    end
end

vgui.Register("MazeUpgradeFrame", MAZE_PANEL, "DFrame")

net.Receive("ixMazeUpgradeGame", function()
    local index = net.ReadUInt(8)
    local upgradeType = net.ReadString()
    local prop = net.ReadString()
    local cost = net.ReadUInt(16)
    local maze = net.ReadTable()
    
    local frame
    
    if IsValid(ix.gui.BigTerminal) then
        frame = ix.gui.BigTerminal:ShowGame("MazeUpgradeFrame")
    else
        frame = vgui.Create("MazeUpgradeFrame")
        frame:SetSize(ScrW() * 0.5, ScrH() * 0.7)
        frame:Center()
        frame:MakePopup()
    end
    
    if IsValid(frame) then
        frame:SetMazeData(index, upgradeType, prop, cost, maze)
    end
end)
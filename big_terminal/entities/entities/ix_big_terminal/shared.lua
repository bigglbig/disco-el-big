ENT.Type = "anim"
ENT.Author = "Big.txt"
ENT.PrintName = "Терминал"
ENT.Category = "H13"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
ENT.bNoPersist = true

-- 3D Text configuration
ENT.TextOffsetX = 4.5
ENT.TextOffsetY = 28.8
ENT.TextOffsetZ = -7
ENT.TextAnglePitch = 0
ENT.TextAngleYaw = 0
ENT.TextAngleRoll = 90
ENT.TextScale = 0.07

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Display")
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("String", 1, "DisplayName")
    self:NetworkVar("String", 2, "Description")
end

if SERVER then
    util.AddNetworkString("ixBigTerminalOpen")
    util.AddNetworkString("ixBigTerminalClose")
    
    function ENT:Initialize()
        self:SetModel("models/bybig/monitor_2.mdl")
        self:SetUseType(SIMPLE_USE)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:DrawShadow(true)
        self:SetSolid(SOLID_BBOX)
        self:PhysicsInit(SOLID_BBOX)
        self:SetDisplay(1)
        self:SetDisplayName("Терминал")
        self:SetDescription("С виду обычный компьютер, но с секретом под капотом.")
        
        local phys = self:GetPhysicsObject()
        if (IsValid(phys)) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
        
        self.canUse = true
        
        -- Включаем сохранение через Helix
        -- self:SetPersistent(true)
    end
    
    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        local char = activator:GetCharacter()
        if not char then return end
        
        if activator.CantPlace then
            activator:Notify("Подождите перед использованием!")
            return
        end
        
        activator.CantPlace = true
        timer.Simple(3, function()
            if IsValid(activator) then
                activator.CantPlace = false
            end
        end)
        
        if not self.canUse then
            return
        end
        
        self:EmitSound("buttons/button1.wav")
        
        net.Start("ixBigTerminalOpen")
            net.WriteEntity(self)
        net.Send(activator)
        
        activator.activeTerminal = self
    end
    
    -- Убираем вызов сохранения из OnRemove – Helix сделает это сам
    function ENT:OnRemove()
        -- Пусто, ничего не делаем
    end
    
    -- Сохраняемые данные
    function ENT:OnSave()
        return {
            displayName = self:GetDisplayName(),
            description = self:GetDescription()
        }
    end
    
    -- Восстановление
    function ENT:OnRestore(data)
        if data.displayName then
            self:SetDisplayName(data.displayName)
        end
        if data.description then
            self:SetDescription(data.description)
        end
    end
    
    net.Receive("ixBigTerminalClose", function(len, ply)
        if IsValid(ply.activeTerminal) then
            ply.activeTerminal.canUse = true
        end
        ply.activeTerminal = nil
    end)
else
    -- Client side (без изменений)
    net.Receive("ixBigTerminalOpen", function(len)
        local terminalEntity = net.ReadEntity()
        LocalPlayer().activeTerminal = terminalEntity
        if IsValid(ix.gui.BigTerminal) then
            ix.gui.BigTerminal:Remove()
        end
        vgui.Create("BigTerminalFrame")
    end)
    
    function ENT:Draw()
        self:DrawModel()
        local offsetX = self.TextOffsetX or 0
        local offsetY = self.TextOffsetY or 0
        local offsetZ = self.TextOffsetZ or 0
        local pitch = self.TextAnglePitch or 0
        local yaw = self.TextAngleYaw or 0
        local roll = self.TextAngleRoll or 0
        local scale = self.TextScale or 0.1
        
        local ang = self:GetAngles()
        local pos = self:GetPos() + ang:Up() * offsetY + ang:Forward() * offsetZ + ang:Right() * offsetX
        
        ang:RotateAroundAxis(ang:Right(), pitch)
        ang:RotateAroundAxis(ang:Up(), yaw)
        ang:RotateAroundAxis(ang:Forward(), roll)
        
        cam.Start3D2D(pos, ang, scale)
            surface.SetDrawColor(Color(0, 0, 0, 240))
            surface.DrawRect(0, 0, 200, 150)
            surface.SetDrawColor(Color(0, 255, 0, 50))
            local scanY = (CurTime() * 50) % 150
            surface.DrawRect(0, scanY, 200, 2)
            surface.SetTextColor(Color(0, 255, 0, 200))
            surface.SetFont("DermaDefault")
            surface.SetTextPos(10, 65)
            surface.DrawText("TERMINAL v2.0")
            surface.SetTextPos(10, 80)
            surface.DrawText("READY...")
        cam.End3D2D()
    end

    ENT.PopulateEntityInfo = true
    function ENT:OnPopulateEntityInfo(container)
        local name = container:AddRow("name")
        name:SetImportant()
        name:SetText(self:GetDisplayName())
        name:SizeToContents()

        local descriptionText = self:GetDescription()
        if descriptionText != "" then
            local description = container:AddRow("description")
            description:SetText(descriptionText)
            description:SizeToContents()
        end
    end
end
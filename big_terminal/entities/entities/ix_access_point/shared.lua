ENT.Type = "anim"
ENT.Author = "Big.txt"
ENT.PrintName = "Точка доступа"
ENT.Category = "H13"
ENT.Spawnable = true
ENT.AdminOnly = true
-- ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "AccessCode")
    self:NetworkVar("Float", 0, "CodeExpireTime")
    self:NetworkVar("Int", 0, "OwnerID")
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("String", 1, "DisplayName")
    self:NetworkVar("String", 2, "Description")
    self:NetworkVar("String", 3, "MasterKey")
    self:NetworkVar("Float", 1, "MasterKeyExpire")  
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_lab/reciever01b.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_BBOX)
        self:PhysicsInit(SOLID_BBOX)
        self:SetUseType(SIMPLE_USE)
        self:SetHealth(100)
        self:SetMaxHealth(100)
        self:SetDisplayName("Точка доступа")
        self:SetDescription("Небольшая коробочка с кучей проводов и микросхем.")

        local physObj = self:GetPhysicsObject()
        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        self:GenerateNewCode()
        
        -- Включаем сохранение через Helix
        -- self:SetPersistent(true)
    end

    function ENT:GenerateNewCode()
        local code = string.format("%06d", math.random(0, 999999))
        self:SetAccessCode(code)
        local expire = CurTime() + math.random(1800, 3600)
        self:SetCodeExpireTime(expire)
        return code
    end

    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        local char = activator:GetCharacter()
        if not char then return end
        local PLUGIN = ix.plugin.Get("big_terminal")
        if PLUGIN then
            PLUGIN:StartAccessPointHack(activator, self)
        end
    end

    function ENT:OnTakeDamage(dmgInfo)
        self:SetHealth(self:Health() - dmgInfo:GetDamage())
        if self:Health() <= 0 then
            self:Explode()
            self:Remove()
        end
    end

    function ENT:Explode()
        local pos = self:GetPos()
        local ed = EffectData()
        ed:SetOrigin(pos)
        ed:SetMagnitude(1)
        ed:SetScale(1)
        util.Effect("Explosion", ed, true, true)
        self:EmitSound("ambient/explosions/explode_3.wav", 75, 100)
        for _, ent in ipairs(ents.FindInSphere(pos, 50)) do
            if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
                local dmg = DamageInfo()
                dmg:SetDamage(10)
                dmg:SetAttacker(self)
                dmg:SetInflictor(self)
                dmg:SetDamageType(DMG_BLAST)
                ent:TakeDamageInfo(dmg)
            end
        end
    end

    function ENT:Think()
        if self:GetCodeExpireTime() < CurTime() then
            self:GenerateNewCode()
        end
        self:NextThink(CurTime() + 10)
        return true
    end

    -- Убираем вызов сохранения из OnRemove
    function ENT:OnRemove() end

    -- Сохраняемые данные
    function ENT:OnSave()
        return {
            displayName = self:GetDisplayName(),
            description = self:GetDescription(),
            owner = self:GetOwnerID(),
            code = self:GetAccessCode(),
            expire = self:GetCodeExpireTime()
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
        if data.owner then
            self:SetOwnerID(data.owner)
        end
        if data.code then
            self:SetAccessCode(data.code)
        end
        if data.expire then
            self:SetCodeExpireTime(data.expire)
        end
    end
else
    function ENT:Draw()
        self:DrawModel()
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
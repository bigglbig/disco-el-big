-- SERVER

print('[Big Neo] sv_plugin.lua loading...')

local function GetPlugin()
    return ix.plugin.Get('big_neo')
end

-- ФУНКЦИЯ УКЛОНЕНИЯ
local function DoDash(ply, dir, isHeadshot, side)
    if not IsValid(ply) then return end
    local plugin = GetPlugin()
    if not plugin then return end
    local id = ply:SteamID()
    if plugin.dashCooldowns[id] and plugin.dashCooldowns[id] > CurTime() then return end
    plugin.dashCooldowns[id] = CurTime() + 0.3
    local microShift = -ply:GetForward() * 5
    ply:SetPos(ply:GetPos() + microShift)
    net.Start('BigNeo_DodgeVisual')
        net.WriteEntity(ply)
        net.WriteVector(dir)
        net.WriteBool(isHeadshot or false)
        net.WriteFloat(side or 0)
    net.Broadcast()
    print('[Big Neo] Dodge for ' .. ply:Name() .. ' isHead=' .. tostring(isHeadshot))
end

local function IsNeoMode(ply)
    if not IsValid(ply) then return false end
    local plugin = GetPlugin()
    if not plugin then return false end
    return plugin.neoModePlayers[ply:SteamID()] == true or ply:GetNWBool('BigNeoMode', false)
end

-- BULLET TRACE
hook.Add('EntityFireBullets', 'BigNeo_TraceHeadshot', function(attacker, data)
    if not IsValid(attacker) then return end
    local start = data.Src
    local dir = data.Dir
    for _, ply in ipairs(player.GetAll()) do
        if ply == attacker then continue end
        if not IsNeoMode(ply) then continue end
        local headPos = ply:LookupBone('ValveBiped.Bip01_Head1')
        if headPos then headPos = ply:GetBonePosition(headPos) else headPos = ply:EyePos() end
        local bodyPos = ply:GetPos() + Vector(0,0,40)
        local toHead = headPos - start
        local proj = toHead:Dot(dir)
        if proj < 0 or proj > 2000 then continue end
        local closest = start + dir * proj
        local distHead = headPos:Distance(closest)
        local distBody = bodyPos:Distance(closest)
        if distHead < 25 then
            local side = (closest - ply:GetPos()):Dot(ply:GetRight()) > 0 and 1 or -1
            DoDash(ply, dir, true, side)
        elseif distBody < 40 then
            local side = (closest - ply:GetPos()):Dot(ply:GetRight()) > 0 and 1 or -1
            DoDash(ply, dir, false, side)
        end
    end
end)

-- NPC AIM DODGE
hook.Add('Think', 'BigNeo_NPC_AimDetect', function()
    for _, npc in ipairs(ents.GetAll()) do
        if not npc:IsNPC() then continue end
        local enemy = npc:GetEnemy()
        if not IsValid(enemy) or not enemy:IsPlayer() then continue end
        if not IsNeoMode(enemy) then continue end
        local npcPos = npc.GetShootPos and npc:GetShootPos() or npc:GetPos() + Vector(0,0,60)
        local dir = npc:GetForward()
        local tr = util.TraceLine({start = npcPos, endpos = npcPos + dir * 1500, filter = npc})
        if tr.Entity == enemy then
            local side = math.random() > 0.5 and 1 or -1
            DoDash(enemy, dir, false, side)
        end
    end
end)

-- ABSOLUTE IMMUNITY
hook.Add('EntityTakeDamage', 'BigNeo_AbsoluteImmunity', function(target, dmg)
    if not IsValid(target) or not target:IsPlayer() then return end
    if not IsNeoMode(target) then return end
    print('[Big Neo] BLOCKING DAMAGE for ' .. target:Name())
    dmg:SetDamage(0)
    dmg:ScaleDamage(0)
    local attacker = dmg:GetAttacker()
    local dir = IsValid(attacker) and (target:GetPos() - attacker:GetPos()):GetNormalized() or VectorRand()
    local side = math.random() > 0.5 and 1 or -1
    DoDash(target, dir, false, side)
    return true
end)

hook.Add('PlayerShouldTakeDamage', 'BigNeo_PlayerNoDamage', function(ply, attacker)
    if not IsValid(ply) then return end
    if IsNeoMode(ply) then return false end
end)

-- INVIS
hook.Add('ShouldCollide', 'BigNeo_InvisNoCollision', function(ent1, ent2)
    if not IsValid(ent1) or not IsValid(ent2) then return end
    local plugin = GetPlugin()
    if not plugin then return end
    if ent1:IsPlayer() and plugin.invisModePlayers[ent1:SteamID()] then return false end
    if ent2:IsPlayer() and plugin.invisModePlayers[ent2:SteamID()] then return false end
end)


-- Восстановление режимов после спавна
hook.Add('PlayerSpawn', 'BigNeo_RestoreModes', function(ply)
    if not IsValid(ply) then return end
    local plugin = GetPlugin()
    if not plugin then return end
    local steamID = ply:SteamID()
    
    if plugin.neoModePlayers[steamID] then
        timer.Simple(0.5, function()
            if IsValid(ply) then ply:SetNWBool('BigNeoMode', true) end
        end)
    end
    
    if plugin.invisModePlayers[steamID] then
        timer.Simple(0.5, function()
            if IsValid(ply) then
                local targetPly = plugin.invisModePlayers[steamID].targetPly
                if IsValid(targetPly) then
                    ply:SetNWBool('BigNeoInvisMode', true)
                    ply:SetNWEntity('BigNeoInvisTarget', targetPly)
                    ply:SetNotSolid(true)
                    ply:DrawShadow(false)
                end
            end
        end)
    end
end)

hook.Add('PlayerDisconnected', 'BigNeo_PlayerDisconnect', function(ply)
    if not IsValid(ply) then return end
    local plugin = GetPlugin()
    if not plugin then return end
    local steamID = ply:SteamID()
    plugin.neoModePlayers[steamID] = nil
    plugin.invisModePlayers[steamID] = nil
end)

print('[Big Neo] sv_plugin.lua loaded!')
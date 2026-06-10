-- CLIENT - WESKER STYLE DODGE

local holograms = {}
local boneCache = {}

-- GOLOGRAMS
local function CreateHolo(ply, dir)
    local m = ClientsideModel(ply:GetModel(), RENDERGROUP_TRANSLUCENT)
    if not IsValid(m) then return end
    m:SetPos(ply:GetPos())
    m:SetAngles(ply:GetAngles())
    m:SetSequence(ply:GetSequence())
    m:SetCycle(ply:GetCycle())
    m:SetMaterial('models/debug/debugwhite')
    m:SetColor(Color(0, 180, 255, 50))
    m.life = CurTime() + 0.08
    table.insert(holograms, m)
end

net.Receive('BigNeo_DodgeVisual', function()
    local ply = net.ReadEntity()
    local dir = net.ReadVector()
    local isHead = net.ReadBool()
    local side = net.ReadFloat()
    if not IsValid(ply) then return end
    CreateHolo(ply, dir)
    boneCache[ply] = {time = CurTime() + 0.45, head = isHead, side = side, dir = dir, startTime = CurTime()}
end)

hook.Add('PostDrawOpaqueRenderables', 'BigNeo_DrawHolo', function()
    for i = #holograms, 1, -1 do
        local h = holograms[i]
        if not IsValid(h) or CurTime() > h.life then
            if IsValid(h) then h:Remove() end
            table.remove(holograms, i)
        else h:DrawModel() end
    end
end)

-- WESKER STYLE DODGE (RE5)
hook.Add('Think', 'BigNeo_WeskerSpine', function()
    for ply, data in pairs(boneCache) do
        if not IsValid(ply) then continue end
        local tLeft = data.time - CurTime()
        if tLeft <= 0 then
            for i = 0, ply:GetBoneCount() - 1 do ply:ManipulateBoneAngles(i, Angle(0,0,0)) end
            boneCache[ply] = nil continue
        end
        local elapsed = CurTime() - data.startTime
        local prog = math.min(elapsed / 0.45, 1)
        local prep = math.min(prog / 0.1, 1)
        local main = math.min((prog - 0.1) / 0.25, 1)
        local back = math.Min((prog - 0.35) / 0.65, 1)
        local prepPow = math.sin(prep * math.pi * 0.5)
        local mainPow = math.sin(main * math.pi)
        local backPow = math.sin(back * math.pi * 0.5)
        local isHead = data.head
        local side = data.side or 0
        local function smooth(b, t, l)
            local bb = b * prepPow * 0.15 + b * mainPow - b * backPow * 0.7
            local tt = t * prepPow * 0.1 + t * mainPow - t * backPow * 0.6
            local ll = l * prepPow * 0.08 + l * mainPow - l * backPow * 0.5
            return bb, tt, ll
        end
        for i = 0, ply:GetBoneCount() - 1 do
            local name = ply:GetBoneName(i)
            if not name then continue end
            name = name:lower()
            -- ПОЗВОНОЧНИК - изгиб назад + доворот в сторону
            if string.find(name, 'spine') then
                local sm = string.find(name, 'spine1') and 0.2 or string.find(name, 'spine2') and 0.5 or 1.0
                if isHead then
                    local b, t, l = smooth(22 * sm, 8 * sm, 3 * sm)
                    ply:ManipulateBoneAngles(i, Angle(-b, l, t))
                else
                    -- Доворот в сторону вместо наклона
                    local b, t, l = smooth(12 * sm, 20 * sm * side, 5 * sm)
                    ply:ManipulateBoneAngles(i, Angle(-b, l, t))
                end
            -- ГОЛОВА - уходит назад и поворачивается
            elseif string.find(name, 'head') then
                if isHead then
                    local b, t, l = smooth(28, 10, 5)
                    ply:ManipulateBoneAngles(i, Angle(-b, l + math.sin(elapsed * 40) * 1.5, t))
                else
                    -- Поворот головы в сторону
                    local b, t, l = smooth(15, 18 * side, 6)
                    ply:ManipulateBoneAngles(i, Angle(-b, l, t))
                end
            -- ПЛЕЧИ - поднимаются для защиты
            elseif string.find(name, 'clavicle') or string.find(name, 'shoulder') then
                local sh = string.find(name, 'left') and -1 or 1
                if isHead then
                    local b, t, l = smooth(5, 6 * sh, 4 * sh)
                    ply:ManipulateBoneAngles(i, Angle(-b, l, t))
                else
                    local b, t, l = smooth(4, 10 * sh * side, 6 * sh)
                    ply:ManipulateBoneAngles(i, Angle(-b, l, t))
                end
            -- РУКИ - прижимаются к телу
            elseif string.find(name, 'upperarm') then
                local a = string.find(name, 'left') and 1 or -1
                local roll = isHead and 6 * a or 12 * a * side + 5 * a
                ply:ManipulateBoneAngles(i, Angle(0, 0, roll))
            elseif string.find(name, 'forearm') then
                local a = string.find(name, 'left') and 1 or -1
                local roll = isHead and 4 * a or 8 * a * side + 3 * a
                ply:ManipulateBoneAngles(i, Angle(0, 0, roll))
            elseif string.find(name, 'hand') then
                local a = string.find(name, 'left') and 1 or -1
                local roll = isHead and 3 * a or 5 * a * side
                ply:ManipulateBoneAngles(i, Angle(0, 0, roll))
            -- НОГИ - минимальное движение
            elseif string.find(name, 'thigh') then
                local l = string.find(name, 'left') and 1 or -1
                ply:ManipulateBoneAngles(i, Angle(isHead and 2 * l or 3 * l * side, 0, 0))
            elseif string.find(name, 'calf') then
                local l = string.find(name, 'left') and 1 or -1
                ply:ManipulateBoneAngles(i, Angle(isHead and 1 * l or 2 * l * side, 0, 0))
            end
        end
    end
end)

-- CAMERA - минимальное смещение
hook.Add('CalcView', 'BigNeo_DodgeCamera', function(ply, pos, ang, fov)
    if not boneCache[ply] then return end
    local d = boneCache[ply]
    local t = d.time - CurTime()
    if t <= 0 then return end
    local prog = math.min((CurTime() - d.startTime) / 0.45, 1)
    local i = math.sin(prog * math.pi) * 0.3
    local off = d.head and Vector(-2 * i, 0, 1 * i) or Vector(0, 2 * d.side * i, 0.5 * i)
    local angOff = d.head and Angle(i * 1.5, 0, 0) or Angle(i * 0.5, 0, d.side * i)
    return {origin = pos + off, angles = ang + angOff, fov = fov}
end)

-- INVIS (исправленная версия)
hook.Add('PrePlayerDraw', 'BigNeo_DrawInvisPlayer', function(ply)
if not IsValid(ply) then return end
-- Не скрывать самого себя, даже если он в инвизе (иначе он не видит себя)
if ply == LocalPlayer() then return end

local isInvis = ply:GetNWBool('BigNeoInvisMode', false)
if not isInvis then return end -- Игрок ply не в инвизе, рисуем нормально

local target = ply:GetNWEntity('BigNeoInvisTarget', NULL) -- Цель ИНВИЗА (т.е. тот, кто должен видеть ply)
local lp = LocalPlayer()

-- Если я (lp) - это цель, которая должна видеть ply, то рисуем его (ничего не делаем)
if IsValid(target) and target == lp then
-- Цель: разрешить отрисовку с эффектом полупрозрачности
render.SetBlend(0.3)
-- Продолжаем стандартную отрисовку
return -- nil означает продолжить стандартную отрисовку
end

-- Если я (lp) - НЕ цель, или цель недействительна, скрываем ply
-- Устанавливаем прозрачность в 0 (полностью невидим)
render.SetBlend(0)
-- Прерываем стандартную отрисовку
return true
end)

-- Не забудь сбросить прозрачность в PostPlayerDraw
hook.Add('PostPlayerDraw', 'BigNeo_RestoreBlend', function(ply)
if not IsValid(ply) then return end
-- Сбрасываем blend только если это был игрок в инвизе
if ply:GetNWBool('BigNeoInvisMode', false) then
-- Важно: если PrePlayerDraw вернул true, PostPlayerDraw всё равно вызовется.
-- Но мы установили render.SetBlend(0) перед return true.
-- Поэтому сбрасываем blend всегда, когда работали с ним для этого игрока.
render.SetBlend(1)
end
end)


hook.Add('PostPlayerDraw', 'BigNeo_RestoreBlend', function(ply)
    if not IsValid(ply) then return end
    if ply:GetNWBool('BigNeoInvisMode', false) then
        render.SetBlend(1)
    end
end)

-- HUD
hook.Add('HUDPaint', 'BigNeo_HUDInfo', function()
    local p = LocalPlayer()
    if not IsValid(p) then return end
    local isNeo = p:GetNWBool('BigNeoMode', false)
    local isInv = p:GetNWBool('BigNeoInvisMode', false)
    local tp = p:GetNWEntity('BigNeoInvisTarget', NULL)
    if isNeo then
        surface.SetFont('DermaLarge')
        local t = '[NEO MODE]'
        draw.SimpleTextOutlined(t, 'DermaLarge', ScrW() - surface.GetTextSize(t) - 15, 15, Color(0,200,255), 0,0, 2, Color(0,0,0))
    end
    if isInv and IsValid(tp) then
        surface.SetFont('DermaLarge')
        local t = '[INVIS: ' .. tp:Name() .. ']'
        draw.SimpleTextOutlined(t, 'DermaLarge', ScrW() - surface.GetTextSize(t) - 15, 50, Color(100,255,100), 0,0, 2, Color(0,0,0))
    end
end)

print('[Big Neo] cl_plugin.lua loaded!')
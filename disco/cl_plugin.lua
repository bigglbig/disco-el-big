local PLUGIN = PLUGIN

local enabled = true
local yaw = PLUGIN.defaultYaw
local zoom = PLUGIN.cameraDistance
local clickTime = 0
local targetPos
local markerLife = 0

hook.Add("CalcView", "ixDiscoCamera", function(client, pos, angles, fov)
    if not enabled then return end

    local focus = client:GetPos() + Vector(0,0,64)

    local ang = Angle(
        PLUGIN.cameraPitch,
        yaw,
        0
    )

    local camPos =
        focus
        - ang:Forward() * zoom
        + Vector(0,0,PLUGIN.cameraHeight)

    local tr = util.TraceHull({
        start = focus,
        endpos = camPos,
        mins = Vector(-8,-8,-8),
        maxs = Vector(8,8,8),
        filter = client
    })

    return {
        origin = tr.HitPos,
        angles = ang,
        fov = 75,
        drawviewer = true
    }
end)

hook.Add("InputMouseApply", "ixDiscoRotate", function(cmd, x, y)
    if not enabled then return end

    if input.IsMouseDown(MOUSE_MIDDLE) then
        yaw = yaw - x * 0.25
        return true
    end
end)

hook.Add("PlayerBindPress", "ixDiscoZoom", function(client, bind)
    if bind == "invprev" then
        zoom = math.Clamp(zoom - 25, 250, 800)
        return true
    end

    if bind == "invnext" then
        zoom = math.Clamp(zoom + 25, 250, 800)
        return true
    end
end)

local function GetMouseWorld()
    local mouseX, mouseY = gui.MousePos()

    local tr = util.TraceLine({
        start = EyePos(),
        endpos = EyePos() + gui.ScreenToVector(mouseX, mouseY) * 10000,
        filter = LocalPlayer()
    })

    return tr
end

hook.Add("Think", "ixDiscoClickMove", function()
    if not enabled then return end
    if not input.IsMouseDown(MOUSE_LEFT) then return end

    if PLUGIN.nextClick and PLUGIN.nextClick > CurTime() then
        return
    end

    PLUGIN.nextClick = CurTime() + 0.25

    local tr = GetMouseWorld()

    if not tr.Hit then return end

    local run = false

    if CurTime() - clickTime < 0.35 then
        run = true
    end

    clickTime = CurTime()

    targetPos = tr.HitPos
    markerLife = CurTime() + 1

    net.Start("ixDiscoMove")
        net.WriteVector(tr.HitPos)
        net.WriteBool(run)
    net.SendToServer()
end)

hook.Add("PostDrawTranslucentRenderables", "ixDiscoMarker", function()
    if not targetPos then return end
    if markerLife < CurTime() then return end

    render.SetColorMaterial()

    render.DrawSphere(
        targetPos + Vector(0,0,4),
        8,
        12,
        12,
        Color(255,255,255)
    )
end)

concommand.Add("ix_disco_toggle", function()
    enabled = not enabled

    chat.AddText(
        Color(0,255,0),
        "Disco Camera: ",
        Color(255,255,255),
        enabled and "ON" or "OFF"
    )
end)

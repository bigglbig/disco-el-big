local PLUGIN = PLUGIN

net.Receive("ixDiscoMove", function(_, client)
    local pos = net.ReadVector()
    local run = net.ReadBool()

    if not IsValid(client) then return end

    client.ixDiscoTarget = pos
    client.ixDiscoRun = run
end)

hook.Add("Think", "ixDiscoMoveThink", function()
    for _, ply in ipairs(player.GetAll()) do
        local target = ply.ixDiscoTarget

        if not target then continue end

        local diff = target - ply:GetPos()
        diff.z = 0

        local dist = diff:Length()

        if dist < 20 then
            ply.ixDiscoTarget = nil
            continue
        end

        local dir = diff:GetNormalized()
        local speed = ply.ixDiscoRun and 240 or 120

        ply:SetVelocity(dir * speed)
    end
end)

    local PLUGIN = PLUGIN

-- Client-side plugin initialization
ix.util.IncludeDir("derma", "client")

-- Network strings are already defined in sh_plugin.lua
-- Additional client-side code can be added here

-- Glitch effect rendering
hook.Add("RenderScreenspaceEffects", "ixBigTerminalGlitch", function()
    local client = LocalPlayer()
    
    if client:GetNWBool("ixGlitchEffect", false) then
        local glitchMat = Material("pp/dizzy")
        
        render.SetMaterial(glitchMat)
        render.DrawScreenQuad()
        
        -- Color modification for glitch effect
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0.1,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1 + math.sin(CurTime() * 10) * 0.2,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
    end
end)

-- Inverted controls hook
hook.Add("StartCommand", "ixBigTerminalInvert", function(ply, cmd)
    if ply:GetNWBool("ixInvertControls", false) then
        local forward = cmd:GetForwardMove()
        local side = cmd:GetSideMove()
        
        cmd:SetForwardMove(-forward)
        cmd:SetSideMove(-side)
    end
end)

-- Weapon jam effect
hook.Add("EntityFireBullets", "ixBigTerminalWeaponJam", function(entity, data)
    if not entity:IsPlayer() then return end
    
    if entity:GetNWBool("ixWeaponJam", false) then
        entity:EmitSound("buttons/button8.wav")
        return false
    end
end)

-- Casino open handler перенесён в derma/cl_casino.lua

ITEM.name = "Терминал"
ITEM.uniqueID = "big_terminal"
ITEM.model = "models/bybig/monitor_1.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.description = "Перепрошитый ноутбук с возможностью выходить дальше чем это дозволено законом."
ITEM.category = "Компьютеры"

ITEM.functions.Place = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local entity = ents.Create("ix_big_terminal")
        local trace = client:GetEyeTraceNoCursor()
        
        if (trace.HitPos:Distance(client:GetShootPos()) <= 192) and not client.CantPlace then
            entity:SetPos(trace.HitPos + Vector(0, 0, 17))
            entity:Spawn()
            entity:SetNWInt("owner", client:GetCharacter():GetID())
            
            client.CantPlace = true
            
            if IsValid(entity) then
                entity:SetAngles(Angle(0, client:EyeAngles().yaw + 180, 0))
            end
            
            timer.Simple(3, function()
                if client then
                    client.CantPlace = false
                end
            end)

            local plugin = ix.plugin.Get("big_terminal")
            if plugin then plugin:SaveData() end
            
            client:Notify("Терминал установлен! Нажмите E для открытия.")
        elseif client.CantPlace then
            client:Notify("Вы не можете поставить это сейчас!")
            return false
        else
            client:Notify("Вы не можете поставить это так далеко!")
            return false
        end
    end
}
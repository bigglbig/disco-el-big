local PLUGIN = PLUGIN

ITEM.name = "Точка доступа"
ITEM.uniqueID = "access_point"
ITEM.model = "models/props_lab/reciever01b.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.description = "Портативная точка доступа для подключения к сети."
ITEM.category = "Компьютеры"

ITEM.functions.Place = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local entity = ents.Create("ix_access_point")
        local trace = client:GetEyeTraceNoCursor()

        if (trace.HitPos:Distance(client:GetShootPos()) <= 192) and not client.CantPlace then
            entity:SetPos(trace.HitPos + Vector(0, 0, 10))
            entity:Spawn()
            
            local plugin = ix.plugin.Get("big_terminal")
            if plugin then plugin:SaveData() end

            local char = client:GetCharacter()
            if char then
                entity:SetOwnerID(char:GetID())
                timer.Simple(0.5, function()
                    if IsValid(client) then
                        client:Notify("Ваша точка доступа активирована. Код: " .. entity:GetAccessCode())
                    end
                end)
            end

            client.CantPlace = true

            if IsValid(entity) then
                entity:SetAngles(Angle(0, client:EyeAngles().yaw + 180, 0))
            end

            timer.Simple(3, function()
                if client then client.CantPlace = false end
            end)

            client:Notify("Точка доступа установлена! Нажмите E для взлома.")
        elseif client.CantPlace then
            client:Notify("Вы не можете поставить это сейчас!")
            return false
        else
            client:Notify("Вы не можете поставить это так далеко!")
            return false
        end
    end
}
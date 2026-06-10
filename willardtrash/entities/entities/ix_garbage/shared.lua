DEFINE_BASECLASS("base_gmodentity")
local PLUGIN = PLUGIN

TYPE_WATERCAN = 0
TYPE_SUPPLIES = 1

ENT.Type              = "anim"
ENT.Author            = "M!NT, Fruity"
ENT.PrintName         = "Trash Pile"
ENT.Contact	      = "Willard Networks"
ENT.Purpose	      = "Lootable trash pile."
ENT.Spawnable	      = true
ENT.AdminOnly         = true
ENT.PhysgunDisable    = true
ENT.bNoPersist        = true

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "index")
end

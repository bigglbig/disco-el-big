
PLUGIN.name = "Better Logs"
PLUGIN.author = "AleXXX_007"
PLUGIN.description = "Saves logs in a database and allows permitted staff to look them up."

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Logs",
	MinAccess = "admin"
})

CAMI.RegisterPrivilege({
	Name = "Helix - Tp",
	MinAccess = "admin"
})

ix.option.Add("logDefaultTime", ix.type.string, "3d", {
	bNetworked = true,
	category = "log",
	hidden = function()
		return !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Logs", nil)
	end
})

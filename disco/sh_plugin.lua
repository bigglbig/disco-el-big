PLUGIN.name = "Disco Camera"
PLUGIN.author = "OpenAI"
PLUGIN.description = "Disco Elysium inspired camera and movement."

ix.util.Include("sh_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

local PLUGIN = PLUGIN

PLUGIN.cameraDistance = 450
PLUGIN.cameraHeight = 280
PLUGIN.cameraPitch = 35
PLUGIN.defaultYaw = 45

if SERVER then
    util.AddNetworkString("ixDiscoMove")
end

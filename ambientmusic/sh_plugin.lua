local PLUGIN = PLUGIN

PLUGIN.name = "Ambient Music"
PLUGIN.description = "Ambient Music"
PLUGIN.author = "Schwarz Kruppzo"

if SERVER then 
	return
end

local timerID = "ixAmbient"
local ambients = {
	[1] = {"big/1.mp3", 360},
	[2] = {"big/2.mp3", 280},
	[3] = {"big/3.mp3", 280},
	[4] = {"big/4.mp3", 494},
	[5] = {"big/5.mp3", 351},
	[6] = {"big/6.mp3", 275},
	[7] = {"big/7.mp3", 157},
	[8] = {"big/8.mp3", 281},
	[9] = {"big/9.mp3", 168},
	[10] = {"big/10.mp3", 493}
}

local function SetVolume(volume)
	if PLUGIN.snd then 
		PLUGIN.snd:ChangeVolume(volume)
	end
end

local function StopAmbient()
	if timer.Exists(timerID) then
		timer.Remove(timerID)
	end

	if PLUGIN.snd then
		PLUGIN.snd:Stop()
		PLUGIN.snd = nil
	end
end

local function PlayAmbient(ambientData)
	--[[if LocalPlayer():InOutlands() then
		ambientData = {
			"cellar_event/music_tno.mp3",
			223
		}
	end]]

	StopAmbient()

	PLUGIN.snd = CreateSound(LocalPlayer(), ambientData[1])
	PLUGIN.snd:Play()
	
	timer.Simple(0, function()
		PLUGIN.snd:ChangeVolume(ix.option.Get("ambientVol"), 0)
	end)

	timer.Create(timerID, ambientData[2] + ix.option.Get("ambientTime", 0), 1, function()
		PlayAmbient(ambients[math.random(1, #ambients)])
	end)
end

function PLUGIN:CharacterLoaded(character)
	if timer.Exists(timerID) or !ix.option.Get("ambientToggle") then
		return
	end

	PlayAmbient(ambients[math.random(1, #ambients)])
end

ix.option.Add("ambientToggle", ix.type.bool, true, {
	category = "Музыка",
	OnChanged = function(_, value)
		if !value then
			StopAmbient()
			return
		end

		PlayAmbient(ambients[math.random(1, #ambients)])
	end
})

ix.option.Add("ambientVol", ix.type.number, 1, {
	category = "Музыка",
	decimals = 2,
	min = 0.01, 
	max = 1, 
	OnChanged = function(_, value)
		SetVolume(value)
	end
})

ix.option.Add("ambientTime", ix.type.number, 0, {
	category = "Музыка",
	decimals = 0,
	min = 0, 
	max = 600
})

ix.lang.AddTable("english", {
	optAmbientToggle = "Toggle music",
	optAmbientVol = "Music volume",
	optAmbientTime = "Time between music (sec)",
})

ix.lang.AddTable("russian", {
	optAmbientToggle = "Включить музыку",
	optAmbientVol = "Громкость музыки",
	optAmbientTime = "Время между музыкой (сек)"
})
PLUGIN.name = "Diff Chat Sizes"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Different chat sizes also different colors."

if CLIENT then
	surface.CreateFont("nut_C_Whisper", {
		font = mainFont,
		size = 15,
		weight = 1000,
		antialias = true
	})
	surface.CreateFont("nut_C_Yell", {
		font = mainFont,
		size = 24,
		weight = 1000,
		antialias = true
	})
end

-- Register chat classes.
do
	local r, g, b = 232, 232, 88

	nut.chat.Register("whisper", {
		canHear = nut.config.whisperRange,
		onChat = function(speaker, text)
			chat.AddText(Color(r - 25, g - 25, b - 25), nut.schema.Call("GetPlayerName", speaker, "whisper", text)..': "'..text..'"')
		end,
		prefix = {"/w", "/whisper"},
		font = "nut_C_Whisper"
	})

	nut.chat.Register("looc", {
		canHear = nut.config.chatRange,
		onChat = function(speaker, text)
			chat.AddText(Color(250, 40, 40), "[LOOC] ", speaker, color_white, ": "..text)
		end,
		prefix = {".//", "[[", "/looc"},
		canSay = function(speaker)
			return true
		end,
		noSpacing = true
	})

	nut.chat.Register("pm", {
		canHear = function() return false end,
		deadCanTalk = true,
		onChat = function(speaker, text)
			return
		end
	})

	nut.chat.Register("ic", {
		canHear = nut.config.chatRange,
		onChat = function(speaker, text)
			chat.AddText(Color(r, g, b), nut.schema.Call("GetPlayerName", speaker, "ic", text)..': "'..text..'"')
		end
	})

	nut.chat.Register("yell", {
		canHear = nut.config.yellRange,
		onChat = function(speaker, text)
			chat.AddText(Color(r + 35, g + 35, b + 35), nut.schema.Call("GetPlayerName", speaker, "yell", text)..': "'..text..'"')
		end,
		prefix = {"/y", "/yell"},
		font = "nut_C_Yell"
	})

	nut.chat.Register("it", {
		canHear = nut.config.chatRange,
		onChat = function(speaker, text)
			chat.AddText(Color(r, g, b), "**"..text)
		end,
		prefix = "/it",
		font = "nut_ChatFontAction"
	})
	
	nut.chat.Register("me", {
		canHear = nut.config.chatRange,
		onChat = function(speaker, text)
			chat.AddText(Color(r, g, b), "**"..nut.schema.Call("GetPlayerName", speaker, "me", text).." "..text)
		end,
		prefix = {"/me", "/action"},
		font = "nut_ChatFontAction"
	})
end

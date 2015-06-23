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

-- register chat classes.
do
	local r, g, b = 209, 255, 139

	nut.chat.register("whisper", {
		format = "%s whispers \"%s\"",
		onGetColor = function(speaker, text)
			return Color(r - 25, g - 25, b - 25)
		end,
		font = "nut_C_Whisper",
		onCanHear = nut.config.get("chatRange", 280) * 0.25,
		prefix = {"/w", "/whisper"}
	})

	nut.chat.register("looc", {
		canHear = nut.config.chatRange,
		onChatAdd = function(speaker, text)
			chat.AddText(Color(250, 40, 40), "[LOOC] ", speaker, color_white, ": "..text)
		end,
		prefix = {".//", "[[", "/looc"},
		canSay = function(speaker)
			return true
		end,
		noSpaceAfter = true
	})

	nut.chat.register("pm", {
		onCanHear = function() return false end,
		deadCanChat = true,
		onChatAdd = function(speaker, text)
			return
		end
	})

	nut.chat.register("ic", {
		format = "%s says \"%s\"",
		onGetColor = function(speaker, text)
			-- If you are looking at the speaker, make it greener to easier identify who is talking.
			if (LocalPlayer():GetEyeTrace().Entity == speaker) then
				return nut.config.get("chatListenColor")
			end

			-- Otherwise, use the normal chat color.
			return Color(r, g, b)
		end,
		onCanHear = nut.config.get("chatRange", 280)
	})

	nut.chat.register("yell", {
		format = "%s yells \"%s\"",
		onGetColor = function(speaker, text)
			return Color(r + 35, g + 35, b + 35)
		end,
		font = "nut_C_Yell",
		onCanHear = nut.config.get("chatRange", 280) * 2,
		prefix = {"/y", "/yell"}
	})

	nut.chat.register("it", {
		onChatAdd = function(speaker, text)
			chat.AddText(Color(r, g, b), "**"..text)
		end,
		onCanHear = nut.config.get("chatRange", 280),
		prefix = {"/it"},
		font = "nut_ChatFontAction",
		filter = "actions",
		deadCanChat = true
	})
	
	nut.chat.register("me", {
		format = "**%s %s",
		onGetColor = Color(r, g, b),
		onCanHear = nut.config.get("chatRange", 280),
		prefix = {"/me", "/action"},
		font = "nut_ChatFontAction",
		filter = "actions",
		deadCanChat = true
	})
end

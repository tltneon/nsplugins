READ ME:

Before using this plugin, you have to follow these steps.

STEP 1: Go to your schema's sv_hook.
Your schema's hook folder is located in "gamemodes/<<YOUR SCHEMA NAME>>/gamemode/schema/sv_hooks.lua

STEP 2: Wipe line

EXAMPLE: SAMPLE SCHEMA


line 12:	if (data.faction == FACTION_CITIZEN) then

line 13:		inventory:Add("cid", 1, {

line 14:			Digits = math.random(11111, 99999),

line 15:			Owner = data.charname

line 16:		})

line 17:	end

If you modified your SCHEMA:GetDefaultInv() hook, you have to remove something related with cid.

STEP 3: Install the plugin.

STEP 4: MOD sh_plugin.lua in cidvisual.
IF YOU HAVE CUSTOM FACTION FOR CITIZEN GROUP, YOU HAVE TO MOD PLUGIN:GetDefaultInv()!!!!!!!!!!!!
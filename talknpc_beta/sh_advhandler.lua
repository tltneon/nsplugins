local PLUGIN = PLUGIN
local questPLUGIN = nut.plugin.Get( "quests" )
if not questPLUGIN then
	print( 'quest_honeya example will not work properly without "quest" plugin.' )
end

/*---------------------------------------------------------
	This is advanced handler for dialogue plugin.
	You can make some quest like things with this.
	But I recommends you don't care about this handler
	If you don't know how to code. 
	
	I will not answer any question about how to use this plugin.
	Unless you have any clue about this dialogue handler.
--------------------------------------------------------*/

-- You can call SpecialCall with !.
-- example. when a player call dialouge that has uid "!quest_recieve_test" then it will call SpecialCall["quest_receive_test"].
PLUGIN.SpecialCall =
{

		["quest_honeya"] = { -- QUEST EXAMPLE.
			sv = function( client, data ) 
				if client:HasQuest( "honeya" ) then
					-- questPLUGIN = from the "quests" plugin.
					local pqst_dat = client:GetQuest( "honeya" ) -- get player quest data
					if client:CanCompleteQuest( "honeya", pqst_dat ) then -- If see player can complete quest
						client:GiveQuestReward( "honeya", pqst_dat ) -- Give quest reward
						client:RemoveQuest( "honeya" ) -- and remove player quest.
						data.done = true -- send client data.done. It will generate you're done text.
					else
						data.done = false
					end
				else
					-- set quest and get quest.
					data.gotquest = true -- Just got a quest!
					local d_qst = questPLUGIN:GetQuest( "honeya" )
					client:AddQuest( "honeya", d_qst:GenerateData( client ) ) -- Give a quest that has uniqueid 'honeya' and generates random data for quest.
					-- Quest data generating function is in sh_quests.lua file.
				end
				return data -- MUST RETURN DATA
			end,
			cl = function( client, panel, data )
				if data.gotquest then
					local d_qst = questPLUGIN:GetQuest( "honeya" )
					local pqst_dat = LocalPlayer():GetQuest( "honeya" ) -- get player quest data
					panel:AddChat( data.name, "Can you get some items for me?" )
					for k, v in pairs( pqst_dat ) do
						panel:AddCustomText( Format( d_qst.desc, unpack( { v, nut.item.Get(k).name } ) ), "nut_ChatFont" )
					end
					panel.talking = false -- Get quest and end the converstaion.
					return
				end
				if data.done then
					panel:AddChat( data.name, "Okay I'll give you some moeney!")
				else
					panel:AddChat( data.name, "You don't have enough items to return your quest.")
				end
				panel.talking = false
			end,
		},

		["test2"] = {
			sv = function( client, data )
				return data -- MUST RETURN DATA
			end,
			cl = function( client, panel, data ) 
				panel.talking = false -- Ends the current conversation and allows player to talk about other topics.
			end,
		},

		["test"] = {
			sv = function( client, data )
				client:EmitSound( "items/smallmedkit1.wav" )
				client:SetHealth( 100 )
				return data -- MUST RETURN DATA
			end,
			cl = function( client, panel, data ) 
				panel:AddChat( data.name, "By the name of Black Tea! You're healed!" )
				panel.talking = false -- Ends the current conversation and allows player to talk about other topics.
			end,
		},
}

-- Handler.
if SERVER then
	netstream.Hook( "nut_DialogueMessage", function( client, data )
		if string.Left( data.request, 1 ) == "!" then
			data.request = string.sub( data.request, 2 )
			if PLUGIN.SpecialCall[ data.request ] then
				data = PLUGIN.SpecialCall[ data.request ].sv( client, data )
				netstream.Start( client, "nut_DialoguePingpong", data )
			else
				print( Format( "%s( %s ) tried to call invalid dialouge request( %s ) from %s.", client:Name(), client:Nick(), data.request, data.name ) )
				print( "Please check PLUGIN.SpecialCall or NPC's dialouge unique id." )
				client:EmitSound( "HL1/fvox/hev_general_fail.wav" )
			end
		end
	end)
else
	netstream.Hook( "nut_DialoguePingpong", function( data )
		if IsValid( nut.gui.dialogue ) then
			if PLUGIN.SpecialCall[ data.request ] then
				PLUGIN.SpecialCall[ data.request ].cl( client, nut.gui.dialogue, data )
			end
		end
	end)
end
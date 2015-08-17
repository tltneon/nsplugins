PLUGIN.name = "Cook Food"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "How about getting new foods in NutScript?"

PLUGIN.hungerSpeed = 300 -- decreases 10 hunger every * seconds.
PLUGIN.thirstSpeed = 200 -- decreases 10 thirst every * seconds.
--PLUGIN.meActions = true

nut.util.Include("sh_lang.lua")

ATTRIB_COOK = nut.attribs.SetUp("Cooking", "Affects how good is the result of cooking.", "cook")
function PLUGIN:CreateCharVars(character)
	character:NewVar("hunger", 100, CHAR_PRIVATE, true)
	character:NewVar("thirst", 100, CHAR_PRIVATE, true)
end

local entityMeta = FindMetaTable("Entity")
	
function entityMeta:IsStove()
	return ( self:GetClass() == "nut_stove" or self:GetClass() == "nut_bucket"  or self:GetClass() == "nut_barrel" )
end
	
if (CLIENT) then
	
	nut_Fire_sprite = {}
	nut_Fire_sprite.fire = Material("particles/fire1") 
	nut_Fire_sprite.nextFrame = CurTime()
	nut_Fire_sprite.curFrame = 0

	function PLUGIN:Think()
			if nut_Fire_sprite.nextFrame < CurTime() then
				nut_Fire_sprite.nextFrame = CurTime() + 0.05 * (1 - FrameTime())
				nut_Fire_sprite.curFrame = nut_Fire_sprite.curFrame + 1
				nut_Fire_sprite.fire:SetFloat("$frame", nut_Fire_sprite.curFrame % 22 )
			end
	end

	nut.bar.Add("hunger", {
		getValue = function()
			if (LocalPlayer().character) then
				return LocalPlayer().character:GetVar("hunger", 0)
			else
				return 0
			end
		end,
		color = Color(188, 255, 122)
	})

	nut.bar.Add("thirst", {
		getValue = function()
			if (LocalPlayer().character) then
				return LocalPlayer().character:GetVar("thirst", 0)
			else
				return 0
			end
		end,
		color = Color(123, 156, 255)
	})

	function PLUGIN:ShouldDrawTargetEntity(entity)
		if (entity:GetClass() == "nut_stove") then
			return true
		end
	end

	function PLUGIN:DrawTargetID(entity, x, y, alpha)
		if (entity:GetClass() == "nut_stove") then
			local mainColor = nut.config.mainColor
			local color = Color(mainColor.r, mainColor.g, mainColor.b, alpha)

			nut.util.DrawText(x, y, nut.lang.Get("stove_name"), color)
				y = y + nut.config.targetTall
				local text = nut.lang.Get("stove_desc")
			nut.util.DrawText(x, y, text, Color(255, 255, 255, alpha))
		end
	end

else

	HUNGER_MAX = 100
	THIRST_MAX = 100
	local HUNGER_RATE = CurTime()
	local THIRST_RATE = CurTime()

	function PLUGIN:PlayerSpawn( player )
		player.character:SetVar("hunger", math.Clamp( HUNGER_MAX, 0, HUNGER_MAX ))
		player.character:SetVar("thirst", math.Clamp( THIRST_MAX, 0, THIRST_MAX ))
	end
	
	local playerMeta = FindMetaTable("Player")
	function playerMeta:SolveHunger( intAmount, intHealth )
		local hunger = self.character:GetVar("hunger", 0)
		local hp = self:Health()
		local multp = .01
		self.character:SetVar("hunger", math.Clamp( hunger + intAmount, 0, HUNGER_MAX ))
		if !intHealth or !intHealth == 0 then
			self:SetHealth( math.Clamp( hp + intAmount * multp, 0, self:GetMaxHealth() ) )
		end
	end

	function playerMeta:SolveThirst( intAmount, intHealth )
		local hunger = self.character:GetVar("thirst", 0)
		local stamina = self.character:GetVar("stamina", 0)
		local multp = .5
		self.character:SetVar("thirst", math.Clamp( hunger + intAmount, 0, THIRST_MAX ))
		self.character:SetVar("stamina", math.Clamp( stamina + intAmount * multp, 0, 100 ))
	end

	local math_Clamp = math.Clamp

	function PLUGIN:Think()
	
		local curTime = CurTime()

		if HUNGER_RATE < curTime then
			for _, player in pairs( player.GetAll() ) do
				local character = player.character

				if character then
					local hunger = character:GetVar("hunger", 0)
					character:SetVar("hunger", math_Clamp( hunger - 10, 0, HUNGER_MAX ))
					
					-------------------------------------------------------------------------------
					-------------------------------------------------------------------------------
					nut.schema.Call("PlayerHunger", player) -- MAKE THIS HOOK IF YOU WANT TO ADD SOME EFFECTS.
					-- THIS FUNCTION WILL CALL ALL " PLUGIN:PlayerHunger( player ) " IN ANY PLUGIN FOLDER.
					-------------------------------------------------------------------------------
					-------------------------------------------------------------------------------
					
				end
			end
			HUNGER_RATE = curTime + self.hungerSpeed
		end

		if THIRST_RATE < curTime then
			for _, player in pairs( player.GetAll() ) do
				local character = player.character

				if character then
					local thirst = character:GetVar("thirst", 0)
					character:SetVar("thirst", math.Clamp( thirst - 10, 0, THIRST_MAX ))
					
					-------------------------------------------------------------------------------
					-------------------------------------------------------------------------------
					nut.schema.Call("PlayerThirst", player) -- MAKE THIS HOOK IF YOU WANT TO ADD SOME EFFECTS.
					-- THIS FUNCTION WILL CALL ALL " PLUGIN:PlayerHunger( player ) " IN ANY PLUGIN FOLDER.
					-------------------------------------------------------------------------------
					-------------------------------------------------------------------------------
					
				end
			end
			THIRST_RATE = curTime + self.thirstSpeed
		end
		
	end
	
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	/*   A Simple Example of Hunger/Thirst Handling
	function PLUGIN:PlayerHunger( player )
		local character = player.character
		local hunger = character:GetVar("hunger", 0)
		if hunger <= 0 then
			player:ChatPrint( "You're hungry and angry. now you're hangry." )
		end
	end
	
	function PLUGIN:PlayerThirst( player )
		local character = player.character
		local thirst = character:GetVar("thirst", 0)
		if thirst <= 0 then
			player:ChatPrint( "You're thirsty. Your throat is dry." )
		end
	end
	*/
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	
	PLUGIN.tableStove = {
		"nut_stove",
		"nut_barrel",
		"nut_bucket",
	}
	
	function PLUGIN:LoadData()
		local restored = nut.util.ReadTable("stoves")

		if (restored) then
			for class, data in pairs(restored) do
				for k, v in pairs( data ) do
					local position = v.position
					local angles = v.angles
					local active = v.active

					local entity = ents.Create( class )
					entity:SetPos(position)
					entity:SetAngles(angles)
					entity:Spawn()
					entity:Activate()
					entity:SetNetVar("active", active)
					local phys = entity:GetPhysicsObject()
					if phys and phys:IsValid() then
						phys:EnableMotion(false)
					end
				end
			end
		end
	end

	function PLUGIN:SaveData()
		local data = {}

		for k, v in pairs( ents.GetAll() ) do
			if table.HasValue( self.tableStove, v:GetClass() ) then
				data[v:GetClass()] = data[v:GetClass()] or {}
				data[v:GetClass()][ #data[v:GetClass()] + 1 ] = {
					position = v:GetPos(),
					angles = v:GetAngles(),
					active = v:GetNetVar("active")
				}
			end
		end
		nut.util.WriteTable("stoves", data)
	end

end

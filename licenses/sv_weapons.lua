local PLUGIN = PLUGIN

-- Globals
TESTS_RANGE_STATUS = false
TESTS_RANGE_PLAYER = nil

function PLUGIN:PopUpTarget( ply )
	local data = table.Random(self.weapons.targets)
	local target = ents.Create("nut_target")
	target:SetPos(data.pos)
	target:SetAngles(data.ang)
	target:SetModel(data.mdl)
	target.tester = ply
	target:Spawn()
	target:Activate()
	timer.Simple(self.weapons.targetPopup, function()
		if not IsValid(target) then return end
		target:Remove()
	end)
end

function PLUGIN:StartWeaponsTest( ply, test )
	for k,v in pairs(ply:GetWeapons()) do
		if not table.HasValue(self.weapons.whitelist, v:GetClass()) then
			nut.util.Notify("You cannot take a weapons test with your own firearms!", ply)
			return
		end
	end
	if test == "attachments" then
		if table.HasValue(ply.FAS2Attachments, self.weapons.tests[test].att) then
			nut.util.Notify("You cannot take a weapons test with this attachment! ("..self.weapons.tests[test].att..")", ply)
			return
		end
	end
	if not ply.character:GetVar("testData").status then
		if ply:HasMoney(self.weapons.tests[test].price) then
			ply:TakeMoney(self.weapons.tests[test].price)
			nut.util.Notify("The test will start in 10 seconds. Get ready!", ply)
			local data = {
				status = true,
				endTime = CurTime() + self.weapons.tests[test].time + 10,
				test = test,
				points = 0
			}
			ply.character:SetVar("testData", data)
			TESTS_RANGE_STATUS = true
			TESTS_RANGE_PLAYER = ply
			local weapon = ply:Give(self.weapons.tests[test].weapon)
			ply:SelectWeapon(self.weapons.tests[test].weapon)
			ply:SetAmmo(self.weapons.tests[test].ammo, self.weapons.tests[test].ammoType)
			if test == "attachments" then
				ply:FAS2_PickUpAttachment(self.weapons.tests[test].att, true)
				nut.util.Notify("You were given a "..self.weapons.tests[test].att..", equip it by pressing C (Context. Menu).", ply)
			end
			timer.Simple(10, function()
				if not ply then return end
				self:PopUpTarget(ply)
				timer.Simple(1, function()
					timer.Create("rangeSpawnLoop", self.weapons.targetDelay, 30, function()
						self:PopUpTarget(ply)
					end)
				end)
				timer.Simple(self.weapons.tests[test].time, function()
					TESTS_RANGE_STATUS = false
					TESTS_RANGE_PLAYER = nil
					timer.Destroy("rangeSpawnLoop")
					if not ply then return end
					if test == "attachments" then
						ply:FAS2_RemoveAttachment(self.weapons.tests[test].att, true)
					end
					ply:StripWeapon(self.weapons.tests[test].weapon)
					local points = ply.character:GetVar("testData").points
					if points >= self.weapons.tests[test].reqPoints then
						self:GiveLicense(ply, test)
						nut.util.Notify("You have successfully completed the test!", ply)
					else
						nut.util.Notify("You have failed the test. Try again later.", ply)
					end
					self:ResetTest(ply)
				end)
			end)
		else
			nut.util.Notify("You do not have enough money!", ply)
		end
	else
		nut.util.Notify("You are already taking a test!", ply)
	end
end

netstream.Hook("ReqWepTest", function( ply, test )
	if PLUGIN.weapons.tests[test] then
		if ply:GetPos():WithinAABox(PLUGIN.weapons.range[1], PLUGIN.weapons.range[2]) then
			if not TESTS_RANGE_STATUS then
				PLUGIN:StartWeaponsTest(ply, test)
			else
				nut.util.Notify("Someone is already taking this test.", ply)
			end
		else
			nut.util.Notify("You are not in the firing range!", ply)
		end
	end
end)
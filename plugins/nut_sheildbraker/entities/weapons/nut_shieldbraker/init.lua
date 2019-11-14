include("shared.lua")

AddCSLuaFile("shared.lua")

function SWEP:isTraceForcefield()
    local data = {}
    data.start = self.Owner:GetShootPos()
    data.endpos = data.start + self.Owner:GetAimVector()*96
    data.filter = self.Owner
	local entity = util.TraceLine(data).Entity

    return IsValid(entity) and entity:GetClass() == 'nut_forcefield', entity
end

function SWEP:PrimaryAttack()
	local time = nut.config.get("forcefieldBrakeTime", 1)
    local time2 = time + 2

	self:SetNextPrimaryFire(CurTime() + time2)
	self:SetNextSecondaryFire(CurTime() + time2)

	if (not IsFirstTimePredicted()) then
		return
	end

    local isforcefield, entity = self:isTraceForcefield()
	if isforcefield and entity.mode ~= 3 then
		self.Owner:setAction("@brake_forcefield", time, function()
			entity.mode = 3
            self.Owner:ChatPrint("Changed barrier mode to: Allow everything.")

            if nut.config.get("forcefieldBrakeStrip", true) then
                self.Owner:ChatPrint("Forcefield Braker broke down.")
                self.Owner:StripWeapon('nut_shieldbraker')
            end
		end)

		return
	end
end

function SWEP:Think()
    if not self:isTraceForcefield() then
        self.Owner:setAction(false)
    end
end
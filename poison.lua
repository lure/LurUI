--[[
Poison remainder  
Every time zone is changed and enchantment duration on main or offhand weapon is less than specific time 
message appears in the first chat window.  Nothing special, but yellow color brings attention 
]]
local TEXTCOLOR = RAID_CLASS_COLORS["ROGUE"]
local DELTA = 15 -- text color and time to expire

local function expiration(ref, hand, existsEnchant, duration)
    local e = existsEnchant and math.floor(duration / 600) / 100 or 0     
	if e < DELTA then
		if e == 0 then 
			ref.msg = (ref.msg and ref.msg or "").." ["..hand.." expired]"
		else
			ref.msg = (ref.msg and ref.msg or "").." ["..hand.." in "..e.."]"
		end
	end
end

local frame = CreateFrame("Frame", "PoisonRemainderFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame.PLAYER_ENTERING_WORLD = function(self, ...)
    if ("ROGUE" == select(2, UnitClass("player"))) then
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    end
end

frame.ZONE_CHANGED_NEW_AREA = function(self, ...)
    local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration, _, hasThrownEnchant, thrownExpiration, _ = GetWeaponEnchantInfo()
	local ref = {msg = nil}
	
	expiration(ref, "main", hasMainHandEnchant, mainHandExpiration)
	expiration(ref, "off", hasOffHandEnchant, offHandExpiration)
	expiration(ref, "throw", hasThrownEnchant, thrownExpiration)
	
	if (ref.msg) then 
		ref.msg = "POISONS: expires"..ref.msg
		ChatFrame1:AddMessage(ref.msg, TEXTCOLOR.r, TEXTCOLOR.g, TEXTCOLOR.b)	
	end
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

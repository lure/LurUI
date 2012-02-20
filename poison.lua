--[[
Poison remainder  
Every time zone is changed and enchantment duration on main or offhand weapon is less than specific time 
message appears in the first chat window.  Nothing special, but yellow color brings attention 
]]

if (select(2, UnitClass("player")) ~= "ROGUE") then return end;

local Poison = {};
Poison.color = nil;
Poison.time = 15; -- acceptable time to expire

local frame = CreateFrame("Frame", "PoisonRemainderFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MERCHANT_SHOW")

frame.PLAYER_ENTERING_WORLD = function(self, ...)
    local _, classFileName = UnitClass("player")
    Poison.color = RAID_CLASS_COLORS[classFileName]
    if ("ROGUE" == classFileName) then
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    end
end

frame.ZONE_CHANGED_NEW_AREA = function(self, ...)
    pvpType, _, _ = GetZonePVPInfo()
    --if(pvpType == 'arena') then
    local hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration, _ = GetWeaponEnchantInfo()
    notify("mainhand", hasMainHandEnchant, mainHandExpiration)
    notify("offhand", hasOffHandEnchant, offHandExpiration)
--end
end

function notify(hand, existsEnchant, duration)
    duration = existsEnchant and math.floor(duration / 600) / 100 or 0

    if (duration < Poison.time) then
        ChatFrame1:AddMessage(hand .. " poison expires too early, in " .. duration, Poison.color.r, Poison.color.g, Poison.color.b)
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

local poisonName = "яд"
frame.MERCHANT_SHOW = function(self, ... )
	for index = 1,GetMerchantNumItems() do 
		local nm = GetMerchantItemInfo(index)
		if (nm and nm:find(poisonName)) then 
			local count = 20 - GetItemCount(nm, nil, true)
			if count>0 then BuyMerchantItem(index, count) end
		end
	end
end






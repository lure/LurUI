
--[[-----------------------------------
- 		ARENA ALERT
--------------------------------------]]

lu_frame = CreateFrame("Frame", nil, UIParent);
lu_frame:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
lu_frame:SetScript("OnEvent", function(self, event, ...) local battleID, areaName = ...; print(battleID, areaName); PlaySound("PVPTHROUGHQUEUE", "Master"); end)
print("sound alarm is ready")
-- PlaySoundFile("Sound\\interface\\RaidWarning.wav", "Master"); 
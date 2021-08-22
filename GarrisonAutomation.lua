--[[--------------------------------------
	Garrison mission auto complete
-----------------------------------------]]
LurUI.GarrisonAuto = {
	frame = nil
}
local ui = LurUI.GarrisonAuto

function LurUI.GarrisonAuto.InitMissionAutoCompletist()
	ui.frame = CreateFrame("Frame", nil, UIParent);
	ui.frame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	ui.frame:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	ui.frame:RegisterEvent("GARRISON_MISSION_FINISHED");
	ui.frame.missionList = {};
	ui.frame.missionPrint = {};
	ui.frame:Show();
	
	ui.frame:SetScript("OnEvent", function(self, event, ...)
		if ( event == "GARRISON_MISSION_COMPLETE_RESPONSE" ) then
			local missionID, canComplete, succeeded = ...;
			
			local missionAsKey = self.missionList[missionID];
			if missionAsKey then
				self.missionPrint[missionAsKey] = succeeded;
			end
			self.missionList[missionID] = nil;
			
			if C_Garrison.CanOpenMissionChest(missionID) then
				C_Garrison.MissionBonusRoll(missionID);
			end
			
			if (ui.GarnisonIsOpen() and (#(self.missionList) == 0)) then
				GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide();
				for mission, result in pairs(self.missionPrint) do 
					ui.PrintMissionSummary(mission, result)
				end
				wipe(self.missionPrint)
			end
		elseif (event == "GARRISON_MISSION_FINISHED" or event == "GARRISON_MISSION_NPC_OPENED") then
			if  ui.GarnisonIsOpen() then
				ui.MarkCompletedMissions()
			end
		end	
	end)
end

function LurUI.GarrisonAuto.GarnisonIsOpen()
	return (GarrisonMissionFrame and GarrisonMissionFrame:IsVisible())
end


function LurUI.GarrisonAuto.MarkCompletedMissions()
	local missions = C_Garrison.GetCompleteMissions();
	if (#missions > 0 and ui.GarnisonIsOpen()) then
		for index,mission in ipairs(missions) do
			local missionID = mission.missionID;
			ui.frame.missionList[missionID] = mission;
			C_Garrison.MarkMissionComplete(missionID);
		end
		C_Timer.After(1, ui.MarkCompletedMissions)
	end
end

-- /run LUR_PrintMissionSummary(C_Garrison.GetCompleteMissions()[4], true)
--/ /run LUR_PrintMissionSummary(C_Garrison.GetAvailableMissions()[4], true)
function LurUI.GarrisonAuto.PrintMissionSummary(mission, succeeded)
	if (mission) then
		local success = succeeded and ("|cFF00FF00"..SCENARIO_BONUS_SUCCESS.."|r ") or ("|cFFFF0000"..FAILED .. "|r ");
		print(success .. mission.name);
		for _, reward in pairs (mission.rewards) do
			local title = reward.title and " " .. reward.title or "";
			local name = reward.name and " " ..reward.name or "";
			
			local quant = "";
			if (reward.currencyID and reward.currencyID == 0) then
				quant = " " .. GetCoinTextureString(reward.quantity);
			else 
				quant = reward.quantity and (" " ..reward.quantity) or "";
			end
			
			local currency = reward.currencyID and (" " .. GetCurrencyInfo(reward.currencyID)) or "";
			
			local item = "";
			if (reward.itemID) then
				local itemName, itemLink, itemRarity = GetItemInfo(reward.itemID);
				item = " " ..(itemLink or COMBATLOG_UNKNOWN_UNIT);
			end
			print("    " .. SCENARIO_BONUS_REWARD .. " " .. title .. name .. quant .. currency .. item)
		end
	end
end

LurUI.GarrisonAuto.InitMissionAutoCompletist();

--[[-----------------------------------
- 		AUTO-ORDER
--------------------------------------]]
hooksecurefunc("Garrison_LoadUI", function()
	if (not LurUI.GarrisonAuto.autoorder) then
		LurUI.GarrisonAuto.autoorder = true;
		LurUI.GarrisonAuto.OrderButton = CreateFrame("Button", nil, GarrisonCapacitiveDisplayFrame, "OptionsButtonTemplate");
		local f = LurUI.GarrisonAuto.OrderButton;
		f:SetText("AutoOrder");
		f:SetPoint("BOTTOMRIGHT", GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, "TOPRIGHT", 0, 5);
		f:SetScript("OnClick", function() 
			local maxShipments = GarrisonCapacitiveDisplayFrame.maxShipments;
			local numPending = C_Garrison.GetNumPendingShipments();
			local available = maxShipments - numPending;
			C_Timer.NewTicker(1, C_Garrison.RequestShipmentCreation, available);
		end);
	end
end)

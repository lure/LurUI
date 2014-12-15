--[[ 
	core functionality. Some functions and definitions. 
	
	P.S.:/script DEFAULT_CHAT_FRAME:AddMessage( GetMouseFocus():GetName() );
]]

--ReloadUI
SlashCmdList.LURRELOADUI = ReloadUI
SLASH_LURRELOADUI1, SLASH_LURRELOADUI2 = '/кд', '/rl'

SlashCmdList.LURROLL = function() RandomRoll(1,100) end
SLASH_LURROLL1 = '/кщдд'

LurUI = {}
hooksecurefunc("CastingBarFrame_OnShow", function() CastingBarFrame:SetPoint("BOTTOM", 0, 107) end)


function LurUI:getFreeInventoryNum(bagtype)
  local commonbag, specificbag = 0, 0;

  for bag = 0, NUM_BAG_SLOTS do
    local slots, bt = GetContainerNumFreeSlots(bag);
    if (bt == bagtype) then
      specificbag = specificbag + slots
    end
    if (bt == 0) then
      commonbag = commonbag + slots
    end
  end
  if (specificbag > 0) then
    return specificbag
  else
    return commonbag;
  end
end

--[[ Forms a string with a '4g 3s 12c' format ]]--
function LurUI:formMoneyString(gold, silver, copper)
    return string.format("%dg %ds %dc", gold, silver, copper)
end

--[[ 2 in 1 : parses amount and formats money string for output]]--
function LurUI:moneyToString(money) 
	return LurUI:formMoneyString(LurUI:parseMoney(money))
end

--[[ parses copper to copper, silver and gold ]]--
function LurUI:parseMoney(money)
    local msgGold = math.floor(money / 10000)
    local msgSilver = math.floor((money - msgGold * 10000) / 100)
    local msgCopper = money - (msgGold * 10000) - (msgSilver * 100)
    return msgGold, msgSilver, msgCopper;
end

--[[ makes any frame movable ]]--
function LurUI:makeFrameMovable(frame)
  frame:RegisterForDrag("LeftButton", "RightButton")
  frame:EnableMouse(true)
  frame:SetMovable(true)

  frame:SetScript("OnDragStart", function(self, button)
    self:StartMoving();
  end)

  frame:SetScript("OnDragStop", function(self, button)
    self:StopMovingOrSizing();
  end)
end

function LurUI:trim(s)
  return s:match "^%s*(.-)%s*$"
end

--[[--------------------------------------
	Garrison mission auto complete
-----------------------------------------]]
local a = false;
local frame = nil;
function LUR_InitMissionAutoCompletist()
	frame = CreateFrame("Frame", nil, UIParent);
	frame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	frame:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	frame:RegisterEvent("GARRISON_MISSION_FINISHED");
	frame.missionList = {};
	frame:Show();
	
	frame:SetScript("OnEvent", function(self, event, ...)
		if ( event == "GARRISON_MISSION_COMPLETE_RESPONSE" ) then
			local missionID, canComplete, succeeded = ...;
			-- Иногда сундук открыть нельзя. Видимо, я неправильно обрабатывать 'succeeded'
			LUR_PrintMissionSummary(self.missionList[missionID], succeeded)
			self.missionList[missionID] = nil;
			if C_Garrison.CanOpenMissionChest(missionID) then
				C_Garrison.MissionBonusRoll(missionID);
			end
			if (LUR_GarnisonIsOpen() and (#(self.missionList) == 0)) then
				GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide();
			end
		elseif (event == "GARRISON_MISSION_FINISHED" or event == "GARRISON_MISSION_NPC_OPENED") then
			if  LUR_GarnisonIsOpen() then
				LUR_MarkCompletedMissions()
			end
		end	
	end)
end

function LUR_GarnisonIsOpen()
	return (GarrisonMissionFrame and GarrisonMissionFrame:IsVisible())
end


function LUR_MarkCompletedMissions()
	local missions = C_Garrison.GetCompleteMissions();
	if (#missions > 0 and LUR_GarnisonIsOpen()) then
		--
		for index,mission in ipairs(missions) do
			local missionID = mission.missionID;
			frame.missionList[missionID] = mission;
			C_Garrison.MarkMissionComplete(missionID);
		end
		C_Timer.After(1, LUR_MarkCompletedMissions)
	end
end

-- /run LUR_B(C_Garrison.GetCompleteMissions()[4], true)
function LUR_PrintMissionSummary(mission, succeeded)
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

-- Наверное, снова заработало
LUR_InitMissionAutoCompletist()

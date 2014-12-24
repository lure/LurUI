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
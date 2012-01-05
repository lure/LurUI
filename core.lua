--[[ 
	core functionality. Some functions and definitions. 
]] --

--ReloadUI
SlashCmdList.MAILRELOADUI = ReloadUI
SLASH_MAILRELOADUI1, SLASH_MAILRELOADUI2 = '/кд', '/rl'

local LURUI_GLOBAL = "LurUI"
local lurui = _G[LURUI_GLOBAL]
if not lurui then 
	_G[LURUI_GLOBAL] = {func={}}
end

function getFreeInventoryNum(bagtype)
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
function getMoneyString(gold, silver, copper)
    return string.format("%dg %ds %dc", gold, silver, copper)
end

--[[ parses copper to copper, silver and gold ]]--
function parseMoney(money)
    local msgGold = math.floor(money / 10000)
    local msgSilver = math.floor((money - msgGold * 10000) / 100)
    local msgCopper = money - (msgGold * 10000) - (msgSilver * 100)
    return msgGold, msgSilver, msgCopper;
end

--[[ makes any frame movable ]]--
function makeFrameMovable(frame)
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

LurUI.func.trim = function(s)
  return s:match "^%s*(.-)%s*$"
end
--[[ 

]] --

--ReloadUI
SlashCmdList.MAILRELOADUI = ReloadUI
SLASH_MAILRELOADUI1, SLASH_MAILRELOADUI2 = '/кд', '/rl'


function getFreeInventoryNum(bagtype)
  local commonbag, specificbag = 0, 0;

  for bag = 1, NUM_BAG_SLOTS do
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
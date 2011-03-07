--http://us.blizzard.com/support/article.xml?locale=en_US&articleId=21466&pageNumber=1&searchQuery=Blizzard+Interface
local lurui = {}
lurui.frame = CreateFrame("Frame", "classicon", TargetFrame)
local f = lurui.frame
f:SetWidth(32)
f:SetHeight(32)
f:SetFrameStrata("MEDIUM")
f:SetPoint("LEFT", "TargetFrame", "RIGHT", -42, -17)

-- Class texture
local classTexture = f:CreateTexture(nil, "BACKGROUND")
classTexture:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
classTexture:SetPoint("CENTER", f, "CENTER")
classTexture:SetSize(20,20);
f.texture = classTexture

-- icon border
local borderTexture = f:CreateTexture(nil, "BACKGROUND ")
borderTexture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
borderTexture:SetTexCoord(0, 0.60, 0, 0.60)
borderTexture:SetAllPoints(f)


-- http://www.wowinterface.com/forums/showthread.php?p=78820
f:RegisterEvent("PLAYER_TARGET_CHANGED");
f:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)
f.PLAYER_TARGET_CHANGED = function(self, ...)
   local _, className = UnitClass("target")
   if (className) then
      lurui.frame.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[className]));
   end
end

--makeFrameMovable(f)
f:Show()
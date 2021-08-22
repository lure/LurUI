--[[ 	
	Adds player's coordinates to the map
]]--
local coordMouse = WorldMapFrameCloseButton:CreateFontString(nil, "BORDER", "GameFontNormal")
coordMouse:SetPoint("TOPLEFT", WorldMapFrameCloseButton, "TOPLEFT", -270, -12)
coordMouse:SetJustifyH("LEFT")
local coordPlayer = WorldMapFrameCloseButton:CreateFontString(nil, "BORDER", "GameFontNormal")
coordPlayer:SetPoint("TOPLEFT", WorldMapFrameCloseButton, "TOPLEFT", -140, -12)
coordPlayer:SetJustifyH("LEFT")
 
local function GetMouseCoord()
	local scale = WorldMapFrame.BorderFrame:GetEffectiveScale()
	local width = WorldMapFrame.ScrollContainer:GetWidth()
	local height = WorldMapFrame.ScrollContainer:GetHeight()
	local centerX, centerY = WorldMapFrame.ScrollContainer:GetCenter()
	local x, y = GetCursorPosition()	
	local adjustedX = (x / scale - (centerX - width / 2)) / width
	local adjustedY = (centerY + (height/2) - y / scale) / height  

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = adjustedX * 100
		adjustedY = adjustedY * 100
	else 
		adjustedX = 0
		adjustedY = 0
	end
		
	return adjustedX, adjustedY
end

local function roundCoords(varx, vary)
	varx = math.floor(varx * 1000 + 0.5)/10
	vary = math.floor(vary * 1000 + 0.5)/10	
	return varx, vary
end

WorldMapFrame:HookScript("OnUpdate", function(self, button)

	local map = C_Map.GetBestMapForUnit("player")
	local px, py = C_Map.GetPlayerMapPosition(map, "player"):GetXY()
		local mx, my = GetMouseCoord()
		coordMouse:SetText(string.format("mouse = %04.1f / %04.1f", mx, my))
		coordPlayer:SetText(string.format("you = %04.1f / %04.1f", px * 100, py * 100))
    end)

--[[ 	
	Adds player's coordinates to the map
]]--
local coord = WorldMapFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
coord:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -400, 11)
coord:SetHeight(10)
coord:SetWidth(400)

local function GetMouseCoord()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()	
	local adjustedX = (x/scale - (centerX - width / 2)) / width
	local adjustedY = (centerY + (height/2) - y / scale) / height  

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <=1 and adjustedY <=1) then
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
        local px, py = roundCoords(GetPlayerMapPosition("player"))
		local mx, my = GetMouseCoord()
        local playerCoords = string.format("mouse = %04.1f / %04.1f you = %04.1f / %04.1f", mx, my,px, py)
		coord:SetText(playerCoords)
    end)	




